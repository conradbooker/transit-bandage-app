//
//  LocalPanel.swift
//  Transit Bandage
//
//  Created by Conrad on 6/14/24.
//

import SwiftUI

struct LocalPanel: View {

    var alerts: Line_ServiceDisruption
    var destination: String
    var alert: String
    var few: Bool

    @State var isExpanded: Bool = false
    
    @State var textSize: CGFloat = 0

    var body: some View {
            ZStack {
//                Rectangle()
//                    .frame(height: isExpanded ? textSize+60 : 60)
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(bgColor.third.value)
                    .shadow(radius: 2)
//                    .opacity(0.5)
                HStack {
                    Image(systemName: "tortoise.fill")
                        .foregroundStyle(Color("whiteblack"))
                        .padding(1)
                        .padding(.leading,12)
                        .font(.system(size: 21))
                    
                    VStack(alignment: .leading) {
                        if isExpanded {
                            Spacer().frame(height: 10)
                        }
                        if few {
                            Text("A few running **Local** from")
                            .foregroundColor(Color("whiteblack"))
                        } else {
                            Text("Running **Local** from")
                            .foregroundColor(Color("whiteblack"))
                        }
                        Text("**\(stationsDict[alerts.new[destination]?.serviceAlerts.localStations?[alert]?.from ?? ""]?.short1 ?? "")** to **\(stationsDict[alerts.new[destination]?.serviceAlerts.localStations?[alert]?.to ?? ""]?.short1 ?? "")**")
                            .foregroundColor(Color("whiteblack"))
                        if isExpanded {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Trains **WILL stop at:**")
                                    .padding(.top, 5)
                                    .foregroundColor(Color("whiteblack"))
                                ForEach(0..<(alerts.new[destination]?.serviceAlerts.localStations?[alert]?.stations?.count ?? 0), id: \.self) { index in
                                    if alerts.new[destination]?.serviceAlerts.localStations?[alert]?.stations?[index].count ?? 0 > 0 {
                                        Text(getAllStations(stations: alerts.new[destination]?.serviceAlerts.localStations?[alert]?.stations?[index] ?? []))
                                            .multilineTextAlignment(.leading)
//                                            .padding(.top, -5)
                                            .fixedSize(horizontal: false, vertical: true)
                                            .foregroundColor(Color("whiteblack"))
                                    }
                                }
                                Spacer()
                            }
                            .readSize { size in
                                if size.height > textSize {
                                    textSize = size.height
                                }
                            }
                        }
                    }
                    .padding(.leading, 2)
                    Spacer()
                    Image(systemName: "chevron.down.circle.fill")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .foregroundColor(Color("whiteblack"))
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

#Preview {
    LocalPanel(alerts: load("exampleServiceDisruption.json"), destination: "A02", alert: "A09A24", few: false)
}
