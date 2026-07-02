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
        case .dashboard: return "square.grid.2x2.fill"
        case .queue: return "film.stack.fill"
        case .dependencies: return "cpu"
        case .privacy: return "lock.shield.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

public struct SidebarView: View {
    @Binding public var selection: NavigationTarget
    @State private var hoveredTarget: NavigationTarget?
    @State private var pressedTarget: NavigationTarget?
    
    public init(selection: Binding<NavigationTarget>) {
        self._selection = selection
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Friendly Gamified Header
            VStack(spacing: ReMasteraDesign.space4) {
                HStack(spacing: 0) {
                    Text("Re")
                        .font(ReMasteraType.display(24))
                        .foregroundStyle(ReMasteraDesign.heading)
                    Text("Mastera")
                        .font(ReMasteraType.display(24))
                        .foregroundStyle(ReMasteraDesign.brand)
                }
            }
            .padding(.top, 24)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity)
            
            SectionDivider()
                .padding(.horizontal, ReMasteraDesign.space16)
            
            // Navigation items
            VStack(spacing: ReMasteraDesign.space8) {
                ForEach(NavigationTarget.allCases) { target in
                    sidebarItem(target)
                }
            }
            .padding(.horizontal, ReMasteraDesign.space12)
            .padding(.vertical, ReMasteraDesign.space16)
            
            Spacer()
            
            // Bottom status
            VStack(spacing: ReMasteraDesign.space8) {
                HStack(spacing: ReMasteraDesign.space8) {
                    Circle()
                        .fill(ReMasteraDesign.primary)
                        .frame(width: 8, height: 8)
                        .shadow(color: ReMasteraDesign.primary.opacity(0.4), radius: 4)
                    Text("All Local")
                        .font(ReMasteraType.label())
                        .foregroundStyle(ReMasteraDesign.body)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(ReMasteraDesign.surfaceElevated)
                .clipShape(Capsule())
            }
            .padding(.bottom, 24)
        }
        // Native Mac Translucency
        .background(.ultraThinMaterial)
        .frame(minWidth: 200, maxWidth: 220)
    }
    
    @ViewBuilder
    private func sidebarItem(_ target: NavigationTarget) -> some View {
        let isSelected = selection == target
        let isHovered = hoveredTarget == target
        let isPressed = pressedTarget == target
        
        Button {
            withAnimation(ReMasteraDesign.springBouncy) {
                selection = target
            }
        } label: {
            HStack(spacing: ReMasteraDesign.space12) {
                Image(systemName: target.iconName)
                    .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                    .foregroundStyle(isSelected ? ReMasteraDesign.brand : (isHovered ? ReMasteraDesign.heading : ReMasteraDesign.body))
                    .frame(width: 24)
                
                Text(target.displayName)
                    .font(ReMasteraType.label(14))
                    .foregroundStyle(isSelected ? ReMasteraDesign.heading : (isHovered ? ReMasteraDesign.heading : ReMasteraDesign.body))
                
                Spacer()
            }
            .padding(.horizontal, ReMasteraDesign.space12)
            .padding(.vertical, 10)
            .background(
                isSelected ? ReMasteraDesign.brand.opacity(0.15) :
                (isHovered ? ReMasteraDesign.surfaceElevated : .clear)
            )
            .clipShape(RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: ReMasteraDesign.radiusBase, style: .continuous)
                    .stroke(isSelected ? ReMasteraDesign.brand.opacity(0.3) : .clear, lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(ReMasteraDesign.springBouncy, value: isSelected)
            .animation(ReMasteraDesign.springBouncy, value: isHovered)
            .animation(ReMasteraDesign.springBouncy, value: isPressed)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            hoveredTarget = hovering ? target : nil
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressedTarget = target }
                .onEnded { _ in pressedTarget = nil }
        )
    }
}
