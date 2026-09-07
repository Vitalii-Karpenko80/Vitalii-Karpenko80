//
//  DesignSystem.swift
//  VoicePocket
//
//  Дизайн-система в стиле iOS 2026
//

import SwiftUI

// MARK: - Color Palette 2026

extension Color {
    // Liquid Glass Background - глубокий градиент
    static let liquidBackground = Color(red: 0.05, green: 0.05, blue: 0.12)
    static let liquidBackgroundLight = Color(red: 0.08, green: 0.08, blue: 0.18)
    
    // Accent Colors - яркие, но сбалансированные
    static let accentPrimary = Color(red: 0.4, green: 0.8, blue: 1.0) // Cyber Blue
    static let accentSecondary = Color(red: 0.8, green: 0.4, blue: 1.0) // Purple
    static let accentTertiary = Color(red: 1.0, green: 0.5, blue: 0.7) // Pink
    
    // Glass Tints
    static let glassTint = Color.white.opacity(0.05)
    static let glassBorder = Color.white.opacity(0.15)
    
    // Semantic Colors
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let textTertiary = Color.white.opacity(0.4)
}

// MARK: - Typography 2026

extension Font {
    static func display(_ size: CGFloat = 48) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
    
    static func title1(_ size: CGFloat = 32) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
    
    static func title2(_ size: CGFloat = 24) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
    
    static func body(_ size: CGFloat = 17) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }
    
    static func caption(_ size: CGFloat = 13) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }
}

// MARK: - Liquid Glass Modifier

struct LiquidGlassCard: ViewModifier {
    var tintColor: Color = .glassTint
    var cornerRadius: CGFloat = 24
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Soft gradient background
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    tintColor.opacity(0.8),
                                    tintColor.opacity(0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Glass blur effect
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                        .opacity(0.6)
                    
                    // Border shimmer
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.glassBorder,
                                    Color.glassBorder.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
            .shadow(color: tintColor.opacity(0.2), radius: 40, x: 0, y: 20)
    }
}

// MARK: - Soft Depth Shadow

struct SoftDepthShadow: ViewModifier {
    var color: Color = .black
    var radius: CGFloat = 15
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.1), radius: radius * 0.5, x: 0, y: radius * 0.3)
            .shadow(color: color.opacity(0.2), radius: radius, x: 0, y: radius * 0.6)
    }
}

// MARK: - Springy Button Style

struct SpringyButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.95
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: configuration.isPressed)
    }
}

// MARK: - Pulsing Animation

struct PulsingEffect: ViewModifier {
    @State private var isPulsing = false
    var color: Color = .accentPrimary
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Circle()
                    .stroke(color, lineWidth: 4)
                    .scaleEffect(isPulsing ? 1.5 : 1.0)
                    .opacity(isPulsing ? 0.0 : 1.0)
            )
            .onAppear {
                withAnimation(
                    .easeOut(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    isPulsing = true
                }
            }
    }
}

// MARK: - View Extensions

extension View {
    func liquidGlassCard(tintColor: Color = .glassTint, cornerRadius: CGFloat = 24) -> some View {
        modifier(LiquidGlassCard(tintColor: tintColor, cornerRadius: cornerRadius))
    }
    
    func softDepthShadow(color: Color = .black, radius: CGFloat = 15) -> some View {
        modifier(SoftDepthShadow(color: color, radius: radius))
    }
    
    func springyButton(scale: CGFloat = 0.95) -> some View {
        buttonStyle(SpringyButtonStyle(scale: scale))
    }
    
    func pulsing(color: Color = .accentPrimary) -> some View {
        modifier(PulsingEffect(color: color))
    }
}

// MARK: - Animated Gradient Background

struct AnimatedGradientBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: [
                .liquidBackground,
                .liquidBackgroundLight,
                .liquidBackground
            ],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(
                .easeInOut(duration: 8.0)
                .repeatForever(autoreverses: true)
            ) {
                animateGradient = true
            }
        }
    }
}
