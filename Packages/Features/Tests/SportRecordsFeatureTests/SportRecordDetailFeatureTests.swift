import ComposableArchitecture
import Domain
@testable import SportRecordsFeature
import XCTest

@MainActor
final class SportRecordDetailFeatureTests: XCTestCase {
    // MARK: - Delete Flow

    func testDeleteTappedShowsConfirmationAlert() async {
        let store = makeSut()

        await store.send(.onDeleteTapped) { state in
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
                },
                message: {
                    TextState("records.detail.alert.deleteMessage")
                }
            )
        }
    }

    func testConfirmDeleteCallsClientAndDelegates() async {
        let record = SportRecord.stubRecords[0]
        let store = makeSut(record: record)

        await store.send(.onDeleteTapped) { state in
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
                },
                message: {
                    TextState("records.detail.alert.deleteMessage")
                }
            )
        }

        await store.send(.alert(.presented(.confirmDelete))) { state in
            state.alert = nil
        }

        await store.receive(\.deleteResponse.success)
        await store.receive(\.delegate.recordDeleted)
    }

    func testDeleteFailureShowsErrorAlert() async {
        let record = SportRecord.stubRecords[0]
        let store = makeSut(record: record, deleteError: TestError.deleteFailed)

        await store.send(.onDeleteTapped) { state in
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
                },
                message: {
                    TextState("records.detail.alert.deleteMessage")
                }
            )
        }

        await store.send(.alert(.presented(.confirmDelete))) { state in
            state.alert = nil
        }

        await store.receive(\.deleteResponse.failure) { state in
            state.alert = .error(
                String(localized: "records.detail.error.deleteFailed", bundle: .main)
            )
        }
    }

    func testCancelDeleteDismissesAlert() async {
        let store = makeSut()

        await store.send(.onDeleteTapped) { state in
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
                },
                message: {
                    TextState("records.detail.alert.deleteMessage")
                }
            )
        }

        await store.send(.alert(.dismiss)) { state in
            state.alert = nil
        }
    }

    // MARK: - Helpers

    private func makeSut(
        record: SportRecord = SportRecord.stubRecords[0],
        deleteError: Error? = nil
    ) -> TestStoreOf<SportRecordDetailFeature> {
        TestStore(
            initialState: SportRecordDetailFeature.State(record: record),
            reducer: SportRecordDetailFeature.init
        ) {
            $0.sportRecordsClient.delete = { _ in
                if let error = deleteError { throw error }
            }
        }
    }
}

// MARK: - Test Helpers

private enum TestError: Error, LocalizedError {
    case deleteFailed

    var errorDescription: String? {
        switch self {
        case .deleteFailed: "Failed to delete record"
        }
    }
}
