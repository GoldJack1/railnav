import SwiftUI
import OSLog

class NavigateViewModel: ObservableObject {
    let darwinService: DarwinService
    private let logger = Logger(subsystem: "com.railnav", category: "NavigateViewModel")
    
    @Published var departureBoard: DepartureBoard?
    @Published var isLoading = false
    @Published var error: Error?
    @Published var currentStation: Station?
    @Published var searchQuery = ""
    @Published var searchResults: [Station] = []
    @Published var isSearching = false
    
    init(darwinService: DarwinService) {
        self.darwinService = darwinService
        logger.info("NavigateViewModel initialized")
    }
    
    func searchStations() {
        guard !searchQuery.isEmpty else {
            searchResults = []
            return
        }
        
        searchResults = StationData.search(searchQuery)
    }
    
    func selectStation(_ station: Station) {
        self.currentStation = station
        self.searchQuery = ""
        self.searchResults = []
        
        Task {
            await fetchDepartures(for: station.id)
        }
    }
    
    @MainActor
    func fetchDepartures(for stationCRS: String? = nil) async {
        logger.info("Starting to fetch departures for \(stationCRS ?? self.currentStation?.id ?? "LDS")")
        self.isLoading = true
        self.error = nil
        
        do {
            let crs = stationCRS ?? self.currentStation?.id ?? "LDS"
            logger.info("Making request to DarwinService...")
            self.departureBoard = try await darwinService.getDepartureBoard(for: crs)
            self.currentStation = self.departureBoard?.station
            
            logger.info("Successfully fetched departures")
            if let count = self.departureBoard?.services.count {
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
        
        self.isLoading = false
    }
    
    func refreshData() {
        logger.info("Manual refresh triggered")
        Task {
            await self.fetchDepartures()
        }
    }
} 