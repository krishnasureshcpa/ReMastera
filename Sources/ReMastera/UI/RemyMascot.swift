import SwiftUI
import NaturalLanguage

// MARK: - The Mascot: Remy the Film Reel
// A playful character built from geometric shapes. No emoji. No AI clipart.
// Remy lives in the matrix-terminal world: brand-blue glow, monochrome body.

public struct RemyMascot: View {
    let mood: RemyMood
    let size: CGFloat
    
    @State private var breatheScale: CGFloat = 1.0
    @State private var reelRotation: Double = 0
    @State private var eyeBlink = false
    @State private var bounceOffset: CGFloat = 0
    @State private var glowPulse: CGFloat = 0.3
    
    @State private var blinkTask: Task<Void, Never>?
    
    public init(mood: RemyMood = .idle, size: CGFloat = 120) {
        self.mood = mood
        self.size = size
    }
    
    public var body: some View {
        ZStack {
            // Glow aura - brand blue
            Circle()
                .fill(
                    RadialGradient(
                        colors: [moodGlowColor.opacity(glowPulse), .clear],
                        center: .center,
                        startRadius: size * 0.2,
                        endRadius: size * 0.9
                    )
                )
                .frame(width: size * 1.8, height: size * 1.8)
            
            // Scanline overlay on the glow
            Circle()
                .fill(.clear)
                .frame(width: size * 1.8, height: size * 1.8)
                .overlay(
                    VStack(spacing: 3) {
                        ForEach(0..<30, id: \.self) { _ in
                            Rectangle()
                                .fill(ReMasteraDesign.black.opacity(0.15))
                                .frame(height: 1)
                        }
                    }
                    .clipShape(Circle())
                )
            
            ZStack {
                // Main body - dark with brand border
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [ReMasteraDesign.surfaceElevated, ReMasteraDesign.black],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)
                    .overlay(
                        Circle()
                            .stroke(ReMasteraDesign.brand.opacity(0.6), lineWidth: 1.5)
                    )
                
                // Film reel spokes
                ForEach(0..<6, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(ReMasteraDesign.borderSubtle)
                        .frame(width: 2, height: size * 0.32)
                        .offset(y: -size * 0.04)
                        .rotationEffect(.degrees(Double(i) * 60 + reelRotation))
                }
                
                // Inner hub
                Circle()
                    .fill(ReMasteraDesign.surface)
                    .frame(width: size * 0.42, height: size * 0.42)
                    .overlay(
                        Circle()
                            .stroke(ReMasteraDesign.borderSubtle, lineWidth: 1)
                    )
                
                // Face plate
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [ReMasteraDesign.surfaceElevated, ReMasteraDesign.black],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: size * 0.38, height: size * 0.38)
                
                // Eyes - brand blue glow
                HStack(spacing: size * 0.07) {
                    RemyEye(blink: eyeBlink, mood: mood, eyeSize: size * 0.085)
                    RemyEye(blink: eyeBlink, mood: mood, eyeSize: size * 0.085)
                }
                .offset(y: -size * 0.02)
                
                // Mouth
                RemyMouth(mood: mood, width: size * 0.13, height: size * 0.045)
                    .offset(y: size * 0.075)
                
                // Film strip sprockets
                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(ReMasteraDesign.brand.opacity(0.5))
                            .frame(width: 5, height: 8)
                    }
                }
                .offset(x: size * 0.46, y: size * 0.01)
                .opacity(mood == .happy ? 1.0 : 0.4)
            }
            .scaleEffect(breatheScale)
            .offset(y: bounceOffset)
        }
        .onAppear { startAnimations() }
        .onChange(of: mood) { _, _ in startAnimations() }
        .onDisappear { blinkTask?.cancel() }
    }
    
    private var moodGlowColor: Color {
        switch mood {
        case .idle: return ReMasteraDesign.brand
        case .thinking: return ReMasteraDesign.brandSoft
        case .happy: return ReMasteraDesign.success
        case .talking: return ReMasteraDesign.brand
        case .working: return ReMasteraDesign.warning
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            breatheScale = mood == .happy ? 1.08 : 1.03
            glowPulse = mood == .thinking ? 0.5 : 0.3
        }
        
        if mood == .thinking || mood == .working {
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                reelRotation = 360
            }
        } else {
            withAnimation(.easeOut(duration: 0.5)) { reelRotation = 0 }
        }
        
        if mood == .happy {
            withAnimation(.interpolatingSpring(stiffness: 200, damping: 5).repeatForever(autoreverses: true)) {
                bounceOffset = -10
            }
        } else {
            withAnimation(.spring()) { bounceOffset = 0 }
        }
        
        // Blink logic with Task instead of Timer to fix concurrency warnings
        blinkTask?.cancel()
        blinkTask = Task { @MainActor in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 3_500_000_000)
                if Task.isCancelled { break }
                withAnimation(.easeInOut(duration: 0.12)) { eyeBlink = true }
                try? await Task.sleep(nanoseconds: 120_000_000)
                if Task.isCancelled { break }
                withAnimation(.easeInOut(duration: 0.12)) { eyeBlink = false }
            }
        }
    }
}

// MARK: - Moods

public enum RemyMood: Sendable {
    case idle, thinking, happy, talking, working
}

// MARK: - Eye

struct RemyEye: View {
    let blink: Bool
    let mood: RemyMood
    let eyeSize: CGFloat
    
    var body: some View {
        ZStack {
            Capsule()
                .fill(ReMasteraDesign.brand)
                .frame(width: eyeSize, height: blink ? 2 : eyeSize)
                .shadow(color: ReMasteraDesign.brand.opacity(0.6), radius: blink ? 0 : 4)
            
            if !blink {
                Circle()
                    .fill(ReMasteraDesign.black)
                    .frame(width: eyeSize * 0.5)
                    .offset(y: mood == .thinking ? -1 : 0)
                
                Circle()
                    .fill(ReMasteraDesign.brand.opacity(0.9))
                    .frame(width: eyeSize * 0.18)
                    .offset(x: eyeSize * 0.1, y: -eyeSize * 0.1)
            }
        }
    }
}

// MARK: - Mouth

struct RemyMouth: View {
    let mood: RemyMood
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        switch mood {
        case .happy:
            Capsule()
                .fill(ReMasteraDesign.brand)
                .frame(width: width * 1.2, height: height)
                .shadow(color: ReMasteraDesign.brand.opacity(0.4), radius: 3)
        case .talking:
            Ellipse()
                .fill(ReMasteraDesign.surface)
                .frame(width: width * 0.5, height: height * 1.1)
                .overlay(Ellipse().stroke(ReMasteraDesign.brand.opacity(0.5), lineWidth: 1))
        case .thinking:
            Circle()
                .fill(ReMasteraDesign.surface)
                .frame(width: height * 0.7)
                .overlay(Circle().stroke(ReMasteraDesign.borderSubtle, lineWidth: 1))
        default:
            Capsule()
                .fill(ReMasteraDesign.borderSubtle)
                .frame(width: width * 0.6, height: 2)
        }
    }
}

// MARK: - Speech Bubble

public struct RemySpeechBubble: View {
    let text: String
    let isTyping: Bool
    
    @State private var visibleCharacters = 0
    @State private var typeTask: Task<Void, Never>?
    
    public init(_ text: String, isTyping: Bool = false) {
        self.text = text
        self.isTyping = isTyping
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Arrow pointing up toward Remy
            Triangle()
                .fill(ReMasteraDesign.surfaceElevated)
                .frame(width: 12, height: 8)
                .padding(.leading, 40)
            
            // Bubble body
            Text(displayedText)
                .font(ReMasteraType.body(14))
                .foregroundStyle(ReMasteraDesign.heading)
                .lineSpacing(4)
                .padding(.horizontal, ReMasteraDesign.space16)
                .padding(.vertical, ReMasteraDesign.space12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(ReMasteraDesign.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase))
                .overlay(
                    RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase)
                        .stroke(ReMasteraDesign.borderSubtle, lineWidth: 1)
                )
        }
        .onAppear {
            if isTyping { startTyping() }
        }
        .onChange(of: text) { _, _ in
            if isTyping {
                visibleCharacters = 0
                startTyping()
            }
        }
        .onDisappear {
            typeTask?.cancel()
        }
    }
    
    private var displayedText: String {
        if isTyping && visibleCharacters < text.count {
            return String(text.prefix(visibleCharacters)) + "_"
        }
        return text
    }
    
    private func startTyping() {
        visibleCharacters = 0
        typeTask?.cancel()
        typeTask = Task { @MainActor in
            for _ in 0..<text.count {
                if Task.isCancelled { break }
                try? await Task.sleep(nanoseconds: 25_000_000)
                visibleCharacters += 1
            }
        }
    }
}

// MARK: - Triangle Shape

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
