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
        case .assistant: return "Remy"
        case .dashboard: return "Dashboard"
        case .queue: return "Queue"
        case .dependencies: return "Dependencies"
        case .privacy: return "Privacy"
        case .settings: return "Settings"
        }
    }
    
    public var iconName: String {
        switch self {
        case .assistant: return "sparkles"
        case .dashboard: return "square.grid.2x2"
        case .queue: return "film.stack"
        case .dependencies: return "cpu"
        case .privacy: return "lock.shield"
        case .settings: return "gearshape"
        }
    }
    
    public var shortLabel: String {
        switch self {
        case .assistant: return "AST"
        case .dashboard: return "DSH"
        case .queue: return "QUE"
        case .dependencies: return "DEP"
        case .privacy: return "PRI"
        case .settings: return "SET"
        }
    }
}

public struct SidebarView: View {
    @Binding public var selection: NavigationTarget
    @State private var hoveredTarget: NavigationTarget?
    
    public init(selection: Binding<NavigationTarget>) {
        self._selection = selection
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Brand header
            VStack(spacing: ReMasteraDesign.space4) {
                Text("Re")
                    .font(ReMasteraType.display(28))
                    .foregroundStyle(ReMasteraDesign.heading)
                +
                Text("Mastera")
                    .font(ReMasteraType.display(28))
                    .foregroundStyle(ReMasteraDesign.brand)
            }
            .padding(.vertical, ReMasteraDesign.space16)
            .frame(maxWidth: .infinity)
            
            SectionDivider()
            
            // Navigation items
            VStack(spacing: ReMasteraDesign.space4) {
                ForEach(NavigationTarget.allCases) { target in
                    sidebarItem(target)
                }
            }
            .padding(.horizontal, ReMasteraDesign.space8)
            .padding(.vertical, ReMasteraDesign.space12)
            
            Spacer()
            
            SectionDivider()
            
            // Bottom status
            VStack(spacing: ReMasteraDesign.space8) {
                HStack(spacing: ReMasteraDesign.space4) {
                    Circle()
                        .fill(ReMasteraDesign.success)
                        .frame(width: 5, height: 5)
                    Text("ALL LOCAL")
                        .font(ReMasteraType.caption(9))
                        .tracking(1.5)
                        .foregroundStyle(ReMasteraDesign.fgDisabled)
                }
                
                Text("v1.0.0")
                    .font(ReMasteraType.caption(9))
                    .foregroundStyle(ReMasteraDesign.fgDisabled)
            }
            .padding(.vertical, ReMasteraDesign.space12)
        }
        .background(ReMasteraDesign.surface)
        .frame(minWidth: 180, maxWidth: 200)
    }
    
    @ViewBuilder
    private func sidebarItem(_ target: NavigationTarget) -> some View {
        let isSelected = selection == target
        let isHovered = hoveredTarget == target
        
        Button {
            selection = target
        } label: {
            HStack(spacing: ReMasteraDesign.space8) {
                // Icon with glow when selected
                Image(systemName: target.iconName)
                    .font(.system(size: 14))
                    .foregroundStyle(isSelected ? ReMasteraDesign.brand : (isHovered ? ReMasteraDesign.heading : ReMasteraDesign.body))
                    .shadow(color: isSelected ? ReMasteraDesign.brand.opacity(0.5) : .clear, radius: 4)
                    .frame(width: 20)
                
                Text(target.displayName)
                    .font(ReMasteraType.label(12))
                    .foregroundStyle(isSelected ? ReMasteraDesign.brand : (isHovered ? ReMasteraDesign.heading : ReMasteraDesign.body))
                
                Spacer()
                
                // Terminal-style short label
                if isSelected {
                    Text(target.shortLabel)
                        .font(ReMasteraType.caption(9))
                        .tracking(1)
                        .foregroundStyle(ReMasteraDesign.brandMedium)
                }
            }
            .padding(.horizontal, ReMasteraDesign.space8)
            .padding(.vertical, ReMasteraDesign.space8)
            .background(
                isSelected ? ReMasteraDesign.brandSofter :
                (isHovered ? ReMasteraDesign.surfaceElevated : .clear)
            )
            .clipShape(RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase))
            .overlay(
                RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase)
                    .stroke(isSelected ? ReMasteraDesign.borderSubtle : .clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.1)) { hoveredTarget = hovering ? target : nil }
        }
    }
}
