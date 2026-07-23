import Cocoa
import SwiftUI

class PopupWindowController {
    private var panel: NSPanel?
    private let clipboardMonitor: ClipboardMonitor

    init(clipboardMonitor: ClipboardMonitor) {
        self.clipboardMonitor = clipboardMonitor
    }

    func toggle() {
        if let panel = panel, panel.isVisible {
            panel.close()
            return
        }
        show()
    }

    private func show() {
        let contentView = ClipboardListView(
            clipboardMonitor: clipboardMonitor,
            onSelect: { [weak self] text in self?.pasteAndClose(text) },
            onDismiss: { [weak self] in self?.panel?.close() }
        )

        let hosting = NSHostingController(rootView: contentView)
        let width: CGFloat = 360
        let height: CGFloat = 420

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: width, height: height),
            styleMask: [.titled, .closable, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.contentViewController = hosting
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.hidesOnDeactivate = false
        panel.isMovableByWindowBackground = true
        panel.setContentSize(NSSize(width: width, height: height))

        // Position near the mouse cursor, clamped to stay on-screen.
        if let screen = NSScreen.main {
            let mouseLoc = NSEvent.mouseLocation
            var origin = NSPoint(x: mouseLoc.x - width / 2, y: mouseLoc.y - height - 10)
            origin.x = max(screen.visibleFrame.minX, min(origin.x, screen.visibleFrame.maxX - width))
            origin.y = max(screen.visibleFrame.minY, min(origin.y, screen.visibleFrame.maxY - height))
            panel.setFrameOrigin(origin)
        }

        self.panel = panel
        // Nonactivating panel: it appears and can be clicked without
        // stealing focus from whatever app you were typing into, which is
        // what lets the paste simulation below land in the right place.
        panel.orderFrontRegardless()
        panel.makeKey()
    }

    private func pasteAndClose(_ text: String) {
        clipboardMonitor.pasteItem(text)
        panel?.close()

        // Small delay so focus fully returns to the previous app before we
        // simulate Cmd+V. Requires Accessibility permission (see README).
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            self.simulatePaste()
        }
    }

    private func simulatePaste() {
        let source = CGEventSource(stateID: .hidSystemState)
        let vKeyCode: CGKeyCode = 9 // 'v' key

        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: true)
        keyDown?.flags = .maskCommand
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: false)
        keyUp?.flags = .maskCommand

        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }
}
