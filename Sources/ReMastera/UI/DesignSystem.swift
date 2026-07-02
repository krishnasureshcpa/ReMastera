import SwiftUI

// MARK: - Gamified "Taste-Skill" Design System
// Lively, native macOS aesthetics. No neon, no matrix terminal.
// Inspired by Duolingo & Emil Kowalski animations.

public enum ReMasteraDesign {
    
    // MARK: - Matrix Accent Tones (#389DC6)
    static let brand = Color(red: 0.22, green: 0.62, blue: 0.78)       // Matrix Blue (#389DC6)
    static let brandDeep = Color(red: 0.16, green: 0.48, blue: 0.61)   // Dark Accent Blue (#2A7A9B)
    static let primary = Color(red: 0.22, green: 0.62, blue: 0.78)
    static let primaryDeep = Color(red: 0.53, green: 0.77, blue: 0.88) // Light Accent Blue (#88C5E0)
    
    // MARK: - Deep Terminal Backdrops (#020804)
    static let background = Color(red: 0.01, green: 0.03, blue: 0.02)
    static let surface = Color(red: 0.01, green: 0.03, blue: 0.02)     // Fully flat backdrop
    static let surfaceElevated = Color(red: 0.05, green: 0.12, blue: 0.15)
    
    // MARK: - Text (Matrix Blue Shades)
    static let heading = Color(red: 0.53, green: 0.77, blue: 0.88)
    static let body = Color(red: 0.22, green: 0.62, blue: 0.78)
    static let bodySubtle = Color(red: 0.16, green: 0.48, blue: 0.61)
    static let fgDisabled = Color(red: 0.08, green: 0.24, blue: 0.31)
    
    // MARK: - Status
    static let success = Color(red: 0.00, green: 0.60, blue: 0.42)     // Matrix green
    static let warning = Color(red: 0.98, green: 0.57, blue: 0.15)
    static let error = Color(red: 0.78, green: 0.00, blue: 0.21)
    
    // MARK: - Borders & Shadows (Sharp 1px border defaults)
    static let borderSubtle = Color(red: 0.16, green: 0.48, blue: 0.61).opacity(0.4)
    static let shadowColor = Color(red: 0.22, green: 0.62, blue: 0.78).opacity(0.15)
    
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
    
    // MARK: - Radius (Sharp 4px default)
    static let radiusSm: CGFloat = 2
    static let radiusBase: CGFloat = 4
    static let radiusLg: CGFloat = 4
    static let radiusFull: CGFloat = 9999
    
    // MARK: - Snappy Terminal Motion
    static let springBouncy = Animation.spring(response: 0.20, dampingFraction: 0.70, blendDuration: 0)
    static let springSmooth = Animation.spring(response: 0.25, dampingFraction: 0.85, blendDuration: 0)
}

// MARK: - Typography Scale

/// Swiss Typographic scale utilizing Bebas Neue (headers) and DM Sans/DM Mono (body/code)
public enum ReMasteraType {
    
    static func display(_ size: CGFloat = 84) -> Font {
        .custom("Bebas Neue", size: size).bold()
    }
    
    static func heading(_ size: CGFloat = 48) -> Font {
        .custom("Bebas Neue", size: size)
    }
    
    static func subheading(_ size: CGFloat = 28) -> Font {
        .custom("DM Sans", size: size).weight(.semibold)
    }
    
    static func body(_ size: CGFloat = 20) -> Font {
        .custom("DM Mono", size: size)
    }
    
    static func label(_ size: CGFloat = 18) -> Font {
        .custom("DM Mono", size: size).weight(.semibold)
    }
    
    static func caption(_ size: CGFloat = 16) -> Font {
        .custom("DM Mono", size: size).weight(.medium)
    }
    
    static func code(_ size: CGFloat = 18) -> Font {
        .custom("DM Mono", size: size)
    }
}

// MARK: - Mixed Typography Components

/// Stark Swiss International Mixed Typography Heading view
public struct SwissMixedHeading: View {
    public let prefix: String
    public let title: String
    public let suffix: String?
    
    public init(prefix: String, title: String, suffix: String? = nil) {
        self.prefix = prefix
        self.title = title
        self.suffix = suffix
    }
    
    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: ReMasteraDesign.space12) {
            Text(prefix)
                .font(ReMasteraType.code(18))
                .foregroundStyle(ReMasteraDesign.brand)
                .bold()
            
            Text(title)
                .font(ReMasteraType.heading(48))
                .foregroundStyle(ReMasteraDesign.heading)
            
            if let suffix = suffix {
                Text(suffix)
                    .font(ReMasteraType.caption(15))
                    .foregroundStyle(ReMasteraDesign.bodySubtle)
                    .bold()
            }
        }
    }
}

// MARK: - Reusable View Modifiers

/// Sharp-edged Terminal outline glow card
struct ReMasteraCard: ViewModifier {
    var interactive: Bool = false
    @State private var isPressed = false
    @State private var isHovered = false
    
    func body(content: Content) -> some View {
        content
            .background(ReMasteraDesign.surface)
            .overlay(
                RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase, style: .continuous)
                    .stroke(isHovered ? ReMasteraDesign.primary : ReMasteraDesign.borderSubtle, lineWidth: 1)
            )
            .shadow(
                color: ReMasteraDesign.brand.opacity(isHovered ? 0.25 : 0.0),
                radius: isHovered ? 8 : 0,
                x: 0,
                y: 0
            )
            .scaleEffect(isPressed ? 0.99 : 1.0)
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

/// A dashed section divider
struct SectionDivider: View {
    var body: some View {
        Line()
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
            .foregroundStyle(ReMasteraDesign.borderSubtle)
            .frame(height: 1)
    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

extension View {
    func remasteraCard(interactive: Bool = false) -> some View {
        modifier(ReMasteraCard(interactive: interactive))
    }
}
