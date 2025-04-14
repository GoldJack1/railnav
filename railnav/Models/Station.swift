import Foundation

struct Station: Identifiable {
    let id: String // CRS code
    let name: String
    let latitude: Double
    let longitude: Double
    let iataAirportCode: String?
    var manager: String?
    var managerCode: String?
    var isPlatformsHidden: Bool = false
    var isServicesAvailable: Bool = true
    
    init(id: String, name: String, latitude: Double, longitude: Double, iataAirportCode: String? = nil, manager: String? = nil, managerCode: String? = nil, isPlatformsHidden: Bool = false, isServicesAvailable: Bool = true) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.iataAirportCode = iataAirportCode
        self.manager = manager
        self.managerCode = managerCode
        self.isPlatformsHidden = isPlatformsHidden
        self.isServicesAvailable = isServicesAvailable
    }
} 