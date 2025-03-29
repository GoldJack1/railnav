import Foundation
import OSLog
import UserNotifications
import Combine

protocol DarwinServiceDelegate: AnyObject {
    func darwinService(_ service: DarwinService, didUpdateBoard board: DepartureBoard)
    func darwinService(_ service: DarwinService, didEncounterError error: Error)
}

class DarwinService {
    private let client: OpenLDBWSClient
    private let logger = Logger(subsystem: "com.railnav", category: "DarwinService")
    private var currentStation: String?
    private var updateTimer: Timer?
    
    weak var delegate: DarwinServiceDelegate?
    
    @Published private(set) var currentBoard: DepartureBoard?
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    init(apiKey: String) {
        self.client = OpenLDBWSClient(accessToken: apiKey)
    }
    
    func startMonitoring(station: String) {
        stopMonitoring()
        currentStation = station
        
        // Initial fetch
        Task {
            await fetchDepartureBoard()
        }
        
        // Set up timer for periodic updates (every 30 seconds)
        updateTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            Task {
                await self?.fetchDepartureBoard()
            }
        }
    }
    
    func stopMonitoring() {
        updateTimer?.invalidate()
        updateTimer = nil
        currentStation = nil
    }
    
    func refreshBoard() {
        Task {
            await fetchDepartureBoard()
        }
    }
    
    @MainActor
    private func fetchDepartureBoard() async {
        guard let station = currentStation else { return }
        
        isLoading = true
        error = nil
        
        do {
            let domainBoard = try await client.getDepartureBoard(for: station)
            let board = domainBoard.toAppModel()
            currentBoard = board
            delegate?.darwinService(self, didUpdateBoard: board)
            
            // Check for services that need notifications
            checkForServiceUpdates(in: board)
            
        } catch {
            self.error = error
            delegate?.darwinService(self, didEncounterError: error)
            logger.error("Failed to fetch departure board: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func getDepartureBoard(for station: String) async throws -> DepartureBoard {
        logger.info("Fetching departure board for station: \(station)")
        do {
            let domainBoard = try await client.getDepartureBoard(for: station)
            let board = domainBoard.toAppModel()
            logger.info("Successfully fetched board with \(board.services.count) services")
            return board
        } catch {
            logger.error("Failed to fetch departure board: \(error.localizedDescription)")
            throw error
        }
    }
    
    func getServiceDetails(serviceID: String) async throws -> TrainService {
        logger.info("Getting service details for ID: \(serviceID)")
        do {
            let domainService = try await client.getServiceDetails(serviceID: serviceID)
            logger.info("Successfully fetched domain service details")
            let appService = domainService.toAppModel()
            logger.info("Converted to app model - Destination: \(appService.destination.name)")
            logger.info("Service has \(appService.callingPoints.count) calling points")
            logger.info("Service has \(appService.coaches?.count ?? 0) coaches")
            logger.info("Service has \(appService.serviceMessages.count) messages")
            return appService
        } catch {
            logger.error("Failed to get service details: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                logger.error("Error domain: \(nsError.domain), code: \(nsError.code)")
                if let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? Error {
                    logger.error("Underlying error: \(underlyingError)")
                }
            }
            throw error
        }
    }
    
    // MARK: - Convenience Methods
    
    func findService(by id: String) -> TrainService? {
        return currentBoard?.services.first { $0.id == id }
    }
    
    func findNextDeparture(to destination: String) -> TrainService? {
        return currentBoard?.services.first { $0.destination.name.contains(destination) }
    }
    
    func hasDisruptions() -> Bool {
        return currentBoard?.services.contains { $0.isDelayed || $0.isCancelled } ?? false
    }
    
    // MARK: - Notifications
    
    private func requestNotificationPermission() async -> Bool {
        do {
            let center = UNUserNotificationCenter.current()
            let options: UNAuthorizationOptions = [.alert, .sound]
            let granted = try await center.requestAuthorization(options: options)
            return granted
        } catch {
            logger.error("Failed to request notification permission: \(error.localizedDescription)")
            return false
        }
    }
    
    private func scheduleNotification(for service: TrainService) {
        let content = UNMutableNotificationContent()
        content.title = "Train Update"
        content.body = "\(service.operatingCompany) service to \(service.destination.name) has been \(service.isDelayed ? "delayed" : "cancelled")"
        
        // Schedule for immediate delivery
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // Create the request
        let request = UNNotificationRequest(
            identifier: service.id,
            content: content,
            trigger: trigger
        )
        
        // Schedule the request
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                self.logger.error("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
    
    private func checkForServiceUpdates(in board: DepartureBoard) {
        Task {
            let hasPermission = await requestNotificationPermission()
            guard hasPermission else { return }
            
            for service in board.services where service.isDelayed || service.isCancelled {
                scheduleNotification(for: service)
            }
        }
    }
} 