import SwiftUI

public struct MSColor {
    public static let primary = Color(hex: "#1D9E75")
    public static let primaryDark = Color(hex: "#158B63")
    public static let primaryLight = Color(hex: "#4FB894")
    
    public static let background = Color(uiColor: .systemBackground)
    public static let secondaryBackground = Color(uiColor: .secondarySystemBackground)
    public static let tertiaryBackground = Color(uiColor: .tertiarySystemBackground)
    
    public static let textPrimary = Color(uiColor: .label)
    public static let textSecondary = Color(uiColor: .secondaryLabel)
    public static let textTertiary = Color(uiColor: .tertiaryLabel)
    
    public static let success = Color(hex: "#00C851")
    public static let warning = Color(hex: "#FFA000")
    public static let error = Color(hex: "#F44336")
    
    public static let separator = Color(uiColor: .separator)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

public struct MSFont {
    public static let largeTitle = Font.system(size: 34, weight: .bold)
    public static let title = Font.system(size: 28, weight: .bold)
    public static let title2 = Font.system(size: 22, weight: .bold)
    public static let title3 = Font.system(size: 20, weight: .semibold)
    public static let headline = Font.system(size: 17, weight: .semibold)
    public static let body = Font.system(size: 17, weight: .regular)
    public static let callout = Font.system(size: 16, weight: .regular)
    public static let subheadline = Font.system(size: 15, weight: .regular)
    public static let footnote = Font.system(size: 13, weight: .regular)
    public static let caption = Font.system(size: 12, weight: .regular)
    public static let caption2 = Font.system(size: 11, weight: .regular)
}

public struct MSSpacing {
    public static let xs: CGFloat = 4
    public static let sm: CGFloat = 8
    public static let md: CGFloat = 16
    public static let lg: CGFloat = 24
    public static let xl: CGFloat = 32
    public static let xxl: CGFloat = 48
}

public struct MSRadius {
    public static let xs: CGFloat = 4
    public static let sm: CGFloat = 8
    public static let md: CGFloat = 12
    public static let lg: CGFloat = 16
    public static let xl: CGFloat = 24
    public static let round: CGFloat = 999
}
