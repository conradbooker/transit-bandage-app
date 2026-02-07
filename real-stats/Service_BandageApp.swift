//
//  real_statsApp.swift
//  real-stats
//
//  Created by Conrad on 2/8/23.
//

import SwiftUI

@main
struct Service_BandageApp: App {
    let persistentContainer = CoreDataManager.shared.persistentContainer
    @StateObject var locationViewModel = LocationViewModel()
    
    @AppStorage("darkMode") var darkMode: Int = 2
    @Environment(\.colorScheme) var colorScheme: ColorScheme

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
    
    @State private var showPopup = false

    @AppStorage("selectedMapView") var selectedMapView: Int = 1
    var key: String {
        let thing = "\(mapViewData[selectedMapView].country)_\(mapViewData[selectedMapView].region)_key"
//        print(thing)
        return thing
    }
    
    var body: some Scene {
        WindowGroup {
            Home()
                .environment(\.managedObjectContext, persistentContainer.viewContext)
                .preferredColorScheme(getColorScheme())
                .environmentObject(locationViewModel)
                .onOpenURL { url in
                    let string = url.absoluteString
                    if String(url.scheme ?? "") == "transitbandage", let host = url.host {
                        if host == "map-event" {
                            showPopup = true
                        }
                    }
                }
                .sheet(isPresented: $showPopup) {
                    ZStack {
                        NavigationView {
                            ZStack {
                                bgColor.third.value
                                    .ignoresSafeArea()
                                VStack {
                                    ZoomableScrollView2 {
                                        ZStack {
                                            bgColor.third.value
                                                .ignoresSafeArea()
                                            VStack {
                                                if getColorScheme() == .dark {
                                                    Image(key + "_dark")
                                                        .resizable()
                                                        .scaledToFit()
                                                } else {
                                                    Image(key + "_light")
                                                        .resizable()
                                                        .scaledToFit()
                                                }
                                                Spacer()
                                            }
                                        }
                                    }
                                    VStack(alignment: .leading) {
                                        LeadingText(text: "Scroll to move the map around\n\nPinch to zoom with two fingers\n\nTap to open a station", padding: 12, fontType: .body)
                                    }
                                }
                                .navigationTitle("How to use the map!")
                            }
                        }
                        CloseSheet()
                    }
                }
        }
    }
}

