import SwiftUI

struct HomeDetailView: View {
    @Binding var selectedTab: TabItem
    
    var body: some View {
        VStack(spacing: 20) {
            // Add your detail view content here
            Text("Detail View Content")
                .font(.title)
                .padding(.top, 20)
            
            // Add more content as needed
            ForEach(0..<5) { index in
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.1))
                    .frame(height: 100)
                    .overlay(
                        Text("Content Item \(index + 1)")
                            .foregroundColor(.blue)
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
}

struct HomeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeDetailView(selectedTab: .constant(.home))
        }
    }
} 