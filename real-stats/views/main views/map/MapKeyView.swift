//
//  MapKeyView.swift
//  Transit Bandage
//
//  Created by Conrad on 3/21/24.
//

import SwiftUI

struct MapKeyView: View {
    @AppStorage("selectedMapView") var selectedMapView: Int = 1
    var key: String {
        let thing = "\(mapViewData[selectedMapView].country)_\(mapViewData[selectedMapView].region)_key"
//        print(thing)
        return thing
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

    var body: some View {
        NavigationView {
            ZStack {
                bgColor.third.value
                    .ignoresSafeArea()
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
                .navigationTitle("Key")
            }
        }
//            .navigationback
    }
}

#Preview {
    MapKeyView()
}

struct ZoomableScrollView2<Content: View>: UIViewRepresentable {
    private var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    

    func makeUIView(context: Context) -> UIScrollView {
        // set up the UIScrollView
        let scrollView = UIScrollView()
        
        
        scrollView.delegate = context.coordinator  // for viewForZooming(in:)
        scrollView.maximumZoomScale = 10
        scrollView.minimumZoomScale = 1
        scrollView.bouncesZoom = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        scrollView.contentInsetAdjustmentBehavior = .never
        let hostedView = context.coordinator.hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = true
        hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostedView.frame = scrollView.bounds
        scrollView.addSubview(hostedView)
        return scrollView
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(hostingController: UIHostingController(rootView: self.content))
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        context.coordinator.hostingController.rootView = self.content
        assert(context.coordinator.hostingController.view.superview == uiView)
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>
        
        init(hostingController: UIHostingController<Content>) {
            self.hostingController = hostingController
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController.view
        }
        
        
    }
}
