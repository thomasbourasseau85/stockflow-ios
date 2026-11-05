import SwiftUI

struct LocationsView: View {
    @EnvironmentObject var store: StockStore
    @State private var showingAdd = false
    var body: some View {
        NavigationStack {
            List {
                ForEach(store.data.locations) { location in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack { Image(systemName: "shippingbox.fill").foregroundStyle(Color(red:0.76,green:0.95,blue:0.36)); Text(location.name).font(.headline); Spacer(); Text("\(store.data.items.filter{$0.locationID == location.id}.count) articles").font(.caption).foregroundStyle(.secondary) }
                        if !location.detail.isEmpty { Text(location.detail).font(.caption).foregroundStyle(.secondary) }
                    }.padding(.vertical, 6).listRowBackground(Color(white: 0.105))
                }.onDelete { offsets in for i in offsets { store.deleteLocation(store.data.locations[i]) } }
            }.scrollContentBackground(.hidden).background(Color.black).navigationTitle("Emplacements")
                .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button { showingAdd = true } label: { Image(systemName: "plus") } } }
                .sheet(isPresented: $showingAdd) { LocationFormView() }
        }
    }
}

struct LocationFormView: View {
    @EnvironmentObject var store: StockStore
    @Environment(\.dismiss) var dismiss
    @State private var name = ""; @State private var detail = ""
    var body: some View {
        NavigationStack { Form { Section("Nouvel emplacement") { TextField("Nom (ex. Armoire A / Bac 04)", text: $name); TextField("Détail (ex. Étagère 2)", text: $detail) } }.scrollContentBackground(.hidden).background(Color.black).navigationTitle("Ajouter un rangement").navigationBarTitleDisplayMode(.inline).toolbar { ToolbarItem(placement: .cancellationAction) { Button("Annuler") { dismiss() } }; ToolbarItem(placement: .confirmationAction) { Button("Créer") { store.addLocation(StorageLocation(name: name, detail: detail)); dismiss() }.disabled(name.trimmingCharacters(in: .whitespaces).isEmpty) } } }.preferredColorScheme(.dark)
    }
}
