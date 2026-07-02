import SwiftUI

public struct WelcomeAssistantView: View {
    @State private var mascotMood: RemyMood = .idle
    @State private var showingQuickActions = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: ReMasteraDesign.space48) {
            
            // Remy Mascot with Rive integration
            RemyMascot(mood: mascotMood, size: 140)
                .onTapGesture {
                    withAnimation(ReMasteraDesign.springBouncy) {
                        mascotMood = (mascotMood == .happy) ? .idle : .happy
                    }
                }
            
            // Gamified Speech Bubble
            VStack(spacing: ReMasteraDesign.space24) {
                RemySpeechBubble(
                    "Hey! I'm Remy. Let's make your videos look incredible without ever leaving your Mac.",
                    isTyping: true
                )
                .frame(maxWidth: 400)
                
                if showingQuickActions {
                    HStack(spacing: ReMasteraDesign.space16) {
                        QuickActionButton(
                            title: "Upscale 4K",
                            icon: "arrow.up.right.square.fill",
                            color: ReMasteraDesign.primary,
                            action: { mascotMood = .working }
                        )
                        
                        QuickActionButton(
                            title: "Denoise",
                            icon: "sparkles",
                            color: ReMasteraDesign.brand,
                            action: { mascotMood = .thinking }
                        )
                        
                        QuickActionButton(
                            title: "Film Look",
                            icon: "film.fill",
                            color: ReMasteraDesign.warning,
                            action: { mascotMood = .happy }
                        )
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ReMasteraDesign.background)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(ReMasteraDesign.springSmooth) {
                    showingQuickActions = true
                    mascotMood = .talking
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    mascotMood = .idle
                }
            }
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    @State private var isHovered = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: ReMasteraDesign.space12) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundStyle(color)
                    .scaleEffect(isHovered ? 1.1 : 1.0)
                    .animation(ReMasteraDesign.springBouncy, value: isHovered)
                
                Text(title)
                    .font(ReMasteraType.label())
                    .foregroundStyle(ReMasteraDesign.heading)
            }
            .padding(ReMasteraDesign.space16)
            .frame(width: 110, height: 110)
            .background(ReMasteraDesign.surface)
            .clipShape(RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase, style: .continuous))
            .shadow(color: isHovered ? color.opacity(0.3) : ReMasteraDesign.shadowColor, radius: isHovered ? 12 : 4, y: isHovered ? 6 : 2)
            .scaleEffect(isPressed ? 0.92 : 1.0)
            .animation(ReMasteraDesign.springBouncy, value: isPressed)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}
