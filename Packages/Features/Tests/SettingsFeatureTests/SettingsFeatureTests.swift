import ComposableArchitecture
import ConcurrencyExtras
@testable import SettingsFeature
import SharedFeatures
import XCTest

@MainActor
final class SettingsFeatureTests: XCTestCase {
    // MARK: - State Init

    func testStateInitWithAppearanceSetsCorrectValues() {
        let state = SettingsFeature.State(appearance: .dark)

        XCTAssertEqual(state.appearance, .dark)
        XCTAssertEqual(
            state.appearanceSection,
            SettingsFeature.makeAppearanceSection(.dark)
        )
    }

    func testStateInitDefaultsToSystem() {
        let state = SettingsFeature.State()

        XCTAssertEqual(state.appearance, .system)
        XCTAssertEqual(
            state.appearanceSection,
            SettingsFeature.makeAppearanceSection(.system)
        )
    }

    // MARK: - On Appear

    func testOnAppearLoadsAppInfo() async {
        let store = makeSut()

        await store.send(.onAppear) { state in
            state.appVersion = "1.0.0"
            state.buildNumber = "42"
        }
    }

    // MARK: - Appearance

    func testAppearanceChange() async {
        let store = makeSut()

        await store.send(.appearanceSection(.itemTapped("dark"))) { state in
            state.appearanceSection.items[id: "system"]?.isSelected = false
            state.appearanceSection.items[id: "dark"]?.isSelected = true
        }

        await store.receive(\.appearanceSection.delegate.selectionChanged) { state in
            state.appearance = .dark
        }
    }

    // MARK: - Invalid Appearance

    func testInvalidAppearanceIDIsIgnored() async {
        let store = makeSut()

        // Directly send a delegate with an ID that doesn't map to any AppAppearance.
        // The guard in onAppearanceSelectionChanged should cause a no-op.
        await store.send(.appearanceSection(.delegate(.selectionChanged(Set(["invalid"])))))
        // No state change expected, no effects -- test passes if exhaustive check is satisfied.
    }

    // MARK: - Open Settings

    func testOnOpenSettingsOpensURL() async {
        let openedURL = LockIsolated<URL?>(nil)
        let store = TestStore(
            initialState: SettingsFeature.State(),
            reducer: SettingsFeature.init
        ) {
            $0.settingsClient.setAppearance = { _ in }
            $0.appInfoClient.appVersion = { "1.0.0" }
            $0.appInfoClient.buildNumber = { "42" }
            $0.openURL = .init(handler: { url in
                openedURL.withValue { $0 = url }
                return true
            })
        }

        await store.send(.onOpenSettings)

        XCTAssertNotNil(openedURL.value)
    }

    // MARK: - Helpers

    private func makeSut(
        state: SettingsFeature.State = .init()
    ) -> TestStoreOf<SettingsFeature> {
        TestStore(initialState: state, reducer: SettingsFeature.init) {
            $0.settingsClient.setAppearance = { _ in }
            $0.appInfoClient.appVersion = { "1.0.0" }
            $0.appInfoClient.buildNumber = { "42" }
        }
    }
}
