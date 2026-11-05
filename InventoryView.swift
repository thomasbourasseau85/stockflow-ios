import SwiftUI

struct InventoryView: View {
    @EnvironmentObject var store: StockStore
    @State private var showingAdd = false
    @State private var search = ""
    var filtered: [StockItem] { store.data.items.filter { search.isEmpty || ($0.name + $0.brand + $0.size).localizedCaseInsensitiveContains(search) } }
    var body: some View {
        NavigationStack {
            List {
                ForEach(filtered) { item in
                    NavigationLink { ItemDetailView(item: item) } label: { ItemRow(item: item).listRowBackground(Color.clear) }
                        .listRowSeparator(.hidden)
                }.onDelete { offsets in for index in offsets { store.deleteItem(filtered[index]) } }
            }
            .listStyle(.plain).scrollContentBackground(.hidden).background(Color.black)
            .searchable(text: $search, prompt: "Rechercher un article")
            .navigationTitle("Mon stock")
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button { showingAdd = true } label: { Image(systemName: "plus").fontWeight(.bold) } } }
            .sheet(isPresented: $showingAdd) { ItemFormView() }
        }
    }
}

struct ItemFormView: View {
    @EnvironmentObject var store: StockStore
    @Environment(\.dismiss) private var dismiss
    var existing: StockItem? = nil
    @State private var name = ""; @State private var brand = ""; @State private var size = ""
    @State private var purchase = ""; @State private var sale = ""; @State private var locationID: UUID?; @State private var notes = ""
    var body: some View {
        NavigationStack {
            Form {
                Section("Article") { TextField("Nom (ex. Pull Ralph Lauren)", text: $name); TextField("Marque", text: $brand); TextField("Taille", text: $size) }
                Section("Prix") { TextField("Prix d'achat (€)", text: $purchase).keyboardType(.decimalPad); TextField("Prix de vente (€)", text: $sale).keyboardType(.decimalPad) }
                Section("Rangement") { Picker("Emplacement", selection: $locationID) { Text("Aucun").tag(UUID?.none); ForEach(store.data.locations) { loc in Text(loc.name).tag(Optional(loc.id)) } }; TextField("Notes", text: $notes) }
            }.scrollContentBackground(.hidden).background(Color.black).navigationTitle(existing == nil ? "Nouvel article" : "Modifier l'article").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Annuler") { dismiss() } }; ToolbarItem(placement: .confirmationAction) { Button("Enregistrer") { save() }.disabled(name.trimmingCharacters(in: .whitespaces).isEmpty) } }
                .onAppear { if let item = existing { name=item.name; brand=item.brand; size=item.size; purchase=String(item.purchasePrice); sale=String(item.salePrice); locationID=item.locationID; notes=item.notes } }
        }.preferredColorScheme(.dark)
    }
    private func number(_ s: String) -> Double { Double(s.replacingOccurrences(of: ",", with: ".")) ?? 0 }
    private func save() {
        var item = existing ?? StockItem(name: name, brand: brand, size: size, purchasePrice: 0, salePrice: 0)
        item.name=name; item.brand=brand; item.size=size; item.purchasePrice=number(purchase); item.salePrice=number(sale); item.locationID=locationID; item.notes=notes
        if existing == nil { store.addItem(item) } else { store.updateItem(item) }; dismiss()
    }
}

struct ItemDetailView: View {
    @EnvironmentObject var store: StockStore
    @Environment(\.dismiss) private var dismiss
    let item: StockItem
    @State private var editing = false
    var current: StockItem { store.data.items.first(where: {$0.id == item.id}) ?? item }
    var body: some View {
        List {
            Section { ItemRow(item: current) }
            Section("Informations") { LabeledContent("Marque", value: current.brand); LabeledContent("Taille", value: current.size); LabeledContent("Achat", value: current.purchasePrice.euros); LabeledContent("Vente", value: current.salePrice.euros); LabeledContent("État", value: current.status.rawValue); LabeledContent("Notes", value: current.notes.isEmpty ? "—" : current.notes) }
            Section { Button("Supprimer l'article", role: .destructive) { store.deleteItem(current); dismiss() } }
        }.scrollContentBackground(.hidden).background(Color.black).navigationTitle(current.name).toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Modifier") { editing = true } } }.sheet(isPresented: $editing) { ItemFormView(existing: current) }
    }
}
