import SwiftUI

struct MSButton: View {
    let title: String
    let style: ButtonStyle
    let action: () -> Void
    
    enum ButtonStyle {
        case primary
        case secondary
        case destructive
        case ghost
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(MSFont.headline)
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, MSSpacing.md)
                .background(backgroundColor)
                .cornerRadius(MSRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: MSRadius.md)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary: return .white
        case .secondary: return MSColor.primary
        case .destructive: return .white
        case .ghost: return MSColor.textPrimary
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary: return MSColor.primary
        case .secondary: return MSColor.background
        case .destructive: return MSColor.error
        case .ghost: return .clear
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .primary: return .clear
        case .secondary: return MSColor.primary
        case .destructive: return .clear
        case .ghost: return MSColor.separator
        }
    }
    
    private var borderWidth: CGFloat {
        switch style {
        case .primary, .destructive: return 0
        case .secondary, .ghost: return 1
        }
    }
}

struct MSCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: MSSpacing.sm) {
            content
        }
        .padding(MSSpacing.md)
        .background(MSColor.secondaryBackground)
        .cornerRadius(MSRadius.md)
    }
}

struct MSTextField: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: MSSpacing.xs) {
            Text(title)
                .font(MSFont.subheadline)
                .foregroundColor(MSColor.textSecondary)
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .font(MSFont.body)
                .padding(MSSpacing.sm)
                .background(MSColor.tertiaryBackground)
                .cornerRadius(MSRadius.sm)
        }
    }
}

struct MSBadge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(MSFont.caption)
            .foregroundColor(.white)
            .padding(.horizontal, MSSpacing.sm)
            .padding(.vertical, MSSpacing.xs)
            .background(color)
            .cornerRadius(MSRadius.xs)
    }
}

struct ConditionBadge: View {
    let state: ConditionState
    
    var body: some View {
        HStack(spacing: MSSpacing.xs) {
            Circle()
                .fill(Color(hex: state.color))
                .frame(width: 8, height: 8)
            
            Text(state.localizedName)
                .font(MSFont.caption)
                .foregroundColor(MSColor.textSecondary)
        }
        .padding(.horizontal, MSSpacing.sm)
        .padding(.vertical, MSSpacing.xs)
        .background(MSColor.tertiaryBackground)
        .cornerRadius(MSRadius.sm)
    }
}
