import ComposableArchitecture
import SettingsFeature
import SharedUI
import SportRecordsFeature
import SwiftUI

struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>
    @Environment(\.appTheme) private var theme

    var body: some View {
        TabView(
            selection: $store.selectedTab.sending(\.tabSelected)
        ) {
            Tab("tab.records", systemImage: Assets.clipboard.rawValue, value: AppFeature.State.Tab.sportRecords) {
                SportRecordsCoordinatorView(
                    store: store.scope(
                        state: \.sportRecordsTab,
                        action: \.sportRecordsTab
                    )
                )
            }

            Tab("tab.settings", systemImage: Assets.gearshape.rawValue, value: AppFeature.State.Tab.settings) {
                NavigationStack {
                    SettingsView(
                        store: store.scope(
                            state: \.settingsTab,
                            action: \.settingsTab
                        )
                    )
                }
            }
        }
        .tint(theme.colors.appTint)
        .preferredColorScheme(store.colorScheme)
    }
}
