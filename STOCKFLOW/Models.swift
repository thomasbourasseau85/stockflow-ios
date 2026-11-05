import Foundation

struct StockItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var brand: String
    var size: String
    var purchasePrice: Double
    var salePrice: Double
    var locationID: UUID?
    var status: ItemStatus = .available
    var notes: String = ""
    var createdAt = Date()
}

enum ItemStatus: String, Codable, CaseIterable, Identifiable {
    case available = "En stock", reserved = "Réservé", sold = "Vendu"
    var id: String { rawValue }
}

struct StorageLocation: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var detail: String = ""
}

struct SaleOrder: Identifiable, Codable, Equatable {
    var id = UUID()
    var itemID: UUID?
    var itemName: String
    var buyer: String = ""
    var amount: Double
    var status: OrderStatus = .toPrepare
    var createdAt = Date()
    var tracking: String = ""
}

enum OrderStatus: String, Codable, CaseIterable, Identifiable {
    case toPrepare = "À préparer", toShip = "À expédier", shipped = "Expédiée", completed = "Terminée"
    var id: String { rawValue }
}

struct LocalData: Codable {
    var items: [StockItem] = []
    var locations: [StorageLocation] = []
    var orders: [SaleOrder] = []
}
