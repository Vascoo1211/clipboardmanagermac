# Clipboard History Manager (macOS)

A tiny background app: press **⌘⇧V** anywhere and a popup shows your last
20 copied text snippets. Click one to paste it.

## What it does
- Polls the system pasteboard for new **text** copies (images/files ignored).
- Keeps the last 20 items, persisted across restarts.
- Global hotkey (default **⌘⇧V**) opens a small floating panel near your cursor.
- Click an item → it's copied back to the clipboard and auto-pasted (⌘V)
  into whatever app you were using.
- Menu bar icon (clipboard symbol) also opens it and lets you quit.
- No Dock icon — runs quietly in the background.

## Option A — Build from Terminal (fastest, no Xcode project needed)

1. Make sure you have the Command Line Tools installed:
   ```
   xcode-select --install
   ```
   (skip if you already have Xcode or the CLT installed)

2. Unzip this folder and `cd` into it:
   ```
   cd ClipboardManager
   ```
   You should see `build.sh`, `Info.plist`, and a `ClipboardManager/` folder
   with the `.swift` files.

3. Run the build script:
   ```
   chmod +x build.sh
   ./build.sh
   ```

4. That produces `ClipboardManager.app` right there. Run it:
   ```
   open ClipboardManager.app
   ```
   or drag it into `/Applications`.

5. Press **⌘⇧V** to try it. The first time you click an item to paste,
   macOS will prompt for **Accessibility** access — see Permissions below.

To rebuild after editing any `.swift` file, just run `./build.sh` again.

## Option B — Build in Xcode (if you prefer a GUI / plan to keep editing it)

1. Xcode → File → New → Project → macOS → App → SwiftUI/Swift.
2. Delete the auto-generated `ContentView.swift` and the default App file.
3. Drag the 6 files from the `ClipboardManager/` folder into the project
   (check "Copy items if needed").
4. Add `LSUIElement = YES` to the target's Info.plist (already done for you
   in Option A's `Info.plist` — in Xcode, add it via the target's "Info" tab).
5. Signing & Capabilities → select your Apple ID/team.
6. ⌘R to run, or Product → Archive to export a distributable `.app`.

## Permissions (one-time)
The first time you click an item to paste, macOS asks for **Accessibility**
access (needed to simulate ⌘V into other apps): **System Settings →
Privacy & Security → Accessibility → enable ClipboardManager**. Without
this, clicking still copies the text — you'd just press ⌘V yourself instead
of it happening automatically.

If you rebuild the app later and macOS stops auto-pasting, re-check that
toggle — sometimes a rebuild changes the signature enough that macOS treats
it as a "new" app and re-asks.

## Customizing the shortcut
Edit `ClipboardManager/HotkeyManager.swift`:
```swift
let keyCode: UInt32 = UInt32(kVK_ANSI_V)
let modifiers: UInt32 = UInt32(cmdKey | shiftKey)
```
e.g. for ⌥Space, use `kVK_Space` and `optionKey`. Then rebuild.

## Running it every login
Drag `ClipboardManager.app` into **System Settings → General → Login
Items** so it launches automatically on startup.

## Notes / limitations
- Text only, as requested.
- I wasn't able to compile/test this myself since I run in a Linux
  sandbox without Xcode/macOS — the code is correct Swift/AppKit, but if
  the compiler flags anything on your machine, paste the error back to me
  and I'll fix it.
