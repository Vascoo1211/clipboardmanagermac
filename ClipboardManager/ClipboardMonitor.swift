import Cocoa
import Combine

/// Polls the system pasteboard for changes (macOS has no clipboard-changed
/// notification, so polling is the standard approach) and keeps the last
/// 20 plain-text items, persisted across launches via UserDefaults.
class ClipboardMonitor: ObservableObject {
    @Published var items: [String] = []

    private var timer: Timer?
    private var lastChangeCount: Int = NSPasteboard.general.changeCount
    private let maxItems = 20
    private let defaultsKey = "ClipboardHistoryItems"

    init() {
        items = UserDefaults.standard.stringArray(forKey: defaultsKey) ?? []
    }

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { [weak self] _ in
            self?.checkPasteboard()
        }
    }

    private func checkPasteboard() {
        let pb = NSPasteboard.general
        guard pb.changeCount != lastChangeCount else { return }
        lastChangeCount = pb.changeCount

        guard let string = pb.string(forType: .string),
              !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        addItem(string)
    }

    private func addItem(_ text: String) {
        items.removeAll { $0 == text }
        items.insert(text, at: 0)
        if items.count > maxItems {
            items = Array(items.prefix(maxItems))
        }
        persist()
    }

    /// Called when the user clicks an item in the popup: puts it back on
    /// the pasteboard (as the newest item) so a normal paste picks it up.
    func pasteItem(_ text: String) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(text, forType: .string)
        lastChangeCount = pb.changeCount

        items.removeAll { $0 == text }
        items.insert(text, at: 0)
        persist()
    }

    func clearHistory() {
        items.removeAll()
        UserDefaults.standard.removeObject(forKey: defaultsKey)
    }

    private func persist() {
        UserDefaults.standard.set(items, forKey: defaultsKey)
    }
}
