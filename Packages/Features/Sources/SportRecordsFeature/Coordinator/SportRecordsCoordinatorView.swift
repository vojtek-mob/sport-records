import ComposableArchitecture
import SwiftUI

public struct SportRecordsCoordinatorView: View {
    @Bindable var store: StoreOf<SportRecordsCoordinatorFeature>

    public init(store: StoreOf<SportRecordsCoordinatorFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            listView
        } destination: { store in
            destination(store: store)
        }
        .sheet(item: $store.scope(state: \.filter, action: \.filter)) { filterStore in
            SportRecordsFilterView(store: filterStore)
        }
        .sheet(item: $store.scope(state: \.addSportRecord, action: \.addSportRecord)) { addStore in
            AddSportRecordView(store: addStore)
        }
    }
}

private extension SportRecordsCoordinatorView {
    var listView: some View {
        SportRecordsListView(
            store: store.scope(
                state: \.sportRecordsList,
                action: \.sportRecordsList
            )
        )
    }

    func destination(store: StoreOf<SportRecordsCoordinatorFeature.Path>) -> some View {
        switch store.case {
        case let .detail(detailStore):
            SportRecordDetailView(store: detailStore)
        }
    }
}
