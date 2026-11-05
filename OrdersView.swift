import SwiftUI

struct OrdersView: View {
    @EnvironmentObject var store: StockStore
    @State private var showingAdd = false
    var body: some View {
        NavigationStack {
            List {
                if store.data.orders.isEmpty { Text("Aucune commande pour le moment.").foregroundStyle(.secondary).listRowBackground(Color.clear) }
                ForEach(store.data.orders) { order in NavigationLink { OrderDetailView(order: order) } label: { OrderRow(order: order).listRowBackground(Color.clear) }.listRowSeparator(.hidden) }
                .onDelete { offsets in let ids = offsets.map { store.data.orders[$0].id }; store.data.orders.removeAll { ids.contains($0.id) } }
            }.listStyle(.plain).scrollContentBackground(.hidden).background(Color.black).navigationTitle("Commandes")
                .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button { showingAdd = true } label: { Image(systemName: "plus") } } }
                .sheet(isPresented: $showingAdd) { OrderFormView() }
        }
    }
}

struct OrderFormView: View {
    @EnvironmentObject var store: StockStore
    @Environment(\.dismiss) var dismiss
    @State private var itemName = ""; @State private var buyer = ""; @State private var amount = ""; @State private var tracking = ""
    @State private var selectedItem: UUID?
    var body: some View {
        NavigationStack { Form {
            Section("Commande") {
                Picker("Article du stock", selection: $selectedItem) { Text("Saisie libre").tag(UUID?.none); ForEach(store.data.items) { item in Text(item.name).tag(Optional(item.id)) } }.onChange(of: selectedItem) { id in if let id, let item = store.data.items.first(where: {$0.id == id}) { itemName = item.name; amount = String(item.salePrice) } }
                TextField("Nom de l'article", text: $itemName); TextField("Acheteur", text: $buyer); TextField("Montant (€)", text: $amount).keyboardType(.decimalPad); TextField("Numéro de suivi", text: $tracking)
            }
        }.scrollContentBackground(.hidden).background(Color.black).navigationTitle("Nouvelle commande").navigationBarTitleDisplayMode(.inline).toolbar { ToolbarItem(placement: .cancellationAction) { Button("Annuler") { dismiss() } }; ToolbarItem(placement: .confirmationAction) { Button("Créer") { create() }.disabled(itemName.isEmpty) } } }.preferredColorScheme(.dark)
    }
    private func create() {
        let value = Double(amount.replacingOccurrences(of: ",", with: ".")) ?? 0
        let order = SaleOrder(itemID: selectedItem, itemName: itemName, buyer: buyer, amount: value, tracking: tracking)
        store.addOrder(order); if let id = selectedItem, let item = store.data.items.first(where: {$0.id == id}) { var updated = item; updated.status = .reserved; store.updateItem(updated) }
        Task { _ = await store.requestNotifications(); store.scheduleReminder(for: order) }; dismiss()
    }
}

struct OrderDetailView: View {
    @EnvironmentObject var store: StockStore
    let order: SaleOrder
    var current: SaleOrder { store.data.orders.first(where: {$0.id == order.id}) ?? order }
    var body: some View {
        Form {
            Section("Détails") { LabeledContent("Article", value: current.itemName); LabeledContent("Acheteur", value: current.buyer.isEmpty ? "—" : current.buyer); LabeledContent("Montant", value: current.amount.euros); LabeledContent("Suivi", value: current.tracking.isEmpty ? "—" : current.tracking) }
            Section("Avancement") { Picker("Statut", selection: Binding(get: {current.status}, set: { newValue in var copy = current; copy.status = newValue; store.updateOrder(copy); if newValue == .shipped || newValue == .completed, let id = copy.itemID, let item = store.data.items.first(where: {$0.id == id}) { var changed = item; changed.status = .sold; store.updateItem(changed) } })) { ForEach(OrderStatus.allCases) { status in Text(status.rawValue).tag(status) } } }
        }.scrollContentBackground(.hidden).background(Color.black).navigationTitle("Commande")
    }
}
