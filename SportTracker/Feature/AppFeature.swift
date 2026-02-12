import ComposableArchitecture
import Foundation
import SettingsFeature
import SportRecordsFeature
import SwiftUI

// Root reducer. Manages tab selection and scopes to child features.
// Feature modules never depend on each other -- they communicate only through
// this root reducer via parent actions or shared state.

@Reducer
struct AppFeature: Sendable {
    var body: some ReducerOf<Self> {
        Scope(state: \.sportRecordsTab, action: \.sportRecordsTab) {
            SportRecordsCoordinatorFeature()
        }

        Scope(state: \.settingsTab, action: \.settingsTab) {
            SettingsFeature()
        }

        Reduce { state, action in
            switch action {
            case let .tabSelected(tab):
                tabSelected(&state, tab: tab)
            case .sportRecordsTab:
                .none
            case .settingsTab:
                .none
            }
        }
    }
}

// MARK: - Reducer Logic

private extension AppFeature {
    func tabSelected(_ state: inout State, tab: State.Tab) -> Effect<Action> {
        state.selectedTab = tab
        return .none
    }
}

// MARK: - State

extension AppFeature {
    @ObservableState
    struct State: Equatable, Sendable {
        var selectedTab: Tab = .sportRecords
        var sportRecordsTab = SportRecordsCoordinatorFeature.State()
        var settingsTab: SettingsFeature.State

        /// Resolved color scheme for the app. Exposed so the root view does not reach into child state.
        var colorScheme: ColorScheme? {
            settingsTab.appearance.colorScheme
        }

        enum Tab: Equatable, Sendable {
            case sportRecords
            case settings
        }

        init(appearance: AppAppearance = .system) {
            self.settingsTab = SettingsFeature.State(appearance: appearance)
        }
    }
}

// MARK: - Action

extension AppFeature {
    @CasePathable
    enum Action: Sendable {
        case tabSelected(State.Tab)
        case sportRecordsTab(SportRecordsCoordinatorFeature.Action)
        case settingsTab(SettingsFeature.Action)
    }
}
