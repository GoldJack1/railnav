import SwiftUI
import OSLog

struct NavigateView: View {
    @StateObject private var viewModel: NavigateViewModel
    @Binding var selectedTab: TabItem
    @FocusState private var isSearchFocused: Bool
    
    init(selectedTab: Binding<TabItem>) {
        self._selectedTab = selectedTab
        self._viewModel = StateObject(wrappedValue: NavigateViewModel(darwinService: DarwinService(apiKey: Config.openLDBWSApiKey)))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 16) {
                    // Search Bar with Button
                    HStack(spacing: 12) {
                        HStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            
                            TextField("Search stations...", text: $viewModel.searchQuery)
                                .textFieldStyle(PlainTextFieldStyle())
                                .focused($isSearchFocused)
                                .submitLabel(.search)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                                .onChange(of: viewModel.searchQuery) { _ in
                                    viewModel.searchStations()
                                }
                                .onSubmit {
                                    if let firstResult = viewModel.searchResults.first {
                                        viewModel.selectStation(firstResult)
                                        isSearchFocused = false
                                    }
                                }
                            
                            if !viewModel.searchQuery.isEmpty {
                                Button(action: {
                                    viewModel.searchQuery = ""
                                    viewModel.searchResults = []
                                    isSearchFocused = false
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        
                        // Search Button
                        Button(action: {
                            if let firstResult = viewModel.searchResults.first {
                                viewModel.selectStation(firstResult)
                                isSearchFocused = false
                            }
                        }) {
                            Text("Search")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    !viewModel.searchResults.isEmpty ?
                                    Color.accentColor :
                                    Color.gray
                                )
                                .cornerRadius(12)
                        }
                        .disabled(viewModel.searchResults.isEmpty)
                    }
                    .padding(.horizontal)
                    
                    if !viewModel.searchResults.isEmpty {
                        // Search Results
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.searchResults) { station in
                                    Button(action: {
                                        viewModel.selectStation(station)
                                        isSearchFocused = false
                                    }) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(station.name)
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                                Text(station.id)
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.secondary)
                                        }
                                        .padding()
                                        .background(Color(UIColor.secondarySystemBackground))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else if let board = viewModel.departureBoard {
                        VStack(alignment: .leading, spacing: 20) {
                            // Station Info with Refresh Button
                            HStack(alignment: .center) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(board.station.name)
                                        .font(.system(size: 32, weight: .bold))
                                    Text("Live Departures")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    viewModel.refreshData()
                                }) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.title2)
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .padding(.horizontal)
                            
                            // Departures List
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(board.services) { service in
                                        NavigationLink {
                                            ServiceDetailView(service: service, darwinService: viewModel.darwinService)
                                        } label: {
                                            ModernDepartureRow(service: service)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    } else if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.5)
                        Spacer()
                    } else if let error = viewModel.error {
                        ErrorView(error: error, onRetry: { viewModel.refreshData() })
                    }
                }
                .padding(.top, 70)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await viewModel.fetchDepartures()
        }
    }
}

struct ModernDepartureRow: View {
    let service: TrainService
    
    private var delayStatus: DelayStatus {
        if service.isCancelled {
            return .cancelled
        }
        
        guard let scheduled = service.scheduledDeparture,
              let estimated = service.estimatedDeparture else {
            return .onTime
        }
        
        let delayInMinutes = Calendar.current.dateComponents([.minute], 
            from: scheduled, to: estimated).minute ?? 0
        
        if delayInMinutes <= 0 {
            return .onTime
        } else if delayInMinutes < 10 {
            return .delayed
        } else {
            return .severeDelay
        }
    }
    
    private var statusColor: Color {
        switch delayStatus {
        case .onTime:
            return .green
        case .delayed:
            return .orange
        case .severeDelay, .cancelled:
            return .red
        }
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                // First row: Destination
                Text(service.destination.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                // Second row: Operator
                Text(service.operatingCompany)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Third row: Platform
                if let platform = service.platform {
                    Text("Platform \(platform)")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            // Time display
            if service.isCancelled {
                Text("CANCELLED")
                    .font(.system(.headline, design: .monospaced))
                    .foregroundColor(statusColor)
            } else {
                VStack(alignment: .trailing, spacing: 0) {
                    // Scheduled time (gray if delayed)
                    Text(formatTime(service.scheduledDeparture))
                        .foregroundColor(service.isDelayed ? .secondary : statusColor)
                        .strikethrough(service.isDelayed)
                    
                    // Actual time if delayed
                    if service.isDelayed, let estimated = service.estimatedDeparture {
                        Text(formatTime(estimated))
                            .foregroundColor(statusColor)
                    }
                }
                .font(.system(.headline, design: .monospaced))
            }
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(.body, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func formatTime(_ date: Date?) -> String {
        guard let date = date else { return "TBA" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

private enum DelayStatus {
    case onTime
    case delayed
    case severeDelay
    case cancelled
}

struct ErrorView: View {
    let error: Error
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            Text("Error loading departures")
                .font(.headline)
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            Button("Try Again", action: onRetry)
                .buttonStyle(.bordered)
        }
        .padding()
    }
}

#Preview {
    NavigateView(selectedTab: .constant(.navigate))
} 
