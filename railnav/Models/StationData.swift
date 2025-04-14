import Foundation
import os

@Observable
class StationData {
    private static let logger = Logger(subsystem: "com.railnav", category: "StationData")
    private static var cachedStations: [Station]?
    
    static var stations: [Station] {
        get {
            if let cached = cachedStations {
                return cached
            }
            
            let stationList = Stationcodelist.stations
            let stations = stationList.map { station in
                Station(
                    id: station.crsCode,
                    name: station.stationName,
                    latitude: station.latitude,
                    longitude: station.longitude,
                    iataAirportCode: station.iataAirportCode,
                    manager: nil,
                    managerCode: nil,
                    isPlatformsHidden: false,
                    isServicesAvailable: true
                )
            }
            cachedStations = stations
            return stations
        }
    }
    
    static func clearCache() {
        cachedStations = nil
        Stationcodelist.clearCache()
    }
    
    static func search(_ query: String) -> [Station] {
        guard !query.isEmpty else { return [] }
        
        // Normalize the search query
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalizedQuery.isEmpty else { return [] }
        
        // Get all stations
        let allStations = Self.stations
        
        // Score and sort stations based on match quality
        let scoredStations = allStations.map { station -> (Station, Double) in
            var score = 0.0
            
            // Normalize station name for comparison
            let normalizedName = station.name.lowercased()
            let normalizedCRS = station.id.lowercased()
            
            // Exact matches get highest score
            if normalizedName == normalizedQuery {
                score += 100
            } else if normalizedCRS == normalizedQuery {
                score += 100
            }
            
            // CRS code partial matches
            if normalizedQuery.count <= 3 && normalizedCRS.starts(with: normalizedQuery) {
                score += 75
            }
            
            // Station name starts with query
            if normalizedName.starts(with: normalizedQuery) {
                score += 50
            }
            
            // Words in station name start with query
            let stationWords = normalizedName.split(separator: " ")
            if stationWords.contains(where: { $0.starts(with: normalizedQuery) }) {
                score += 25
            }
            
            // Partial matches anywhere in the name
            if normalizedName.contains(normalizedQuery) {
                score += 10
            }
            
            return (station, score)
        }
        
        // Filter out non-matches and sort by score
        return scoredStations
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
            .map { $0.0 }
    }
}