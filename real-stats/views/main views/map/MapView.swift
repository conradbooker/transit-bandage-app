//
//  MapView.swift
//  real-stats
//
//  Created by Conrad on 3/13/23.
//

//import SwiftUI
import CoreLocation
import MapKit

import Foundation
import MapKit
import SwiftUI
import Map
//import WrappingHStack
import MessageUI

struct MapView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var locationViewModel: LocationViewModel
        
    let persistedContainer = CoreDataManager.shared.persistentContainer
    var coordinate: CLLocationCoordinate2D? {
        locationViewModel.lastSeenLocation?.coordinate
    }
    
    @State var selectedItem: Item?
    @State var chosenStation: Int = 0
    
    @State var showSettings = false
    
    @State var fromFavorites = false
    
    @FetchRequest(entity: FavoriteStation.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var favoriteStations: FetchedResults<FavoriteStation>
    @State private var userTrackingMode = UserTrackingMode.follow
    
    @State private var scale: CGFloat = 1
    
    // Vars for the Preferences
    @State private var isSheetExpanded = true
    @State private var showAbout = false
    @State private var showFeedback = false
    @State private var alertNoMail = false
    @GestureState private var dragOffset: CGFloat = 0
    @AppStorage("trackTimes") var trackTimes: Bool = true
    @State var result: Result<MFMailComposeResult, Error>? = nil
    
    @State private var showKey = false
    
    private let pastboard = UIPasteboard.general
    
//    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("selectedMapView") var selectedMapView: Int = 1
    
    @AppStorage("darkMode") var darkMode: Int = 1

    private func getColorScheme() -> ColorScheme {
        if darkMode == 2 {
            if (UITraitCollection.current.userInterfaceStyle == .dark) {
                return .dark
            }
            return .light
        }
        if darkMode == 0 {
            return .light
        }
        return .dark
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

    var mapTypes = [0,1]
    var mapTypesString = ["Nearby Locations","Diagramic"]
    
    @State private var isPresentWebView = false

    var body: some View {
        VStack {
            ZStack {
                if mapViewData[selectedMapView].mapName == "station_locations" {
                    Map(
                        coordinateRegion:  $locationViewModel.region,
                        type: .standard,
                        pointOfInterestFilter: .excludingAll,
                        informationVisibility: .default.union(.userLocation),
                        interactionModes: [.all],
                        userTrackingMode: $userTrackingMode,
                        annotationItems: lookForNearbyStations(),
                        annotationContent: { station in
                            ViewMapAnnotation(coordinate: correctComplex(Int(station.id)).location.coordinate) {
                                VStack {
                                    Spacer()
                                        .frame(height: 40)
                                    VStack(spacing: 0) {
                                        ZStack {
                                            Circle()
                                                .frame(width: 46, height: 46)
                                                .foregroundColor(.black)
                                            Circle()
                                                .frame(width: 40, height: 55)
                                                .foregroundColor(.white)
                                            Image(systemName: "tram")
                                                .resizable()
                                                .frame(width: 20,height:30)
                                                .foregroundColor(.black)
                                        }
                                        Text(correctComplex(Int(station.id)).stations[0].short1)
                                            .foregroundColor(Color("whiteblack"))
                                            .frame(width: 1000)
                                        if correctComplex(Int(station.id)).stations[0].short2 != "" {
                                            Text(correctComplex(Int(station.id)).stations[0].short2)
                                                .foregroundColor(Color("whiteblack"))
                                                .font(.footnote)
                                                .frame(width: 1000)
                                        }
                                        HStack(spacing: 2) {
                                            ForEach(correctComplex(Int(station.id)).stations, id: \.self) { station in
                                                ForEach(station.weekdayLines, id: \.self) { line in
                                                    if ["LIRR","HBLR","NJT","MNR","PATH"].contains(line) {
                                                        Image(line)
                                                            .resizable()
                                                            .frame(width: 30,height: 15)
                                                    } else {
                                                        Image(line)
                                                            .resizable()
                                                            .frame(width: 15,height: 15)
                                                    }
                                                }
                                            }
                                        }
                                        
                                    }
                                    .onTapGesture {
                                        withAnimation(.spring()) {
                                            scale = 0.8
                                        }
                                        selectedItem = Item(complex: correctComplex(Int(station.id)))
                                        for favoriteStation in favoriteStations {
                                            if favoriteStation.complexID == correctComplex(Int(station.id)).id {
                                                fromFavorites = true
                                                break
                                            }
                                            fromFavorites = false
                                        }
                                    }
                                }
                            }
                        }
                    )
                    .ignoresSafeArea()
                } else if mapViewData[selectedMapView].mapName == "diagramic" {
                    DiagramicMapView()
                }
                
                VStack(spacing: 10) {
// MARK: - Settings Button
                    HStack {
                        Spacer()
                        Button {
                            showSettings = true
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color("cDarkGray"))
                                    .shadow(radius: 2)
                                Image(systemName: "gear")
                                    .resizable()
                                    .frame(width: 20,height:20)
                            }
                            .frame(width: 40,height: 40)
                        }
                        .buttonStyle(CButton())
                        .padding(.horizontal)
                        .padding(.top,15)
                    }
// MARK: - Location Button
                    if mapViewData[selectedMapView].mapName == "station_locations" {
                        HStack {
                            Spacer()
                            Button {
                                withAnimation(.linear(duration: 0.4)) {
                                    locationViewModel.region = MKCoordinateRegion(
                                        center: CLLocationCoordinate2D(latitude: (coordinate?.latitude ?? 40.791642) - 0.005, longitude: coordinate?.longitude ?? -73.964696),
                                        span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025))
                                    print(abs((coordinate?.latitude ?? 0) - 0.005) - abs(locationViewModel.region.center.latitude), abs((coordinate?.longitude ?? 0)) - abs(locationViewModel.region.center.longitude) )
                                }
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color("cDarkGray"))
                                        .shadow(radius: 2)
                                    if abs((coordinate?.latitude ?? 0) - 0.005) - abs(locationViewModel.region.center.latitude) < 0.00001 && abs((coordinate?.longitude ?? 0)) - abs(locationViewModel.region.center.longitude) < 0.00001 {
                                        Image(systemName: "location.fill")
                                            .resizable()
                                            .frame(width: 20,height:20)
                                    } else {
                                        Image(systemName: "location")
                                            .resizable()
                                            .frame(width: 20,height:20)
                                    }
                                }
                                .frame(width: 40,height: 40)
                                .padding(.top, -10)
                            }
                            .buttonStyle(CButton())
                            .padding()
                        }
                    } else {
                        HStack {
                            Spacer()
                            Button {
                                showKey = true
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color("cDarkGray"))
                                        .shadow(radius: 2)
                                    Image(systemName: "questionmark")
                                        .font(.title2)
//                                        .resizable()
                                        .frame(width: 20,height:20)
                                }
                                .frame(width: 40,height: 40)
                                .padding(.top, -10)
                            }
                            .padding()
                            
                        }
                        .buttonStyle(CButton())
                    }
                    Spacer()
                }
            }
            
        }
//        .preferredColorScheme(getColorScheme())
        .sheet(item: $selectedItem) { item in
            ZStack {
                if fromFavorites {
                    // chosen station = favoriteStationNumber thing
                    StationView(complex: item.complex, chosenStation: chosenStation, isFavorited: true)
                        .environment(\.managedObjectContext, persistedContainer.viewContext)
                } else {
                    StationView(complex: item.complex, chosenStation: 0, isFavorited: false)
                        .environment(\.managedObjectContext, persistedContainer.viewContext)
                }
                CloseSheet()
            }
            .syncLayoutOnDissappear()
        }
        .sheet(isPresented: $showKey) {
            ZStack {
                MapKeyView()
                CloseSheet()
            }
            .syncLayoutOnDissappear()
        }
// MARK: Settings Page
        .sheet(isPresented: $showSettings) {
            ZStack {
                Color("cDarkGray")
                    .ignoresSafeArea()
                NavigationView {
                    ScrollView {
                        VStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color("cLessDarkGray"))
                                    .shadow(radius: 2)
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack {
                                        Text("Region: NYC (More regions coming soon)")
                                            .padding()
                                        Spacer()
                                    }
                                    HStack {
                                        Text("Map: ")
                                            .padding([.leading, .top, .bottom])
                                        Picker("Please choose a color", selection: $selectedMapView) {
                                            ForEach(mapTypes, id: \.self) { index in
                                                Text(mapTypesString[index])
                                            }
                                        }
                                        .pickerStyle(.segmented)
//                                        .padding(.leading, -15)
                                        Spacer()
                                    }
                                    HStack {
                                        Toggle("Sort departure view by track", isOn: $trackTimes)
                                            .padding()
                                    }
                                    Text("Color Scheme:")
                                        .padding([.top, .leading, .trailing])
                                    HStack {
                                        VStack {
                                            Button {
                                                darkMode = 0
                                            } label: {
                                                HStack {
                                                    Text("Light")
                                                        .foregroundColor(.black)
                                                    Image(systemName: "sun.max.fill")
                                                        .foregroundColor(.black)
                                                }
                                                .padding(.vertical, 2)
                                            }
                                            .buttonStyle(ToggleButton(color: .white))
                                            if darkMode == 0 {
                                                RoundedRectangle(cornerRadius: 100)
                                                    .frame(width: 40, height: 5)
                                                    .foregroundColor(Color("blue"))
                                                    .shadow(radius: 2)
                                            } else {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .frame(width: 40, height: 3)
                                                    .foregroundColor(Color("cLessDarkGray"))
                                            }
                                        }
                                        
                                        VStack {
                                            Button {
                                                darkMode = 1
                                            } label: {
                                                HStack {
                                                    Text("Dark")
                                                        .foregroundColor(.white)
                                                    Image(systemName: "moon.fill")
                                                        .foregroundColor(.white)
                                                }
                                                .padding(.vertical, 2)
                                            }
                                            .buttonStyle(ToggleButton(color: .black))
                                            if darkMode == 1 {
                                                RoundedRectangle(cornerRadius: 100)
                                                    .frame(width: 40, height: 5)
                                                    .foregroundColor(Color("blue"))
                                                    .shadow(radius: 2)
                                            } else {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .frame(width: 40, height: 3)
                                                    .foregroundColor(Color("cLessDarkGray"))
                                            }
                                        }
                                        
                                        VStack {
                                            Button {
                                                darkMode = 2
                                            } label: {
                                                HStack {
                                                    Text("System")
                                                        .foregroundColor(.white)
                                                }
                                                .padding(.vertical, 2)
                                            }
                                            .buttonStyle(ToggleButton(color: .gray))
                                            if darkMode == 2 {
                                                RoundedRectangle(cornerRadius: 100)
                                                    .frame(width: 40, height: 5)
                                                    .foregroundColor(Color("blue"))
                                                    .shadow(radius: 2)
                                            } else {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .frame(width: 40, height: 3)
                                                    .foregroundColor(Color("cLessDarkGray"))
                                            }
                                        }
                                    }
                                    .padding([.top, .leading, .trailing])
                                    Spacer()
                                }
                            }
                            .frame(width: UIScreen.screenWidth - 24, height: 160)
                            Spacer()
                                .frame(height: 50)
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color("cLessDarkGray"))
                                    .shadow(radius: 2)
                                    .frame(width: UIScreen.screenWidth - 24, height: 200)
                                HStack {
                                    VStack(alignment: .leading, spacing: 13) {
                                        Button {
                                            showAbout = true
                                        } label: {
                                            Text("About")
                                        }
                                        Button {
                                            if MFMailComposeViewController.canSendMail() {
                                                showFeedback = true
                                            } else {
                                                alertNoMail = true
                                            }
                                        } label: {
                                            Text("Send Feedback")
                                        }
                                        .alert("No Email Set Up", isPresented: $alertNoMail, actions: {
                                            Button("Cancel", role: .cancel) { }
                                            Button {
                                                pastboard.string = "transitbandage@gmail.com"
                                            } label: {
                                                Label("Copy Email", systemImage: "doc.on.doc")
                                            }
                                        }, message: {
                                            Text("You do not have an email set up. Go to settings, or send the email to \"transitbandage@gmail.com\".")
                                        })

                                        Text("Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")")
                                        Text("Made with ❤️ in NYC 🗽🥨")
                                        Button {
                                            showSettings = false
                                            isPresentWebView = true
                                        } label: {
                                            Text("Donate to Transit Bandage :)")
                                        }
                                    }
                                    .frame(width: UIScreen.screenWidth - 110, height: 250)
                                    Spacer()
                                }
                                
                            }
                            Spacer()
                                .frame(height: 20)
                        }
                        .padding(.top,65)
                    }
                    .navigationTitle("Settings")
                    .sheet(isPresented: $showAbout) {
                        ZStack {
                            VStack {
                                HStack {
                                    Text("We value privacy. Transit Bandage does not collect user data.")
                                        .padding()
                                    Spacer()
                                }
                                HStack {
                                    Text(String(format: NSLocalizedString("about-section", comment: "")))
                                        .padding()
                                    Spacer()
                                }
                                Spacer()
                            }
                            CloseSheet()
                        }
                    }
                    .sheet(isPresented: $showFeedback) {
                        MailView(result: self.$result)
                    }
                }
                CloseSheet()
            }
//            .preferredColorScheme(getColorScheme())
            .syncLayoutOnDissappear()
        }
        .sheet(isPresented: $isPresentWebView) {
            ZStack {
                NavigationView {
                    WebView(url: URL(string: "https://ko-fi.com/conradbooker")!)
                        .ignoresSafeArea()
                        .navigationBarTitleDisplayMode(.inline)
                }
                .padding(.bottom, 80)
                VStack {
                    ZStack {
                        CloseSheet()
                        OpenInSafari()
                    }
                }
//                .padding(.bottom, 60)
            }
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environment(\.managedObjectContext, CoreDataManager.shared.persistentContainer.viewContext)
            .environmentObject(LocationViewModel())
    }
}
