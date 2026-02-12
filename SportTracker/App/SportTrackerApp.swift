import ComposableArchitecture
import SettingsFeature
import SwiftUI

@main
struct SportTrackerApp: App {
    // Single root store for the entire app.
    // All state and side effects flow through this store.
    let store: StoreOf<AppFeature>

    init() {
        let appearance = SettingsClient.liveValue.getAppearance()
        store = Store(initialState: AppFeature.State(appearance: appearance)) {
            AppFeature()
        }
    }

    var body: some Scene {
        WindowGroup {
            AppView(store: store)
        }
    }
}
