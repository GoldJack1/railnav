import Foundation

struct StationData {
    static let stations: [Station] = [
        Station(id: "LDS", name: "Leeds"),
        Station(id: "DEW", name: "Dewsbury"),
        Station(id: "HUD", name: "Huddersfield"),
        Station(id: "MAN", name: "Manchester Piccadilly"),
        Station(id: "MCV", name: "Manchester Victoria"),
        Station(id: "LIV", name: "Liverpool Lime Street"),
        Station(id: "YRK", name: "York"),
        Station(id: "KGX", name: "London Kings Cross"),
        Station(id: "EUS", name: "London Euston"),
        Station(id: "PAD", name: "London Paddington"),
        Station(id: "BHM", name: "Birmingham New Street"),
        Station(id: "GLC", name: "Glasgow Central"),
        Station(id: "EDB", name: "Edinburgh Waverley"),
        Station(id: "BTL", name: "Batley"),
        Station(id: "MRF", name: "Morley"),
        Station(id: "WKF", name: "Wakefield Westgate"),
        Station(id: "SHF", name: "Sheffield"),
        Station(id: "NCL", name: "Newcastle"),
        Station(id: "LBA", name: "Leeds Bradford Airport"),
        Station(id: "BFD", name: "Bradford Interchange")
    ]
    
    static func search(_ query: String) -> [Station] {
        let lowercaseQuery = query.lowercased()
        
        // If the query is exactly 3 characters, prioritize CRS code matches
        if query.count == 3 {
            let exactCRSMatches = stations.filter { $0.id.lowercased() == lowercaseQuery }
            if !exactCRSMatches.isEmpty {
                return exactCRSMatches
            }
        }
        
        // Search both name and CRS code
        return stations.filter { station in
            station.name.lowercased().contains(lowercaseQuery) ||
            station.id.lowercased().contains(lowercaseQuery)
        }
    }
} 