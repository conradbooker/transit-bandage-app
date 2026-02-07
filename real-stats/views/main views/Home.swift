//
//  Home.swift
//  real-stats
//
//  Created by Conrad on 3/20/23.
//

import SwiftUI
import CoreLocation
import BottomSheet
import WrappingStack
import Reachability

func rand() -> Int {
    return Int.random(in: 1..<445)
}

struct Item: Identifiable {
    let id = UUID()
    let complex: Complex
}

struct BusItem: Identifiable {
    let id = UUID()
    let stopID: String
}

//var exampleStationTimes: NewTimes = load("608.json")

func correctComplex(_ id: Int) -> Complex {
    for station in complexData {
        if station.id == id {
            return station
        }
    }
    return complexData[0]
}

struct Home: View {
            
    @State var bottomSheetPosition: BottomSheetPosition = .relative(0.65) // 0.65
    @State var lastBottomSheetPosition: BottomSheetPosition?
    @State var sheetWidth = UIScreen.screenWidth
    
    @State var bottomSheetSize = CGSize()
    let backgroundColors: [Color] = [Color(red: 0.28, green: 0.28, blue: 0.53), Color(red: 1, green: 0.69, blue: 0.26)]
    
    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
    @EnvironmentObject var locationViewModel: LocationViewModel
    var coordinate: CLLocationCoordinate2D? {
        locationViewModel.lastSeenLocation?.coordinate
    }
    
    @State private var search: String = ""
    @State private var showStation: Bool = false
    @State private var complex: Complex = complexData[0]
    
    @State var selectedItem: Item?
    @State var selectedBusStop: BusItem?
    @State var selectedDisruption: DisruptionItem?

    @State var fromFavorites: Bool = false
    @State var chosenStation: Int = 0
    
    @FetchRequest(entity: FavoriteStation.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var favoriteStations: FetchedResults<FavoriteStation>
    @FetchRequest(entity: FavoriteLine.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var favoriteLines: FetchedResults<FavoriteLine>

//    private func getNearByStations(_ location: MK)
//    for station in stations, if station.location choser than station-1, set.add

    @State var searchStations: [Complex] = []
    @State var searchBusStops: [BusStop_Array] = []

    @FocusState var inputIsActive: Bool
    
    @AppStorage("stationTimes", store: UserDefaults(suiteName: "group.Schematica.real-stats")) var timeData: String = ""
    
    @AppStorage("version") var version: String = "2.5"
    @State var showWhatsNew = false
    @State var showNeedsUpdate = false

    @State private var duration = 0.2
    @State private var bounce = 0.2
    
    @State private var previouslySelectedSearchType: String = ""
    
    let bundleId = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
    
    func correctComplex(_ id: Int) -> Complex {
        for station in complexData {
            if station.id == id {
                return station
            }
        }
        return complexData[0]
    }
    
    func lookForNearbyStations() -> [Complex] {
        let currentLoc = CLLocation(latitude: coordinate?.latitude ?? 0, longitude: coordinate?.longitude ?? 0)
        let stations = complexData
            .sorted(by: {
                return $0.location.distance(from: currentLoc) < $1.location.distance(from: currentLoc)
            })
        var newStations = [Complex]()
        
        for num in 0...10 {
            newStations.append(stations[num])
        }
                
        return newStations
    }
    
    func getNearByBusStops(coordinate: CLLocationCoordinate2D) -> [String] {
        let currentLoc = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let stations = busData_array
            .sorted(by: {
                return $0.location.distance(from: currentLoc) < $1.location.distance(from: currentLoc)
            })
        var newStations = [String]()
        
        for num in 0...15 {
            newStations.append(String(stations[num].id))
        }
                
        return newStations
    }
    
    func returnReverse() -> ColorScheme {
        if colorScheme == .dark {
            return .light
        }
        return .dark
    }
    
    func getSummaryKeys(_ dict: [String: LineDisruptionSummary], _ category: String) -> [String] {
        var keys = [String]()
        for item in dict {
            if category == "all" {
                keys.append(item.key)
            } else if item.value.disruptions.first ?? "" == category {
                keys.append(item.key)
            }
        }
        
        return keys
    }
    
    func getFavoriteLines() -> [String] {
        var thingToReturn = [String]()
        for favoriteLine in favoriteLines {
            thingToReturn.append(favoriteLine.line ?? "")
        }
        return thingToReturn
    }
    
    func checkIfAny(_ type: String) -> Bool {
        for line in summary {
            if line.value.disruptions.first ?? "" == type {
                return true
            }
        }
        return false
    }
    
    @State private var searchTypes = ["Subway", "Bus", "Rail"]
    @State var selectedSearchType = "Subway"
    @State var showTypes = false
    
    @State private var keyboardHeight: CGFloat = 0
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var summary: [String: LineDisruptionSummary] = exampleLineDisruptionSummary
    
    @State private var counter: Double = 0
    
    var dict: [String: String] = [
        "good_service": "Good Service!",
        "behind_schedule": "Behind Schedule",
        "no_service": "No Service",
        "reroutes": "Reroutes",
        "suspended": "Partially Suspended",
        "delays": "Delays",
        "express": "Skipped Stations",
        "local": "Local"
    ]
    
    var lineSummaryKeys = [
        "good_service",
        "suspended",
        "reroutes",
        "express",
        "local",
        "delays",
        "behind_schedule",
        "no_service"
    ]
    
    var searchText: String {
        if selectedSearchType == "Subway" {
            return "Search for a Subway or PATH station"
        }
        return "Search for a Bus stop"
    }
    
    @State private var loading: Bool = false
    
    private func checkInternetConnection() {
        guard let reachability = try? Reachability() else {
            return
        }

        if reachability.connection != .unavailable {
            isInternetConnected = true
        } else {
            isInternetConnected = false
            loading = false
        }
    }
    
    @State private var isInternetConnected = true
    
    
    var searchPaddingHeight: CGFloat {
        if UIScreen.screenHeight < 812 && keyboardHeight == 0 {
            return 0
        }
        return 26
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                MapView()
//                Text("hiii")
                    .onAppear {
                        apiCall().getLineSummary() { (summary) in
                            self.summary = summary
                            loading = false
                        }
                        print(UIScreen.screenHeight)
                        if version != (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "") {
                            showWhatsNew = true
                            version = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
                        }
                        print(version, (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""))
                    }
                    .environment(\.managedObjectContext, CoreDataManager.shared.persistentContainer.viewContext)
                    .environmentObject(locationViewModel)
                    .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
                    .padding(.leading, -UIScreen.screenWidth)
                Spacer().frame(width: 0.01,height: 0.01)
                    .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
                    


                    .bottomSheet(bottomSheetPosition: self.$bottomSheetPosition, switchablePositions: [
                        .relativeBottom(0.25),
                        .relative(0.65),
                        .relativeTop(0.975)
                    ]
                     , headerContent: {
                        // MARK: - HEADER
                        VStack {
                            HStack(spacing: 2) {
                                ForEach(searchTypes, id: \.self) { type in
                                    Button {
                                        selectedSearchType = type
                                        if previouslySelectedSearchType == "Bus" {
                                            bottomSheetPosition = lastBottomSheetPosition ?? .relative(0.65)
                                            previouslySelectedSearchType = ""
                                        } else if selectedSearchType == "Bus" {
                                            lastBottomSheetPosition = bottomSheetPosition
                                            bottomSheetPosition = .relativeTop(0.975)
                                            previouslySelectedSearchType = "Bus"
                                        }
                                        let temp = searchTypes[0]
                                        let currentIndex = searchTypes.firstIndex(of: type) ?? 0
                                        searchTypes[0] = type
                                        searchTypes[currentIndex] = temp
                                    } label: {
                                        if type == selectedSearchType {
                                            Text("**\(type)**")
                                                .font(.title)
                                                .padding(.horizontal,5)
                                                .padding(.vertical,2)
//                                                .padding(3)
//                                                .background(
//                                                    bgColor.fifth.value
//                                                        .cornerRadius(12)
//                                                        .shadow(radius: 2)
//                                                )
                                            
                                        } else {
                                            Text(type)
                                                .padding(.horizontal,5)
                                                .opacity(0.5)
                                                .padding(.top, 2)
                                        }
                                    }
                                    .buttonStyle(CButton())
                                }
                                Spacer()
                                Button {
                                    if selectedSearchType == "Subway" {
                                        loading = true
                                        apiCall().getLineSummary() { (summary) in
                                            withAnimation(.spring(response: 0.4)) {
                                                self.summary = summary
                                                loading = false
                                            }
                                        }
                                    } else if selectedSearchType == "Bus" {
                                        counter += 1
                                    }
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(bgColor.fifth.value)
                                            .shadow(radius: 2)
                                        Image(systemName: "arrow.clockwise")
                                    }
                                }
                                .buttonStyle(CButton())
                                .padding(.trailing, 20)
                            }
                            .padding(.leading, 6)
                            .padding(.top, -5)
                        }
                    }
                    ) {
                        ScrollView {
                            VStack(spacing: 0) {
// MARK: - SEARCH - Subway
                                if selectedSearchType == "Subway" {
                                    ForEach(searchStations, id: \.self) { station in
                                        Button {
                                            DispatchQueue.main.async {
                                                selectedItem = Item(complex: station)
                                                for favoriteStation in favoriteStations {
                                                    if favoriteStation.complexID == station.id {
                                                        fromFavorites = true
                                                        break
                                                    }
                                                    fromFavorites = false
                                                }
                                            }
                                        } label: {
                                            StationRow(complex: station)
                                                .frame(width: geometry.size.width-12)
                                        }
                                        .buttonStyle(CButton())
                                    }
                                    if !search.isEmpty {
                                        Spacer().frame(height: 200 + keyboardHeight)
                                        
                                    }
                                }
// MARK: - SEARCH - Bus
                                else if selectedSearchType == "Bus" {
                                    ForEach(searchBusStops, id: \.self) { stop in
                                        
                                        Button {
//                                            selectedItem = Item(complex: station)
//                                            for favoriteStation in favoriteStations {
//                                                if favoriteStation.complexID == station.id {
//                                                    fromFavorites = true
//                                                    break
//                                                }
//                                                fromFavorites = false
//                                            }
                                        } label: {
                                            BusSearchRow(stop_id: String(stop.id))
                                                .frame(width: geometry.size.width-12)
                                        }
                                        .buttonStyle(CButton())
                                    }
                                }
// MARK: - SEARCH - Rail
                                else {
                                    
                                }
                            }
                            
// MARK: - MAIN CONTENT - Subway
                            if search.isEmpty && selectedSearchType == "Subway" {
                                HStack {
                                    Text("Favorite Stations")
                                        .padding(.horizontal, 12)
                                        .padding(.bottom, -20)
                                        .padding(.top,4)
                                    Spacer()
                                }
                                if favoriteStations.count == 0 {
                                    ZStack {
                                        bgColor.third.value
                                            .background()
                                            .cornerRadius(10)
                                            .shadow(radius: 2)
//                                            .frame(width: 130,height: 82)
                                        VStack {
                                            Text("**You have no favorited stations!**")
                                            HStack(spacing: 0) {
                                                Spacer()
                                                Text("Press the")
                                                Image(systemName: "star")
                                                    .shadow(radius: 2)
                                                Text("in the top right of a station")
                                                Spacer()
                                            }
                                            Text("to favorite it.")
                                        }
                                    }
                                    .frame(width: geometry.size.width-24, height: 82)
                                    .padding(.vertical, 16)
//                                    .padding(.top, 10)
                                } else {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            ForEach(favoriteStations, id: \.self) { station in
                                                Button {
                                                    DispatchQueue.main.async {
                                                        chosenStation = Int(station.chosenStationNumber)
                                                        fromFavorites = true
                                                        selectedItem = Item(complex: correctComplex(Int(station.complexID)))
                                                    }
                                                } label: {
                                                    ZStack {
                                                        bgColor.third.value
                                                            .background()
                                                            .cornerRadius(10)
                                                            .shadow(radius: 2)
                                                            .frame(width: 152, height: 90)
                                                        
                                                        StationBox(complex: correctComplex(Int(station.complexID)))
                                                            .frame(width: 152, height: 90)
                                                    }
                                                    .padding(.vertical, 4)
                                                }
                                                .buttonStyle(CButton())
                                            }
                                        }
                                        .padding(.horizontal,12)
                                    }
                                    .padding(.vertical, 12.0)
                                }
// MARK: - Nearby
                                HStack {
                                    Text("Nearby")
                                        .padding(.horizontal, 12)
                                        .padding(.bottom, -10)
                                        .padding(.top, -10)
                                    Spacer()
                                }
                                //                            Text("location: \(coordinate?.latitude ?? 0)")
                                //                            Text("location: \(coordinate?.longitude ?? 0)")
                                switch locationViewModel.authorizationStatus {
                                case .notDetermined:
                                    Text("request permission")
                                        .onAppear {
                                            if !showWhatsNew {
                                                locationViewModel.requestPermission()
                                            }
                                        }
                                case .denied:
                                    Text("Location is not shared, please go to Settings to enable it.")
                                case .authorizedAlways, .authorizedWhenInUse:
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            ForEach(lookForNearbyStations(), id: \.self) { station in
                                                Button {
                                                    DispatchQueue.main.async {
                                                        selectedItem = Item(complex: station)
                                                        
                                                        for favoriteStation in favoriteStations {
                                                            if favoriteStation.complexID == station.id {
                                                                fromFavorites = true
                                                                chosenStation = Int(favoriteStation.chosenStationNumber)
                                                                break
                                                            }
                                                            fromFavorites = false
                                                        }
                                                    }
                                                } label: {
                                                    ZStack {
                                                        bgColor.third.value
                                                            .background()
                                                            .cornerRadius(10)
                                                            .shadow(radius: 2)
                                                            .frame(width: 152,height: 90)
                                                        StationBox(complex: station)
                                                            .frame(width: 152,height: 90)
                                                    }
                                                    .padding(.vertical, 4)
                                                }
                                                .buttonStyle(CButton())
                                            }
                                        }
                                        .padding(.horizontal,12)
                                    }
                                    .padding(.bottom, 6)
                                    .padding(.top, 6)
                                default:
                                    Text("Unexpected status")
                                }
// MARK: - Favorite Lines
                                HStack {
                                    Text("Favorite Lines")
                                        .padding(.horizontal, 12)
                                        .padding(.bottom, -20)
                                        .padding(.top,4)
                                    Spacer()
                                }
                                if loading {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(Color("cLessDarkGray"))
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
                                                .frame(width: UIScreen.screenWidth / 2)
                                        }
                                    }
                                    .onAppear {
                                        checkInternetConnection()
                                    }
                                } else if !isInternetConnected {
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
                                    if favoriteLines.count < 1 {
                                        ZStack {
                                            bgColor.third.value
                                                .background()
                                                .cornerRadius(10)
                                                .shadow(radius: 2)
    //                                            .frame(width: 130,height: 82)
                                            VStack {
                                                Text("**You have no favorited lines!**")
                                                HStack(spacing: 0) {
                                                    Spacer()
                                                    Text("Press the")
                                                    Image(systemName: "star")
                                                        .shadow(radius: 2)
                                                    Text("in the top right of a line")
                                                    Spacer()
                                                }
                                                Text("to favorite it.")
                                            }
                                        }
                                        .frame(width: geometry.size.width-24, height: 82)
                                        .padding(.vertical, 16)
    //                                    .padding(.top, 10)
                                    } else {
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 0) {
                                                ForEach(getSummaryKeys(summary, "all").sorted(), id: \.self) { key in
                                                    if getFavoriteLines().contains(key) {
                                                        LineBox(line: key, first: summary[key]?.disruptions ?? [String]())
                                                            .environment(\.managedObjectContext, persistedContainer.viewContext)
                                                    }
                                                }
                                            }
                                            .padding(.horizontal,12)
                                        }
                                        .padding(.vertical, 12.0)
                                        .padding(.top, 5)
                                    }
    // MARK: - All Lines
                                    VStack {
                                        HStack {
                                            Text("All Lines")
                                                .padding(.horizontal, 12)
                                                .padding(.top,4)
                                            Spacer()
                                        }
                                        ForEach(lineSummaryKeys, id: \.self) { category in
                                            if checkIfAny(category) {
                                                HStack {
                                                    Text("\(dict[category] ?? "")")
                                                        .font(.footnote)
                                                        .padding(.horizontal, 12)
                                                        .padding(.bottom, -10)
                                                    Spacer()
                                                }
                                                WrappingHStack(id: \.self, alignment: .leading, horizontalSpacing: 6) {
                                                    ForEach(getSummaryKeys(summary, category).sorted(), id: \.self) { line in
                                                        if summary[line]?.disruptions.first ?? "" == category {
                                                            Button {
                                                                selectedDisruption = DisruptionItem(line: line, direction: "all")
                                                                for favoriteLine in favoriteLines {
                                                                    if favoriteLine.line == line {
                                                                        fromFavorites = true
                                                                        break
                                                                    }
                                                                    fromFavorites = false
                                                                }
                                                            } label: {
                                                                Image(line)
                                                                    .resizable()
                                                                    .frame(width: 40,height: 40)
                                                                    .shadow(radius: 2)
                                                                    .padding(.top, 6)
                                                            }
                                                            .buttonStyle(CButton())
                                                        }
                                                    }
                                                }.padding(.leading, 12)

                                            }
                                        }
                                    }
                                    Spacer()
                                        .frame(height: 200)
                                }
                            }
// MARK: - MAIN CONTENT - Bus
                            else if search.isEmpty && selectedSearchType == "Bus" {
                                // find near by bus stops (0.25 mile radius)
                                // make POST request for multiple bus stops
                                BusView(coordinate: coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0), counter: counter)
                                
                            }
// MARK: - MAIN CONTENT - Rail
                            else if selectedSearchType == "Rail" {
                                Text("Coming soon!")
                                    .padding(20)
                            }
                        }
//                        .scrollDismissesKeyboard(.interactively)
                        .sheet(item: $selectedItem) { item in
                            ZStack {
                                if fromFavorites {
                                    // chosen station = favoriteStationNumber thing
                                    StationView(complex: item.complex, chosenStation: chosenStation, isFavorited: true)
                                        .environment(\.managedObjectContext, persistedContainer.viewContext)
                                        .syncLayoutOnDissappear()
                                } else {
                                    StationView(complex: item.complex, chosenStation: 0, isFavorited: false)
                                        .environment(\.managedObjectContext, persistedContainer.viewContext)
                                        .syncLayoutOnDissappear()
                                }
                                CloseSheet()
                            }
                        }
                        .sheet(item: $selectedDisruption, onDismiss: {
                            selectedDisruption = nil
                        }) { disruption in
                            ZStack {
                                if fromFavorites {
                                    serviceAlertsViewNew(line: disruption.line, direction: disruption.direction, isFavorited: true)
                                        .environment(\.managedObjectContext, persistedContainer.viewContext)
                                } else {
                                    serviceAlertsViewNew(line: disruption.line, direction: disruption.direction, isFavorited: false)
                                        .environment(\.managedObjectContext, persistedContainer.viewContext)
                                }
                                CloseSheet()
                            }
                            .syncLayoutOnDissappear()
                        }

//                        .sheet(item: $selectedBusStop) { item in
//                            BusStopView(stopID: item.stopID)
//                                .syncLayoutOnDissappear()
//                        }
                    }
    //                .customAnimation(.linear.speed(0.4))
                    .customAnimation(.spring(response: 0.3, dampingFraction: 0.825))
                    
                    .enableBackgroundBlur(false)
                    .customBackground(
                        bgColor.first.value
                            .background(.thickMaterial)
                            .environment(\.colorScheme,colorScheme)
                            .cornerRadius(20, corners: [.topLeft, .topRight])
                            .shadow(radius: 2)
                    )
                    .sheetWidth(BottomSheetWidth.absolute(sheetWidth))
//                    .padding(.leading, (UIScreen.screenWidth-sheetWidth)/2)
//              MARK: - START Input Field
                VStack {
                    Spacer()
                    ZStack {
                        VStack {
                            Spacer()
                            Rectangle()
                                .background(.ultraThinMaterial)
                                .environment(\.colorScheme,returnReverse())
                                .cornerRadius(20, corners: [.topLeft, .topRight])
                                .frame(height: 70+searchPaddingHeight + keyboardHeight)
                                .padding(.bottom,-20)
                                .padding(.horizontal, -10)
                            
//                                .opacity(0.5)
                                .blur(radius: 10)
                        }

                        VStack {
                            Spacer()
                            HStack {
                                ZStack {
                                    bgColor.fifth.value
                                        .background()
                                        .environment(\.colorScheme,colorScheme)
                                        .cornerRadius(10)
                                        .shadow(radius: 2)
                                        .frame(height: 40)
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                            .opacity(0.2)
                                            .padding(.leading,8)

                                        TextField(searchText, text: $search)
                                            .focused($inputIsActive)
                                            .onChange(of: search) { _ in
                                                if search.isEmpty {
                                                    searchStations = []
                                                    searchBusStops = []
                                                } else {
                                                    bottomSheetPosition = .relative(0.975)
                                                    let currentLoc = CLLocation(latitude: coordinate?.latitude ?? 0, longitude: coordinate?.longitude ?? 0)
                                                    
                                                    if selectedSearchType == "Subway" {
                                                        withAnimation(.spring(blendDuration: 0.25)) {
                                                            searchStations = complexData.filter { $0.searchName.localizedCaseInsensitiveContains(search)
                                                            }.sorted(by: {
                                                                return $0.location.distance(from: currentLoc) < $1.location.distance(from: currentLoc)
                                                            })
                                                        }
                                                    } else if selectedSearchType == "Bus" {
                                                        withAnimation(.spring(blendDuration: 0.25)) {
                                                            searchBusStops = busData_array.filter { $0.name.localizedCaseInsensitiveContains(search)
                                                            }.sorted(by: {
                                                                return $0.location.distance(from: currentLoc) < $1.location.distance(from: currentLoc)
                                                            })
                                                            if searchBusStops.count > 41 {
                                                                let arraySlice = searchBusStops[0..<41]
                                                                searchBusStops = Array(arraySlice)
                                                                
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                    }
                                }
                                .onTapGesture {
                                    inputIsActive = true
//                                    selectedSearchType = "Subway"
                                }
                                if search != "" {
                                    // Cancel
                                    Button {
                                        withAnimation(.linear(duration: 0.25)) { search = "" }
                                        withAnimation(.linear(duration: 0.25)) { inputIsActive = false }
                                    } label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .frame(width: 40, height: 40)
                                                .foregroundColor(bgColor.fifth.value)
                                                .shadow(radius: 2)
                                            Image(systemName: "xmark")
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .buttonStyle(CButton())
                                    
                                    Button {
                                        withAnimation(.linear(duration: 0.25)) { inputIsActive = false }
                                    } label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .frame(width: 40, height: 40)
                                                .foregroundColor(bgColor.fifth.value)
                                                .shadow(radius: 2)
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.green)
                                        }
                                    }
                                    .buttonStyle(CButton())
                                } else if inputIsActive {
                                    Button {
                                        withAnimation(.linear(duration: 0.25)) { inputIsActive = false }
                                    } label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .frame(width: 40, height: 40)
                                                .foregroundColor(bgColor.fifth.value)
                                                .shadow(radius: 2)
                                            Image(systemName: "xmark")
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .buttonStyle(CButton())
                                }
                            }
                            .padding(.bottom, searchPaddingHeight + keyboardHeight)
                            .padding(12.0)
                            .onTapGesture {
                                self.bottomSheetPosition = .relativeTop(0.975)
                        }
                        }
                    }

                }
                .frame(width: UIScreen.screenWidth,height: UIScreen.screenHeight)
                .padding(.leading, -UIScreen.screenWidth)
                .ignoresSafeArea()
                
//                MARK: - Dark material at the top
                VStack {
                    Rectangle()
                        .frame(width: UIScreen.screenWidth * 2, height: geometry.safeAreaInsets.top)
                        .background(.ultraThinMaterial)
                        .environment(\.colorScheme, returnReverse())
                    Spacer()
                }
                .ignoresSafeArea()
            }

        }
        .sheet(isPresented: $showWhatsNew, onDismiss: {
            locationViewModel.requestPermission()
            
        }, content: WhatsNew.init)
        .onAppear {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    withAnimation(.spring(blendDuration: 0.01)) {
                        self.keyboardHeight = keyboardSize.height-26
                        bottomSheetPosition = .relative(0.975)
                    }
                }
            }

            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                withAnimation(.spring(blendDuration: 0.01)) {
                    self.keyboardHeight = 0
                }

            }
        }
    }
}
struct Home_Previews: PreviewProvider {
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistentContainer
        Home()
            .environment(\.managedObjectContext, persistedContainer.viewContext)
            .environmentObject(LocationViewModel())
    }
}
