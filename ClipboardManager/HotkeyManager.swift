import Carbon
import Cocoa

/// Registers a system-wide keyboard shortcut (default: ⌘⇧V) using the
/// Carbon HotKey API. This works system-wide without needing Accessibility
/// permission (that permission is only needed later, for simulating paste).
class HotkeyManager {
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private let callback: () -> Void

    init(callback: @escaping () -> Void) {
        self.callback = callback
    }

    func register() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: OSType(kEventHotKeyPressed)
        )

        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        InstallEventHandler(GetApplicationEventTarget(), { (_, _, userData) -> OSStatus in
            guard let userData = userData else { return noErr }
            let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
            manager.callback()
            return noErr
        }, 1, &eventType, selfPtr, &eventHandler)

        let hotKeyID = EventHotKeyID(signature: fourCharCode("CLPB"), id: 1)

        // Default shortcut: Cmd+Shift+V. Change keyCode / modifiers below to customize.
        let keyCode: UInt32 = UInt32(kVK_ANSI_V)
        let modifiers: UInt32 = UInt32(cmdKey | shiftKey)

        RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
    }

    deinit {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
        }
    }
}

private func fourCharCode(_ string: String) -> FourCharCode {
    var result: FourCharCode = 0
    for char in string.utf16.prefix(4) {
        result = (result << 8) + FourCharCode(char)
    }
    return result
}
