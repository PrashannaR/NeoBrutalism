import SwiftUI

public struct NBSelect<Item, Label>: View where Item: Hashable, Label: View {
    @Environment(\.nbTheme) var theme: NBTheme

    @Binding private var selection: Item
    private let items: [Item]
    private let label: (Item) -> Label

    @State private var isExpanded = false

    public init(_ title: String? = nil, items: [Item], selection: Binding<Item>, @ViewBuilder label: @escaping (Item) -> Label) {
        self._selection = selection
        self.items = items
        self.label = label
    }

    public var body: some View {
        VStack(spacing: 0) {
            triggerView
                .overlay(
                    Divider()
                        .frame(maxWidth: .infinity, maxHeight: theme.borderWidth)
                        .background(theme.border), alignment: .bottom
                )

            if isExpanded {
                optionsList
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .foregroundStyle(theme.mainText)
        .nbBox()
    }
}

private extension NBSelect {
    var triggerView: some View {
        Button {
            withAnimation(.interactiveSpring) {
                isExpanded.toggle()
            }
        } label: {
            ZStack {
                theme.main
                HStack(spacing: 8) {
                    label(selection)
                        .bold()
                        .padding(theme.padding)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.interactiveSpring, value: isExpanded)
                        .padding(.trailing, theme.padding)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    var optionsList: some View {
        VStack(spacing: 0) {
            // Enumerate to draw dividers between rows
            ForEach(Array(items.enumerated()), id: \.element) { index, item in
                Button {
                    withAnimation(.interactiveSpring) {
                        selection = item
                        isExpanded = false
                    }
                } label: {
                    HStack(spacing: 8) {
                        label(item)
                            .padding(theme.padding)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(theme.text)

                        if item == selection {
                            Image(systemName: "checkmark")
                                .foregroundStyle(theme.text)
                                .padding(.trailing, theme.padding)
                        } else {
                            // Maintain right padding alignment when no checkmark
                            Color.clear.frame(width: 0)
                                .padding(.trailing, theme.padding)
                        }
                    }
                    .contentShape(Rectangle())
                    .background(theme.bw)
                }
                .buttonStyle(.plain)
                .overlay(alignment: .bottom) {
                    if index < items.count - 1 {
                        Divider()
                            .frame(maxWidth: .infinity, maxHeight: theme.borderWidth)
                            .background(theme.border)
                    }
                }
            }
        }
        .background(theme.bw)
    }
}

public extension NBSelect where Item == String, Label == Text {
    init(options: [String], selection: Binding<String>) {
        self.init(items: options, selection: selection) { value in
            Text(value)
        }
    }

    init(_ title: String? = nil, options: [String], selection: Binding<String>) {
        self.init(title, items: options, selection: selection) { value in
            Text(value)
        }
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(NBPreviewHelper())) {
    VStack(spacing: 18) {
        StatefulPreviewWrapper("Expecto Patronum") { selection in
            NBSelect(options: [
                "Piertotum Locomotor",
                "Expecto Patronum",
                "Expelliarmus",
                "Alohomora"
            ], selection: selection)
        }

        StatefulPreviewWrapper("Expelliarmus") { selection in
            NBSelect(items: [
                "Piertotum Locomotor",
                "Expecto Patronum",
                "Expelliarmus",
                "Alohomora"
            ], selection: selection) { value in
                HStack {
                    Text(value)
                    Spacer(minLength: 0)
                }
            }
        }
    }
    .padding()
}

// Helper to host @State in previews without altering the project
@available(iOS 18.0, *)
struct StatefulPreviewWrapper<Value: Hashable, Content: View>: View {
    @State var value: Value
    var content: (Binding<Value>) -> Content

    init(_ value: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
        self._value = State(initialValue: value)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}
