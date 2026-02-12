import ComposableArchitecture

extension AlertState {
    /// Creates a dismissable error alert with a localized title, message, and OK button.
    public static func error(_ message: String) -> Self {
        AlertState(
            title: {
                TextState("general.error.title")
            },
            actions: {
                ButtonState(role: .cancel) {
                    TextState("general.ok")
                }
            },
            message: {
                TextState(verbatim: message)
            }
        )
    }
}
