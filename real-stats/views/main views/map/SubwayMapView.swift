//
//  SubwayMapView.swift
//  Service Bandage
//
//  Created by Conrad on 2/23/24.
//

import SwiftUI

import SwiftUI
import SVGView

extension UIScreen {
    static var topSafeArea: CGFloat {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        
        return (keyWindow?.safeAreaInsets.top) ?? 0
    }
}

struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    @Binding var inited: Bool
    @Binding var inited2: Bool
    @Binding var settingPosition: Bool
    var contentOffset: CGPoint
    private var content: Content
    
    @AppStorage("xOffset") var xOffset: Double = 1000
    @AppStorage("yOffset") var yOffset: Double = 1000
    @AppStorage("zoom") var zoom: Double = 10
    

    init(inited: Binding<Bool>, inited2: Binding<Bool>, contentOffset: CGPoint, settingPosition: Binding<Bool>, @ViewBuilder content: () -> Content) {

        self.content = content()
        self._inited = inited
        self._inited2 = inited2
//        self.xOffset = xOffset
//        self.yOffset = yOffset
        self.contentOffset = contentOffset
        self._settingPosition = settingPosition
    }
    

    func makeUIView(context: Context) -> UIScrollView {
        // set up the UIScrollView
        let scrollView = UIScrollView()
        
        
        scrollView.delegate = context.coordinator  // for viewForZooming(in:)
        scrollView.maximumZoomScale = 20
        scrollView.minimumZoomScale = 3
        scrollView.bouncesZoom = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -300 /* ends in 95*/, right: 0)
//        scrollView.setContentOffset(CGPoint(x: 500, y: 500), animated: true)
//        scrollView.contentInset = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)
        DispatchQueue.main.async {
            if !inited {
                scrollView.setZoomScale(zoom, animated: true)
                inited = true
            }
        }

        // create a UIHostingController to hold our SwiftUI content
        let hostedView = context.coordinator.hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = true
        hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostedView.frame = scrollView.bounds
        scrollView.addSubview(hostedView)
//        scrollView.setContentOffset(CGPoint(x: xOffset, y: yOffset), animated: false)
        print("CURRENT CONTENT AT \(CGPoint(x: xOffset, y: yOffset))")
//        scrollView.zoomScale = 8

        return scrollView
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(hostingController: UIHostingController(rootView: self.content), parent: self)
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // update the hosting controller's SwiftUI content
        context.coordinator.hostingController.rootView = self.content
//        print("UIVIEW x: \(uiView.contentOffset.x), y: \(uiView.contentOffset.y)")
        
//        DispatchQueue.main.async {
////            if !inited {
//                print(contentOffset)
//                uiView.setContentOffset(contentOffset, animated: false)
////                inited = true
////            }
//        }
        
        assert(context.coordinator.hostingController.view.superview == uiView)
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>
        
        let parent: ZoomableScrollView

        init(hostingController: UIHostingController<Content>, parent: ZoomableScrollView) {
            self.hostingController = hostingController
            self.parent = parent
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let offset = scrollView.contentOffset

            if parent.settingPosition {
                scrollView.contentOffset = self.parent.contentOffset
                self.parent.settingPosition = false
            }
            
            if !parent.inited2 {
                scrollView.setContentOffset(CGPoint(x: parent.xOffset, y: parent.yOffset), animated: false)
                parent.inited2 = true
            }
            
//            print("Relative content offset: x:\(offset.x/scrollView.zoomScale), y:\(offset.y/scrollView.zoomScale)")
//            print("Content offset: x:\(offset.x), y:\(offset.y)")
//            print("APPSTOR offset: x:\(parent.xOffset), y:\(parent.yOffset)")
            parent.xOffset = offset.x
            parent.yOffset = offset.y
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            parent.zoom = scrollView.zoomScale
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController.view
        }
        
        
    }
}

struct StationItem: Identifiable {
    let id = UUID()
    let complex: Complex
    let station: Int
}

struct DiagramicMapView: View {
    @State var inited = false
    @State var inited2 = false
    @State var contentOffset = CGPoint(x: 0, y: 0)
    @State var settingPosition = false
    
    @AppStorage("xOffset") var xOffset: Double = 1000
    @AppStorage("yOffset") var yOffset: Double = 1000
    @AppStorage("zoom") var zoom: Double = 10
    
    @AppStorage("offsetInited") var offsetInited: Bool = false
    
    @State private var showSVG = false
    
    @State var selectedStation: StationItem?
    
    @State var fromFavorites: Bool = false
    @FetchRequest(entity: FavoriteStation.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var favoriteStations: FetchedResults<FavoriteStation>

    @Environment(\.managedObjectContext) private var viewContext
    let persistedContainer = CoreDataManager.shared.persistentContainer
    
    func isWithinBounds(station: MapLocation, geometry: GeometryProxy) -> Bool {
        let inBoundsOfX = station.x * zoom > xOffset && station.x * zoom - geometry.size.width < xOffset
        let inBoundsOfY = station.y * zoom/(UIScreen.screenHeight/UIScreen.screenWidth) >= yOffset && station.y * zoom/(UIScreen.screenHeight/UIScreen.screenWidth) - UIScreen.screenHeight < yOffset
        
        return inBoundsOfX
    }
        
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

    @AppStorage("selectedMapView") var selectedMapView: Int = 1
    @State private var offsetyChange: Double = 72
    @State private var offsetY: Double = -393.4
    @State private var scaleX: Double = 1.0
    @State private var scaleY: Double = 1.0

    func mapAnnotationStation(_ key: String) -> MapLocation {
        
        var newThang = mapViewData[selectedMapView].stationLocations[key] ?? MapLocation(x: 0, y: 0, station: 0, shape: 0, angle: 0)
        newThang.x = newThang.x/393 * UIScreen.screenWidth
        newThang.y = (newThang.y/393 * UIScreen.screenWidth) - UIScreen.offsetVal

        return newThang
    }
    
    var mapName: String {
        let thing = "\(mapViewData[selectedMapView].country)_\(mapViewData[selectedMapView].region)_\(mapViewData[selectedMapView].mapName)_\(getMapType(mapViewData[selectedMapView].region))_0_"
//        print(thing)
        return thing
    }
        
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ZoomableScrollView(inited: $inited, inited2: $inited2, contentOffset: CGPoint(x: xOffset, y: yOffset + offsetyChange*2), settingPosition: $settingPosition) {
                    ZStack {
                        if getColorScheme() == .dark {
                            
                            Image(mapName + "dark")
                                .resizable()
                                .frame(width: geometry.size.width, height: geometry.size.width * 1.217)
                                .onAppear {
                                    contentOffset = CGPoint(x: xOffset, y: yOffset + offsetyChange*2)
                                    settingPosition = true
                                }
                                .padding(.top, offsetY + offsetyChange*2 + geometry.safeAreaInsets.top)
                        } else {
                            Image(mapName + "light")
                                .resizable()
                                .frame(width: geometry.size.width, height: geometry.size.width * 1.217)
                                .onAppear {
                                    contentOffset = CGPoint(x: xOffset, y: yOffset + offsetyChange*2)
                                    settingPosition = true
                                }
                                .padding(.top, offsetY + offsetyChange*2 + geometry.safeAreaInsets.top)
                        }
                        ForEach(Array(mapViewData[selectedMapView].stationLocations.keys), id: \.self) { key in
                            if isWithinBounds(station: mapAnnotationStation(key), geometry: geometry) {
                                Button {
                                    var tempStation = ""
                                    for complex in complexData {
                                        for stat in complex.stations {
                                            if key == stat.GTFSID {
                                                selectedStation = StationItem(complex: complex, station: mapAnnotationStation(key).station)
                                                for favoriteStation in favoriteStations {
                                                    if favoriteStation.complexID == complex.id {
                                                        fromFavorites = true
                                                        break
                                                    }
                                                    fromFavorites = false
                                                }
                                                break
                                            }
                                        }
                                    }
                                } label: {
                                    if mapAnnotationStation(key).shape == 0 {
                                        Circle()
                                            .frame(width: 2,height: 2)
                                    } else {
                                        Rectangle()
                                            .frame(width: 4,height: 2)
                                            .rotationEffect(mapAnnotationStation(key).angle_deg)
                                    }
                                }
                                .position(x: mapAnnotationStation(key).x, y: mapAnnotationStation(key).y + offsetyChange)
                                .padding(.top, offsetY + geometry.safeAreaInsets.top)
                            }
                        }
                    }
                }
                .ignoresSafeArea(.all)
//                VStack {
//                    Slider(
//                        value: $offsetyChange,
//                        in: -100...100
//                    )
//                    Text("\(offsetyChange)")
//                    Text("height: \(UIScreen.screenHeight)")
//                }
            }
            .sheet(item: $selectedStation) { item in
                ZStack {
                    if fromFavorites {
                        // chosen station = favoriteStationNumber thing
                        StationView(complex: item.complex, chosenStation: item.station, isFavorited: true)
                            .environment(\.managedObjectContext, persistedContainer.viewContext)
                            .syncLayoutOnDissappear()
                    } else {
                        StationView(complex: item.complex, chosenStation: item.station, isFavorited: false)
                            .environment(\.managedObjectContext, persistedContainer.viewContext)
                            .syncLayoutOnDissappear()
                    }
                    CloseSheet()
                }
            }
        }
    }
}

struct DiagramicMapView_Previews: PreviewProvider {
    static var previews: some View {
        DiagramicMapView()
    }
}
