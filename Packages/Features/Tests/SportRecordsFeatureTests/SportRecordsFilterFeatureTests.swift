import ComposableArchitecture
import Domain
import SharedFeatures
@testable import SportRecordsFeature
import XCTest

@MainActor
final class SportRecordsFilterFeatureTests: XCTestCase {
    // MARK: - Category Selection

    func testSelectCategory() async {
        let store = makeSut(state: .init(filter: .init(categories: [])))

        await store.send(.categoryTapped(.running)) { state in
            state.filter.categories = [.running]
        }
    }

    func testDeselectCategory() async {
        let store = makeSut(
            state: .init(filter: .init(categories: [.running]))
        )

        await store.send(.categoryTapped(.running)) { state in
            state.filter.categories = []
        }
    }

    func testMultipleCategories() async {
        let store = makeSut(state: .init(filter: .init(categories: [])))

        await store.send(.categoryTapped(.running)) { state in
            state.filter.categories = [.running]
        }

        await store.send(.categoryTapped(.cycling)) { state in
            state.filter.categories = [.running, .cycling]
        }
    }

    func testDeselectOneOfMultipleCategories() async {
        let store = makeSut(
            state: .init(filter: .init(categories: [.running, .cycling]))
        )

        await store.send(.categoryTapped(.running)) { state in
            state.filter.categories = [.cycling]
        }
    }

    // MARK: - Search

    func testSearchTextChanged() async {
        let store = makeSut()

        await store.send(.binding(.set(\.filter.searchText, "run"))) { state in
            state.filter.searchText = "run"
        }
    }

    func testEmptySearchTextClearsFilter() async {
        let store = makeSut(
            state: .init(filter: .init(searchText: "run"))
        )

        await store.send(.binding(.set(\.filter.searchText, ""))) { state in
            state.filter.searchText = ""
        }
    }

    // MARK: - Sort

    func testDefaultSortIsByDate() async {
        let store = makeSut()
        XCTAssertEqual(store.state.sort, .byDate)
    }

    func testSortTappedUpdatesSort() async {
        let store = makeSut()

        await store.send(.sortTapped(.byDuration)) { state in
            state.sort = .byDuration
        }
    }

    // MARK: - Source Toggle

    func testToggleSourceRemovesIt() async {
        let store = makeSut()

        await store.send(.sourceSection(.itemTapped("local"))) { state in
            state.sourceSection.items[id: "local"]?.isSelected = false
        }

        await store.receive(\.sourceSection.delegate.selectionChanged) { state in
            state.filter.sources = [.remote]
        }
    }

    func testToggleSourceAddsIt() async {
        let store = makeSut(
            state: .init(filter: .init(sources: [.local]))
        )

        await store.send(.sourceSection(.itemTapped("remote"))) { state in
            state.sourceSection.items[id: "remote"]?.isSelected = true
        }

        await store.receive(\.sourceSection.delegate.selectionChanged) { state in
            state.filter.sources = [.local, .remote]
        }
    }

    func testToggleLastSourceRemovesIt() async {
        let store = makeSut(
            state: .init(filter: .init(sources: [.remote]))
        )

        await store.send(.sourceSection(.itemTapped("remote"))) { state in
            state.sourceSection.items[id: "remote"]?.isSelected = false
        }

        await store.receive(\.sourceSection.delegate.selectionChanged) { state in
            state.filter.sources = []
        }
    }

    // MARK: - Apply and Dismiss

    func testOnApplyTappedDelegatesApply() async {
        let store = makeSut(
            state: .init(
                filter: .init(categories: [.running]),
                sort: .byName
            )
        )

        await store.send(.onApplyTapped)
        await store.receive(\.delegate.apply)
    }

    func testDelegateDismissDoesNotChangeState() async {
        let store = makeSut(
            state: .init(filter: .init(categories: [.cycling]), sort: .byDuration)
        )

        await store.send(.delegate(.dismiss))
    }

    // MARK: - Reset

    func testResetDelegates() async {
        let store = makeSut(
            state: .init(
                filter: .init(categories: [.cycling], searchText: "bike", sources: [.local]),
                sort: .byName,
                isSourceExpanded: false
            )
        )

        await store.send(.onResetTapped)
        await store.receive(\.delegate.reset)
    }

    // MARK: - Helpers

    private func makeSut(
        state: SportRecordsFilterFeature.State = .init()
    ) -> TestStoreOf<SportRecordsFilterFeature> {
        TestStore(initialState: state, reducer: SportRecordsFilterFeature.init)
    }
}
