import Foundation
import os

struct StationCodeListEntry {
    let stationName: String
    let latitude: Double
    let longitude: Double
    let crsCode: String
    let iataAirportCode: String?
}

@Observable
class Stationcodelist {
    private static let logger = Logger(subsystem: "com.railnav", category: "Stationcodelist")
    private static var cachedStations: [StationCodeListEntry]?
    
    static var stations: [StationCodeListEntry] {
        get {
            if let cached = cachedStations {
                return cached
            }
            
            do {
                let stations = try loadStationsFromCSV()
                cachedStations = stations
                return stations
            } catch {
                logger.error("Failed to load stations from CSV: \(error.localizedDescription)")
                return fallbackStations
            }
        }
    }
    
    static func clearCache() {
        cachedStations = nil
    }
    
    private static func loadStationsFromCSV() throws -> [StationCodeListEntry] {
        guard let csvPath = Bundle.main.path(forResource: "stations", ofType: "csv") else {
            throw NSError(domain: "com.railnav", code: 404, userInfo: [NSLocalizedDescriptionKey: "stations.csv not found"])
        }
        
        let csvString = try String(contentsOfFile: csvPath, encoding: .utf8)
        var stations: [StationCodeListEntry] = []
        
        let rows = csvString.components(separatedBy: .newlines)
        // Skip header row
        for row in rows.dropFirst() where !row.isEmpty {
            let columns = row.components(separatedBy: ",")
            guard columns.count >= 4 else { continue }
            
            let station = StationCodeListEntry(
                stationName: columns[0],
                latitude: Double(columns[1]) ?? 0,
                longitude: Double(columns[2]) ?? 0,
                crsCode: columns[3],
                iataAirportCode: columns.count > 4 ? columns[4] : nil
            )
            stations.append(station)
        }
        
        return stations
    }
    
    // Fallback stations in case CSV file is not available
    static let fallbackStations: [StationCodeListEntry] = [
        StationCodeListEntry(stationName: "London Paddington", latitude: 51.5168, longitude: -0.1778, crsCode: "PAD", iataAirportCode: nil),
        StationCodeListEntry(stationName: "London Kings Cross", latitude: 51.5322, longitude: -0.1240, crsCode: "KGX", iataAirportCode: nil),
        StationCodeListEntry(stationName: "London Euston", latitude: 51.5284, longitude: -0.1334, crsCode: "EUS", iataAirportCode: nil)
    ]
} 