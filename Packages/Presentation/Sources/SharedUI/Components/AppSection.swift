import SwiftUI

/// App-wide section wrapper providing consistent, centralized styling.
public struct AppSection<Content: View>: View {
    @Environment(\.appTheme) private var theme

    @Binding private var isExpanded: Bool
    private let header: LocalizedStringKey
    private let isCollapsible: Bool
    private let style: AppSectionStyle
    private let isSeparated: Bool
    private let content: Content

    /// Creates a static section with a localized header.
    public init(
        _ header: LocalizedStringKey,
        style: AppSectionStyle = .card,
        isSeparated: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.header = header
        self._isExpanded = .constant(true)
        self.isCollapsible = false
        self.style = style
        self.isSeparated = isSeparated
        self.content = content()
    }

    /// Creates a collapsible section; the isExpanded binding implies the chevron toggle.
    public init(
        _ header: LocalizedStringKey,
        style: AppSectionStyle = .card,
        isExpanded: Binding<Bool>,
        isSeparated: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.header = header
        self._isExpanded = isExpanded
        self.isCollapsible = true
        self.style = style
        self.isSeparated = isSeparated
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            headerView
            contentView
        }
        .background(.clear)
    }
}

// MARK: - Subviews

private extension AppSection {
    @ViewBuilder
    var contentView: some View {
        if isExpanded {
            switch style {
            case .card:
                sectionCardContent
                    .padding(AppSpacing.large)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(theme.colors.sectionBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
                    .elevatedShadow()
            case .plain:
                sectionPlainContent
            }
        }
    }

    @ViewBuilder
    private var sectionCardContent: some View {
        if isSeparated {
            _VariadicView.Tree(SeparatedSectionLayout()) { content }
        } else {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                content
            }
        }
    }

    @ViewBuilder
    private var sectionPlainContent: some View {
        if isSeparated {
            _VariadicView.Tree(SeparatedSectionLayout()) { content }
        } else {
            content
        }
    }

    @ViewBuilder
    var headerView: some View {
        if isCollapsible {
            collapsibleHeaderView
        } else {
            headerTitleView
        }
    }

    @ViewBuilder
    var collapsibleHeaderView: some View {
        Button {
            withAnimation {
                isExpanded.toggle()
            }
        } label: {
            HStack {
                headerTitleView
                Spacer()
                collapsibleIconView
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isHeader)
        .accessibilityValue(isExpanded ? "accessibility.expanded" : "accessibility.collapsed")
    }

    var headerTitleView: some View {
        Text(header)
            .textStyleCaption(color: theme.colors.secondaryText)
            .textCase(.uppercase)
    }

    var collapsibleIconView: some View {
        Assets.chevronDown.image
            .foregroundStyle(theme.colors.appTint)
            .rotationEffect(.degrees(isExpanded ? 0 : -90))
            .padding(.trailing, AppSpacing.small)
            .animation(.default, value: isExpanded)
            .accessibilityHidden(true)
    }
}

// MARK: - Section style

/// Visual style for section content (card vs plain).
public enum AppSectionStyle {
    /// Card with background, padding, rounded corners, and shadow.
    case card
    /// Raw content with no decoration.
    case plain
}

// MARK: - Separated section layout

/// Layout root that renders ViewBuilder children in a VStack with a custom divider between each row.
/// Uses SwiftUI's variadic view tree so the section can insert separators without the caller listing them.
private struct SeparatedSectionLayout: _VariadicView_UnaryViewRoot {
    @ViewBuilder
    func body(children: _VariadicView.Children) -> some View {
        let lastId = children.last?.id
        VStack(alignment: .leading, spacing: AppSpacing.large) {
            ForEach(children) { child in
                child
                if child.id != lastId {
                    Divider().appDividerStyle()
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Collapsible & With Header") {
    CollapsiblePreview()
}

private struct CollapsiblePreview: View {
    @State private var isExpanded = true

    var body: some View {
        AppSection(
            "Category",
            isExpanded: $isExpanded,
            isSeparated: true
        ) {
            Text("Row 1")
            Text("Row 2")
            Text("Row 3")
        }
        .padding()
    }
}
