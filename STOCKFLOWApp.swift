import SwiftUI

@main
struct STOCKFLOWApp: App {
    @StateObject private var store = StockStore()
    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(store).preferredColorScheme(.dark)
        }
    }
}
