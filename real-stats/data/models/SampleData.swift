//
//  SampleData.swift
//  Service Bandage
//
//  Created by Conrad on 6/25/24.
//

import SwiftUI

let defaultBusTimes_dict_large = [
    "401091": defaultBusTimes,
    "401092": defaultBusTimes,
    "401090": defaultBusTimes,
    "401029": defaultBusTimes,
    "401334": defaultBusTimes,
    "401256": defaultBusTimes,
    "401335": defaultBusTimes,
    "401257": defaultBusTimes,
    "404320": defaultBusTimes,
    "401030": defaultBusTimes,
    "401333": defaultBusTimes,
    "401255": defaultBusTimes,
    "401336": defaultBusTimes,
    "401258": defaultBusTimes,
    "403111": defaultBusTimes,
    "401936": defaultBusTimes,
    "404308": defaultBusTimes,
    "404075": defaultBusTimes,
    "401898": defaultBusTimes,
    "403159": defaultBusTimes,
    "401254": defaultBusTimes
]

let defaultBusTimes_dict = ["401906": defaultBusTimes, "401921": defaultBusTimes]
let defaultBusTimes =  Bus_Times(service: true, times: defaultTimesForBus)

let defaultTimesForBus: [String: [String: IndividualBusTime]] = [
    "M101": [
        "1705779137": IndividualBusTime(tripID: "AB*M101", destination: "401331", next_stops: ["403777","401946","403436","405181","402502"])
    ],
    "M102": [
        "1705779237": IndividualBusTime(tripID: "AB*M102", destination: "401331", next_stops: ["402696","402697","403765","403777","401946"]),
        "1705779337": IndividualBusTime(tripID: "AB*M102", destination: "401331", next_stops: ["402696","402697","403765","403777","401946"]),
    ],
    "M103": [
        "1705779437": IndividualBusTime(tripID: "AB*M103", destination: "401331", next_stops: ["402696","402697","403765","403777","401946"]),
    ]
]


var exampleTripAndStationData: TripAndStation = load("tripAndStationData.json")
var exampleTrips: [String: Trip] = load("stopTimes.json")
var exampleTrip: Trip = load("stopTime.json")
var exampleServiceAlerts: [String: Line_ServiceDisruption] = load("exampleServiceDisruptions.json")
var exampleServiceAlert: Line_ServiceDisruption = load("exampleServiceDisruption.json")
var exampleLineDisruptionSummary: [String: LineDisruptionSummary] = load("exampleLineDisruptionSummary.json")
var stationsDict: [String: TripStationEntry] = load("tripStationData.json")

var defaultBusTrip: BusTrip = load("defaultBusTrip.json")

var defaultStationTimes: NewTimes = load("608.json")
var placeHolderStationTimes: NewTimes = load("601.json")
