import Foundation

enum Config {
    static let openLDBWSApiKey = "c487598e-7f29-4a7c-bd18-5f867de9c0b6"  // Replace with your actual API key
    
    static let defaultStation = "DEW"  // Dewsbury
    static let defaultNumRows = 10     // Number of departures to fetch
    
    enum URLs {
        static let openLDBWS = "https://lite.realtime.nationalrail.co.uk/OpenLDBWS/ldb11.asmx"
    }
} 