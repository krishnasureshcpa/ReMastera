import SwiftUI

// MARK: - Gamified "Taste-Skill" Design System
// Lively, native macOS aesthetics. No neon, no matrix terminal.
// Inspired by Duolingo & Emil Kowalski animations.

public enum ReMasteraDesign {
    
    // MARK: - Gamified Brand Colors
    // Soft but vibrant, high-end look
    static let brand = Color(red: 0.35, green: 0.80, blue: 0.98)       // Friendly Sky Blue
    static let brandDeep = Color(red: 0.11, green: 0.63, blue: 0.87)   // Deep Sky Blue
    static let primary = Color(red: 0.35, green: 0.80, blue: 0.40)     // Duolingo-style Green
    static let primaryDeep = Color(red: 0.25, green: 0.65, blue: 0.30) // Darker Green
    
    // MARK: - Neutrals (Adaptive for Light/Dark Mode)
    static let background = Color(nsColor: .windowBackgroundColor)
    static let surface = Color(nsColor: .controlBackgroundColor)
    static let surfaceElevated = Color(nsColor: .textBackgroundColor)
    
    // MARK: - Text
    static let heading = Color(nsColor: .labelColor)
    static let body = Color(nsColor: .secondaryLabelColor)
    static let bodySubtle = Color(nsColor: .tertiaryLabelColor)
    static let fgDisabled = Color(nsColor: .quaternaryLabelColor)
    
    // MARK: - Status
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    
    // MARK: - Borders & Shadows
    static let borderSubtle = Color(nsColor: .separatorColor)
    static let shadowColor = Color.black.opacity(0.1)
    
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
    static let radiusSm: CGFloat = 8
    static let radiusBase: CGFloat = 16
    static let radiusLg: CGFloat = 24
    static let radiusFull: CGFloat = 9999
    
    // MARK: - Emil Kowalski Fluid Springs
    static let springBouncy = Animation.spring(response: 0.35, dampingFraction: 0.55, blendDuration: 0)
    static let springSmooth = Animation.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0)
}

// MARK: - Typography Scale

/// Friendly, rounded typography scale to match gamified UI.
public enum ReMasteraType {
    
    static func display(_ size: CGFloat = 48) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
    
    static func heading(_ size: CGFloat = 28) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
    
    static func subheading(_ size: CGFloat = 20) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
    
    static func body(_ size: CGFloat = 15) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }
    
    static func label(_ size: CGFloat = 13) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
    
    static func caption(_ size: CGFloat = 11) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }
    
    static func code(_ size: CGFloat = 13) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }
}

// MARK: - Reusable View Modifiers

/// Bouncy gamified card modifier
struct ReMasteraCard: ViewModifier {
    var interactive: Bool = false
    @State private var isPressed = false
    @State private var isHovered = false
    
    func body(content: Content) -> some View {
        content
            .background(ReMasteraDesign.surface)
            .clipShape(RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase, style: .continuous))
            .shadow(color: ReMasteraDesign.shadowColor, radius: isHovered ? 12 : 4, y: isHovered ? 6 : 2)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(ReMasteraDesign.springBouncy, value: isHovered)
            .animation(ReMasteraDesign.springBouncy, value: isPressed)
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
