import SwiftUI

struct ExploreView: View {
    @Binding var selectedTab: TabItem
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Featured section
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.purple.opacity(0.1))
                    .frame(height: 200)
                    .overlay(
                        VStack {
                            Image(systemName: "map")
                                .font(.system(size: 40))
                                .foregroundColor(.purple)
                            Text("Featured Destinations")
                                .font(.title2)
                                .foregroundColor(.purple)
                        }
                    )
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                
                // Explore grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(0..<4) { index in
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.purple.opacity(0.1))
                            .overlay(
                                VStack(spacing: 8) {
                                    Image(systemName: "location.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.purple)
                                    Text("Location \(index + 1)")
                                        .font(.headline)
                                        .foregroundColor(.purple)
                                }
                            )
                            .aspectRatio(1, contentMode: .fill)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 100) // Add padding for navigation bar
            }
        }
        .scrollIndicators(.hidden)
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView(selectedTab: .constant(.explore))
    }
} 