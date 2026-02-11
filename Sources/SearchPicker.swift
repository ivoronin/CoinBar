import SwiftUI

struct PickerItem: Identifiable {
    let id: String
    let label: String
}

struct SearchPicker: View {
    let title: String
    let items: [PickerItem]
    @Binding var selection: String

    @State private var isExpanded = false
    @State private var searchText = ""
    @State private var hoveredId: String?

    private var selectedLabel: String {
        items.first { $0.id == selection }?.label ?? selection.uppercased()
    }

    private var filteredItems: [PickerItem] {
        if searchText.isEmpty {
            return Array(items.prefix(5))
        }
        let query = searchText.lowercased()
        return Array(items.lazy.filter { $0.label.lowercased().contains(query) }.prefix(5))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button {
                withAnimation(.easeInOut(duration: 0.15)) { isExpanded.toggle() }
                if !isExpanded { searchText = "" }
            } label: {
                HStack {
                    Text(title)
                    Spacer()
                    Text(selectedLabel)
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.tertiary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                TextField("Search...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .controlSize(.small)
                ForEach(filteredItems) { item in
                    Button {
                        selection = item.id
                        searchText = ""
                        withAnimation(.easeInOut(duration: 0.15)) { isExpanded = false }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: item.id == selection ? "checkmark" : "")
                                .font(.system(size: 10, weight: .bold))
                                .frame(width: 12)
                                .foregroundStyle(Color.accentColor)
                            Text(item.label)
                            Spacer()
                        }
                        .padding(.vertical, 3)
                        .padding(.horizontal, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(hoveredId == item.id ? Color.accentColor.opacity(0.1) : .clear)
                        )
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .onHover { isHovered in
                        hoveredId = isHovered ? item.id : nil
                    }
                }
            }
        }
    }
}
