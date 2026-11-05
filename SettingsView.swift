import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: StockStore
    @State private var notificationMessage = ""
    var body: some View {
        NavigationStack {
            Form {
                Section("Notifications") {
                    Button { Task { let ok = await store.requestNotifications(); notificationMessage = ok ? "Notifications autorisées." : "Autorisation refusée. Vérifie les réglages iOS." } } label: { Label("Activer les notifications", systemImage: "bell.badge") }
                    if !notificationMessage.isEmpty { Text(notificationMessage).font(.caption).foregroundStyle(.secondary) }
                }
                Section("Vinted") {
                    Label("Connexion Vinted non activée", systemImage: "link")
                    Text("STOCKFLOW est prêt à gérer ton stock et tes commandes saisies dans l'application. La synchronisation automatique nécessite une API ou une intégration officiellement autorisée par Vinted. Ne saisis pas ton mot de passe Vinted dans une intégration non vérifiée.").font(.caption).foregroundStyle(.secondary)
                }
                Section("Données") {
                    Label("Sauvegarde locale", systemImage: "iphone.gen3")
                    Text("Tes données sont enregistrées dans le stockage privé de cette application sur cet iPhone. Elles ne sont pas synchronisées avec Windows et seront perdues si tu supprimes l'application sans export préalable.").font(.caption).foregroundStyle(.secondary)
                }
                Section("STOCKFLOW") { LabeledContent("Version", value: "1.0.0"); LabeledContent("Mode", value: "Local · Hors cloud") }
            }.scrollContentBackground(.hidden).background(Color.black).navigationTitle("Réglages")
        }
    }
}
