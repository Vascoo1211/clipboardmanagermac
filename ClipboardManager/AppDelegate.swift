import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var clipboardMonitor: ClipboardMonitor!
    var hotkeyManager: HotkeyManager!
    var popup: PopupWindowController!
    var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // No Dock icon - this runs as a background "agent" app.
        NSApp.setActivationPolicy(.accessory)

        clipboardMonitor = ClipboardMonitor()
        clipboardMonitor.start()

        popup = PopupWindowController(clipboardMonitor: clipboardMonitor)

        hotkeyManager = HotkeyManager { [weak self] in
            self?.popup.toggle()
        }
        hotkeyManager.register()

        setupStatusItem()
    }

    // A small menu bar icon as a fallback way to open the popup / quit the app.
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Clipboard History")
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Show Clipboard History  (⌘⇧V)", action: #selector(showPopup), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu

        for item in menu.items {
            item.target = self
        }
    }

    @objc private func showPopup() {
        popup.toggle()
    }
}
