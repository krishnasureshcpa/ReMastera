import SwiftUI

public enum NavigationTarget: String, CaseIterable, Identifiable {
    case assistant
    case dashboard
    case queue
    case dependencies
    case privacy
    case settings
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .assistant: return "AI Assistant"
        case .dashboard: return "Dashboard"
        case .queue: return "Processing Queue"
        case .dependencies: return "Dependency Manager"
        case .privacy: return "Privacy Assurance"
        case .settings: return "Settings"
        }
    }
    
    public var iconName: String {
        switch self {
        case .assistant: return "sparkles"
        case .dashboard: return "square.grid.2x2"
        case .queue: return "film.stack"
        case .dependencies: return "cpu"
        case .privacy: return "shield.checkered"
        case .settings: return "gearshape"
        }
    }
}

public struct SidebarView: View {
    @Binding public var selection: NavigationTarget
    
    public init(selection: Binding<NavigationTarget>) {
        self._selection = selection
    }
    
    public var body: some View {
        List(NavigationTarget.allCases, selection: $selection) { target in
            NavigationLink(value: target) {
                Label(target.displayName, systemImage: target.iconName)
                    .font(.body)
            }
            .padding(.vertical, 4)
        }
        .listStyle(.sidebar)
        .frame(minWidth: 200)
    }
}
