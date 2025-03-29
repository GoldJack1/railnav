import Foundation
import XMLCoder
import os

// MARK: - XML Response Models
struct SOAPEnvelope: Decodable {
    let Body: SOAPBody
    
    enum CodingKeys: String, CodingKey {
        case Body = "soap:Body"
    }
}

struct SOAPBody: Decodable {
    let GetArrBoardWithDetailsResponse: GetArrBoardWithDetailsResponse
}

struct GetArrBoardWithDetailsResponse: Decodable {
    let GetStationBoardResult: StationBoard
}

struct StationBoard: Decodable {
    let generatedAt: String
    let locationName: String
    let crs: String
    let platformAvailable: Bool
    let trainServices: TrainServices?
    
    private enum CodingKeys: String, CodingKey {
        case generatedAt = "lt4:generatedAt"
        case locationName = "lt4:locationName"
        case crs = "lt4:crs"
        case platformAvailable = "lt4:platformAvailable"
        case trainServices = "lt8:trainServices"
    }
}

struct TrainServices: Decodable {
    let service: [Service]
    
    private enum CodingKeys: String, CodingKey {
        case service = "lt8:service"
    }
}

struct Service: Decodable {
    let sta: String
    let eta: String
    let platform: String?
    let operator_: String
    let operatorCode: String
    let serviceType: String
    let serviceID: String
    let origin: LocationContainer
    let destination: LocationContainer
    
    private enum CodingKeys: String, CodingKey {
        case sta = "lt4:sta"
        case eta = "lt4:eta"
        case platform = "lt4:platform"
        case operator_ = "lt4:operator"
        case operatorCode = "lt4:operatorCode"
        case serviceType = "lt4:serviceType"
        case serviceID = "lt4:serviceID"
        case origin = "lt5:origin"
        case destination = "lt5:destination"
    }
}

struct LocationContainer: Decodable {
    let location: [Location]
    
    private enum CodingKeys: String, CodingKey {
        case location = "lt4:location"
    }
}

struct Location: Decodable {
    let locationName: String
    let crs: String
    
    private enum CodingKeys: String, CodingKey {
        case locationName = "lt4:locationName"
        case crs = "lt4:crs"
    }
}

struct ServiceDetailsSOAPEnvelope: Decodable {
    let Body: ServiceDetailsSOAPBody
    
    enum CodingKeys: String, CodingKey {
        case Body = "soap:Body"
    }
}

struct ServiceDetailsSOAPBody: Decodable {
    let GetServiceDetailsResponse: ServiceDetailsResponse
    
    enum CodingKeys: String, CodingKey {
        case GetServiceDetailsResponse = "GetServiceDetailsResponse"
    }
}

struct ServiceDetailsResponse: Decodable {
    let GetServiceDetailsResult: ServiceDetails
    
    enum CodingKeys: String, CodingKey {
        case GetServiceDetailsResult = "GetServiceDetailsResult"
    }
}

struct LocationDetail: Decodable {
    let location: [Location]
}

struct CallingPoints: Decodable {
    let callingPointList: [CallingPointList]
    
    enum CodingKeys: String, CodingKey {
        case callingPointList = "lt8:callingPointList"
    }
}

struct CallingPointList: Decodable {
    let callingPoints: [CallingPointItem]
    
    enum CodingKeys: String, CodingKey {
        case callingPoints = "lt8:callingPoint"
    }
}

struct CallingPointItem: Decodable {
    let locationName: String
    let crs: String
    let st: String  // Scheduled Time
    let et: String? // Estimated Time
    let at: String? // Actual Time
    let platform: String?
    let length: Int?
    let delayReason: String?
    
    enum CodingKeys: String, CodingKey {
        case locationName = "lt8:locationName"
        case crs = "lt8:crs"
        case st = "lt8:st"
        case et = "lt8:et"
        case at = "lt8:at"
        case platform = "lt8:platform"
        case length = "lt8:length"
        case delayReason = "lt8:delayReason"
    }
}

enum DomainServiceStatus {
    case onTime
    case delayed
    case arrived
    case cancelled
}

enum DomainCoachClass {
    case first
    case standard
}

enum DomainMessageSeverity {
    case normal
    case warning
    case error
}

enum DomainMessageCategory {
    case serviceMessage
    case stationMessage
}

struct DomainServiceMessage {
    let id = UUID()  // Unique identifier for each message
    let message: String
    let severity: DomainMessageSeverity
    let category: DomainMessageCategory
}

struct XMLFormation: Decodable {
    let coaches: [XMLCoach]?
    
    enum CodingKeys: String, CodingKey {
        case coaches = "lt4:coaches"
    }
}

struct XMLCoach: Decodable {
    let number: String
    let coachClass: String
    let toilet: XMLToiletStatus?
    let loading: Int?
    
    enum CodingKeys: String, CodingKey {
        case number = "lt4:coachNumber"
        case coachClass = "lt4:coachClass"
        case toilet = "lt4:toilet"
        case loading = "lt4:loading"
    }
}

struct XMLToiletStatus: Decodable {
    let status: String
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case status = "lt4:status"
        case type = "lt4:type"
    }
}

struct ServiceDetails: Decodable {
    let generatedAt: String
    let serviceID: String?
    let std: String
    let etd: String
    let sta: String?
    let eta: String?
    let platform: String?
    let operator_: String
    let operatorCode: String
    let serviceType: String
    let locationName: String
    let crs: String
    let origin: LocationDetail?
    let destination: LocationDetail?
    let subsequentCallingPoints: CallingPoints?
    let previousCallingPoints: CallingPoints?
    let length: Int?
    let delayReason: String?
    let cancelReason: String?
    let serviceMessages: [String]?
    let formation: XMLFormation?
    let isReverseFormation: Bool?
    let detachFront: Bool?
    
    enum CodingKeys: String, CodingKey {
        case generatedAt = "lt7:generatedAt"
        case serviceID = "lt7:serviceID"
        case std = "lt7:std"
        case etd = "lt7:etd"
        case sta = "lt7:sta"
        case eta = "lt7:eta"
        case platform = "lt7:platform"
        case operator_ = "lt7:operator"
        case operatorCode = "lt7:operatorCode"
        case serviceType = "lt7:serviceType"
        case locationName = "lt7:locationName"
        case crs = "lt7:crs"
        case origin = "lt7:origin"
        case destination = "lt7:destination"
        case subsequentCallingPoints = "lt8:subsequentCallingPoints"
        case previousCallingPoints = "lt8:previousCallingPoints"
        case length = "lt7:length"
        case delayReason = "lt7:delayReason"
        case cancelReason = "lt7:cancelReason"
        case serviceMessages = "lt7:message"
        case formation = "lt7:formation"
        case isReverseFormation = "lt7:isReverseFormation"
        case detachFront = "lt7:detachFront"
    }
}

// Update domain models with id properties
struct DomainStation {
    let id: String  // CRS Code
    let name: String
}

struct DomainCoach {
    let number: String  // This will be used as the id
    let coachClass: DomainCoachClass
    let loading: Int?
    let toilet: DomainToiletStatus?
}

struct DomainToiletStatus {
    let status: String
    let type: String
}

struct DomainCallingPoint {
    var id: String { station.id }  // Computed id from station
    let station: DomainStation
    let scheduledTime: Date
    let estimatedTime: Date?
    let actualTime: Date?
    let platform: String?
    let status: DomainServiceStatus
    let isCancelled: Bool
    let isCircularPoint: Bool
}

struct DomainTrainService {
    let id: String  // RTTI Service ID
    let origin: DomainStation
    let destination: DomainStation
    let operatingCompany: String
    let operatorCode: String
    let scheduledDeparture: Date?
    let estimatedDeparture: Date?
    let actualDeparture: Date?
    let scheduledArrival: Date?
    let estimatedArrival: Date?
    let actualArrival: Date?
    let platform: String?
    let isPlatformHidden: Bool
    let status: DomainServiceStatus
    let isCircularRoute: Bool
    let isCancelled: Bool
    let isDelayed: Bool
    let delayReason: String?
    let cancelReason: String?
    let callingPoints: [DomainCallingPoint]
    let coaches: [DomainCoach]?
    let serviceMessages: [DomainServiceMessage]
    let currentStation: DomainStation
}

struct DomainDepartureBoard {
    let station: DomainStation
    let generatedAt: Date
    let services: [DomainTrainService]
    let messages: [DomainServiceMessage]
    let filterStation: DomainStation?
}

class OpenLDBWSClient {
    private let baseURL = "https://lite.realtime.nationalrail.co.uk/OpenLDBWS/ldb12.asmx"
    private let accessToken: String
    private let session: URLSession
    private let decoder: XMLDecoder
    private let logger = Logger(subsystem: "com.railnav", category: "OpenLDBWSClient")
    
    init(accessToken: String, session: URLSession = .shared) {
        self.accessToken = accessToken
        self.session = session
        
        self.decoder = XMLDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        self.decoder.keyDecodingStrategy = .useDefaultKeys
        
        logger.info("OpenLDBWSClient initialized with token: \(accessToken.prefix(8))...")
    }
    
    private func buildRequest(for method: String, body: String) -> URLRequest {
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("text/xml;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue("\"\(method)\"", forHTTPHeaderField: "SOAPAction")
        request.setValue("gzip,deflate", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
        request.setValue("Apache-HttpClient/4.5.5 (Java/17.0.12)", forHTTPHeaderField: "User-Agent")
        request.httpBody = buildSOAPEnvelope(body: body).data(using: .utf8)
        
        logger.info("Built request for method: \(method)")
        logger.debug("Request headers: \(request.allHTTPHeaderFields ?? [:])")
        if let bodyString = String(data: request.httpBody ?? Data(), encoding: .utf8) {
            logger.debug("Request body: \(bodyString)")
        }
        
        return request
    }
    
    private func buildSOAPEnvelope(body: String) -> String {
        return """
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:typ="http://thalesgroup.com/RTTI/2013-11-28/Token/types" xmlns:ldb="http://thalesgroup.com/RTTI/2021-11-01/ldb/">
           <soapenv:Header>
              <typ:AccessToken>
                 <typ:TokenValue>\(accessToken)</typ:TokenValue>
              </typ:AccessToken>
           </soapenv:Header>
           <soapenv:Body>
              \(body)
           </soapenv:Body>
        </soapenv:Envelope>
        """
    }
    
    func getDepartureBoard(for station: String) async throws -> DomainDepartureBoard {
        logger.info("Getting departure board for station: \(station)")
        
        let body = """
        <ldb:GetArrBoardWithDetailsRequest>
            <ldb:numRows>10</ldb:numRows>
            <ldb:crs>\(station)</ldb:crs>
            <ldb:timeOffset>0</ldb:timeOffset>
            <ldb:timeWindow>120</ldb:timeWindow>
        </ldb:GetArrBoardWithDetailsRequest>
        """
        
        let request = buildRequest(for: "http://thalesgroup.com/RTTI/2015-05-14/ldb/GetArrBoardWithDetails", body: body)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("Invalid response type")
                throw OpenLDBWSError.invalidResponse
            }
            
            logger.info("Received response with status code: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode != 200 {
                if let responseString = String(data: data, encoding: .utf8) {
                    logger.error("Server error response: \(responseString)")
                    if responseString.contains("soap:Fault") {
                        // Extract SOAP fault details
                        if let faultString = extractSOAPFault(from: responseString) {
                            throw OpenLDBWSError.serverError(statusCode: httpResponse.statusCode, message: faultString)
                        }
                    }
                }
                throw OpenLDBWSError.serverError(statusCode: httpResponse.statusCode, message: "Unknown server error")
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                logger.debug("Response body: \(responseString)")
            }
            
            return try parseGetBoardResponse(data)
        } catch let error as OpenLDBWSError {
            logger.error("OpenLDBWS error: \(error.localizedDescription)")
            throw error
        } catch {
            logger.error("Network error: \(error.localizedDescription)")
            throw OpenLDBWSError.networkError(error)
        }
    }
    
    private func extractSOAPFault(from response: String) -> String? {
        if let range = response.range(of: "<faultstring>"),
           let endRange = response.range(of: "</faultstring>") {
            return String(response[range.upperBound..<endRange.lowerBound])
        }
        return nil
    }
    
    func getServiceDetails(serviceID: String) async throws -> DomainTrainService {
        let body = """
        <ldb:GetServiceDetailsRequest>
            <ldb:serviceID>\(serviceID)</ldb:serviceID>
        </ldb:GetServiceDetailsRequest>
        """
        
        let request = buildRequest(for: "http://thalesgroup.com/RTTI/2012-01-13/ldb/GetServiceDetails", body: body)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            if let httpResponse = response as? HTTPURLResponse {
                logger.error("Service details request failed with status code: \(httpResponse.statusCode)")
                if let responseData = String(data: data, encoding: .utf8) {
                    logger.error("Response body: \(responseData)")
                }
            }
            throw OpenLDBWSError.invalidResponse
        }
        
        if let responseString = String(data: data, encoding: .utf8) {
            logger.debug("Service details response: \(responseString)")
        }
        
        return try parseGetServiceDetailsResponse(data)
    }
    
    // MARK: - Response Parsing
    
    private func parseGetBoardResponse(_ data: Data) throws -> DomainDepartureBoard {
        logger.info("Starting to parse board response")
        do {
            if let xmlString = String(data: data, encoding: .utf8) {
                logger.debug("Raw XML response: \(xmlString)")
            }
            
            let envelope = try decoder.decode(SOAPEnvelope.self, from: data)
            logger.info("Successfully decoded SOAP envelope")
            
            let board = envelope.Body.GetArrBoardWithDetailsResponse.GetStationBoardResult
            logger.info("Got station board for \(board.locationName) (\(board.crs)) with \(board.trainServices?.service.count ?? 0) services")
            
            let station = DomainStation(id: board.crs, name: board.locationName)
            
            let trainServices: [DomainTrainService] = board.trainServices?.service.map { service in
                logger.debug("Processing service \(service.serviceID) from \(service.origin.location[0].locationName) to \(service.destination.location[0].locationName)")
                
                let origin = DomainStation(id: service.origin.location[0].crs,
                                   name: service.origin.location[0].locationName)
                
                let destination = DomainStation(id: service.destination.location[0].crs,
                                        name: service.destination.location[0].locationName)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                
                let scheduledDeparture = dateFormatter.date(from: service.sta)
                var estimatedDeparture: Date? = nil
                if service.eta != "On time" {
                    estimatedDeparture = dateFormatter.date(from: service.eta)
                }
                
                return DomainTrainService(id: service.serviceID,
                                  origin: origin,
                                  destination: destination,
                                  operatingCompany: service.operator_,
                                  operatorCode: service.operatorCode,
                                  scheduledDeparture: scheduledDeparture,
                                  estimatedDeparture: estimatedDeparture,
                                  actualDeparture: nil as Date?,
                                  scheduledArrival: nil as Date?,
                                  estimatedArrival: nil as Date?,
                                  actualArrival: nil as Date?,
                                  platform: service.platform,
                                  isPlatformHidden: false,
                                  status: service.eta == "On time" ? .onTime : .delayed,
                                  isCircularRoute: false,
                                  isCancelled: service.eta == "Cancelled",
                                  isDelayed: service.eta != "On time",
                                  delayReason: nil as String?,
                                  cancelReason: nil as String?,
                                  callingPoints: [],
                                  coaches: nil as [DomainCoach]?,
                                  serviceMessages: [],
                                  currentStation: station)
            } ?? []
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZZZZZ"
            let generatedAt = dateFormatter.date(from: board.generatedAt) ?? Date()
            
            return DomainDepartureBoard(station: station,
                                generatedAt: generatedAt,
                                services: trainServices,
                                messages: [],
                                filterStation: nil as DomainStation?)
            
        } catch {
            logger.error("Failed to parse board response: \(error)")
            throw OpenLDBWSError.parsingError(error)
        }
    }
    
    private func parseGetServiceDetailsResponse(_ data: Data) throws -> DomainTrainService {
        logger.debug("Starting to parse service details response")
        do {
            if let xmlString = String(data: data, encoding: .utf8) {
                logger.info("Raw XML response: \(xmlString)")
            }
            
            let envelope = try decoder.decode(ServiceDetailsSOAPEnvelope.self, from: data)
            logger.debug("Successfully decoded SOAP envelope")
            
            let details = envelope.Body.GetServiceDetailsResponse.GetServiceDetailsResult
            logger.debug("Got service details")
            
            // Get current station from the API response
            let currentStation = DomainStation(id: details.crs, name: details.locationName)
            
            // Get origin/destination from calling points if not directly provided
            let origin: DomainStation
            if let originDetail = details.origin?.location.first {
                origin = DomainStation(id: originDetail.crs, name: originDetail.locationName)
            } else if let firstPrevious = details.previousCallingPoints?.callingPointList.first?.callingPoints.first {
                origin = DomainStation(id: firstPrevious.crs, name: firstPrevious.locationName)
            } else {
                // Fallback to current location if no origin found
                origin = currentStation
            }
            
            let destination: DomainStation
            if let destinationDetail = details.destination?.location.first {
                destination = DomainStation(id: destinationDetail.crs, name: destinationDetail.locationName)
            } else if let lastSubsequent = details.subsequentCallingPoints?.callingPointList.first?.callingPoints.last {
                destination = DomainStation(id: lastSubsequent.crs, name: lastSubsequent.locationName)
            } else {
                // Fallback to current location if no destination found
                destination = currentStation
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            
            let scheduledDeparture = dateFormatter.date(from: details.std)
            var estimatedDeparture: Date? = nil
            if details.etd != "On time" {
                estimatedDeparture = dateFormatter.date(from: details.etd)
            }
            
            // Parse subsequent calling points
            let subsequentPoints: [DomainCallingPoint] = details.subsequentCallingPoints?.callingPointList.flatMap { list in
                list.callingPoints.map { point in
                    let station = DomainStation(id: point.crs, name: point.locationName)
                    let scheduled = dateFormatter.date(from: point.st)!
                    let estimated = point.et.flatMap { dateFormatter.date(from: $0) }
                    let actual = point.at.flatMap { dateFormatter.date(from: $0) }
                    
                    return DomainCallingPoint(station: station,
                                      scheduledTime: scheduled,
                                      estimatedTime: estimated,
                                      actualTime: actual,
                                      platform: point.platform,
                                      status: estimated != nil ? .delayed : .onTime,
                                      isCancelled: false,
                                      isCircularPoint: false)
                }
            } ?? []
            
            // Parse previous calling points
            let previousPoints: [DomainCallingPoint] = details.previousCallingPoints?.callingPointList.flatMap { list in
                list.callingPoints.map { point in
                    let station = DomainStation(id: point.crs, name: point.locationName)
                    let scheduled = dateFormatter.date(from: point.st)!
                    let estimated = point.et.flatMap { dateFormatter.date(from: $0) }
                    let actual = point.at.flatMap { dateFormatter.date(from: $0) }
                    
                    return DomainCallingPoint(station: station,
                                      scheduledTime: scheduled,
                                      estimatedTime: estimated,
                                      actualTime: actual,
                                      platform: point.platform,
                                      status: actual != nil ? .arrived : (estimated != nil ? .delayed : .onTime),
                                      isCancelled: false,
                                      isCircularPoint: false)
                }
            } ?? []
            
            // Combine calling points in correct order
            let allCallingPoints = previousPoints + subsequentPoints
            
            // Create coaches array if length is provided
            var coaches: [DomainCoach]? = nil
            if let length = details.length {
                coaches = (0..<length).map { index in
                    DomainCoach(number: String(index + 1),
                          coachClass: .standard,
                          loading: nil,
                          toilet: nil)
                }
            }
            
            // Parse service messages
            let messages = details.serviceMessages?.map { message in
                DomainServiceMessage(
                    message: message,
                    severity: .normal,
                    category: .serviceMessage
                )
            } ?? []
            
            return DomainTrainService(id: details.serviceID ?? "",
                              origin: origin,
                              destination: destination,
                              operatingCompany: details.operator_,
                              operatorCode: details.operatorCode,
                              scheduledDeparture: scheduledDeparture,
                              estimatedDeparture: estimatedDeparture,
                              actualDeparture: nil,
                              scheduledArrival: details.sta.flatMap { dateFormatter.date(from: $0) },
                              estimatedArrival: details.eta.flatMap { $0 != "On time" ? dateFormatter.date(from: $0) : nil },
                              actualArrival: nil,
                              platform: details.platform,
                              isPlatformHidden: false,
                              status: details.etd == "On time" ? .onTime : .delayed,
                              isCircularRoute: false,
                              isCancelled: details.etd == "Cancelled",
                              isDelayed: details.etd != "On time",
                              delayReason: details.delayReason,
                              cancelReason: details.cancelReason,
                              callingPoints: allCallingPoints,
                              coaches: coaches,
                              serviceMessages: messages,
                              currentStation: currentStation)
            
        } catch {
            logger.error("Failed to parse service details: \(error)")
            throw OpenLDBWSError.parsingError(error)
        }
    }
}

// MARK: - Errors

enum OpenLDBWSError: LocalizedError {
    case invalidResponse
    case serverError(statusCode: Int, message: String)
    case parsingError(Error)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let statusCode, let message):
            return "Server error (status \(statusCode)): \(message)"
        case .parsingError(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
} 