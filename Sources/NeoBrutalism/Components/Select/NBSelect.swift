import SwiftUI

public struct NBSelect<Item, Label>: View where Item: Hashable, Label: View {
    @Environment(\.nbTheme) var theme: NBTheme

    private let title: String?
    @Binding private var selection: Item
    private let items: [Item]
    private let label: (Item) -> Label

    @State private var isExpanded = false
    @State private var triggerSize: CGSize = .zero

    public init(_ title: String? = nil,
                items: [Item],
                selection: Binding<Item>,
                @ViewBuilder label: @escaping (Item) -> Label) {
        self.title = title                        
        self._selection = selection
        self.items = items
        self.label = label
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            triggerView

            // Full-screen overlay to dismiss + the floating menu itself
            if isExpanded {
                // Tap catcher across the whole window
                Color.clear
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation(.spring) { isExpanded = false } }

                // The floating menu
                optionsList
                    .frame(width: triggerSize.width)
                    .fixedSize(horizontal: false, vertical: true)
                    .background(theme.main) // panel fill
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(theme.border, lineWidth: theme.borderWidth)
                    )
                    .shadow(radius: 8, y: 6)
                    .offset(x: 0, y: triggerSize.height + 8) // sit under trigger
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .zIndex(1)
            }
        }
        .foregroundStyle(theme.mainText)
    }
}

private extension NBSelect {
    var triggerView: some View {
        Button {
            withAnimation(.spring) { isExpanded.toggle() }
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
            .background( // measure trigger size
                GeometryReader { proxy in
                    if #available(iOS 17.0, *) {
                        Color.clear
                            .onAppear { triggerSize = proxy.size }
                            .onChange(of: proxy.size) { _, newSize in
                                triggerSize = newSize
                            }
                    } else {
                        Color.clear
                            .onAppear { triggerSize = proxy.size }
                            .onChange(of: proxy.size) { newSize in
                                triggerSize = newSize
                            }
                    }
                }
            )
            .nbBox()
            .fixedSize(horizontal: false, vertical: true)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    var optionsList: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            if let title {
                Text(title)
                    .font(.headline)
                    .padding(.horizontal, theme.padding)
                    .padding(.top, theme.padding)
                    .padding(.bottom, theme.padding * 0.5)
                    .foregroundStyle(theme.mainText)
            }

            // LIST
            ScrollView {
                VStack(spacing: theme.borderWidth) {
                    ForEach(items, id: \.self) { item in
                        let isSelected = item == selection

                        Button {
                            withAnimation(.interactiveSpring) {
                                selection = item
                                isExpanded = false
                            }
                        } label: {
                            // Row content
                            HStack(spacing: 8) {
                                label(item)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, theme.padding * 0.9)
                                    .padding(.horizontal, theme.padding)
                                if isSelected{
                                    Image(systemName: "checkmark")
                                        .padding(8)
                                }
                            }
                            .background(
                                // Rounded outline for selected row
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(theme.border, lineWidth: isSelected ? theme.borderWidth * 1.5 : 0)
                            )
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, theme.padding)
                .padding(.bottom, theme.padding)
            }
            .frame(maxHeight: 280)
            .background(theme.main)
        }
        .background(theme.main)
    }
}

// MARK: - String convenience inits stay the same
public extension NBSelect where Item == String, Label == Text {
    init(options: [String], selection: Binding<String>) {
        self.init(items: options, selection: selection) { Text($0) }
    }

    init(_ title: String? = nil, options: [String], selection: Binding<String>) {
        self.init(title, items: options, selection: selection) { Text($0) }
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
