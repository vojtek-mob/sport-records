import ComposableArchitecture
import SharedFeatures
import SharedUI
import SwiftUI

public struct SettingsView: View {
    @Environment(\.appTheme) private var theme

    @Bindable var store: StoreOf<SettingsFeature>

    public init(store: StoreOf<SettingsFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGapLarge) {
                appearanceSection
                aboutSection
                languageSection
            }
            .screenPadding()
        }
        .navigationTitle("settings.title")
        .background(theme.colors.background)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

// MARK: - Subviews

private extension SettingsView {
    var appearanceSection: some View {
        SelectSectionView(
            "settings.appearance",
            store: store.scope(state: \.appearanceSection, action: \.appearanceSection)
        )
    }

    var languageSection: some View {
        AppButton(title: "settings.language.openSettings") {
            store.send(.onOpenSettings)
        }
        .accessibilityHint("settings.accessibility.openSettingsHint")
    }

    @ViewBuilder
    var aboutSection: some View {
        if store.shouldDisplayAboutSection {
            AppSection("settings.about", isExpanded: $store.isAboutExpanded, isSeparated: true) {
                if let appVersion = store.appVersion {
                    AppLabeledContent("settings.about.version", value: appVersion, font: AppTypography.caption2)
                }

                if let buildNumber = store.buildNumber {
                    AppLabeledContent("settings.about.build", value: buildNumber, font: AppTypography.caption2)
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Default") {
    NavigationStack {
        SettingsView(
            store: Store(
                initialState: {
                    var state = SettingsFeature.State(appearance: .light)
                    state.appVersion = "1.0.0"
                    state.buildNumber = "43"
                    return state
                }()
            ) {
                SettingsFeature()
            } withDependencies: {
                $0.settingsClient.setAppearance = { _ in }
            }
        )
    }
}
