import SwiftUI
import OSLog

class NavigateViewModel: ObservableObject {
    let darwinService: DarwinService
    private let stationCode = "DEW"
    private let logger = Logger(subsystem: "com.railnav", category: "NavigateViewModel")
    
    @Published var departureBoard: DepartureBoard?
    @Published var isLoading = false
    @Published var error: Error?
    
    init(darwinService: DarwinService) {
        self.darwinService = darwinService
        logger.info("NavigateViewModel initialized")
    }
    
    @MainActor
    func fetchDepartures() async {
        logger.info("Starting to fetch departures for \(self.stationCode)")
        isLoading = true
        error = nil
        
        do {
            logger.info("Making request to DarwinService...")
            departureBoard = try await darwinService.getDepartureBoard(for: self.stationCode)
            logger.info("Successfully fetched departures")
            if let count = departureBoard?.services.count {
                logger.info("Received \(count) services")
            } else {
                logger.warning("Departure board is empty")
            }
        } catch {
            self.error = error
            logger.error("Failed to fetch departures: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                logger.error("Error domain: \(nsError.domain), code: \(nsError.code)")
                if let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? Error {
                    logger.error("Underlying error: \(underlyingError)")
                }
            }
        }
        
        isLoading = false
    }
    
    func refreshData() {
        logger.info("Manual refresh triggered")
        Task {
            await fetchDepartures()
        }
    }
}

struct NavigateView: View {
    @StateObject private var viewModel: NavigateViewModel
    @Binding var selectedTab: TabItem
    
    init(selectedTab: Binding<TabItem>) {
        self._selectedTab = selectedTab
        self._viewModel = StateObject(wrappedValue: NavigateViewModel(darwinService: DarwinService(apiKey: Config.openLDBWSApiKey)))
    }
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView("Loading departures...")
            } else if let error = viewModel.error {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text("Error loading departures")
                        .font(.headline)
                    Text(error.localizedDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Try Again") {
                        viewModel.refreshData()
                    }
                    .buttonStyle(.bordered)
                }
            } else if let board = viewModel.departureBoard {
                VStack {
                    HStack {
                        Text("Departures from \(board.station.name)")
                            .font(.title2)
                            .bold()
                        Spacer()
                        Button {
                            viewModel.refreshData()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                    .padding(.horizontal)
                    
                    List {
                        ForEach(board.services, id: \.id) { service in
                            NavigationLink {
                                ServiceDetailView(service: service, darwinService: viewModel.darwinService)
                            } label: {
                                DepartureRow(service: service)
                            }
                        }
                    }
                    .refreshable {
                        await viewModel.fetchDepartures()
                    }
                }
            } else {
                Text("No departures found")
                    .foregroundColor(.secondary)
            }
        }
        .task {
            await viewModel.fetchDepartures()
        }
    }
}

struct DepartureRow: View {
    let service: TrainService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(service.destination.name)
                    .font(.headline)
                Spacer()
                if let platform = service.platform {
                    Text("Platform \(platform)")
                        .font(.subheadline)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            
            HStack {
                Text(service.operatingCompany)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                if service.isCancelled {
                    Text("Cancelled")
                        .foregroundColor(.red)
                        .font(.system(.subheadline, design: .monospaced))
                } else {
                    HStack(spacing: 4) {
                        Text(formatTime(service.scheduledDeparture))
                            .strikethrough(service.isDelayed)
                        if service.isDelayed {
                            Text(formatTime(service.estimatedDeparture))
                                .foregroundColor(.red)
                        }
                    }
                    .font(.system(.subheadline, design: .monospaced))
                }
            }
            
            if let delayReason = service.delayReason {
                Text(delayReason)
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            if let cancelReason = service.cancelReason {
                Text(cancelReason)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatTime(_ date: Date?) -> String {
        guard let date = date else { return "TBA" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    NavigateView(selectedTab: .constant(.navigate))
} 