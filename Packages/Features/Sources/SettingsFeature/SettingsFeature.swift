import ComposableArchitecture
import Foundation
import SharedFeatures
import UIKit

@Reducer
public struct SettingsFeature: Sendable {
    @Dependency(\.settingsClient) private var client
    @Dependency(\.appInfoClient) private var appInfoClient
    @Dependency(\.openURL) private var openURL

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Scope(state: \.appearanceSection, action: \.appearanceSection) {
            SelectSectionFeature()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                onAppear(&state)
            case .onOpenSettings:
                onOpenSettings(&state)
            case .appearanceSection(.delegate(.selectionChanged(let ids))):
                onAppearanceSelectionChanged(&state, ids: ids)
            case .appearanceSection:
                .none
            case .binding:
                .none
            }
        }
    }
}

// MARK: - Reducer Logic

private extension SettingsFeature {
    func onAppear(_ state: inout State) -> Effect<Action> {
        state.appVersion = appInfoClient.appVersion()
        state.buildNumber = appInfoClient.buildNumber()
        return .none
    }

    func onOpenSettings(_ state: inout State) -> Effect<Action> {
        // Uses the official UIKit API for the app's settings URL.
        // This is Apple's supported way to open the app's Settings page
        // and is safe for App Store submission, unlike private URL schemes.
        .run { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            await openURL(url)
        }
    }

    func onAppearanceSelectionChanged(_ state: inout State, ids: Set<String>) -> Effect<Action> {
        guard let id = ids.first, let appearance = AppAppearance(rawValue: id) else { return .none }
        state.appearance = appearance
        return .run { _ in
            await client.setAppearance(appearance)
        }
    }
}

// MARK: - State

extension SettingsFeature {
    @ObservableState
    public struct State: Equatable, Sendable {
        public var appearance: AppAppearance = .system
        public var appVersion: String?
        public var buildNumber: String?
        public var appearanceSection: SelectSectionFeature.State
        public var isAboutExpanded: Bool

        var shouldDisplayAboutSection: Bool {
            appVersion?.isEmpty == false || buildNumber?.isEmpty == false
        }

        public init(appearance: AppAppearance = .system) {
            self.appearance = appearance
            self.appearanceSection = SettingsFeature.makeAppearanceSection(appearance)
            self.isAboutExpanded = true
        }
    }
}

// MARK: - Action

extension SettingsFeature {
    @CasePathable
    public enum Action: Sendable, BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case onOpenSettings
        case appearanceSection(SelectSectionFeature.Action)
    }
}

// MARK: - Section Builders

extension SettingsFeature {
    static func makeAppearanceSection(_ appearance: AppAppearance) -> SelectSectionFeature.State {
        let items = AppAppearance.allCases.map { option in
            SelectItem(
                id: option.rawValue,
                title: option.displayName,
                icon: option.icon,
                isSelected: option == appearance
            )
        }
        return .init(items: .init(uniqueElements: items), selectionMode: .single)
    }
}
