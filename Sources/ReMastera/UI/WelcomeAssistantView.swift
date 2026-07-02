import SwiftUI
import NaturalLanguage

public struct WelcomeAssistantView: View {
    @State private var assistantMessage = "Hi! I'm your ReMastera AI Assistant. What would you like to remaster today?"
    @State private var userInput = ""
    @State private var isThinking = false
    @State private var isSpeaking = false
    @State private var animationPhase: CGFloat = 0.0
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 24) {
            // Animated AI Character/Logo
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: isThinking ? [.purple, .indigo] : (isSpeaking ? [.blue, .cyan] : [.gray, .black]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(1.0 + (isSpeaking ? sin(animationPhase) * 0.1 : 0))
                    .shadow(color: isSpeaking ? .cyan.opacity(0.5) : .clear, radius: 20)
                
                Image(systemName: isThinking ? "brain.head.profile" : "sparkles")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(isThinking ? sin(animationPhase) * 10 : 0))
            }
            .onAppear {
                withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: true)) {
                    animationPhase = .pi
                }
            }
            
            // Speech Bubble
            Text(assistantMessage)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal, 40)
            
            // Input Field
            HStack {
                TextField("Tell me what you want to do...", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        processUserInput()
                    }
                
                Button(action: processUserInput) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
    
    private func processUserInput() {
        guard !userInput.isEmpty else { return }
        
        let query = userInput.lowercased()
        userInput = ""
        isThinking = true
        assistantMessage = "Let me think about that..."
        
        // Simulate local MLX processing delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isThinking = false
            self.isSpeaking = true
            
            // Simple rule-based NLP fallback for now
            if query.contains("upscale") || query.contains("4k") {
                self.assistantMessage = "I can definitely help you upscale! Drag a video into the dashboard and select 'Balanced 4K'."
            } else if query.contains("noise") || query.contains("clean") || query.contains("grain") {
                self.assistantMessage = "To remove noise, I recommend using the Archival preset. It utilizes hqdn3d denoising."
            } else if query.contains("subtitle") || query.contains("whisper") {
                self.assistantMessage = "I will scan your system for Whisper audio models so we can extract those subtitles offline."
                ModelScanner.scanForAudioModels()
            } else {
                let googleQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                self.assistantMessage = "I don't have a specific offline tool for that yet. However, I'm always here to help! You might find a quick answer by searching: https://google.com/search?q=\(googleQuery)"
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.isSpeaking = false
            }
        }
    }
}
