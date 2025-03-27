import SwiftUI

struct SlideTransition: ViewModifier {
    let tabItem: TabItem
    let selectedTab: TabItem
    let previousTab: TabItem?
    
    func body(content: Content) -> some View {
        content
            .transition(.asymmetric(
                insertion: insertionTransition,
                removal: removalTransition
            ))
    }
    
    private var insertionTransition: AnyTransition {
        guard let previousTab = previousTab else { return .opacity }
        let direction = getTransitionDirection(from: previousTab, to: selectedTab)
        return .offset(x: direction == .right ? 100 : -100)
            .combined(with: .opacity)
            .combined(with: .scale(scale: 0.95))
    }
    
    private var removalTransition: AnyTransition {
        guard let previousTab = previousTab else { return .opacity }
        let direction = getTransitionDirection(from: previousTab, to: selectedTab)
        return .offset(x: direction == .right ? -100 : 100)
            .combined(with: .opacity)
            .combined(with: .scale(scale: 0.95))
    }
    
    private enum TransitionDirection {
        case left, right
    }
    
    private func getTransitionDirection(from: TabItem, to: TabItem) -> TransitionDirection {
        let tabOrder: [TabItem] = [.home, .explore, .navigate, .tickets]
        guard let fromIndex = tabOrder.firstIndex(of: from),
              let toIndex = tabOrder.firstIndex(of: to) else {
            return .right
        }
        return fromIndex < toIndex ? .right : .left
    }
}

extension View {
    func smartTransition(for tabItem: TabItem, selectedTab: TabItem, previousTab: TabItem?) -> some View {
        modifier(SlideTransition(tabItem: tabItem, selectedTab: selectedTab, previousTab: previousTab))
    }
} 