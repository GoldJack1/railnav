import Foundation

// Read existing stations
let existingStationsURL = URL(fileURLWithPath: "railnav/Resources/stations.csv")
let existingContent = try? String(contentsOf: existingStationsURL, encoding: .utf8)
let existingStations = Set(
    existingContent?
        .components(separatedBy: .newlines)
        .dropFirst() // Skip header
        .compactMap { line -> String? in
            let components = line.components(separatedBy: ",")
            return components.count >= 4 ? components[3] : nil
        } ?? []
)

// Read new stations
let stationsURL = URL(fileURLWithPath: "railnav/Stationnametemp.swift")
guard let content = try? String(contentsOf: stationsURL, encoding: .utf8) else {
    print("Error reading Stationnametemp.swift")
    exit(1)
}

// Extract station data
let pattern = #"Station\(stationName: "(.*?)", latitude: (.*?), longitude: (.*?), crsCode: "(.*?)", iataAirportCode: (nil|".*?")\)"#
let regex = try! NSRegularExpression(pattern: pattern)
let range = NSRange(content.startIndex..<content.endIndex, in: content)
let matches = regex.matches(in: content, range: range)

// Convert to CSV format
var newStations: [[String]] = []
for match in matches {
    let name = (content as NSString).substring(with: match.range(at: 1))
    let lat = (content as NSString).substring(with: match.range(at: 2))
    let lon = (content as NSString).substring(with: match.range(at: 3))
    let crs = (content as NSString).substring(with: match.range(at: 4))
    var iata = (content as NSString).substring(with: match.range(at: 5))
    
    if !existingStations.contains(crs) {
        iata = iata == "nil" ? "" : iata.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        newStations.append([name, lat, lon, crs, iata])
    }
}

// Sort and append new stations
newStations.sort { $0[0] < $1[0] }  // Sort by station name
let csvLines = newStations.map { station in
    station.joined(separator: ",")
}

if !csvLines.isEmpty {
    let newContent = "\n" + csvLines.joined(separator: "\n")
    try! newContent.write(to: existingStationsURL, atomically: true, encoding: .utf8)
} 