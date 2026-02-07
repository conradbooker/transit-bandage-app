//
//  StationView.swift
//  real-stats
//
//  Created by Conrad on 3/13/23.
//

import SwiftUI
//import WrappingHStack
import StoreKit
import Reachability
import CoreLocation
import WrappingStack

func getSortedTimes(direction: [String: NewStationTime]?, destination: String = "", track: String = "") -> [String] {
    var arr = [String]()
    for time in direction!.keys {
        if destination == "" {
            arr.append(time)
        } else {
            if destination == direction?[time]?.destination && track == direction?[time]?.track {
                arr.append(time)
            }
        }
    }
    arr = arr.sorted()
    return Array(arr.prefix(3))
}


struct StationView: View {
//    @Environment(\.requestReview) var requestReview: RequestReviewAction

//    @FetchRequest private var favoriteStations: FetchedResults<FavoriteStation>
    
    @State var isInternetConnected = true
    
    private func checkInternetConnection() {
        guard let reachability = try? Reachability() else {
            return
        }

        if reachability.connection != .unavailable {
            isInternetConnected = true
        } else {
            isInternetConnected = false
        }
    }

    let persistentContainer = CoreDataManager.shared.persistentContainer
    
    @FetchRequest(entity: FavoriteStation.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var favoriteStations: FetchedResults<FavoriteStation>

    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
    
    var complex: Complex
    @State var chosenStation: Int
    
    @State var refreshButtonRotation: Double = 0.0
    
//    @State private var isFavorited: Bool
    
    private func getWidth(_ items: [String]) -> CGFloat {
        var width = 0
        for item in items {
            if ["PATH"].contains(item) {
                width += 30
            }
            width += 30
        }
        width += 15
        return CGFloat(width)
    }
    
    @State var times: NewTimes = load("608.json")
    @State var trips: [String: Trip] = load("stopTimes.json")
    
    @State var tripKeys: [String] = []
    
    @State var short1Size = CGSize()
    @State var short2Size = CGSize()
    @State var lineSelectorSize = CGSize()
    
    @State var isFavorited: Bool
    
    init(complex: Complex, chosenStation: Int, isFavorited: Bool) {
        self.complex = complex
        if chosenStation > complex.stations.count {
            self._chosenStation = State(initialValue: 0)
        } else {
            self._chosenStation = State(initialValue: chosenStation)
        }
        
        self._isFavorited = State(initialValue: isFavorited)
        
    }
            
    func deleteFavorite() {
        for favoriteStation in favoriteStations {
//            print(favoriteStation)
            if favoriteStation.complexID == complex.id && favoriteStation.chosenStationNumber == chosenStation {
                viewContext.delete(favoriteStation)
                do {
                    try viewContext.save()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func addFavorite() {
        let favoriteStation = FavoriteStation(context: viewContext)
        favoriteStation.complexID = Int16(complex.id)
        favoriteStation.chosenStationNumber = Int16(chosenStation)
        favoriteStation.dateCreated = Date()
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @State private var loading = 0
    @State private var showBus = false
    
    @AppStorage("trackTimes") var trackTimes: Bool = true
    
    var isStatenIsland: Bool {
        if ["S09", "S31", "D43", "247", "701", "726", "401", "601", "901"].contains(complex.stations[chosenStation].GTFSID) {
            return true
        }
        return false
    }
    
    private func getTimesWithTracks() -> NewTimesTrack {
        var fullDictNorth = [String: [String: [String: NewStationTime]]]()
        
        for line in Array(times.north!.keys).sorted() {
            var destinations: Set<String> = Set<String>()
            
            for individual_time in Array(arrayLiteral: times.north![line]!) {
                let allTimes = (individual_time ?? [String : NewStationTime]())

                for actualTime in allTimes {
                    let track = String(actualTime.value.track ?? "")
                    let destination = String(actualTime.value.destination)
                    
                    if Array(fullDictNorth.keys ?? [:].keys).contains(track) {
                        if Array(fullDictNorth[track]?.keys ?? [:].keys).contains("\(line)*\(destination)") {
                            fullDictNorth[track]?["\(line)*\(destination)"]?[String(actualTime.key)] = actualTime.value
                        } else {
                            fullDictNorth[track]?["\(line)*\(destination)"] = [String(actualTime.key): actualTime.value]
                        }
                    } else {
                        fullDictNorth[track] = ["\(line)*\(destination)": [String(actualTime.key): actualTime.value]]
                    }
                }
            }
        }
        
        
        var fullDictSouth = [String: [String: [String: NewStationTime]]]()
        
        for line in Array(times.south!.keys).sorted() {
            var destinations: Set<String> = Set<String>()
            
            for individual_time in Array(arrayLiteral: times.south![line]!) {
                let allTimes = (individual_time ?? [String : NewStationTime]())

                for actualTime in allTimes {
                    let track = String(actualTime.value.track ?? "")
                    let destination = String(actualTime.value.destination)
                    
                    if Array(fullDictSouth.keys ?? [:].keys).contains(track) {
                        if Array(fullDictSouth[track]?.keys ?? [:].keys).contains("\(line)*\(destination)") {
                            fullDictSouth[track]?["\(line)*\(destination)"]?[String(actualTime.key)] = actualTime.value
                        } else {
                            fullDictSouth[track]?["\(line)*\(destination)"] = [String(actualTime.key): actualTime.value]
                        }
                    } else {
                        fullDictSouth[track] = ["\(line)*\(destination)": [String(actualTime.key): actualTime.value]]
                    }
                }
            }
        }
//        print(fullDict)
        let thingToReturn = NewTimesTrack(service: true, north: fullDictNorth, south: fullDictSouth)
        return thingToReturn
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ZStack {
                    // MARK: - Main Content
                    bgColor.first.value
                        .ignoresSafeArea()
                        .onAppear {
                            checkInternetConnection()
                        }
                        .onAppear {
                            print("updating...")
                        }
                    ScrollView {
                        if showBus {
                            Spacer().frame(height:lineSelectorSize.height + short1Size.height + short2Size.height + 40)
                            BusView(coordinate: complex.location.coordinate, counter: refreshButtonRotation)
                        } else {
                            VStack(alignment: .leading) {
                                Spacer().frame(height:lineSelectorSize.height + short1Size.height + short2Size.height + 40)
//                                    .onAppear {
//                                        print(chosenStation)
//                                    }
                                
                                // MARK: - No Wifi
                                
                                if !isInternetConnected {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(bgColor.second.value)
                                            .shadow(radius: 2)
                                            .frame(height: 100)
                                            .padding()
                                        HStack {
                                            Image(systemName: "wifi.slash")
                                                .foregroundStyle(.red, .black)
                                                .font(.system(size: 60))
                                                .shadow(radius: 2)
                                                .padding()
                                            Text(String(format: NSLocalizedString("no-connection", comment: "")))
                                                .font(.headline)
                                                .fontWeight(.semibold)
                                                .padding(5)
                                                .frame(width: geometry.size.width / 2)
                                        }
                                    }
                                } else {
                                    if loading == 2 {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .foregroundColor(bgColor.second.value)
                                                .shadow(radius: 2)
                                                .frame(height: 100)
                                                .padding()
                                            HStack {
                                                ActivityIndicator()
                                                    .frame(width: 80, height: 80)
                                                    .padding()
                                                Text(String(format: NSLocalizedString("loading", comment: "")))
                                                    .font(.headline)
                                                    .fontWeight(.semibold)
                                                    .padding(5)
                                                    .frame(width: geometry.size.width / 2)
                                            }
                                        }
                                    }
                                    if times.service {
                                        if (Array(times.north!.keys).sorted().count < 1) {
                                            if loading < 2 {
// MARK: - No North Service
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .foregroundColor(bgColor.second.value)
                                                        .shadow(radius: 2)
                                                        .frame(height: 100)
                                                        .padding()
                                                    HStack {
                                                        Image(systemName: "exclamationmark.triangle.fill")
                                                            .foregroundStyle(.black, .yellow)
                                                            .font(.system(size: 60))
                                                            .shadow(radius: 2)
                                                            .padding()
                                                        Text(String(format: NSLocalizedString("no-service", comment: ""), complex.stations[chosenStation].northDir))
                                                            .font(.headline)
                                                            .fontWeight(.semibold)
                                                            .padding(5)
                                                            .frame(width: geometry.size.width / 2)
                                                    }
                                                }
                                                .padding(.bottom,-20)
                                                .onAppear {
                                                    loading += 1
                                                }
                                            }
// MARK: - North Times
                                        } else if loading < 2 {
                                            Text(complex.stations[chosenStation].northDir)
                                                .font(.title3)
                                                .padding(.horizontal)
                                                .padding(.top,2)
                                                .padding(.bottom, -4)
                                                .onAppear {
                                                    loading = 0
                                                }
                                            // sorted track things would go here
                                            if trackTimes {
                                                ForEach(Array(getTimesWithTracks().north?.keys ?? [:].keys).sorted(), id: \.self) { track in
                                                    if isStatenIsland || Int(track) ?? 0 > 4 {
                                                        Text("Track \(track)")
                                                            .padding(.horizontal)
                                                            .padding(.top, 1)
                                                            .padding(.bottom, -2)
                                                    } else if Int(track) ?? 0 <= 0  {
                                                    } else if trackNames[complex.stations[chosenStation].GTFSID]?.showTrackLabel == true {
                                                        Text(trackNames[complex.stations[chosenStation].GTFSID]?.tracks[Int(Int(track) ?? 0)-1] ?? "")
                                                            .padding(.horizontal)
                                                            .padding(.top, 1)
                                                            .padding(.bottom, -2)
                                                    }

//                                                    trackNames[complex.stations[chosenStation].GTFSID]?.tracks[Int(track) ?? 0]
                                                    ForEach(Array(getTimesWithTracks().north?[track]!!.keys ?? [:].keys).sorted(), id: \.self) { line in
                                                        //                                                        Text(line)
                                                        StationTimeRow(
                                                            line: String(String(line).split(separator: "*")[0]),
                                                            direction: "N",
                                                            trainTimes: times,
                                                            times: getSortedTimes(
                                                                direction: times.north![String(String(line).split(separator: "*")[0])]!!,
                                                                destination: String(String(line).split(separator: "*")[1]),
                                                                track: track
                                                            ),
                                                            trips: trips
                                                        )
                                                        .environment(\.managedObjectContext, persistentContainer.viewContext)
                                                        .padding(.horizontal,5)
                                                        .frame(height: 55)
                                                    }
                                                }
                                            } else {
                                                ForEach(Array(times.north!.keys).sorted(), id: \.self) { line in
                                                    StationTimeRow(
                                                        line: line,
                                                        direction: "N",
                                                        trainTimes: times,
                                                        times: getSortedTimes(direction: times.north![line]!!),
                                                        trips: trips
                                                    )
                                                    .environment(\.managedObjectContext, persistentContainer.viewContext)
                                                    .padding(.horizontal,5)
                                                    .frame(height: 55)
//                                                    .onAppear {
//                                                        print("-----")
//                                                        print(trips)
//                                                    }
                                                    
                                                }
                                            }
                                        }
// MARK: - No South Loading
                                        if (Array(times.south!.keys).sorted().count < 1) {
                                            if loading < 2 {
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .foregroundColor(bgColor.second.value)
                                                        .shadow(radius: 2)
                                                        .frame(height: 100)
                                                        .padding()
                                                    HStack {
                                                        Image(systemName: "exclamationmark.triangle.fill")
                                                            .foregroundStyle(.black, .yellow)
                                                            .font(.system(size: 60))
                                                            .shadow(radius: 2)
                                                            .padding()
                                                        Text(String(format: NSLocalizedString("no-service", comment: ""), complex.stations[chosenStation].southDir))
                                                            .font(.headline)
                                                            .fontWeight(.semibold)
                                                            .padding(5)
                                                            .frame(width: geometry.size.width / 2)
                                                    }
                                                }
                                                .padding(.bottom,-20)
                                                .onAppear {
                                                    loading += 1
                                                }
                                            }
// MARK: - South Times
                                        } else if loading < 2 {
                                            Divider()
                                                .padding(.top)
                                            Text(complex.stations[chosenStation].southDir)
                                                .font(.title3)
                                                .padding(.horizontal)
                                                .padding(.bottom, -4)
                                                .onAppear {
                                                    loading = 0
                                                }
                                            if trackTimes {
                                                ForEach(Array(getTimesWithTracks().south?.keys ?? [:].keys).sorted(), id: \.self) { track in
                                                    if isStatenIsland || Int(track) ?? 0 > 4 {
                                                        Text("Track \(track)")
                                                            .padding(.horizontal)
                                                            .padding(.top, 1)
                                                            .padding(.bottom, -2)
                                                    } else if Int(track) ?? 0 <= 0  {
                                                    } else if trackNames[complex.stations[chosenStation].GTFSID]?.showTrackLabel == true {
                                                        Text(trackNames[complex.stations[chosenStation].GTFSID]?.tracks[Int(Int(track) ?? 0)-1] ?? "")
                                                            .padding(.horizontal)
                                                            .padding(.top, 1)
                                                            .padding(.bottom, -2)
                                                    }

                                                    ForEach(Array(getTimesWithTracks().south?[track]!!.keys ?? [:].keys).sorted(), id: \.self) { line in
//                                                        Text(line)
                                                        StationTimeRow(
                                                            line: String(String(line).split(separator: "*")[0]),
                                                            direction: "S",
                                                            trainTimes: times,
                                                            times: getSortedTimes(
                                                                direction: times.south![String(String(line).split(separator: "*")[0])]!!,
                                                                destination: String(String(line).split(separator: "*")[1]),
                                                                track: track
                                                            ),
                                                            trips: trips
                                                        )
                                                        .environment(\.managedObjectContext, persistentContainer.viewContext)
                                                        .padding(.horizontal,5)
                                                        .frame(height: 55)
//                                                        .onAppear {
//                                                            print("--=++--")
//                                                            print(trips)
//                                                        }
                                                    }
                                                }
                                            } else {
                                                ForEach(Array(times.south!.keys).sorted(), id: \.self) { line in
                                                    StationTimeRow(
                                                        line: line,
                                                        direction: "S",
                                                        trainTimes: times,
                                                        times: getSortedTimes(direction: times.south![line]!!),
                                                        trips: trips
                                                    )
                                                    .environment(\.managedObjectContext, persistentContainer.viewContext)
                                                    .padding(.horizontal,5)
                                                    .frame(height: 55)
                                                }
                                            }
                                        }
                                    } else {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .foregroundColor(bgColor.second.value)
                                                .shadow(radius: 2)
                                                .frame(height: 100)
                                                .padding()
                                            HStack {
                                                Image(systemName: "exclamationmark.triangle.fill")
                                                    .foregroundStyle(.black, .yellow)
                                                    .font(.system(size: 60))
                                                    .shadow(radius: 2)
                                                    .padding()
                                                Text("No service at this station ☹️")
                                                    .font(.headline)
                                                    .fontWeight(.semibold)
                                                    .padding(.leading, -5)
                                            }
                                        }
                                    }
                                    Spacer()
                                        .frame(height: 100)
                                }
                                
                            }
                        }
                    }
                    // MARK: - Top Part
                    ZStack {
                        VStack {
                            Rectangle()
                                .frame(width: geometry.size.width, height: lineSelectorSize.height + short1Size.height + short2Size.height + 30)
                                .foregroundColor(bgColor.second.value)
                                .shadow(radius: 2)
                            Spacer()
                        }
                        VStack(spacing: 0) {
                            Capsule()
                                .fill(Color("second"))
                                .frame(width: 34, height: 4.5)
                                .padding(.top, 6)
                                .onAppear {
                                    apiCall().getStationAndTrips(station: complex.stations[chosenStation].GTFSID) { (stationAndTrip) in
                                        self.times = stationAndTrip.station
                                        self.trips = stationAndTrip.trips
                                        withAnimation(.spring(response: 0.31, dampingFraction: 1-0.26)) {
                                            loading = 0
                                        }
                                    }
                                    
                                }
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(complex.stations[chosenStation].short1)
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .readSize { size in
                                            short1Size = size
                                        }
                                    Text(complex.stations[chosenStation].short2)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .readSize { size in
                                            short2Size = size
                                        }
                                }
                                .padding(.leading)
                                .padding(.vertical, 10)
                                Spacer()
                                
                                // MARK: - ADA Button
                                
                                Button {
                                    
                                } label: {
                                    if complex.stations[chosenStation].ADA > 0 {
                                        Image("ADA")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                    }
                                }
                                .buttonStyle(CButton())
                                .shadow(radius: 2)
                                
                                // MARK: - Favorite Button
                                Button {
                                    if isFavorited {
                                        withAnimation(.linear(duration: 0.1)) {
                                            isFavorited = false
                                        }
                                        deleteFavorite()
                                    } else {
                                        withAnimation(.linear(duration: 0.1)) {
                                            isFavorited = true
                                        }
                                        addFavorite()
                                    }
                                } label: {
                                    Image(systemName: isFavorited ? "star.fill" : "star")
                                        .resizable()
                                        .foregroundColor(isFavorited ? .yellow : Color("whiteblack"))
                                        .frame(width: 30, height: 30)
                                        .padding(.trailing)
                                        .shadow(radius: 2)
                                }
                                .buttonStyle(CButton())
                            }
                            
                            // MARK: - Station Selector
                            WrappingHStack(id: \.self, alignment: .leading) {
                                ForEach(0..<complex.stations.count+1, id: \.self) { index in
                                    if index == complex.stations.count {
                                        Button {
                                            withAnimation(.spring(response: 0.31, dampingFraction: 1-0.26)) {
                                                showBus = true
                                                refreshButtonRotation += 360
                                                checkInternetConnection()
                                                loading = 2
                                            }
                                        } label: {
                                            VStack {
                                                ZStack {
                                                    if showBus {
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .foregroundColor(bgColor.third.value)
                                                            .frame(width: 100, height: 40)
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: 13)
                                                                    .stroke(.blue,lineWidth: 2)
                                                                    .frame(width: 108, height: 48)
                                                            )
                                                            .shadow(radius: 2)
                                                    } else {
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .foregroundColor(bgColor.third.value)
                                                            .frame(width: 68, height: 40)
                                                            .shadow(radius: 2)
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: 12)
                                                                    .stroke(bgColor.second.value,lineWidth: 2)
                                                                    .frame(width: 76, height: 48)
                                                            )
                                                        
                                                    }
                                                    HStack(spacing: 2.5) {
                                                        Image("BUS")
                                                            .resizable()
                                                            .frame(width: 60, height: 30)
                                                        if showBus {
                                                            Image(systemName: "arrow.clockwise")
                                                                .frame(width: 30, height: 30)
                                                                .rotationEffect(.degrees(refreshButtonRotation))
                                                        }
                                                    }
                                                }
                                            }
                                            
                                        }
                                        .padding([.leading,.bottom])
                                        .buttonStyle(CButton())
                                        
                                    } else {
                                        Button {
                                            withAnimation(.spring(response: 0.31, dampingFraction: 1-0.26)) {
                                                showBus = false
                                                chosenStation = index
                                                refreshButtonRotation += 360
                                                checkInternetConnection()
                                                loading = 2
                                            }
                                            
                                            apiCall().getStationAndTrips(station: complex.stations[chosenStation].GTFSID) { (stationAndTrip) in
                                                withAnimation(.spring(response: 0.31, dampingFraction: 1-0.26)) {
                                                    self.times = stationAndTrip.station
                                                    self.trips = stationAndTrip.trips
                                                    //                                    print(stationAndTrip)
                                                    withAnimation(.spring(response: 0.31, dampingFraction: 1-0.26)) {
                                                        loading = 0
                                                    }
                                                    
                                                }
                                            }
                                        } label: {
                                            VStack {
                                                ZStack {
                                                    if chosenStation == index && !showBus {
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .foregroundColor(bgColor.third.value)
                                                            .frame(width: getWidth(complex.stations[index].weekdayLines) + 30, height: 40)
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: 13)
                                                                    .stroke(.blue,lineWidth: 2)
                                                                    .frame(width: getWidth(complex.stations[index].weekdayLines) + 38, height: 48)
                                                            )
                                                            .shadow(radius: 2)
                                                    } else {
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .foregroundColor(bgColor.third.value)
                                                            .frame(width: getWidth(complex.stations[index].weekdayLines), height: 40)
                                                            .shadow(radius: 2)
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: 12)
                                                                    .stroke(bgColor.second.value,lineWidth: 2)
                                                                    .frame(width: getWidth(complex.stations[index].weekdayLines) + 8, height: 48)
                                                            )
                                                        
                                                    }
                                                    HStack(spacing: 2.5) {
                                                        ForEach(complex.stations[index].weekdayLines, id: \.self) { line in
                                                            if line == "PATH" {
                                                                Image(line)
                                                                    .resizable()
                                                                    .frame(width: 60, height: 30)
                                                            } else {
                                                                Image(line)
                                                                    .resizable()
                                                                    .frame(width: 30, height: 30)
                                                            }
                                                        }
                                                        if chosenStation == index && !showBus {
                                                            Image(systemName: "arrow.clockwise")
                                                                .frame(width: 30, height: 30)
                                                                .rotationEffect(.degrees(refreshButtonRotation))
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        .padding([.leading,.bottom])
                                        .buttonStyle(CButton())
                                    }
                                    
                                }
                            }
                            .readSize { size in
                                lineSelectorSize = size
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}

struct StationView_Previews: PreviewProvider {
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistentContainer
            StationView(complex: complexData[423], chosenStation: 0, isFavorited: false)
                .environment(\.managedObjectContext, persistedContainer.viewContext)
    }
}
