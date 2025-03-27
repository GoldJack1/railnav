import SwiftUI

@main
struct RailNavApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

struct MainView: View {
    @State private var selectedTab: TabItem = .home
    @State private var previousTab: TabItem? = nil
    @State private var isShowingDetail = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                // Content area with transitions
                if !isShowingDetail {
                    // Tab content
                    switch selectedTab {
                    case .home:
                        HomeView(selectedTab: $selectedTab, isShowingDetail: $isShowingDetail)
                            .smartTransition(for: .home, selectedTab: selectedTab, previousTab: previousTab)
                    case .explore:
                        ExploreView(selectedTab: $selectedTab)
                            .smartTransition(for: .explore, selectedTab: selectedTab, previousTab: previousTab)
                    case .navigate:
                        NavigateView(selectedTab: $selectedTab)
                            .smartTransition(for: .navigate, selectedTab: selectedTab, previousTab: previousTab)
                    case .tickets:
                        TicketsView(selectedTab: $selectedTab)
                            .smartTransition(for: .tickets, selectedTab: selectedTab, previousTab: previousTab)
                    @unknown default:
                        EmptyView()
                    }
                } else {
                    // Detail view
                    HomeDetailView(selectedTab: $selectedTab)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
                
                // Fixed header area
                VStack(spacing: 0) {
                    CustomHeader(title: isShowingDetail ? "Detail" : selectedTab.rawValue)
                    Spacer()
                }
                .zIndex(1)
                
                // Navigation bar overlay
                VStack {
                    Spacer()
                    NavigationBar(
                        selectedTab: $selectedTab,
                        showBackButton: isShowingDetail,
                        onBackTap: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                isShowingDetail = false
                            }
                        }
                    )
                }
                .ignoresSafeArea()
            }
            .onChange(of: selectedTab) { newValue in
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.2)) {
                    previousTab = selectedTab
                    selectedTab = newValue
                }
            }
        }
    }
}

// Preference key to communicate detail view state
struct DetailViewActiveKey: PreferenceKey {
    static var defaultValue: Bool = false
    
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}

#Preview {
    MainView()
} 
