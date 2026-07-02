import SwiftUI
import AppKit

public struct ReMasteraApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    public init() {}
    
    public var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

@MainActor
public final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    public var panel: NSPanel?
    private var queueManager = QueueManager()
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the custom NSPanel with modern flat look
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 1060, height: 680),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView, .utilityWindow, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        self.panel = panel
        panel.delegate = self
        panel.isFloatingPanel = false
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isMovableByWindowBackground = true
        panel.minSize = NSSize(width: 1060, height: 680)
        
        // Setup background visual effect view for premium glassmorphism/blur
        let visualEffect = NSVisualEffectView()
        visualEffect.blendingMode = .behindWindow
        visualEffect.state = .active
        visualEffect.material = .hudWindow
        panel.contentView = visualEffect
        
        // Host our main application view
        let mainView = MainAppView(queueManager: queueManager)
        let hostingView = NSHostingView(rootView: mainView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        visualEffect.addSubview(hostingView)
        
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: visualEffect.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: visualEffect.bottomAnchor),
            hostingView.leadingAnchor.constraint(equalTo: visualEffect.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: visualEffect.trailingAnchor)
        ])
        
        panel.center()
        panel.makeKeyAndOrderFront(nil)
        panel.orderFrontRegardless()
        
        // Bring app to the foreground
        NSApp.activate(ignoringOtherApps: true)
    }
    
    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

public struct MainAppView: View {
    var queueManager: QueueManager
    @State private var selection: NavigationTarget = .assistant
    
    public init(queueManager: QueueManager) {
        self.queueManager = queueManager
    }
    
    public var body: some View {
        ZStack {
            ReMasteraDesign.background.ignoresSafeArea()
            
            HStack(spacing: 0) {
                SidebarView(selection: $selection)
                
                Rectangle()
                    .fill(ReMasteraDesign.borderSubtle)
                    .frame(width: 1)
                
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
}
