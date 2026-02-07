//
//  DisruptionsModel.swift
//  Transit Bandage
//
//  Created by Conrad on 6/10/24.
//

import Foundation

struct Line_ServiceDisruption_Delay: Hashable, Codable, Identifiable {
    var id: UUID {
        return UUID()
    }
    var destination: String
    var delayAmmount: Int
    var location: String
}

struct Line_ServiceDisruption_Reroutes: Hashable, Codable, Identifiable {
    var id: UUID {
        return UUID()
    }
    var reroutedFrom: String
    var reroutedTo: String
    var via: String
    var sudden: Bool
    var occurances: Int
}

struct Line_ServiceDisruption_Local: Hashable, Codable, Identifiable {
    var id: UUID {
        return UUID()
    }
    var stations: [String]
    var occurances: Int
}

struct Line_ServiceDisruption_Skipped: Hashable, Codable, Identifiable {
    var id: UUID {
        return UUID()
    }
    var stations: [String]
    var occurances: Int
}

struct Line_ServiceDisruption_Suspended: Hashable, Codable, Identifiable {
    var id: UUID {
        return UUID()
    }
    var stations: [String]
    var occurances: Int
}

struct Line_ServiceDisruptionDirection: Hashable, Codable, Identifiable {
    var id: UUID {
        return UUID()
    }
    var delays: [String: Line_ServiceDisruption_Delay]?
    var reroutes: [String: Line_ServiceDisruption_Reroutes]?
    var localStations: [String: Line_ServiceDisruption_Local]?
    var skippedStations: [String: Line_ServiceDisruption_Skipped]?
    var suspended: [String: Line_ServiceDisruption_Suspended]?
    
}

struct Line_ServiceDisruption: Hashable, Codable, Identifiable {
    var id: UUID {
        return UUID()
    }
    var northbound: Line_ServiceDisruptionDirection
    var southbound: Line_ServiceDisruptionDirection
    var overview: DisruptionOverview
    var new: [String: DisruptionNew]
}


struct DisruptionOverview: Hashable, Codable, Identifiable {
    var id: UUID {
        return UUID()
    }
    var service: Bool
    var segments: [String: StationPair]
}

struct StationPair: Hashable, Codable, Identifiable {
    var id: UUID {
        return UUID()
    }
    var occurances: Int
    var startTime: Int
    var stations: [String]
}



struct DisruptionNew: Hashable, Codable, Identifiable {
    var id: UUID {
        return UUID()
    }
    
    var direction: String
    var performance: Performance
    var reroutes: [String: Line_ServiceDisruption_Reroutes]?
    var serviceAlerts: ServiceAlerts
}

struct Performance: Hashable, Codable {
    var OTP: Double
    var trainsInService: Int
    var delays: [String: IndividualDelay]
}
                 
struct IndividualDelay: Hashable, Codable, Identifiable {
    var id: UUID {
        return UUID()
    }
    var destination: String
    var delayAmmount: Int
    var location: String
    var track: String
}

struct ServiceAlerts: Hashable, Codable {
    var suspended: [String: Line_ServiceDisruption_Suspended]?
    var localStations: [String: LocalStations]?
    var skippedStations: [String: SkippedStations]?
}

struct LocalStations: Hashable, Codable, Identifiable {
    var id: UUID {
        return UUID()
    }
    var from: String
    var to: String
    var stations: [[String]]?
    var skipping: [String]?
    var occurances: Int
}
struct SkippedStations: Hashable, Codable, Identifiable {
    var id: UUID {
        return UUID()
    }
    var from: String
    var to: String
    var type: String
    var stations: [[String]]?
    var stoppingAt: [String]?
    var occurances: Int
}


struct LineDisruptionSummary: Hashable, Codable, Identifiable {
    var id: UUID {
        return UUID()
    }
    var description: String
    var disruptions: [String]
    var lines: [String]
}

