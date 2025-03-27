import SwiftUI

enum TabItem: String, CaseIterable {
    case back = "Back"
    case home = "Home"
    case navigate = "Navigate"
    case tickets = "Tickets"
    case explore = "Explore"
    
    var iconName: String {
        switch self {
        case .back:
            return "chevron.left"
        case .home:
            return "house"
        case .navigate:
            return "location"
        case .tickets:
            return "ticket"
        case .explore:
            return "circle.grid.2x1"
        }
    }
    
    var selectedIconName: String {
        switch self {
        case .back:
            return "chevron.left"
        case .home:
            return "house.fill"
        case .navigate:
            return "location.fill"
        case .tickets:
            return "ticket.fill"
        case .explore:
            return "circle.grid.2x1.fill"
        }
    }
    
    var isMainTab: Bool {
        self != .back
    }
}

struct NavigationBar: View {
    @Binding var selectedTab: TabItem
    var showBackButton: Bool = false
    var onBackTap: (() -> Void)? = nil
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Gradient background that sits at bottom
            LinearGradient(
                gradient: Gradient(colors: [.white, .white.opacity(0)]),
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: 100)
            
            // Navigation bar content
            VStack {
                Spacer()
                
                ZStack {
                    // Back button
                    if let onBackTap = onBackTap {
                        Button(action: onBackTap) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(width: 44, height: 44)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                        .offset(x: showBackButton ? 0 : -100)
                        .opacity(showBackButton ? 1 : 0)
                    }
                    
                    // Navigation pill
                    HStack(spacing: 0) {
                        ForEach([TabItem.home, .navigate, .tickets, .explore], id: \.self) { tab in
                            Button(action: {
                                if selectedTab != tab {
                                    selectedTab = tab
                                }
                            }) {
                                Image(systemName: selectedTab == tab ? tab.selectedIconName : tab.iconName)
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(selectedTab == tab ? .black : .gray)
                                    .frame(width: 50, height: 44)
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    .frame(width: 220, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                    )
                }
                .padding(.bottom, 34)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: showBackButton)
    }
}

struct NavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            // Sample background to show gradient effect
            Color.blue.opacity(0.1)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                NavigationBar(selectedTab: .constant(.home), showBackButton: true)
            }
        }
    }
} 