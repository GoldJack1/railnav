import SwiftUI
import OSLog

class ServiceDetailViewModel: ObservableObject {
    private let darwinService: DarwinService
    private let logger = Logger(subsystem: "com.railnav", category: "ServiceDetailViewModel")
    
    @Published var detailedService: TrainService?
    @Published var isLoading = false
    @Published var error: Error?
    
    init(darwinService: DarwinService) {
        self.darwinService = darwinService
    }
    
    @MainActor
    func fetchServiceDetails(for serviceId: String) async {
        logger.info("Fetching service details for ID: \(serviceId)")
        isLoading = true
        error = nil
        
        do {
            detailedService = try await darwinService.getServiceDetails(serviceID: serviceId)
            logger.info("Successfully fetched service details")
        } catch {
            self.error = error
            logger.error("Failed to fetch service details: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}

struct ServiceDetailView: View {
    let service: TrainService
    let darwinService: DarwinService
    @StateObject private var viewModel: ServiceDetailViewModel
    private let logger = Logger(subsystem: "com.railnav", category: "ServiceDetailView")
    
    private var allStations: [CallingPoint] {
        let displayService = viewModel.detailedService ?? service
        
        // Create a calling point for the current station
        let currentStationPoint = CallingPoint(
            station: displayService.currentStation,
            scheduledTime: displayService.scheduledDeparture ?? Date(),
            estimatedTime: displayService.estimatedDeparture,
            actualTime: displayService.actualDeparture,
            platform: displayService.platform,
            status: displayService.status,
            isCancelled: displayService.isCancelled,
            isCircularPoint: false
        )
        
        // Insert the current station into the calling points list at the correct position
        var allPoints = displayService.callingPoints
        if let insertIndex = allPoints.firstIndex(where: { $0.scheduledTime > currentStationPoint.scheduledTime }) {
            allPoints.insert(currentStationPoint, at: insertIndex)
        } else {
            allPoints.append(currentStationPoint)
        }
        
        return allPoints
    }
    
    private var currentStation: Station {
        let displayService = viewModel.detailedService ?? service
        return displayService.currentStation
    }
    
    init(service: TrainService, darwinService: DarwinService) {
        self.service = service
        self.darwinService = darwinService
        self._viewModel = StateObject(wrappedValue: ServiceDetailViewModel(darwinService: darwinService))
        
        logger.info("ServiceDetailView initialized with service ID: \(service.id)")
        logger.info("Destination: \(service.destination.name)")
        logger.info("Platform: \(service.platform ?? "None")")
        logger.info("Scheduled time: \(service.scheduledDeparture?.formatted() ?? "None")")
        logger.info("Estimated time: \(service.estimatedDeparture?.formatted() ?? "None")")
        logger.info("Number of calling points: \(service.callingPoints.count)")
        logger.info("Number of coaches: \(service.coaches?.count ?? 0)")
        logger.info("Number of messages: \(service.serviceMessages.count)")
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading service details...")
            } else if let error = viewModel.error {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text("Error loading service details")
                        .font(.headline)
                    Text(error.localizedDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Try Again") {
                        Task {
                            await viewModel.fetchServiceDetails(for: service.id)
                        }
                    }
                    .buttonStyle(.bordered)
                }
            } else {
                serviceDetailsList
            }
        }
        .navigationTitle("Service Details")
        .task {
            await viewModel.fetchServiceDetails(for: service.id)
        }
    }
    
    private var serviceDetailsList: some View {
        List {
            let displayService = viewModel.detailedService ?? service
            
            // Service Header
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(displayService.origin.name)
                                .font(.title2)
                                .bold()
                            Text("to")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(displayService.destination.name)
                                .font(.title2)
                                .bold()
                        }
                        Spacer()
                        statusBadge
                    }
                    
                    Text(displayService.operatingCompany)
                        .foregroundColor(.secondary)
                    
                    if let platform = displayService.platform {
                        Text("Platform \(platform)")
                            .font(.headline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(6)
                    }
                }
            }
            
            // Times
            Section("Times") {
                HStack {
                    Text("Scheduled")
                    Spacer()
                    Text(formatTime(displayService.scheduledDeparture))
                        .monospacedDigit()
                }
                
                if displayService.isDelayed {
                    HStack {
                        Text("Estimated")
                            .foregroundColor(.red)
                        Spacer()
                        Text(formatTime(displayService.estimatedDeparture))
                            .monospacedDigit()
                            .foregroundColor(.red)
                    }
                }
            }
            
            // Coach Information
            if let coaches = displayService.coaches, !coaches.isEmpty {
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: -2) {
                            ForEach(Array(coaches.enumerated()), id: \.element.number) { index, coach in
                                VStack(spacing: 4) {
                                    Text(coach.number)
                                        .font(.caption.bold())
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(4)
                                    
                                    HStack(spacing: 0) {
                                        // Coach icon with capacity color
                                        Image(systemName: index == coaches.count - 1 ? "train.side.front.car" : 
                                               (index == 0 ? "train.side.rear.car" : "train.side.middle.car"))
                                            .font(.title2)
                                            .foregroundColor(coach.loading.map { loading -> Color in
                                                switch loading {
                                                case 0: return .green  // Empty
                                                case 1: return .yellow // Light
                                                case 2: return .orange // Moderate
                                                case 3: return .red    // Full
                                                default: return .green
                                                }
                                            } ?? .gray)
                                    }
                                    
                                    // Toilet indicator only
                                    if let toilet = coach.toilet {
                                        Image(systemName: toilet.isAvailable ? "toilet" : "toilet.fill")
                                            .foregroundColor(toilet.isAvailable ? .green : .red)
                                            .font(.caption2)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                    }
                }
            }
            
            // Service Information
            if displayService.isDelayed || displayService.isCancelled {
                Section("Service Information") {
                    if let delayReason = displayService.delayReason {
                        Label(delayReason, systemImage: "exclamationmark.triangle")
                            .foregroundColor(.red)
                    }
                    
                    if let cancelReason = displayService.cancelReason {
                        Label(cancelReason, systemImage: "xmark.circle")
                            .foregroundColor(.red)
                    }
                }
            }
            
            // Calling Points
            if !displayService.callingPoints.isEmpty {
                Section("Calling At") {
                    ForEach(allStations, id: \.station.id) { point in
                        CallingPointRow(point: point)
                            .listRowBackground(point.station.id == currentStation.id ? Color.blue.opacity(0.1) : nil)
                    }
                }
            }
            
            // Service Messages
            if !displayService.serviceMessages.isEmpty {
                Section("Service Updates") {
                    ForEach(displayService.serviceMessages, id: \.id) { message in
                        Text(message.message)
                            .foregroundColor(message.severity == .major ? .red : .primary)
                    }
                }
            }
        }
    }
    
    private var statusBadge: some View {
        Group {
            if service.isCancelled {
                Text("Cancelled")
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red)
                    .cornerRadius(4)
            } else if service.isDelayed {
                Text("Delayed")
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange)
                    .cornerRadius(4)
            } else {
                Text("On Time")
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green)
                    .cornerRadius(4)
            }
        }
        .font(.subheadline.bold())
    }
    
    private func formatTime(_ date: Date?) -> String {
        guard let date = date else { return "TBA" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct CallingPointRow: View {
    let point: CallingPoint
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(point.station.name)
                    if let platform = point.platform {
                        Text("P\(platform)")
                            .font(.caption.bold())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                // Scheduled time (shown smaller if we have actual/estimated)
                if point.actualTime != nil || point.estimatedTime != nil {
                    Text(formatTime(point.scheduledTime))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .strikethrough(point.estimatedTime != nil)
                } else {
                    Text(formatTime(point.scheduledTime))
                }
                
                // Actual or Estimated time
                if let actual = point.actualTime {
                    Text(formatTime(actual))
                        .foregroundColor(.green)
                } else if let estimated = point.estimatedTime {
                    Text(formatTime(estimated))
                        .foregroundColor(.orange)
                }
                
                if point.isCancelled {
                    Text("Cancelled")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .font(.system(.subheadline, design: .monospaced))
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationView {
        ServiceDetailView(
            service: TrainService(
                id: "TEST",
                origin: Station(id: "DEW", name: "Dewsbury"),
                destination: Station(id: "LDS", name: "Leeds"),
                operatingCompany: "Northern",
                operatorCode: "NT",
                scheduledDeparture: Date(),
                estimatedDeparture: Date().addingTimeInterval(300),
                actualDeparture: nil,
                scheduledArrival: nil,
                estimatedArrival: nil,
                actualArrival: nil,
                platform: "1",
                isPlatformHidden: false,
                status: .delayed,
                isCircularRoute: false,
                isCancelled: false,
                isDelayed: true,
                delayReason: "Signalling problems",
                cancelReason: nil,
                callingPoints: [
                    CallingPoint(
                        station: Station(id: "BTL", name: "Batley"),
                        scheduledTime: Date().addingTimeInterval(300),
                        estimatedTime: Date().addingTimeInterval(600),
                        actualTime: nil,
                        platform: "1",
                        status: .delayed,
                        isCancelled: false,
                        isCircularPoint: false
                    )
                ],
                coaches: [
                    Coach(number: "1", class: .standard, loading: 2, toilet: ToiletStatus(isAvailable: true, type: .standard)),
                    Coach(number: "2", class: .standard, loading: 1, toilet: ToiletStatus(isAvailable: false, type: .none))
                ],
                serviceMessages: [
                    ServiceMessage(
                        message: "Delays due to signalling problems",
                        severity: .major,
                        category: .serviceMessage
                    )
                ],
                currentStation: Station(id: "DEW", name: "Dewsbury")
            ),
            darwinService: DarwinService(apiKey: Config.openLDBWSApiKey)
        )
    }
} 