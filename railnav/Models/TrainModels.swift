import Foundation

// MARK: - Base Models

struct Station: Identifiable {
    let id: String  // CRS Code
    let name: String
    let manager: String?  // Station manager (usually TOC name)
    let managerCode: String?
    let isPlatformsHidden: Bool
    let isServicesAvailable: Bool
    
    // Convenience initializer for basic station
    init(id: String, name: String) {
        self.id = id
        self.name = name
        self.manager = nil
        self.managerCode = nil
        self.isPlatformsHidden = false
        self.isServicesAvailable = true
    }
}

enum ServiceStatus: String, Codable {
    case onTime = "On time"
    case delayed = "Delayed"
    case cancelled = "Cancelled"
    case arrived = "Arrived"
    case departed = "Departed"
    case unknown = "Unknown"
}

// MARK: - Service Information

struct TrainService: Identifiable {
    let id: String  // RTTI Service ID
    let origin: Station
    let destination: Station
    let operatingCompany: String
    let operatorCode: String
    
    // Times
    let scheduledDeparture: Date?
    let estimatedDeparture: Date?
    let actualDeparture: Date?
    let scheduledArrival: Date?
    let estimatedArrival: Date?
    let actualArrival: Date?
    
    // Platform and status
    let platform: String?
    let isPlatformHidden: Bool
    var status: ServiceStatus
    var isCircularRoute: Bool
    
    // Service details
    var isCancelled: Bool
    var isDelayed: Bool
    var delayReason: String?
    var cancelReason: String?
    let callingPoints: [CallingPoint]
    
    // Coach information if available
    let coaches: [Coach]?
    
    // Station messages/disruption info
    let serviceMessages: [ServiceMessage]
    
    // Current station (the station we're viewing the service from)
    let currentStation: Station
}

// MARK: - Calling Points

struct CallingPoint: Identifiable {
    var id: String { station.id }
    let station: Station
    let scheduledTime: Date
    let estimatedTime: Date?
    let actualTime: Date?
    let platform: String?
    let status: ServiceStatus
    let isCancelled: Bool
    
    // For circular routes
    let isCircularPoint: Bool
}

// MARK: - Coach Information

struct Coach {
    let number: String  // e.g. "A" or "12"
    let `class`: CoachClass
    let loading: Int?  // 0-100
    let toilet: ToiletStatus?
}

enum CoachClass: String, Codable {
    case first = "First"
    case standard = "Standard"
    case mixed = "Mixed"
}

struct ToiletStatus: Codable {
    let isAvailable: Bool
    let type: ToiletType
}

enum ToiletType: String, Codable {
    case standard = "Standard"
    case accessible = "Accessible"
    case none = "None"
}

// MARK: - Messages and Disruptions

struct ServiceMessage: Identifiable {
    let id: UUID = UUID()
    let message: String
    let severity: MessageSeverity
    let category: MessageCategory
}

enum MessageSeverity: Int, Codable {
    case normal = 0
    case minor = 1
    case major = 2
}

enum MessageCategory: String, Codable {
    case stationMessage = "Station"
    case serviceMessage = "Service"
    case connectionMessage = "Connection"
    case systemMessage = "System"
}

// MARK: - Board Types

struct DepartureBoard {
    let station: Station
    let generatedAt: Date
    let services: [TrainService]
    let messages: [ServiceMessage]
    let filterStation: Station?  // If board is filtered by destination
    
    var hasActiveServices: Bool {
        services.contains { !$0.isCancelled }
    }
}

// MARK: - Extensions for Domain Models

extension DomainTrainService {
    var displayTime: String {
        if let scheduled = scheduledDeparture ?? scheduledArrival {
            if let estimated = estimatedDeparture ?? estimatedArrival {
                if estimated > scheduled {
                    return "Exp \(estimated.formattedTime)"
                }
            }
            return scheduled.formattedTime
        }
        return "No time"
    }
    
    var displayStatus: String {
        if isCancelled {
            return "Cancelled"
        }
        if let delay = estimatedDeparture?.timeIntervalSince(scheduledDeparture ?? Date()) {
            if delay > 60 {
                let minutes = Int(delay / 60)
                return "Delayed \(minutes)m"
            }
        }
        return status == .onTime ? "On time" : "Delayed"
    }
}

extension DomainDepartureBoard {
    var hasActiveServices: Bool {
        services.contains { !$0.isCancelled }
    }
}

// MARK: - Date Extensions

extension Date {
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
    var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM HH:mm"
        return formatter.string(from: self)
    }
}

// MARK: - Domain Model Conversions

extension DomainStation {
    func toAppModel() -> Station {
        Station(id: id, name: name)
    }
}

extension Station {
    func toDomainModel() -> DomainStation {
        DomainStation(id: id, name: name)
    }
}

extension DomainServiceMessage {
    func toAppModel() -> ServiceMessage {
        ServiceMessage(
            message: message,
            severity: severity == .error ? .major : (severity == .warning ? .minor : .normal),
            category: category == .serviceMessage ? .serviceMessage : .stationMessage
        )
    }
}

extension DomainCallingPoint {
    func toAppModel() -> CallingPoint {
        CallingPoint(
            station: station.toAppModel(),
            scheduledTime: scheduledTime,
            estimatedTime: estimatedTime,
            actualTime: actualTime,
            platform: platform,
            status: status == .onTime ? .onTime : (status == .delayed ? .delayed : (status == .arrived ? .arrived : .cancelled)),
            isCancelled: isCancelled,
            isCircularPoint: isCircularPoint
        )
    }
}

extension DomainCoach {
    func toAppModel() -> Coach {
        Coach(
            number: number,
            class: coachClass == .first ? .first : .standard,
            loading: loading,
            toilet: toilet?.toAppModel()
        )
    }
}

extension DomainToiletStatus {
    func toAppModel() -> ToiletStatus {
        ToiletStatus(
            isAvailable: status == "Available",
            type: type == "Standard" ? .standard : (type == "Accessible" ? .accessible : .none)
        )
    }
}

extension DomainTrainService {
    func toAppModel() -> TrainService {
        TrainService(
            id: id,
            origin: origin.toAppModel(),
            destination: destination.toAppModel(),
            operatingCompany: operatingCompany,
            operatorCode: operatorCode,
            scheduledDeparture: scheduledDeparture,
            estimatedDeparture: estimatedDeparture,
            actualDeparture: actualDeparture,
            scheduledArrival: scheduledArrival,
            estimatedArrival: estimatedArrival,
            actualArrival: actualArrival,
            platform: platform,
            isPlatformHidden: isPlatformHidden,
            status: status == .onTime ? .onTime : (status == .delayed ? .delayed : (status == .arrived ? .arrived : .cancelled)),
            isCircularRoute: isCircularRoute,
            isCancelled: isCancelled,
            isDelayed: isDelayed,
            delayReason: delayReason,
            cancelReason: cancelReason,
            callingPoints: callingPoints.map { $0.toAppModel() },
            coaches: coaches?.map { $0.toAppModel() },
            serviceMessages: serviceMessages.map { $0.toAppModel() },
            currentStation: currentStation.toAppModel()
        )
    }
}

extension DomainDepartureBoard {
    func toAppModel() -> DepartureBoard {
        DepartureBoard(
            station: station.toAppModel(),
            generatedAt: generatedAt,
            services: services.map { $0.toAppModel() },
            messages: messages.map { $0.toAppModel() },
            filterStation: filterStation?.toAppModel()
        )
    }
} 