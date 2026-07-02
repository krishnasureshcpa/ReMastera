import SwiftUI

// MARK: - Gamified "Taste-Skill" Design System
// Lively, native macOS aesthetics. No neon, no matrix terminal.
// Inspired by Duolingo & Emil Kowalski animations.

public enum ReMasteraDesign {
    
    // MARK: - Swiss Typographic Stark Accents
    static let brand = Color(red: 0.90, green: 0.10, blue: 0.15)       // Stark Crimson Red
    static let brandDeep = Color(red: 0.70, green: 0.05, blue: 0.10)   // Deep Crimson Red
    static let primary = Color(nsColor: .labelColor)                   // Stark Monochrome Black/White
    static let primaryDeep = Color(nsColor: .secondaryLabelColor)
    
    // MARK: - Stark Neutrals (Neumorphic Baseline)
    static let background = Color(nsColor: .windowBackgroundColor)
    static let surface = Color(nsColor: .windowBackgroundColor)        // Matches background for neumorphic blending
    static let surfaceElevated = Color(nsColor: .controlBackgroundColor)
    
    // MARK: - Text
    static let heading = Color(nsColor: .labelColor)
    static let body = Color(nsColor: .secondaryLabelColor)
    static let bodySubtle = Color(nsColor: .tertiaryLabelColor)
    static let fgDisabled = Color(nsColor: .quaternaryLabelColor)
    
    // MARK: - Status
    static let success = Color(red: 0.15, green: 0.68, blue: 0.37)
    static let warning = Color(red: 0.95, green: 0.61, blue: 0.07)
    static let error = Color(red: 0.90, green: 0.10, blue: 0.15)
    
    // MARK: - Borders & Shadows
    static let borderSubtle = Color(nsColor: .separatorColor)
    static let shadowColor = Color.black.opacity(0.12)
    
    // MARK: - Spacing (8px base grid)
    static let space4: CGFloat = 4
    static let space8: CGFloat = 8
    static let space12: CGFloat = 12
    static let space16: CGFloat = 16
    static let space20: CGFloat = 20
    static let space24: CGFloat = 24
    static let space32: CGFloat = 32
    static let space48: CGFloat = 48
    static let space64: CGFloat = 64
    
    // MARK: - Radius
    static let radiusSm: CGFloat = 6
    static let radiusBase: CGFloat = 12
    static let radiusLg: CGFloat = 18
    static let radiusFull: CGFloat = 9999
    
    // MARK: - Swiss Motion (Fluid, Damped Springs)
    static let springBouncy = Animation.spring(response: 0.30, dampingFraction: 0.60, blendDuration: 0)
    static let springSmooth = Animation.spring(response: 0.35, dampingFraction: 0.85, blendDuration: 0)
}

// MARK: - Typography Scale

/// Swiss Typographic scale utilizing Bebas Neue (headers) and DM Sans/DM Mono (body/code)
public enum ReMasteraType {
    
    static func display(_ size: CGFloat = 48) -> Font {
        .custom("Bebas Neue", size: size).bold()
    }
    
    static func heading(_ size: CGFloat = 28) -> Font {
        .custom("Bebas Neue", size: size)
    }
    
    static func subheading(_ size: CGFloat = 20) -> Font {
        .custom("DM Sans", size: size).weight(.semibold)
    }
    
    static func body(_ size: CGFloat = 15) -> Font {
        .custom("DM Sans", size: size).weight(.regular)
    }
    
    static func label(_ size: CGFloat = 13) -> Font {
        .custom("DM Sans", size: size).weight(.semibold)
    }
    
    static func caption(_ size: CGFloat = 11) -> Font {
        .custom("DM Sans", size: size).weight(.medium)
    }
    
    static func code(_ size: CGFloat = 13) -> Font {
        .custom("DM Mono", size: size)
    }
}

// MARK: - Reusable View Modifiers

/// Selective Neumorphic Modifier utilizing double shadows (ambient occlusion + light source extrusions)
struct ReMasteraCard: ViewModifier {
    var interactive: Bool = false
    @State private var isPressed = false
    @State private var isHovered = false
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase, style: .continuous)
                    .fill(ReMasteraDesign.surface)
            )
            .shadow(
                color: Color.black.opacity(isPressed ? 0.06 : (isHovered ? 0.16 : 0.12)),
                radius: isPressed ? 2 : (isHovered ? 8 : 5),
                x: isPressed ? 1 : (isHovered ? 5 : 3),
                y: isPressed ? 1 : (isHovered ? 5 : 3)
            )
            .shadow(
                color: Color.white.opacity(isPressed ? 0.3 : (isHovered ? 0.9 : 0.75)),
                radius: isPressed ? 2 : (isHovered ? 8 : 5),
                x: isPressed ? -1 : (isHovered ? -5 : -3),
                y: isPressed ? -1 : (isHovered ? -5 : -3)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(ReMasteraDesign.springSmooth, value: isHovered)
            .animation(ReMasteraDesign.springSmooth, value: isPressed)
            .onHover { hovering in
                if interactive { isHovered = hovering }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in if interactive { isPressed = true } }
                    .onEnded { _ in if interactive { isPressed = false } }
            )
    }
}

/// A playful section divider
struct SectionDivider: View {
    var body: some View {
        Rectangle()
            .fill(ReMasteraDesign.borderSubtle)
            .frame(height: 2)
            .clipShape(Capsule())
    }
}

extension View {
    func remasteraCard(interactive: Bool = false) -> some View {
        modifier(ReMasteraCard(interactive: interactive))
    }
}
