import SwiftUI

private enum SF {
    static let lime = Color(red: 0.76, green: 0.95, blue: 0.36)
    static let panel = Color(red: 0.105, green: 0.115, blue: 0.12)
    static let muted = Color.white.opacity(0.55)
}

struct RootView: View {
    var body: some View {
        TabView {
            DashboardView().tabItem { Label("Accueil", systemImage: "square.grid.2x2.fill") }
            InventoryView().tabItem { Label("Stock", systemImage: "tshirt.fill") }
            LocationsView().tabItem { Label("Emplacements", systemImage: "shippingbox.fill") }
            OrdersView().tabItem { Label("Commandes", systemImage: "shippingbox") }
            SettingsView().tabItem { Label("Réglages", systemImage: "gearshape.fill") }
        }
        .tint(SF.lime)
    }
}

struct DashboardView: View {
    @EnvironmentObject var store: StockStore

    private var actionableOrders: [SaleOrder] {
        store.orders.filter { order in
            order.status == .toPrepare || order.status == .toShip
        }
    }

    private var recentItems: [StockItem] {
        Array(store.items.prefix(3))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    dashboardHeader
                    metricsGrid
                    pendingOrdersSection
                    recentStockSection
                    dataFooter
                }
                .padding(20)
            }
            .background(Color.black.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var dashboardHeader: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("STOCKFLOW")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(SF.lime)
                Text("Ton activité, maîtrisée.")
                    .font(.title2.bold())
            }
            Spacer()
            Image(systemName: "bolt.fill")
                .font(.title2)
                .foregroundStyle(.black)
                .frame(width: 44, height: 44)
                .background(SF.lime, in: RoundedRectangle(cornerRadius: 14))
        }
    }

    private var metricsGrid: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: columns, spacing: 12) {
            MetricCard(title: "Articles en stock", value: String(store.availableCount), icon: "tshirt")
            MetricCard(title: "Commandes actives", value: String(store.pendingCount), icon: "shippingbox")
            MetricCard(title: "Chiffre d'affaires", value: store.revenue.euros, icon: "eurosign.circle")
            MetricCard(title: "Marge estimée", value: store.estimatedProfit.euros, icon: "chart.line.uptrend.xyaxis")
        }
    }

    private var pendingOrdersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("À traiter").font(.headline)
                Spacer()
                Text("\(store.pendingCount) en attente")
                    .font(.caption)
                    .foregroundStyle(SF.muted)
            }
            if actionableOrders.isEmpty {
                EmptyPanel(icon: "checkmark.circle", title: "Tout est calme", subtitle: "Tes prochaines commandes apparaîtront ici.")
            } else {
                ForEach(Array(actionableOrders.prefix(4))) { order in
                    OrderRow(order: order)
                }
            }
        }
    }

    private var recentStockSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Stock récent").font(.headline)
            if recentItems.isEmpty {
                EmptyPanel(icon: "tshirt", title: "Ton stock est vide", subtitle: "Ajoute ton premier article dans l'onglet Stock.")
            } else {
                ForEach(recentItems) { item in
                    ItemRow(item: item)
                }
            }
        }
    }

    private var dataFooter: some View {
        Text("DONNÉES ENREGISTRÉES SUR CET IPHONE")
            .font(.system(size: 9, weight: .bold))
            .tracking(1.5)
            .foregroundStyle(SF.muted)
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            Image(systemName: icon).foregroundStyle(SF.lime).font(.title3)
            Text(value).font(.system(size: 24, weight: .bold, design: .rounded)).lineLimit(1).minimumScaleFactor(0.7)
            Text(title).font(.caption).foregroundStyle(SF.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(SF.panel, in: RoundedRectangle(cornerRadius: 18))
    }
}

struct EmptyPanel: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 9) {
            Image(systemName: icon).font(.system(size: 28)).foregroundStyle(SF.lime)
            Text(title).font(.headline)
            Text(subtitle).font(.caption).foregroundStyle(SF.muted).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(SF.panel, in: RoundedRectangle(cornerRadius: 18))
    }
}

struct ItemRow: View {
    @EnvironmentObject var store: StockStore
    let item: StockItem

    private var locationName: String {
        store.data.locations.first(where: { $0.id == item.locationID })?.name ?? "Sans emplacement"
    }

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(SF.lime.opacity(0.12))
                .frame(width: 44, height: 44)
                .overlay(Image(systemName: "tshirt.fill").foregroundStyle(SF.lime))
            VStack(alignment: .leading, spacing: 3) {
                Text(item.name).font(.subheadline.bold())
                Text("\(item.brand.isEmpty ? "Sans marque" : item.brand) · \(item.size) · \(locationName)")
                    .font(.caption)
                    .foregroundStyle(SF.muted)
            }
            Spacer()
            Text(item.salePrice.euros).font(.subheadline.bold())
        }
        .padding(12)
        .background(SF.panel, in: RoundedRectangle(cornerRadius: 15))
    }
}

struct OrderRow: View {
    let order: SaleOrder

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(order.itemName).font(.subheadline.bold())
                Text(order.buyer.isEmpty ? "Acheteur non renseigné" : order.buyer)
                    .font(.caption)
                    .foregroundStyle(SF.muted)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(order.amount.euros).font(.subheadline.bold())
                Text(order.status.rawValue).font(.caption).foregroundStyle(SF.lime)
            }
        }
        .padding(14)
        .background(SF.panel, in: RoundedRectangle(cornerRadius: 15))
    }
}
