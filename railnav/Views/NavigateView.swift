import SwiftUI

struct NavigateView: View {
    @Binding var selectedTab: TabItem
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    Text("Search destinations")
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.vertical, 10)
                
                // Recent destinations
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent Routes")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(0..<5) { index in
                                VStack(alignment: .leading, spacing: 8) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.orange.opacity(0.1))
                                        .frame(width: 150, height: 100)
                                        .overlay(
                                            Image(systemName: "train.side.front.car")
                                                .font(.system(size: 30))
                                                .foregroundColor(.orange)
                                        )
                                    Text("Route \(index + 1)")
                                        .font(.subheadline)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 10)
                
                // Popular destinations
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(0..<4) { index in
                        VStack(alignment: .leading, spacing: 8) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.orange.opacity(0.1))
                                .overlay(
                                    VStack(spacing: 8) {
                                        Image(systemName: "location.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.orange)
                                        Text("Popular \(index + 1)")
                                            .font(.headline)
                                            .foregroundColor(.orange)
                                    }
                                )
                                .aspectRatio(1, contentMode: .fill)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 100) // Add padding for navigation bar
            }
        }
        .scrollIndicators(.hidden)
    }
}

struct NavigateView_Previews: PreviewProvider {
    static var previews: some View {
        NavigateView(selectedTab: .constant(.navigate))
    }
} 