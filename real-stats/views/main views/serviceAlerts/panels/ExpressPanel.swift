//
//  ExpressPanel.swift
//  Transit Bandage
//
//  Created by Conrad on 6/14/24.
//

import SwiftUI

struct ExpressPanel: View {
    
    var alerts: Line_ServiceDisruption
    var destination: String
    var alert: String
    var few: Bool
    
    @State var isExpanded: Bool = false
    
    @State var textSize: CGFloat = 0
    
    var body: some View {
        if (alerts.new[destination]?.serviceAlerts.skippedStations?[alert]?.type == "skipping") {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(bgColor.third.value)
                    .shadow(radius: 2)
                HStack {
                    Image(systemName: "clock.badge.xmark.fill")
                        .foregroundStyle(.red, Color("whiteblack"))
                        .padding(2)
                        .padding(.leading,10)
                        .padding(.trailing, 2)
                        .font(.system(size: 30))
                    
                    VStack(alignment: .leading) {
                        if few {
                            Text("A few **skipping**: \(getAllStations(stations: alerts.new[destination]?.serviceAlerts.skippedStations?[alert]?.stations?[0] ?? []))")
                        } else {
                            Text("**Skipping**: \(getAllStations(stations: alerts.new[destination]?.serviceAlerts.skippedStations?[alert]?.stations?[0] ?? []))")
                        }
                    }
                    Spacer()
                }
            }
            .frame(height: 60)
        } else {
            ZStack {
//                    Rectangle()
//                        .frame(height: isExpanded ? textSize+60 : 60)
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(bgColor.third.value)
                    .shadow(radius: 2)
//                        .opacity(0.5)
                HStack {
                    Image(systemName: "hare.fill")
                        .foregroundStyle(Color("whiteblack"))
                        .padding(1)
                        .padding(.leading,12)
                        .font(.system(size: 22))
                    
                    VStack(alignment: .leading) {
                        if isExpanded {
                            Spacer().frame(height: 10)
                        }
                        if few {
                            Text("A few running **Express** from\n**\(stationsDict[alerts.new[destination]?.serviceAlerts.skippedStations?[alert]?.from ?? ""]?.short1 ?? "")** to **\(stationsDict[alerts.new[destination]?.serviceAlerts.skippedStations?[alert]?.to ?? ""]?.short1 ?? "")**")
                        } else {
                            Text("Running **Express** from\n**\(stationsDict[alerts.new[destination]?.serviceAlerts.skippedStations?[alert]?.from ?? ""]?.short1 ?? "")** to **\(stationsDict[alerts.new[destination]?.serviceAlerts.skippedStations?[alert]?.to ?? ""]?.short1 ?? "")**")
                        }
                        VStack(alignment: .leading, spacing: 12) {
                            if isExpanded {
                                Text("Trains **will NOT stop at:**")
                                    .padding(.top, 5)
                                ForEach(0..<(alerts.new[destination]?.serviceAlerts.skippedStations?[alert]?.stations?.count ?? 0), id: \.self) { index in
                                    if alerts.new[destination]?.serviceAlerts.skippedStations?[alert]?.stations?[index].count ?? 0 > 0 {
                                        Text(getAllStations(stations: alerts.new[destination]?.serviceAlerts.skippedStations?[alert]?.stations?[index] ?? []))
//                                                .padding(.top, -5)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                                Spacer()
                            }
                        }
                        .readSize { size in
                            textSize = size.height
                        }
                    }
                    .padding(.leading, 2)
                    Spacer()
                    Image(systemName: "chevron.down.circle.fill")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .padding(.trailing, 12)
                        .font(.title3)
                }
            }
            .frame(height: isExpanded ? textSize+60 : 60)
            .onTapGesture {
                withAnimation(.spring(response: 0.31, dampingFraction: 0.74)) {
                    if !isExpanded {
                        isExpanded = true
                    } else {
                        isExpanded = false
                    }
                }
            }
        }
    }
}

#Preview {
    ExpressPanel(alerts: load("exampleServiceDisruption.json"), destination: "A02", alert: "A15A09", few: false)
}
