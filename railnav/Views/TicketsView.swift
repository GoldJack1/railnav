import SwiftUI

struct TicketsView: View {
    @Binding var selectedTab: TabItem
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Active ticket
                VStack(alignment: .leading, spacing: 8) {
                    Text("Active Ticket")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.green.opacity(0.1))
                        .frame(height: 180)
                        .overlay(
                            VStack(spacing: 12) {
                                Image(systemName: "ticket.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.green)
                                Text("London → Paris")
                                    .font(.title2)
                                    .foregroundColor(.green)
                                Text("Departing in 2 hours")
                                    .font(.subheadline)
                                    .foregroundColor(.green.opacity(0.8))
                            }
                        )
                        .padding(.horizontal)
                }
                .padding(.vertical, 10)
                
                // Upcoming tickets
                VStack(alignment: .leading, spacing: 8) {
                    Text("Upcoming Tickets")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(0..<3) { index in
                                VStack(alignment: .leading, spacing: 8) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.green.opacity(0.1))
                                        .frame(width: 200, height: 120)
                                        .overlay(
                                            VStack(spacing: 8) {
                                                Image(systemName: "train.side.front.car")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(.green)
                                                Text("Trip \(index + 1)")
                                                    .font(.headline)
                                                    .foregroundColor(.green)
                                            }
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 10)
                
                // Past tickets
                VStack(alignment: .leading, spacing: 8) {
                    Text("Past Tickets")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(0..<3) { index in
                        HStack {
                            Image(systemName: "ticket")
                                .font(.system(size: 20))
                                .foregroundColor(.green)
                            Text("Past Trip \(index + 1)")
                                .font(.subheadline)
                            Spacer()
                            Text("12/\(index + 1)/2024")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 10)
                .padding(.bottom, 100) // Add padding for navigation bar
            }
        }
        .scrollIndicators(.hidden)
    }
}

struct TicketsView_Previews: PreviewProvider {
    static var previews: some View {
        TicketsView(selectedTab: .constant(.tickets))
    }
} 