import SwiftUI

struct ClipboardListView: View {
    @ObservedObject var clipboardMonitor: ClipboardMonitor
    var onSelect: (String) -> Void
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Clipboard History")
                    .font(.headline)
                Spacer()
                Button(action: { clipboardMonitor.clearHistory() }) {
                    Image(systemName: "trash")
                }
                .buttonStyle(.plain)
                .help("Clear history")
            }
            .padding(12)

            Divider()

            if clipboardMonitor.items.isEmpty {
                Spacer()
                Text("No clipboard history yet")
                    .foregroundColor(.secondary)
                    .font(.system(size: 13))
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(clipboardMonitor.items.enumerated()), id: \.offset) { index, item in
                            ClipboardRowView(index: index, text: item)
                                .contentShape(Rectangle())
                                .onTapGesture { onSelect(item) }
                            Divider()
                        }
                    }
                }
            }
        }
        .frame(width: 360, height: 420)
        .background(.regularMaterial)
        .onExitCommand { onDismiss() } // Escape key closes the popup
    }
}

struct ClipboardRowView: View {
    let index: Int
    let text: String
    @State private var hovering = false

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(index + 1)")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 18, alignment: .trailing)
            Text(text)
                .lineLimit(2)
                .font(.system(size: 13))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(hovering ? Color.accentColor.opacity(0.15) : Color.clear)
        .onHover { hovering = $0 }
    }
}
