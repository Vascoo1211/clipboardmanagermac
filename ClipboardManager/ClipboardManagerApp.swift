import SwiftUI

@main
struct ClipboardManagerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // No real window - this app lives in the menu bar / behind a hotkey popup only.
        Settings {
            EmptyView()
        }
    }
}
