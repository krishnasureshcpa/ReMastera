import SwiftUI

public struct ReMasteraApp: App {
    @State private var queueManager = QueueManager()
    @State private var selection: NavigationTarget = .dashboard
    
    public init() {}
    
    public var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarView(selection: $selection)
            } detail: {
                switch selection {
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
            .navigationTitle("ReMastera")
            .frame(minWidth: 960, minHeight: 640)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
