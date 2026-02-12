import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct SportRecordDetailFeature: Sendable {
    @Dependency(\.sportRecordsClient) private var client

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .onAppear:
                .none
            case .onDeleteTapped:
                onDeleteTapped(&state)
            case .alert(.presented(.confirmDelete)):
                onConfirmDelete(&state)
            case .alert:
                .none
            case let .deleteResponse(.success(id)):
                onDeleteSuccess(&state, id: id)
            case .deleteResponse(.failure):
                onDeleteFailure(&state)
            case .delegate:
                .none
            case .binding:
                .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

// MARK: - Reducer Logic

private extension SportRecordDetailFeature {
    func onDeleteTapped(_ state: inout State) -> Effect<Action> {
        state.alert = AlertState(
            title: {
                TextState("records.detail.alert.deleteTitle")
            },
            actions: {
                ButtonState(role: .destructive, action: .confirmDelete) {
                    TextState("records.detail.alert.delete")
                }
                ButtonState(role: .cancel) {
                    TextState("records.detail.alert.cancel")
                }
            }, message: {
                TextState("records.detail.alert.deleteMessage")
            }
        )
        return .none
    }

    func onConfirmDelete(_ state: inout State) -> Effect<Action> {
        let record = state.record
        return .run { send in
            await send(.deleteResponse(
                Result {
                    try await client.delete(record)
                    return record.id
                }
            ))
        }
    }

    func onDeleteSuccess(_ state: inout State, id: UUID) -> Effect<Action> {
        .send(.delegate(.recordDeleted(id)))
    }

    func onDeleteFailure(_ state: inout State) -> Effect<Action> {
        state.alert = .error(
            String(localized: "records.detail.error.deleteFailed", bundle: .main)
        )
        return .none
    }
}

// MARK: - State

extension SportRecordDetailFeature {
    @ObservableState
    public struct State: Equatable, Sendable {
        @Presents public var alert: AlertState<Action.Alert>?

        public var record: SportRecord
        public var isActivityExpanded: Bool
        public var isDescriptionExpanded: Bool
        public var isMetadataExpanded: Bool

        public init(record: SportRecord) {
            self.record = record
            self.isActivityExpanded = true
            self.isDescriptionExpanded = true
            self.isMetadataExpanded = true
        }
    }
}

// MARK: - Action

extension SportRecordDetailFeature {
    @CasePathable
    public enum Action: Sendable, BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case onDeleteTapped
        case deleteResponse(Result<UUID, Error>)
        case alert(PresentationAction<Alert>)
        case delegate(Delegate)

        @CasePathable
        public enum Alert: Sendable {
            case confirmDelete
        }

        @CasePathable
        public enum Delegate: Sendable {
            case recordDeleted(UUID)
        }
    }
}
