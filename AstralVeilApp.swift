import SwiftUI

@main
struct AstralVeilApp: App {
    @StateObject var profile = UserProfile()
    @StateObject var store = AppStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(profile)
                .environmentObject(store)
        }
    }
}
