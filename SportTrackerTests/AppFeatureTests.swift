import ComposableArchitecture
import Domain
import SettingsFeature
import SportRecordsFeature
@testable import SportTracker
import XCTest

@MainActor
final class AppFeatureTests: XCTestCase {
    // MARK: - Tab Selection

    func testDefaultTabIsSportRecords() {
        let state = AppFeature.State()
        XCTAssertEqual(state.selectedTab, .sportRecords)
    }

    func testSelectSettingsTab() async {
        let store = makeSut()

        await store.send(.tabSelected(.settings)) { state in
            state.selectedTab = .settings
        }
    }

    func testSelectSportRecordsTab() async {
        let store = makeSut(selectedTab: .settings)

        await store.send(.tabSelected(.sportRecords)) { state in
            state.selectedTab = .sportRecords
        }
    }

    func testSelectingSameTabIsNoOp() async {
        let store = makeSut()

        await store.send(.tabSelected(.sportRecords))
    }

    // MARK: - State Initialization

    func testInitWithAppearance() {
        let state = AppFeature.State(appearance: .dark)
        XCTAssertEqual(state.settingsTab.appearance, .dark)
    }

    func testInitDefaultAppearanceIsSystem() {
        let state = AppFeature.State()
        XCTAssertEqual(state.settingsTab.appearance, .system)
    }

    // MARK: - Helpers

    private func makeSut(
        selectedTab: AppFeature.State.Tab = .sportRecords
    ) -> TestStoreOf<AppFeature> {
        var state = AppFeature.State()
        state.selectedTab = selectedTab

        let store = TestStore(initialState: state, reducer: AppFeature.init) {
            $0.sportRecordsClient.fetchAll = { SportRecordFetchResult(records: []) }
            $0.sportRecordsClient.add = { _ in }
            $0.sportRecordsClient.delete = { _ in }
            $0.settingsClient.getAppearance = { .system }
            $0.settingsClient.setAppearance = { _ in }
            $0.appInfoClient.appVersion = { "1.0.0" }
            $0.appInfoClient.buildNumber = { "1" }
        }
        store.exhaustivity = .off
        return store
    }
}
