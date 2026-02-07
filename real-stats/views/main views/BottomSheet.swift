////
////  BottomSheet.swift
////  real-stats
////
////  Created by Conrad on 6/11/23.
////
//
import SwiftUI
import BottomSheet
import CoreLocation
import UIKit

public extension UIDevice {

    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                       return "iPod touch (5th generation)"
            case "iPod7,1":                                       return "iPod touch (6th generation)"
            case "iPod9,1":                                       return "iPod touch (7th generation)"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":           return "iPhone 4"
            case "iPhone4,1":                                     return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                        return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                        return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                        return "iPhone 5s"
            case "iPhone7,2":                                     return "iPhone 6"
            case "iPhone7,1":                                     return "iPhone 6 Plus"
            case "iPhone8,1":                                     return "iPhone 6s"
            case "iPhone8,2":                                     return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                        return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                        return "iPhone 7 Plus"
            case "iPhone10,1", "iPhone10,4":                      return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                      return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                      return "iPhone X"
            case "iPhone11,2":                                    return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                      return "iPhone XS Max"
            case "iPhone11,8":                                    return "iPhone XR"
            case "iPhone12,1":                                    return "iPhone 11"
            case "iPhone12,3":                                    return "iPhone 11 Pro"
            case "iPhone12,5":                                    return "iPhone 11 Pro Max"
            case "iPhone13,1":                                    return "iPhone 12 Mini"
            case "iPhone13,2":                                    return "iPhone 12"
            case "iPhone13,3":                                    return "iPhone 12 Pro"
            case "iPhone13,4":                                    return "iPhone 12 Pro Max"
            case "iPhone14,4":                                    return "iPhone 13 Mini"
            case "iPhone14,5":                                    return "iPhone 13"
            case "iPhone14,2":                                    return "iPhone 13 Pro"
            case "iPhone14,3":                                    return "iPhone 13 Pro Max"
            case "iPhone14,7":                                    return "iPhone 14"
            case "iPhone14,8":                                    return "iPhone 14 Plus"
            case "iPhone15,2":                                    return "iPhone 14 Pro"
            case "iPhone15,3":                                    return "iPhone 14 Pro Max"
            case "iPhone15,4":                                    return "iPhone 15"
            case "iPhone15,5":                                    return "iPhone 15 Plus"
            case "iPhone16,1":                                    return "iPhone 15 Pro"
            case "iPhone16,2":                                    return "iPhone 15 Pro Max"
            case "iPhone8,4":                                     return "iPhone SE"
            case "iPhone12,8":                                    return "iPhone SE (2nd generation)"
            case "iPhone14,6":                                    return "iPhone SE (3rd generation)"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":      return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":                 return "iPad (3rd generation)"
            case "iPad3,4", "iPad3,5", "iPad3,6":                 return "iPad (4th generation)"
            case "iPad6,11", "iPad6,12":                          return "iPad (5th generation)"
            case "iPad7,5", "iPad7,6":                            return "iPad (6th generation)"
            case "iPad7,11", "iPad7,12":                          return "iPad (7th generation)"
            case "iPad11,6", "iPad11,7":                          return "iPad (8th generation)"
            case "iPad12,1", "iPad12,2":                          return "iPad (9th generation)"
            case "iPad13,18", "iPad13,19":                        return "iPad (10th generation)"
            case "iPad4,1", "iPad4,2", "iPad4,3":                 return "iPad Air"
            case "iPad5,3", "iPad5,4":                            return "iPad Air 2"
            case "iPad11,3", "iPad11,4":                          return "iPad Air (3rd generation)"
            case "iPad13,1", "iPad13,2":                          return "iPad Air (4th generation)"
            case "iPad13,16", "iPad13,17":                        return "iPad Air (5th generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":                 return "iPad mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":                 return "iPad mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":                 return "iPad mini 3"
            case "iPad5,1", "iPad5,2":                            return "iPad mini 4"
            case "iPad11,1", "iPad11,2":                          return "iPad mini (5th generation)"
            case "iPad14,1", "iPad14,2":                          return "iPad mini (6th generation)"
            case "iPad6,3", "iPad6,4":                            return "iPad Pro (9.7-inch)"
            case "iPad7,3", "iPad7,4":                            return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":      return "iPad Pro (11-inch) (1st generation)"
            case "iPad8,9", "iPad8,10":                           return "iPad Pro (11-inch) (2nd generation)"
            case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7":  return "iPad Pro (11-inch) (3rd generation)"
            case "iPad14,3", "iPad14,4":                          return "iPad Pro (11-inch) (4th generation)"
            case "iPad6,7", "iPad6,8":                            return "iPad Pro (12.9-inch) (1st generation)"
            case "iPad7,1", "iPad7,2":                            return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":      return "iPad Pro (12.9-inch) (3rd generation)"
            case "iPad8,11", "iPad8,12":                          return "iPad Pro (12.9-inch) (4th generation)"
            case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11":return "iPad Pro (12.9-inch) (5th generation)"
            case "iPad14,5", "iPad14,6":                          return "iPad Pro (12.9-inch) (6th generation)"
            case "AppleTV5,3":                                    return "Apple TV"
            case "AppleTV6,2":                                    return "Apple TV 4K"
            case "AudioAccessory1,1":                             return "HomePod"
            case "AudioAccessory5,1":                             return "HomePod mini"
            case "i386", "x86_64", "arm64":                       return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                              return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2", "AppleTV11,1", "AppleTV14,1": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #elseif os(visionOS)
            switch identifier {
            case "RealityDevice14,1": return "Apple Vision Pro"
            default: return identifier
            }
            #endif
        }

        return mapToDevice(identifier: identifier)
    }()

}


extension UIScreen {
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let screenSize = UIScreen.main.bounds.size
    
    static var offsetVal: Double {
//        return
//        print(UIDevice.modelName)
        if screenHeight <= 568 { // iPhone 6-8, SE
            return 12.42
        } else if screenHeight <= 667 { // iPhone 6-8, SE
            if #available(iOS 16, *) {
                return 36
            }
            return 46
        } else if screenHeight <= 736 { // iPhone 6-8 Plus
            return 70
        } else if screenHeight <= 812 { // iPhone X, Xs, 11 Pro
//            print(UIDevice.modelName)
            if (UIDevice.modelName.contains("iPhone 12 Mini") || UIDevice.modelName.contains("iPhone 13 Mini")) {
                if #available(iOS 17, *) {
                    return -36.3
                }
                return 5.4
            }
            return -36.6
        } else if screenHeight <= 844 { // iPhone 12-14, 12-13 Pro
            if #available(iOS 17, *) {
                return -30
            }
            return 10.66
        } else if screenHeight <= 852 { // iPhone 15, 14-15 Pro
            return -29.3
        } else if screenHeight <= 896 && (UIDevice.modelName.contains("iPhone XR") || UIDevice.modelName.contains("iPhone 11")) {
            return -19.76
        } else if screenHeight <= 896 { // iPhone XS-11 Pro Max
            return 38.99
        } else if screenHeight <= 926 { // iPhone 12-13 Pro Max, 14-15 Plus
            if #available(iOS 17, *) {
                return -13.9
            }
            return 26.8
        } else if screenHeight <= 932 { // iPhone 14-15 Pro Max
            if #available(iOS 17, *) {
                return -13.9
            }
            return 26.8
        }
        return 0
    }
}

//struct HiD: PreviewProvider {
//    static var previews: some View {
//        let persistedContainer = CoreDataManager.shared.persistentContainer
//        Home()
//            .environment(\.managedObjectContext, persistedContainer.viewContext)
//            .environmentObject(LocationViewModel())
//    }
//}


struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}


extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}
//
//
//
//struct BottomSheet: View {
//    
//    @EnvironmentObject var versionCheck: VersionCheck
//        
//    @State var bottomSheetPosition: BottomSheetPosition = .relative(0.4)
//    @State var bottomSheetSize = CGSize()
//    let backgroundColors: [Color] = [Color(red: 0.28, green: 0.28, blue: 0.53), Color(red: 1, green: 0.69, blue: 0.26)]
//    
//    @Environment(\.managedObjectContext) private var viewContext
//    let persistedContainer = CoreDataManager.shared.persistentContainer
//    @EnvironmentObject var locationViewModel: LocationViewModel
//    var coordinate: CLLocationCoordinate2D? {
//        locationViewModel.lastSeenLocation?.coordinate
//    }
//    
//    @State private var search: String = ""
//    @State private var showStation: Bool = false
//    @State private var complex: Complex = complexData[0]
//    
//    @State var selectedItem: Item?
//    @State var selectedBusStop: BusItem?
//
//    @State var fromFavorites: Bool = false
//    @State var chosenStation: Int = 0
//    
//    @FetchRequest(entity: FavoriteStation.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var favoriteStations: FetchedResults<FavoriteStation>
//    
////    private func getNearByStations(_ location: MK)
////    for station in stations, if station.location choser than station-1, set.add
//
//    @State var searchStations: [Complex] = []
//    
//    @FocusState var inputIsActive: Bool
//    
//    @AppStorage("stationTimes", store: UserDefaults(suiteName: "group.Schematica.real-stats")) var timeData: String = ""
//    
//    @AppStorage("version") var version: String = "1.0"
//    @State var showWhatsNew = false
//    @State var showNeedsUpdate = false
//
//    @State private var duration = 0.2
//    @State private var bounce = 0.2
//    
//    let bundleId = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
//    
//    func correctComplex(_ id: Int) -> Complex {
//        for station in complexData {
//            if station.id == id {
//                return station
//            }
//        }
//        return complexData[0]
//    }
//    
//    func lookForNearbyStations() -> [Complex] {
//        let currentLoc = CLLocation(latitude: coordinate?.latitude ?? 0, longitude: coordinate?.longitude ?? 0)
//        let stations = complexData
//            .sorted(by: {
//                return $0.location.distance(from: currentLoc) < $1.location.distance(from: currentLoc)
//            })
//        var newStations = [Complex]()
//        
//        for num in 0...10 {
//            newStations.append(stations[num])
//        }
//                
//        return newStations
//    }
//    
//    func lookForNearbyBusStops() -> [String] {
//        let currentLoc = CLLocation(latitude: coordinate?.latitude ?? 0, longitude: coordinate?.longitude ?? 0)
//        let stations = busData_array
//            .sorted(by: {
//                return $0.location.distance(from: currentLoc) < $1.location.distance(from: currentLoc)
//            })
//        var newStations = [String]()
//        
//        for num in 0...10 {
//            newStations.append(stations[num].id)
//        }
//                
//        return newStations
//    }
//
//    func needsUpdate() -> Bool {
//        if versionCheck.isUpdateAvailable {
//            return true
//        }
//        return false
//    }
//    
//    let searchTypes = ["Urban rail", "Regional rail", "Bus"]
//    @State var selectedSearchType = "Urban rail"
//    @State var showTypes = false
//    
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack {
//                MapView()
//                    .onAppear {
//                        if version != (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "") {
//                            showWhatsNew = true
//                            version = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
//                        }
//                    }
//                    .environment(\.managedObjectContext, CoreDataManager.shared.persistentContainer.viewContext)
//                    .environmentObject(locationViewModel)
//    //                .ignoresSafeArea()
//
//                    .bottomSheet(bottomSheetPosition: self.$bottomSheetPosition, switchablePositions: [
//                        .relativeBottom(0.125),
//                        .relative(0.4),
//                        .relativeTop(0.975)
//                    ], headerContent: {
//                        
//                        ZStack {
//                            Group {
//                                VStack {
//                                    Rectangle()
//                                        .frame(width:50,height:10)
//                                        .padding(.top,-20)
//                                        .foregroundColor(Color("cDarkGray"))
//                                    Spacer()
//                                        .frame(height: 20)
//                                    
//                                }
//                                VStack {
//                                    Capsule()
//                                        .fill(Color("second"))
//                                        .frame(width: 34, height: 4.5)
//                                        .padding(.top, -15)
//                                    Spacer()
//                                        .frame(height: 30)
//                                }
//                            }.padding(.top, -17)
//                            .padding(12.0)
//                            HStack {
//                                ZStack {
//                                    RoundedRectangle(cornerRadius: 10)
//                                        .foregroundColor(Color("cLessDarkGray"))
//                                        .shadow(radius: 2)
//                                        .frame(height: 40)
//                                    TextField("Search for a station or a train", text: $search)
//                                        .padding(.leading,6)
//                                        .focused($inputIsActive)
//                                        .onChange(of: search) { _ in
//                                            if search.isEmpty {
//                                                searchStations = []
//                                            } else {
//                                                let currentLoc = CLLocation(latitude: coordinate?.latitude ?? 0, longitude: coordinate?.longitude ?? 0)
//                                                
//                                                withAnimation(.spring(blendDuration: 0.25)) {
//                                                    searchStations = complexData.filter { $0.searchName.localizedCaseInsensitiveContains(search)
//                                                    }.sorted(by: {
//                                                        return $0.location.distance(from: currentLoc) < $1.location.distance(from: currentLoc)
//                                                    })
//                                                }
//                                            }
//                                        }
//                                }
//                                if search != "" {
//                                    // Cancel
//                                    Button {
//                                        withAnimation(.linear(duration: 0.25)) { search = "" }
//                                        withAnimation(.linear(duration: 0.25)) { inputIsActive = false }
//                                    } label: {
//                                        ZStack {
//                                            RoundedRectangle(cornerRadius: 10)
//                                                .frame(width: 40, height: 40)
//                                                .foregroundColor(Color("cLessDarkGray"))
//                                                .shadow(radius: 2)
//                                            Image(systemName: "xmark")
//                                                .foregroundColor(.red)
//                                        }
//                                    }
//                                    .buttonStyle(CButton())
//                                    
//                                    Button {
//                                        withAnimation(.linear(duration: 0.25)) { inputIsActive = false }
//                                    } label: {
//                                        ZStack {
//                                            RoundedRectangle(cornerRadius: 10)
//                                                .frame(width: 40, height: 40)
//                                                .foregroundColor(Color("cLessDarkGray"))
//                                                .shadow(radius: 2)
//                                            Image(systemName: "checkmark")
//                                                .foregroundColor(.green)
//                                        }
//                                    }
//                                    .buttonStyle(CButton())
//                                } else if inputIsActive {
//                                    Button {
//                                        withAnimation(.linear(duration: 0.25)) { inputIsActive = false }
//                                    } label: {
//                                        ZStack {
//                                            RoundedRectangle(cornerRadius: 10)
//                                                .frame(width: 40, height: 40)
//                                                .foregroundColor(Color("cLessDarkGray"))
//                                                .shadow(radius: 2)
//                                            Image(systemName: "xmark")
//                                                .foregroundColor(.red)
//                                        }
//                                    }
//                                    .buttonStyle(CButton())
//                                }
//                            }
//                            .padding(.top, -17)
//                            .padding(12.0)
//                            .onTapGesture {
//                                self.bottomSheetPosition = .relativeTop(0.975)
//                        }
//                        }
//                    }) {
//                        ScrollView {
//                            VStack(spacing: 0) {
////                                TODO: FUTURE
////                                if showTypes {
////                                    HStack {
////                                        ForEach(searchTypes, id: \.self) { type in
////                                            Button {
////                                                selectedSearchType = type
////                                            } label: {
////                                                VStack {
////                                                    ZStack {
////                                                        if selectedSearchType == type {
////                                                            RoundedRectangle(cornerRadius: 10)
////                                                                .foregroundColor(Color("cLessDarkGray"))
////                                                                .frame(height: 40)
////                                                                .overlay(
////                                                                    RoundedRectangle(cornerRadius: 13)
////                                                                        .stroke(.blue,lineWidth: 2)
////                                                                        .frame(height: 48)
////                                                                )
////                                                                .shadow(radius: 2)
////                                                        } else {
////                                                            RoundedRectangle(cornerRadius: 10)
////                                                                .foregroundColor(Color("cLessDarkGray"))
////                                                                .frame(height: 40)
////                                                                .shadow(radius: 2)
////                                                                .overlay(
////                                                                    RoundedRectangle(cornerRadius: 12)
////                                                                        .stroke(Color("cDarkGray"),lineWidth: 2)
////                                                                        .frame(height: 48)
////                                                                )
////
////                                                        }
////                                                        HStack(spacing: 2.5) {
////                                                            Text(type)
////                                                        }
////                                                    }
////                                                }
////                                            }
////                                            
////                                        }
////                                    }
////
////                                }
//                                ForEach(searchStations, id: \.self) { station in
//                                    Button {
//                                        selectedItem = Item(complex: station)
//                                        for favoriteStation in favoriteStations {
//                                            if favoriteStation.complexID == station.id {
//                                                fromFavorites = true
//                                                break
//                                            }
//                                            fromFavorites = false
//                                        }
//                                    } label: {
//                                        StationRow(complex: station)
//                                            .frame(width: geometry.size.width-12)
//                                            .onAppear {
//                                                showTypes = true
//                                            }
//                                            .onDisappear {
//                                                showTypes = false
//                                            }
//                                    }
//                                    .buttonStyle(CButton())
//                                }
//                            }
//                            
//                            // MARK: - Favorites
//                            
//                            if search.isEmpty {
//                                HStack {
//                                    Text("Favorites")
//                                        .padding(.horizontal, 12)
//                                        .padding(.bottom, -20)
//                                    Spacer()
//                                }
//                                ScrollView(.horizontal, showsIndicators: false) {
//                                    HStack {
//                                        ForEach(favoriteStations, id: \.self) { station in
//                                            Button {
//                                                chosenStation = Int(station.chosenStationNumber)
//                                                fromFavorites = true
//                                                selectedItem = Item(complex: correctComplex(Int(station.complexID)))
//                                            } label: {
//                                                ZStack {
//                                                    RoundedRectangle(cornerRadius: 10)
//                                                        .foregroundColor(Color("cLessDarkGray"))
//                                                        .shadow(radius: 2)
//                                                        .frame(width: 130,height: 82)
//                                                    StationBox(complex: correctComplex(Int(station.complexID)))
//                                                        .frame(width: 130,height: 82)
//                                                }
//                                                .padding(.vertical, 4)
//                                            }
//                                            .buttonStyle(CButton())
//                                        }
//                                    }
//                                    .padding(.horizontal,12)
//                                }
//                                .padding(.vertical, 12.0)
//                                
//                                // MARK: - Nearby Train
//                                HStack {
//                                    Text("Nearby train")
//                                        .padding(.horizontal, 12)
//                                        .padding(.bottom, -20)
//                                    Spacer()
//                                }
//                                //                            Text("location: \(coordinate?.latitude ?? 0)")
//                                //                            Text("location: \(coordinate?.longitude ?? 0)")
//                                switch locationViewModel.authorizationStatus {
//                                case .notDetermined:
//                                    Text("request permission")
//                                case .denied:
//                                    Text("Location is not shared, please go to Settings to enable it.")
//                                case .authorizedAlways, .authorizedWhenInUse:
//                                    ScrollView(.horizontal, showsIndicators: false) {
//                                        HStack {
//                                            ForEach(lookForNearbyStations(), id: \.self) { station in
//                                                Button {
//                                                    selectedItem = Item(complex: station)
//                                                    
//                                                    for favoriteStation in favoriteStations {
//                                                        if favoriteStation.complexID == station.id {
//                                                            fromFavorites = true
//                                                            chosenStation = Int(favoriteStation.chosenStationNumber)
//                                                            break
//                                                        }
//                                                        fromFavorites = false
//                                                    }
//                                                    
//                                                } label: {
//                                                    ZStack {
//                                                        RoundedRectangle(cornerRadius: 10)
//                                                            .foregroundColor(Color("cLessDarkGray"))
//                                                            .shadow(radius: 2)
//                                                            .frame(width: 130,height: 82)
//                                                        StationBox(complex: station)
//                                                            .frame(width: 130,height: 82)
//                                                    }
//                                                    .padding(.vertical, 4)
//                                                }
//                                                .buttonStyle(CButton())
//                                            }
//                                        }
//                                        .padding(.horizontal,12)
//                                    }
//                                    .padding(.vertical, 12.0)
//                                default:
//                                    Text("Unexpected status")
//                                }
//                                // MARK: - Nearby Bus
//                                HStack {
//                                    Text("Nearby bus")
//                                        .padding(.horizontal, 12)
//                                        .padding(.bottom, -20)
//                                    Spacer()
//                                }
//                                switch locationViewModel.authorizationStatus {
//                                case .notDetermined:
//                                    Text("request permission")
//                                case .denied:
//                                    Text("Location is not shared, please go to Settings to enable it.")
//                                case .authorizedAlways, .authorizedWhenInUse:
//                                    ScrollView(.horizontal, showsIndicators: false) {
//                                        HStack {
//                                            ForEach(lookForNearbyBusStops(), id: \.self) { stop in
//                                                Button {
//                                                    selectedBusStop = BusItem(stopID: stop)
//                                                                                                        
//                                                } label: {
//                                                    ZStack {
//                                                        RoundedRectangle(cornerRadius: 10)
//                                                            .foregroundColor(Color("cLessDarkGray"))
//                                                            .shadow(radius: 2)
//                                                            .frame(width: 130,height: 82)
//                                                        Text(stop)
////                                                        StationBox(complex: station)
//                                                            .frame(width: 130,height: 82)
//                                                    }
//                                                    .padding(.vertical, 4)
//                                                }
//                                                .buttonStyle(CButton())
//                                            }
//                                        }
//                                        .padding(.horizontal,12)
//                                    }
//                                    .padding(.vertical, 12.0)
//                                default:
//                                    Text("Unexpected status")
//                                }
//
//                            }
//                        }
//                        .sheet(item: $selectedItem) { item in
//                            if fromFavorites {
//                                // chosen station = favoriteStationNumber thing
//                                StationView(complex: item.complex, chosenStation: chosenStation, isFavorited: true)
//                                    .environment(\.managedObjectContext, persistedContainer.viewContext)
//                            } else {
//                                StationView(complex: item.complex, chosenStation: 0, isFavorited: false)
//                                    .environment(\.managedObjectContext, persistedContainer.viewContext)
//                            }
//                        }
//                        .sheet(item: $selectedBusStop) { item in
//                            BusStopView(stopID: item.stopID)
//                        }
//                    }
//    //                .customAnimation(.linear.speed(0.4))
//                    .customAnimation(.spring(response: 0.31, dampingFraction: 0.74))
//                    .enableBackgroundBlur(false)
//                    .customBackground(
//                        Color("cDarkGray")
//                            .cornerRadius(20, corners: [.topLeft, .topRight])
//                            .shadow(color: .gray, radius: 10, x: 0, y: 0)
//                    )
//                    .frame(width: UIScreen.screenWidth)
//                    .padding(.leading, -UIScreen.screenWidth)
//
//                VStack {
//                    Rectangle()
//                        .frame(width: UIScreen.screenWidth * 2, height: geometry.safeAreaInsets.top)
//                        .background(.ultraThinMaterial)
//                        .blur(radius: 20)
//                        .padding(.top, -20)
//                    Spacer()
//                }
//                .ignoresSafeArea()
////                VStack {
////                    Text("Duration: \(duration)")
////                    Slider(value: $duration, in: 0...1)
////                    Text("Bounce: \(bounce)")
////                    Slider(value: $bounce, in: 0...1)
////                }
////                .frame(width: UIScreen.screenWidth)
////                .padding(.leading, -UIScreen.screenWidth)
////
//            }
//
//        }
//        .sheet(isPresented: $showWhatsNew, onDismiss: {
//            locationViewModel.requestPermission()
//        }, content: WhatsNew.init)
//        .sheet(isPresented: $versionCheck.isUpdateAvailable) {
//            Update()
//        }
//    }
//}
//struct BottomSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        let persistedContainer = CoreDataManager.shared.persistentContainer
//        BottomSheet()
//            .environment(\.managedObjectContext, persistedContainer.viewContext)
//            .environmentObject(LocationViewModel())
//            .environmentObject(VersionCheck())
//    }
//}
