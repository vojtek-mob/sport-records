import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct AddSportRecordFeature: Sendable {
    private static let secondsPerMinute = 60

    @Dependency(\.sportRecordsClient) private var client
    @Dependency(\.uuid) private var uuid
    @Dependency(\.date.now) private var now

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding(\.name):
                onBindingName(&state)
            case .binding:
                .none
            case .onSaveTapped:
                onSaveTapped(&state)
            case let .sourceSelected(source):
                sourceSelected(&state, source: source)
            case let .saveResult(.success(record)):
                onSaveSuccess(&state, record: record)
            case let .saveResult(.failure(error)):
                onSaveFailure(&state, error: error)
            case .alert:
                .none
            case .delegate:
                .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

// MARK: - Reducer Logic

private extension AddSportRecordFeature {
    func onBindingName(_ state: inout State) -> Effect<Action> {
        if !state.name.trimmingCharacters(in: .whitespaces).isEmpty {
            state.nameShakeTrigger = 0
        }
        return .none
    }

    func onSaveTapped(_ state: inout State) -> Effect<Action> {
        guard state.isValid else {
            state.nameShakeTrigger += 1
            return .none
        }
        state.isSaving = true

        let trimmedPlace = state.place.trimmingCharacters(in: .whitespaces)

        let record = SportRecord(
            id: uuid(),
            name: state.name.trimmingCharacters(in: .whitespaces),
            description: state.description.trimmingCharacters(in: .whitespaces),
            place: trimmedPlace.isEmpty ? nil : trimmedPlace,
            category: state.category,
            duration: TimeInterval(state.durationMinutes * Self.secondsPerMinute),
            date: state.date,
            createdAt: now,
            source: state.source
        )

        return .run { send in
            await send(.saveResult(
                Result {
                    try await client.add(record)
                    return record
                }
            ))
        }
    }

    func sourceSelected(_ state: inout State, source: RecordSource) -> Effect<Action> {
        state.source = source
        return .none
    }

    func onSaveSuccess(_ state: inout State, record: SportRecord) -> Effect<Action> {
        state.isSaving = false
        return .send(.delegate(.recordAdded(record)))
    }

    func onSaveFailure(_ state: inout State, error: Error) -> Effect<Action> {
        state.isSaving = false
        state.alert = .error(error.localizedDescription)
        return .none
    }
}

// MARK: - State

extension AddSportRecordFeature {
    @ObservableState
    public struct State: Equatable, Sendable {
        private static let defaultDurationMinutes = 30

        @Presents public var alert: AlertState<Action.Alert>?

        public var name: String = ""
        public var description: String = ""
        public var place: String = ""
        public var category: SportCategory = .running
        public var durationMinutes: Int = defaultDurationMinutes
        public var date: Date = .now
        public var source: RecordSource = .local
        public var isSaving = false
        public var nameShakeTrigger = 0

        public var isValid: Bool {
            !name.trimmingCharacters(in: .whitespaces).isEmpty
        }

        public var nameValidationFailed: Bool {
            nameShakeTrigger > 0
        }
    }
}

// MARK: - Action

extension AddSportRecordFeature {
    @CasePathable
    public enum Action: Sendable, BindableAction {
        case binding(BindingAction<State>)
        case onSaveTapped
        case sourceSelected(RecordSource)
        case saveResult(Result<SportRecord, Error>)
        case alert(PresentationAction<Alert>)
        case delegate(Delegate)

        @CasePathable
        public enum Alert: Sendable, Equatable {}

        @CasePathable
        public enum Delegate: Sendable {
            case recordAdded(SportRecord)
        }
    }
}
