import Foundation
import SwiftUI
import UserNotifications

@MainActor
final class StockStore: ObservableObject {
    @Published var data: LocalData { didSet { save() } }
    private let fileURL: URL

    init() {
        let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = folder.appendingPathComponent("stockflow-data.json")
        if let bytes = try? Data(contentsOf: fileURL), let decoded = try? JSONDecoder.stockflow.decode(LocalData.self, from: bytes) {
            data = decoded
        } else {
            data = LocalData(locations: [StorageLocation(name: "Armoire A", detail: "Étagères 1 à 5"), StorageLocation(name: "Bac B", detail: "Accessoires")])
        }
    }

    private func save() {
        guard let bytes = try? JSONEncoder.stockflow.encode(data) else { return }
        try? bytes.write(to: fileURL, options: .atomic)
    }

    func addItem(_ item: StockItem) { data.items.insert(item, at: 0) }
    func updateItem(_ item: StockItem) { guard let i = data.items.firstIndex(where: {$0.id == item.id}) else { return }; data.items[i] = item }
    func deleteItem(_ item: StockItem) { data.items.removeAll { $0.id == item.id } }
    func addLocation(_ location: StorageLocation) { data.locations.append(location) }
    func deleteLocation(_ location: StorageLocation) { data.locations.removeAll { $0.id == location.id }; for i in data.items.indices where data.items[i].locationID == location.id { data.items[i].locationID = nil } }
    func addOrder(_ order: SaleOrder) { data.orders.insert(order, at: 0) }
    func updateOrder(_ order: SaleOrder) { guard let i = data.orders.firstIndex(where: {$0.id == order.id}) else { return }; data.orders[i] = order }

    func requestNotifications() async -> Bool {
        let center = UNUserNotificationCenter.current()
        return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    func scheduleReminder(for order: SaleOrder) {
        let content = UNMutableNotificationContent()
        content.title = "STOCKFLOW · Commande à préparer"
        content.body = "Pense à préparer : \(order.itemName)"
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: order.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    var availableCount: Int { data.items.filter { $0.status == .available }.count }
    var pendingCount: Int { data.orders.filter { $0.status == .toPrepare || $0.status == .toShip }.count }
    var revenue: Double { data.orders.filter { $0.status == .shipped || $0.status == .completed }.reduce(0) { $0 + $1.amount } }
    var estimatedProfit: Double {
        data.orders.filter { $0.status == .shipped || $0.status == .completed }.reduce(0) { total, order in
            let cost = data.items.first(where: {$0.id == order.itemID})?.purchasePrice ?? 0
            return total + order.amount - cost
        }
    }
}

extension JSONEncoder {
    static var stockflow: JSONEncoder { let e = JSONEncoder(); e.dateEncodingStrategy = .iso8601; e.outputFormatting = [.prettyPrinted, .sortedKeys]; return e }
}
extension JSONDecoder {
    static var stockflow: JSONDecoder { let d = JSONDecoder(); d.dateDecodingStrategy = .iso8601; return d }
}
extension Double {
    var euros: String { self.formatted(.currency(code: "EUR").locale(Locale(identifier: "fr_FR"))) }
}
