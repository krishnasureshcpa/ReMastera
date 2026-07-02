import SwiftUI

public struct ReMasteraApp: App {
    @State private var queueManager = QueueManager()
    @State private var selection: NavigationTarget = .assistant
    
    public init() {}
    
    public var body: some Scene {
        WindowGroup {
            ZStack {
                ReMasteraDesign.background.ignoresSafeArea()
                
                HStack(spacing: 0) {
                    SidebarView(selection: $selection)
                    
                    // Vertical brand-colored divider
                    Rectangle()
                        .fill(ReMasteraDesign.borderSubtle)
                        .frame(width: 1)
                    
                    // Detail view
                    ZStack {
                        ReMasteraDesign.background.ignoresSafeArea()
                        
                        switch selection {
                        case .assistant:
                            WelcomeAssistantView()
                        case .dashboard:
                            DashboardView(queueManager: queueManager)
                        case .queue:
                            QueueView(queueManager: queueManager)
                        case .dependencies:
                            DependencyView()
                        case .privacy:
                            PrivacyView()
                        case .settings:
                            SettingsView()
                        }
                    }
                }
            }
            .frame(minWidth: 1060, minHeight: 680)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
