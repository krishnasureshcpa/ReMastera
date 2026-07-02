import SwiftUI

// MARK: - ReMastera Design System
// Matrix-terminal aesthetic. Monospace-first. Blue accent (#389DC6).
// Deep black (#020804). Varied typography. Sharp edges. Compact density.

public enum ReMasteraDesign {
    
    // MARK: - Brand
    static let brand = Color(red: 0.22, green: 0.61, blue: 0.78)          // #389DC6
    static let brandStrong = Color(red: 0.17, green: 0.48, blue: 0.61)    // #2A7A9B
    static let brandSoft = Color(red: 0.53, green: 0.77, blue: 0.88)      // #88C5E0
    static let brandSofter = Color(red: 0.04, green: 0.12, blue: 0.15)    // #0B1F27
    static let brandMedium = Color(red: 0.09, green: 0.24, blue: 0.31)    // #163E4F
    
    // MARK: - Neutrals (Dark Mode Primary)
    static let black = Color(red: 0.008, green: 0.031, blue: 0.016)       // #020804
    static let surface = Color(red: 0.047, green: 0.039, blue: 0.024)     // #0C0A06
    static let surfaceElevated = Color(red: 0.11, green: 0.10, blue: 0.086) // #1C1A16
    static let surfaceStrong = Color(red: 0.20, green: 0.19, blue: 0.16)  // #33302A
    static let surfaceQuaternary = Color(red: 0.25, green: 0.24, blue: 0.21) // #403D36
    
    // MARK: - Text
    static let heading = Color(red: 0.96, green: 0.95, blue: 0.94)        // #F5F3EF
    static let body = Color(red: 0.61, green: 0.59, blue: 0.56)           // #9C968E
    static let bodySubtle = Color(red: 0.61, green: 0.59, blue: 0.56)     // #9C968E
    static let fgDisabled = Color(red: 0.36, green: 0.34, blue: 0.31)     // #5C564E
    
    // MARK: - Status
    static let success = Color(red: 0.0, green: 0.60, blue: 0.40)         // #009966
    static let successSoft = Color(red: 0.0, green: 0.17, blue: 0.13)     // #002C22
    static let danger = Color(red: 0.78, green: 0.0, blue: 0.21)          // #C70036
    static let dangerSoft = Color(red: 0.30, green: 0.01, blue: 0.09)     // #4D0218
    static let warning = Color(red: 0.98, green: 0.45, blue: 0.09)        // #F97316
    static let warningSoft = Color(red: 0.49, green: 0.18, blue: 0.07)    // #7C2D12
    static let error = Color(red: 0.93, green: 0.27, blue: 0.27)          // #EF4444
    
    // MARK: - Borders
    static let borderDefault = Color(red: 0.22, green: 0.61, blue: 0.78)  // #389DC6
    static let borderSubtle = Color(red: 0.09, green: 0.24, blue: 0.31)   // #163E4F
    static let borderMuted = Color(red: 0.53, green: 0.77, blue: 0.88).opacity(0.2) // #88C5E0 @ 20%
    
    // MARK: - Spacing (4px base grid)
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
    static let radiusBase: CGFloat = 4
    static let radiusSm: CGFloat = 2
    static let radiusFull: CGFloat = 9999
}

// MARK: - Typography Scale

/// Varied type scale: monospace-first with dramatic size contrast.
/// h1=48pt, h2=36pt, h3=30pt, h4=24pt, h5=20pt, h6=16pt
/// Body=14pt, Caption=12pt, Micro=11pt
public enum ReMasteraType {
    
    static func display(_ size: CGFloat = 48) -> Font {
        .system(size: size, weight: .bold, design: .monospaced)
    }
    
    static func heading(_ size: CGFloat = 30) -> Font {
        .system(size: size, weight: .semibold, design: .monospaced)
    }
    
    static func subheading(_ size: CGFloat = 20) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }
    
    static func body(_ size: CGFloat = 14) -> Font {
        .system(size: size, weight: .regular, design: .monospaced)
    }
    
    static func label(_ size: CGFloat = 12) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }
    
    static func caption(_ size: CGFloat = 11) -> Font {
        .system(size: size, weight: .regular, design: .monospaced)
    }
    
    static func code(_ size: CGFloat = 13) -> Font {
        .system(size: size, weight: .regular, design: .monospaced)
    }
}

// MARK: - Reusable View Modifiers

/// Card modifier: black bg, 1px brand border, 4px radius
struct ReMasteraCard: ViewModifier {
    var interactive: Bool = false
    @State private var isHovered = false
    
    func body(content: Content) -> some View {
        content
            .background(ReMasteraDesign.black)
            .clipShape(RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase))
            .overlay(
                RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase)
                    .stroke(
                        isHovered && interactive ? ReMasteraDesign.brand : ReMasteraDesign.borderSubtle,
                        lineWidth: 1
                    )
            )
            .onHover { hovering in
                if interactive { isHovered = hovering }
            }
    }
}

/// Section divider: dashed line in brand color
struct SectionDivider: View {
    var body: some View {
        Rectangle()
            .fill(ReMasteraDesign.borderSubtle)
            .frame(height: 1)
            .overlay(
                GeometryReader { geo in
                    Path { path in
                        let dashWidth: CGFloat = 6
                        let gapWidth: CGFloat = 4
                        var x: CGFloat = 0
                        while x < geo.size.width {
                            path.addRect(CGRect(x: x, y: 0, width: dashWidth, height: 1))
                            x += dashWidth + gapWidth
                        }
                    }
                    .fill(ReMasteraDesign.brand.opacity(0.4))
                }
            )
    }
}

extension View {
    func remasteraCard(interactive: Bool = false) -> some View {
        modifier(ReMasteraCard(interactive: interactive))
    }
}
