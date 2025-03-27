import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: TabItem
    @Binding var isShowingDetail: Bool
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                // Spacer for header
                Color.clear
                    .frame(height: 60)
                
                // Action button section
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        isShowingDetail = true
                    }
                }) {
                    Text("Show Detail View")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Content grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(0..<6) { index in
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.blue.opacity(0.1))
                            .overlay(
                                VStack(spacing: 8) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.blue)
                                    Text("Item \(index + 1)")
                                        .font(.headline)
                                        .foregroundColor(.blue)
                                }
                            )
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
                .padding(.horizontal)
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 100)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView(
                selectedTab: .constant(.home),
                isShowingDetail: .constant(false)
            )
        }
    }
} 
