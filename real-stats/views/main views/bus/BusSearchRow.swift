//
//  BusSearchRow.swift
//  Service Bandage
//
//  Created by Conrad on 1/13/24.
//

import SwiftUI
import WrappingStack

func getCorrectColor(route: String) -> [Color] {
    do {
        if ["A","C","E","JSQ_33_HOB","33_HOB"].contains(busRouteData[route]) {
            return [Color.white,Color("blue")]
        } else if ["N","Q","R","W","JSQ_33"].contains(busRouteData[route]) {
            return [Color.white,Color("yellow")]
        } else if ["B","D","F","FX","M"].contains(busRouteData[route]) {
            return [Color.white,Color("orange")]
        } else if ["J","Z"].contains(busRouteData[route]) {
            return [Color.white,Color("brown")]
        } else if ["1","2","3","NWK_WTC"].contains(busRouteData[route]) {
            return [Color.white,Color("red")]
        } else if ["4","5","6","6X","HOB_WTC"].contains(busRouteData[route]) {
            return [Color.white,Color("green")]
        } else if ["7","7X"].contains(busRouteData[route]) {
            return [Color.white,Color("purple")]
        }else if ["G"].contains(busRouteData[route]) {
            return [Color.white,Color("lime")]
        } else if ["H","FS","S","GS"].contains(busRouteData[route]) {
            return [Color.white,Color("darkerGray")]
        } else if ["L"].contains(busRouteData[route]) {
            return [Color.white,Color("lighterGray")]
        } else if ["SI"].contains(busRouteData[route]) {
            return [Color.white,Color("grayBlue")]
        } else if ["SS"].contains(busRouteData[route]) {
            return [Color.white,Color("grayRed")]
        } else if busRouteData[route] == "express" {
            return [Color.white,Color("green")]
        } else if busRouteData[route] == "sbs" {
            return [Color.white,Color("turqoise")]
        } else if busRouteData[route] == "limited" {
            return [Color.white,Color("red")]
        } else {
            return [Color.black,Color("yellow")]
        }
    }
    catch {
        return [Color.black,Color("yellow")]
    }
}

import CoreLocation

struct BusSearchRow: View {
    var stop_id: String
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showBus: Bool = false
    
    @State private var counter: Double = 0

    var body: some View {
        Button {
            showBus = true
        } label: {
            ZStack {
                bgColor.third.value
                    .environment(\.colorScheme,colorScheme)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    .frame(height: 60)
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(String(busData_dictionary[stop_id]?.name ?? "Undefined"))
                        WrappingHStack(id: \.self, alignment: .leading) {
                            ForEach(busData_dictionary[stop_id]?.lines ?? [String](), id: \.self) { line in
                                Text(line)
                                    .padding(2)
                                    .font(.footnote)
                                    .foregroundColor(getCorrectColor(route: line)[0])
                                    .background(
                                        getCorrectColor(route: line)[1]
                                        //                                .padding()
                                        //                                .padding(.horizontal,5)
                                            .background(.ultraThinMaterial)
                                            .cornerRadius(3)
                                            .shadow(radius: 2)
                                        
                                    )
                                    .padding(.trailing,4)
                            }
                        }
                        .padding(.top, 5)

                    }
                    .padding(.leading, 5)
                    Spacer()
                }
            }
            .padding(6)
        }
        .buttonStyle(CButton())
        .sheet(isPresented: $showBus) {
            ZStack {
                ScrollView {
                    Spacer().frame(height: 10)
                    BusView(coordinate: CLLocationCoordinate2D(latitude: busData_dictionary[stop_id]?.lat ?? 0, longitude: busData_dictionary[stop_id]?.lon ?? 0), counter: counter)
                }
                CloseSheet()
            }
        }
    }
}

struct BusSearchRow_Previews: PreviewProvider {
    static var previews: some View {
        BusSearchRow(stop_id: "401093")
    }
}
