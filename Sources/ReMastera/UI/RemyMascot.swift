import SwiftUI
import RiveRuntime

public struct RemyMascot: View {
    let mood: RemyMood
    let size: CGFloat
    
    @StateObject private var riveModel: RiveViewModel
    
    public init(mood: RemyMood = .idle, size: CGFloat = 120) {
        self.mood = mood
        self.size = size
        // Use a placeholder or generic Rive file name until a specific one is provided.
        // We initialize the model with a hypothetical "remy" asset. 
        // If not found in the bundle, Rive handles it gracefully (or we provide fallback).
        self._riveModel = StateObject(wrappedValue: RiveViewModel(fileName: "remy", in: Bundle.module, stateMachineName: nil))
    }
    
    public var body: some View {
        ZStack {
            riveModel.view()
                .frame(width: size, height: size)
                .clipShape(Circle())
            
            // Fallback UI in case the Rive asset is missing from the bundle during testing
            if riveModel.riveModel == nil {
                FallbackRemy(mood: mood, size: size)
            }
        }
        .onChange(of: mood) { _, newMood in
            updateRiveState(for: newMood)
        }
        .onAppear {
            updateRiveState(for: mood)
        }
    }
    
    private func updateRiveState(for mood: RemyMood) {
        // Trigger state machine inputs based on the mood.
        // These inputs (e.g., "isHappy", "isTyping") should match the state machine configured in the .riv file.
        switch mood {
        case .idle:
            riveModel.setInput("isHappy", value: false)
            riveModel.setInput("isTyping", value: false)
        case .thinking, .working:
            riveModel.setInput("isHappy", value: false)
            riveModel.setInput("isTyping", value: true)
        case .happy:
            riveModel.setInput("isHappy", value: true)
            riveModel.setInput("isTyping", value: false)
        case .talking:
            riveModel.setInput("isTyping", value: true)
            riveModel.setInput("isHappy", value: true)
        }
    }
}

// MARK: - Moods

public enum RemyMood: Sendable {
    case idle, thinking, happy, talking, working
}

// MARK: - Fallback UI (Native Gamified Shapes)
// This displays gracefully if the remy.riv file isn't bundled yet.

struct FallbackRemy: View {
    let mood: RemyMood
    let size: CGFloat
    
    @State private var bounceOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(ReMasteraDesign.brand)
                .frame(width: size, height: size)
                .shadow(color: ReMasteraDesign.brand.opacity(0.3), radius: 10, y: 5)
            
            VStack(spacing: size * 0.1) {
                HStack(spacing: size * 0.2) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: size * 0.2, height: size * 0.2)
                        .scaleEffect(mood == .happy ? 1.2 : 1.0)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: size * 0.2, height: size * 0.2)
                        .scaleEffect(mood == .happy ? 1.2 : 1.0)
                }
                
                Capsule()
                    .fill(Color.white)
                    .frame(width: mood == .talking ? size * 0.3 : size * 0.15, height: size * 0.08)
            }
        }
        .offset(y: bounceOffset)
        .onAppear {
            if mood == .happy || mood == .talking {
                withAnimation(ReMasteraDesign.springBouncy.repeatForever(autoreverses: true)) {
                    bounceOffset = -8
                }
            }
        }
        .onChange(of: mood) { _, _ in
            withAnimation(ReMasteraDesign.springSmooth) {
                bounceOffset = (mood == .happy || mood == .talking) ? -8 : 0
            }
        }
    }
}

// MARK: - Gamified Speech Bubble

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
            // Friendly speech bubble tail
            Image(systemName: "triangle.fill")
                .resizable()
                .frame(width: 16, height: 12)
                .foregroundStyle(ReMasteraDesign.surfaceElevated)
                .padding(.leading, 32)
                .offset(y: 1)
            
            // Bubble body
            Text(displayedText)
                .font(ReMasteraType.body(15))
                .foregroundStyle(ReMasteraDesign.heading)
                .lineSpacing(6)
                .padding(.horizontal, ReMasteraDesign.space20)
                .padding(.vertical, ReMasteraDesign.space16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(ReMasteraDesign.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase, style: .continuous))
                .shadow(color: ReMasteraDesign.shadowColor, radius: 8, y: 4)
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
            return String(text.prefix(visibleCharacters))
        }
        return text
    }
    
    private func startTyping() {
        visibleCharacters = 0
        typeTask?.cancel()
        typeTask = Task { @MainActor in
            for _ in 0..<text.count {
                if Task.isCancelled { break }
                try? await Task.sleep(nanoseconds: 20_000_000)
                visibleCharacters += 1
            }
        }
    }
}
