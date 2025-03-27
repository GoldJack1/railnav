import SwiftUI

struct CustomHeader: View {
    let title: String
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 1, green: 0.824, blue: 0.169), location: 0.0),
                    .init(color: .white, location: 1.0)
                ]),
                startPoint: .bottomLeading,
                endPoint: .topTrailing
            )
            .edgesIgnoringSafeArea(.top)
            
            VStack(spacing: 0) {
                // Main header content
                HStack(alignment: .center) {
                    Text(title)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .id("header_title_\(title)") // Unique ID for each title to trigger transition
                    
                    Spacer()
                    
                    // Profile image
                    Circle()
                        .fill(.black)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
        }
        .frame(height: 60)
        .background(
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 1, green: 0.824, blue: 0.169), location: 0.0),
                    .init(color: .white, location: 1.0)
                ]),
                startPoint: .bottomLeading,
                endPoint: .topTrailing
            )
        )
    }
}

struct CustomHeader_Previews: PreviewProvider {
    static var previews: some View {
        CustomHeader(title: "Home")
    }
} 
