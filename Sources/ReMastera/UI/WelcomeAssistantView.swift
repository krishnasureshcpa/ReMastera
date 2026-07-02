import SwiftUI
import NaturalLanguage

// MARK: - Welcome Assistant View
// The first thing users see. Remy greets them with a typewriter speech bubble.
// Full matrix-terminal aesthetic. Scanlines. Varied typography.

public struct WelcomeAssistantView: View {
    @State private var remyMood: RemyMood = .idle
    @State private var currentMessage = "Hello, operator. I am Remy -- your local film restoration companion. Everything I do stays on this machine. No cloud. No tracking. Just you and your videos."
    @State private var userInput = ""
    @State private var isTyping = true
    @State private var showQuickActions = false
    @State private var conversationLog: [(role: String, text: String)] = []
    @State private var scanlineOffset: CGFloat = 0
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Deep black background
            ReMasteraDesign.black
                .ignoresSafeArea()
            
            // Faint scanline overlay
            VStack(spacing: 4) {
                ForEach(0..<200, id: \.self) { _ in
                    Rectangle()
                        .fill(ReMasteraDesign.heading.opacity(0.012))
                        .frame(height: 1)
                    Rectangle()
                        .fill(.clear)
                        .frame(height: 3)
                }
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top: Status bar
                statusBar
                
                SectionDivider()
                
                ScrollView {
                    VStack(spacing: ReMasteraDesign.space32) {
                        // Remy section
                        VStack(spacing: ReMasteraDesign.space16) {
                            RemyMascot(mood: remyMood, size: 100)
                                .padding(.top, ReMasteraDesign.space24)
                            
                            // Remy's name badge
                            Text("REMY")
                                .font(ReMasteraType.label(11))
                                .tracking(2.5)
                                .foregroundStyle(ReMasteraDesign.brand)
                                .padding(.horizontal, ReMasteraDesign.space12)
                                .padding(.vertical, ReMasteraDesign.space4)
                                .background(ReMasteraDesign.brandSofter)
                                .clipShape(RoundedRectangle(cornerRadius: ReMasteraDesign.radiusSm))
                                .overlay(
                                    RoundedRectangle(cornerRadius: ReMasteraDesign.radiusSm)
                                        .stroke(ReMasteraDesign.borderSubtle, lineWidth: 1)
                                )
                        }
                        
                        // Speech bubble
                        RemySpeechBubble(currentMessage, isTyping: isTyping)
                            .padding(.horizontal, ReMasteraDesign.space48)
                        
                        // Conversation log
                        if !conversationLog.isEmpty {
                            VStack(spacing: ReMasteraDesign.space12) {
                                ForEach(Array(conversationLog.enumerated()), id: \.offset) { _, entry in
                                    HStack(alignment: .top, spacing: ReMasteraDesign.space8) {
                                        Text(entry.role == "you" ? ">" : "remy:")
                                            .font(ReMasteraType.caption(11))
                                            .foregroundStyle(entry.role == "you" ? ReMasteraDesign.brand : ReMasteraDesign.success)
                                            .frame(width: 40, alignment: .trailing)
                                        
                                        Text(entry.text)
                                            .font(ReMasteraType.body(13))
                                            .foregroundStyle(ReMasteraDesign.body)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                            .padding(.horizontal, ReMasteraDesign.space48)
                        }
                        
                        // Quick action cards
                        if showQuickActions {
                            quickActionsGrid
                                .padding(.horizontal, ReMasteraDesign.space32)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                        
                        Spacer(minLength: ReMasteraDesign.space64)
                    }
                }
                
                SectionDivider()
                
                // Input bar
                inputBar
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showQuickActions = true
                    remyMood = .idle
                }
            }
        }
    }
    
    // MARK: - Status Bar
    
    private var statusBar: some View {
        HStack(spacing: ReMasteraDesign.space16) {
            // Connection status
            HStack(spacing: ReMasteraDesign.space4) {
                Circle()
                    .fill(ReMasteraDesign.success)
                    .frame(width: 6, height: 6)
                Text("OFFLINE")
                    .font(ReMasteraType.caption(10))
                    .tracking(1.5)
                    .foregroundStyle(ReMasteraDesign.success)
            }
            
            Spacer()
            
            Text("ReMastera v1.0.0")
                .font(ReMasteraType.caption(10))
                .tracking(1)
                .foregroundStyle(ReMasteraDesign.fgDisabled)
            
            Spacer()
            
            HStack(spacing: ReMasteraDesign.space4) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(ReMasteraDesign.brand)
                Text("LOCAL ONLY")
                    .font(ReMasteraType.caption(10))
                    .tracking(1.5)
                    .foregroundStyle(ReMasteraDesign.brand)
            }
        }
        .padding(.horizontal, ReMasteraDesign.space16)
        .padding(.vertical, ReMasteraDesign.space8)
        .background(ReMasteraDesign.surface)
    }
    
    // MARK: - Quick Actions Grid
    
    private var quickActionsGrid: some View {
        VStack(alignment: .leading, spacing: ReMasteraDesign.space12) {
            Text("QUICK ACTIONS")
                .font(ReMasteraType.label(11))
                .tracking(2)
                .foregroundStyle(ReMasteraDesign.body)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: ReMasteraDesign.space12),
                GridItem(.flexible(), spacing: ReMasteraDesign.space12)
            ], spacing: ReMasteraDesign.space12) {
                QuickActionCard(
                    icon: "film.stack",
                    title: "Upscale to 4K",
                    subtitle: "Lanczos interpolation",
                    action: { handleQuickAction("I want to upscale my video to 4K") }
                )
                QuickActionCard(
                    icon: "wand.and.stars",
                    title: "Remove Noise",
                    subtitle: "hqdn3d denoiser",
                    action: { handleQuickAction("Clean up grain and noise from my footage") }
                )
                QuickActionCard(
                    icon: "text.bubble",
                    title: "Extract Subtitles",
                    subtitle: "whisper.cpp backend",
                    action: { handleQuickAction("I need subtitles extracted from my video") }
                )
                QuickActionCard(
                    icon: "paintpalette",
                    title: "Kodak Film Look",
                    subtitle: "5247 color grade",
                    action: { handleQuickAction("Give my video a cinematic Kodak film look") }
                )
                QuickActionCard(
                    icon: "sun.max.trianglebadge.exclamationmark",
                    title: "HDR10 Tag",
                    subtitle: "Rec.2020 + PQ curve",
                    action: { handleQuickAction("Add HDR10 metadata to my video") }
                )
                QuickActionCard(
                    icon: "questionmark.circle",
                    title: "Help Me Choose",
                    subtitle: "Remy recommends",
                    action: { handleQuickAction("I have an old family video and I do not know where to start") }
                )
            }
        }
    }
    
    // MARK: - Input Bar
    
    private var inputBar: some View {
        HStack(spacing: ReMasteraDesign.space8) {
            Text(">")
                .font(ReMasteraType.body(16))
                .foregroundStyle(ReMasteraDesign.brand)
            
            TextField("Tell Remy what you need...", text: $userInput)
                .font(ReMasteraType.body(14))
                .foregroundStyle(ReMasteraDesign.heading)
                .textFieldStyle(.plain)
                .onSubmit { processUserInput() }
            
            Button(action: processUserInput) {
                Image(systemName: "arrow.up.square.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(userInput.isEmpty ? ReMasteraDesign.fgDisabled : ReMasteraDesign.brand)
            }
            .buttonStyle(.plain)
            .disabled(userInput.isEmpty)
        }
        .padding(.horizontal, ReMasteraDesign.space16)
        .padding(.vertical, ReMasteraDesign.space12)
        .background(ReMasteraDesign.surface)
    }
    
    // MARK: - Logic
    
    private func handleQuickAction(_ query: String) {
        userInput = query
        processUserInput()
    }
    
    private func processUserInput() {
        guard !userInput.isEmpty else { return }
        
        let query = userInput
        conversationLog.append((role: "you", text: query))
        userInput = ""
        remyMood = .thinking
        currentMessage = "Processing..."
        isTyping = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.remyMood = .talking
            self.isTyping = true
            
            let lowerQuery = query.lowercased()
            
            if lowerQuery.contains("upscale") || lowerQuery.contains("4k") || lowerQuery.contains("resolution") {
                self.currentMessage = "Head to the Dashboard and select 'Balanced 4K' preset. Drag your video into the drop zone and I will handle the rest using Lanczos interpolation. For neural upscaling, make sure realesrgan-ncnn-vulkan is installed via Homebrew."
            } else if lowerQuery.contains("noise") || lowerQuery.contains("grain") || lowerQuery.contains("clean") {
                self.currentMessage = "The Archival preset enables the hqdn3d denoiser at maximum quality. Navigate to Dashboard, enable 'Standard Denoise', and queue your file. Processing stays 100% on your machine."
            } else if lowerQuery.contains("subtitle") || lowerQuery.contains("whisper") || lowerQuery.contains("caption") {
                self.currentMessage = "I will scan your system for Whisper audio models. Enable 'Subtitle Extraction' on the Dashboard. If no model is found, install whisper-cpp: brew install whisper-cpp"
                ModelScanner.scanForAudioModels()
            } else if lowerQuery.contains("kodak") || lowerQuery.contains("film") || lowerQuery.contains("cinematic") || lowerQuery.contains("color") {
                self.currentMessage = "The Kodak 5247 look applies warm highlight grading with slight cyan shadow balance. Toggle 'Kodak Film Look' on the Dashboard. It pairs beautifully with the denoiser for vintage footage."
            } else if lowerQuery.contains("hdr") || lowerQuery.contains("rec.2020") || lowerQuery.contains("pq") {
                self.currentMessage = "HDR10 compatibility tags your output with Rec.2020 color primaries and PQ transfer characteristics. Enable it on the Dashboard. Note: your display needs HDR support to see the difference."
            } else if lowerQuery.contains("old") || lowerQuery.contains("family") || lowerQuery.contains("start") || lowerQuery.contains("help") || lowerQuery.contains("recommend") {
                self.currentMessage = "For vintage family footage, I recommend: 1) Enable Denoise to clean sensor noise. 2) Enable Kodak Film Look for warm color grading. 3) Select 'Balanced 4K' preset. 4) Optionally enable Subtitles if there is dialogue. Head to Dashboard and drag your file in."
                self.remyMood = .happy
            } else {
                let encoded = lowerQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? lowerQuery
                self.currentMessage = "I do not have a built-in tool for that specific request yet, but I am always here to help you navigate. Try searching: google.com/search?q=\(encoded) -- or ask me about upscaling, denoising, subtitles, or color grading and I will walk you through it step by step."
            }
            
            self.conversationLog.append((role: "remy", text: self.currentMessage))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.remyMood = .idle
            }
        }
    }
}

// MARK: - Quick Action Card

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: ReMasteraDesign.space8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(isHovered ? ReMasteraDesign.brand : ReMasteraDesign.brandSoft)
                    .shadow(color: isHovered ? ReMasteraDesign.brand.opacity(0.4) : .clear, radius: 6)
                
                Text(title)
                    .font(ReMasteraType.label(13))
                    .foregroundStyle(ReMasteraDesign.heading)
                
                Text(subtitle)
                    .font(ReMasteraType.caption(11))
                    .foregroundStyle(ReMasteraDesign.fgDisabled)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(ReMasteraDesign.space16)
            .background(isHovered ? ReMasteraDesign.surfaceElevated : ReMasteraDesign.black)
            .clipShape(RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase))
            .overlay(
                RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase)
                    .stroke(isHovered ? ReMasteraDesign.brand : ReMasteraDesign.borderSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.15)) { isHovered = hovering }
        }
    }
}
