//
//  serviceAlertsView.swift
//  Service Bandage
//
//  Created by Conrad on 7/30/23.
//

import SwiftUI
import Reachability

struct serviceAlertsViewNew: View {
    @State var isInternetConnected = true
    
    var line: String
    @State var direction: String
    @State var textSize = CGSize(width: 80, height: 0)
    
    @State var alerts: Line_ServiceDisruption = load("exampleServiceDisruption.json")
    
    func getDestinationsKeys(_ dict: [String: DisruptionNew], _ direction: String, _ selectedSegment: [String]) -> [String] {
        var keys = [String]()
        for disruption in dict {
            if disruption.value.direction.contains(direction) {
                if selectedSegment.count == 0 || selectedSegment.contains(disruption.key) {
                    keys.append(disruption.key)
                }
            } else if direction == "all" {
                if selectedSegment.count == 0 || selectedSegment.contains(disruption.key) {
                    keys.append(disruption.key)
                }
            }
        }
        return keys
    }
    
    func getSuspensionKeys(_ dict: [String: Line_ServiceDisruption_Suspended]) -> [String] {
        var keys = [String]()
        for key in dict {
            keys.append(key.key)
        }
        
        return keys
    }
    func getLocalStationKeys(_ dict: [String: LocalStations]) -> [String] {
        var keys = [String]()
        for key in dict {
            keys.append(key.key)
        }
        
        return keys
    }
    func getSkippedStationKeys(_ dict: [String: SkippedStations]) -> [String] {
        var keys = [String]()
        for key in dict {
            keys.append(key.key)
        }
        
        return keys
    }
    func getRerouteKeys(_ dict: [String: Line_ServiceDisruption_Reroutes]) -> [String] {
        var keys = [String]()
        for key in dict {
            keys.append(key.key)
        }
        
        return keys
    }
    func getDelayKeys(_ dict: [String: IndividualDelay]) -> [String] {
        var keys = [String]()
        for key in dict {
            keys.append(key.key)
        }
        
        return keys
    }
    
    func delay(destination: String, alert: String) -> IndividualDelay  {
        return alerts.new[destination]?.performance.delays[alert] ?? IndividualDelay(destination: "420", delayAmmount: 120, location: "421", track: "2")
    }
    
    func serviceAlerts(destination: String) -> Bool {
        if alerts.new[destination]?.serviceAlerts.localStations?.count ?? 0 > 0 {
            return true
        } else if alerts.new[destination]?.serviceAlerts.skippedStations?.count ?? 0 > 0 {
            return true
        } else if alerts.new[destination]?.serviceAlerts.suspended?.count ?? 0 > 0 {
            return true
        }
        return false
    }
    
//    func delay(destination: String, alert: String) -> IndividualDelay  {
//        return alerts.new[destination]?.performance.delays[alert] ?? IndividualDelay(destination: "420", delayAmmount: 120, location: "421", track: "2")
//    }

    init(line: String, direction: String, isFavorited: Bool) {
        self.line = line
        self._direction = State(initialValue: direction)
        self._isFavorited = State(initialValue: isFavorited)
    }
    
    func roundSecondsToNearestMinute(seconds: Int) -> Int {
        let minutes = Double(seconds) / 60.0
        let roundedMinutes = minutes.rounded()
        return Int(roundedMinutes)
    }
    
    func getDirectionBoros(station: String) -> String {
        let boro = stationsDict[station]?.boro ?? ""
        
        if boro == "M" {
            return "Manhattan"
        } else if boro == "Q" {
            return "Queens"
        } else if boro == "Bx" {
            return "Bronx"
        } else if boro == "Bk" {
            return "Brooklyn"
        } else if boro == "SI" {
            return "Staten Island"
        }
        return boro
    }
    
    func getDirectionText(direction: String) -> String {
        var allDestinationBoros = Set<String>()
        for destination in alerts.new.keys {
            if alerts.new[destination]?.direction == direction {
                allDestinationBoros.insert(getDirectionBoros(station: destination))
            }
        }
        if allDestinationBoros.count == 1 {
            return allDestinationBoros.first ?? ""
        }
        var destinationText = ""
        var index = 0
        for destination in allDestinationBoros {
            if index < allDestinationBoros.count - 1 {
                destinationText += "\(destination)\n"
            } else {
                destinationText += "\(destination)"
            }
        }
        return destinationText
    }
    
    @State var isFavorited: Bool
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(entity: FavoriteLine.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var favoriteLines: FetchedResults<FavoriteLine>
    
    func deleteFavorite() {
        for favoriteLine in favoriteLines {
            if favoriteLine.line == line {
                viewContext.delete(favoriteLine)
                do {
                    try viewContext.save()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func addFavorite() {
        for favoriteLine in favoriteLines {
            if favoriteLine.line == line {
                return
            }
        }
        let favoriteLine = FavoriteLine(context: viewContext)
        favoriteLine.line = line
        favoriteLine.dateCreated = Date()
        favoriteLine.text = ""
        do {
            try viewContext.save()
            print(favoriteLines)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @State var selectedSegment = [String]()
    
    var showSegments: Bool {
        var viableSegments = [String]()
        for key in Array(alerts.overview.segments.keys) {
            if alerts.overview.segments[key]?.startTime ?? 0 < 10000 {
                viableSegments.append(key)
            }
        }
        if viableSegments.count > 1 {
            return true
        }
        return false
    }
    
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

    @State private var loading = true
    
    var body: some View {
        GeometryReader { geometry in
        ZStack {
            bgColor.first.value
                .ignoresSafeArea()
                .onAppear {
                    checkInternetConnection()
                }
            ScrollView {
                Spacer().frame(height: 120)
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
// MARK: - Main Content
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
                    } else {
                        VStack {
                            if showSegments {
                                HStack {
                                    Text("Running in **\(Array(alerts.overview.segments.keys).count) sections**:")
                                        .font(.title2)
                                        .padding(.leading, 12)
                                        .padding(.bottom, 3)
                                    Spacer()
                                }
                                
                                ForEach(Array(alerts.overview.segments.keys), id: \.self) { key in
                                    if alerts.overview.segments[key]?.startTime ?? 0 < 10000 {
                                        Button {
                                            if selectedSegment == alerts.overview.segments[key]?.stations ?? [] {
                                                selectedSegment = [String]()
                                            } else {
                                                selectedSegment = alerts.overview.segments[key]?.stations ?? []
                                            }
                                        } label: {
                                            ZStack {
                                                if selectedSegment == alerts.overview.segments[key]?.stations ?? [] {
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .foregroundColor(bgColor.third.value)
                                                        .frame(width: geometry.size.width-24, height: 40)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 13)
                                                                .stroke(.blue,lineWidth: 2)
                                                                .frame(width: geometry.size.width-16, height: 48)
                                                        )
                                                        .shadow(radius: 2)
                                                } else {
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .foregroundColor(bgColor.third.value)
                                                        .frame(width: geometry.size.width-24, height: 40)
                                                        .shadow(radius: 2)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 12)
                                                                .stroke(bgColor.first.value,lineWidth: 2)
                                                                .frame(width: geometry.size.width-16, height: 48)
                                                        )
                                                    
                                                }
                                                Text("**\(stationsDict[alerts.overview.segments[key]?.stations[0] ?? ""]?.short ?? "") ↔ \(stationsDict[alerts.overview.segments[key]?.stations[1] ?? ""]?.short ?? "")**")
                                                    .font(.title3)
                                            }
                                        }
                                        .buttonStyle(CButton())
                                        .padding(.bottom, 8)
                                    }
                                }
                                Spacer()
                                    .frame(height: 8)
                                Divider()
                            }
                            
                            ForEach(getDestinationsKeys(alerts.new, direction, selectedSegment), id: \.self) { destination in
                                // MARK: - Destination
                                HStack {
                                    Text("**To \(stationsDict[destination]?.short ?? "")**")
                                        .font(.title)
                                        .padding(.leading, 12)
                                        .padding(.bottom, 3)
                                    Spacer()
                                }
                                // MARK: - Service Performance
                                if (abs(Int(alerts.new[destination]?.performance.OTP ?? 0)) < 60) {
                                    HStack(spacing: 0) {
                                        Text("Trains are **on time**")
                                            .font(.title3)
                                        Image(systemName: "clock.badge.checkmark.fill")
                                            .padding(.leading, 4)
                                            .foregroundStyle(Color("green"), Color("whiteblack"))
                                        Spacer()
                                    }
                                    .padding(.leading, 12)
                                } else {
                                    HStack(spacing: 0) {
                                        if roundSecondsToNearestMinute(seconds: Int(alerts.new[destination]?.performance.OTP ?? 0)) > 0 {
                                            Text("Trains are avg. **\(roundSecondsToNearestMinute(seconds: Int(alerts.new[destination]?.performance.OTP ?? 0))) min behind schedule**")
                                                .font(.title3)
                                        } else {
                                            Text("Trains are avg. **\(abs(roundSecondsToNearestMinute(seconds: Int(alerts.new[destination]?.performance.OTP ?? 0)))) min ahead of schedule**")
                                                .font(.title3)
                                        }
                                        Spacer()
                                    }
                                    .padding(.leading, 12)
                                }
                                
                                if getDelayKeys(alerts.new[destination]?.performance.delays ?? [String: IndividualDelay]()).count > 0 {
                                    Spacer().frame(height: 6)
                                    ForEach(getDelayKeys(alerts.new[destination]?.performance.delays ?? [String: IndividualDelay]()), id: \.self) { alert in
                                        if delay(destination: destination, alert: alert).delayAmmount > 120 {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .foregroundColor(bgColor.third.value)
                                                    .shadow(radius: 2)
                                                    .frame(width: geometry.size.width-24,height: 60)
                                                //                                            .padding(.top,3)
                                                //                                        .padding()
                                                HStack {
                                                    Image(systemName: "clock.badge.exclamationmark.fill")
                                                        .foregroundStyle(.yellow, Color("whiteblack"))
                                                        .padding(2)
                                                        .padding(.leading,21)
                                                        .padding(.trailing,-6)
                                                        .padding(.top, 2)
                                                        .font(.system(size: 30))
                                                    VStack(alignment: .leading) {
                                                        HStack(spacing: 0) {
                                                            Image(String(alert.split(separator: "*")[1]))
                                                                .resizable()
                                                                .frame(width: 16, height: 16)
                                                                .padding(.leading, 5)
                                                                .padding(.trailing,1)
                                                            Text("to **\(stationsDict[delay(destination: destination, alert: alert).destination]?.short ?? "")** stalled")
                                                                .padding(4)
                                                        }
                                                        Text("at **\(stationsDict[delay(destination: destination, alert: alert).location]?.short ?? "")** for \(Int(alerts.northbound.delays?[alert]?.delayAmmount ?? 120)/60) minutes.")
                                                            .padding(.top,-10)
                                                            .padding(.leading, 5)
                                                    }
                                                    .padding(.leading, 6)
                                                    Spacer()
                                                }
                                            }
                                            //                                .frame(width: geometry.size.width,height: 60)
                                        }
                                    }
                                }
                                Spacer().frame(height: 0)
                                
                                // MARK: - Reroutes
                                if getRerouteKeys(alerts.new[destination]?.reroutes ?? [String: Line_ServiceDisruption_Reroutes]()).count > 0 {
                                    HStack {
                                        Text("**Reroutes**")
                                            .font(.title3)
                                            .padding(.leading, 12)
                                        Spacer()
                                    }
                                    .padding(.top, 15)
                                    Spacer().frame(height: 6)
                                    ForEach(getRerouteKeys(alerts.new[destination]?.reroutes ?? [String: Line_ServiceDisruption_Reroutes]()), id: \.self) { alert in
                                        if alerts.new[destination]?.reroutes?[alert]?.occurances ?? 0 >= Int(alerts.new[destination]?.performance.trainsInService ?? 0) * 2/3 {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .foregroundColor(bgColor.third.value)
                                                    .shadow(radius: 2)
                                                HStack {
                                                    Image(systemName: "point.topleft.down.curvedto.point.filled.bottomright.up")
                                                        .padding(2)
                                                        .padding(.leading,12)
                                                        .font(.system(size: 30))
                                                    VStack(alignment: .leading, spacing: 0) {
                                                        HStack(spacing: 0) {
                                                            Text("Running via")
                                                                .padding(4)
                                                            Image(alerts.new[destination]?.reroutes?[alert]?.via ?? "")
                                                                .resizable()
                                                                .frame(width: 16, height: 16)
                                                        }
                                                        Text("from **\(stationsDict[alerts.new[destination]?.reroutes?[alert]?.reroutedFrom ?? ""]?.short ?? "")** to **\(stationsDict[alerts.new[destination]?.reroutes?[alert]?.reroutedTo ?? ""]?.short ?? "")**")
                                                            .padding(.horizontal,4)
                                                    }
                                                    Spacer()
                                                }
                                            }
                                            .frame(width: geometry.size.width-24,height: 60)
                                        } else {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .foregroundColor(bgColor.third.value)
                                                    .shadow(radius: 2)
                                                HStack {
                                                    Image(systemName: "point.topleft.down.curvedto.point.filled.bottomright.up")
                                                        .padding(2)
                                                        .padding(.leading,12)
                                                        .font(.system(size: 30))
                                                    VStack(alignment: .leading, spacing: 0) {
                                                        HStack(spacing: 0) {
                                                            Text("A few trains running via")
                                                                .padding(4)
                                                            Image(alerts.new[destination]?.reroutes?[alert]?.via ?? "")
                                                                .resizable()
                                                                .frame(width: 16, height: 16)
                                                        }
                                                        Text("from **\(stationsDict[alerts.new[destination]?.reroutes?[alert]?.reroutedFrom ?? ""]?.short ?? "")** to **\(stationsDict[alerts.new[destination]?.reroutes?[alert]?.reroutedTo ?? ""]?.short ?? "")**")
                                                            .padding(.horizontal,4)
                                                    }
                                                    Spacer()
                                                }
                                            }
                                            .frame(width: geometry.size.width-24,height: 60)
                                        }
                                    }
                                    Spacer().frame(height: 14)
                                }
                                
                                // MARK: - Service Alerts
                                if serviceAlerts(destination: destination) {
                                    if !(getRerouteKeys(alerts.new[destination]?.reroutes ?? [String: Line_ServiceDisruption_Reroutes]()).count > 0) {
                                        Spacer().frame(height: 6)
                                    }
                                    HStack {
                                        Text("**Service Alerts**")
                                            .font(.title3)
                                            .padding(.leading, 12)
                                        Spacer()
                                    }
                                    Spacer().frame(height: 4)
                                    
                                    
                                    // MARK: - Suspended
                                    ForEach(getSuspensionKeys(alerts.new[destination]?.serviceAlerts.suspended ?? [String: Line_ServiceDisruption_Suspended]()), id: \.self) { alert in
                                        if alerts.new[destination]?.serviceAlerts.suspended?[alert]?.occurances ?? 0 >= Int(alerts.new[destination]?.performance.trainsInService ?? 0) * 2/3 {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .foregroundColor(bgColor.third.value)
                                                    .shadow(radius: 2)
                                                HStack {
                                                    Image(systemName: "xmark.octagon.fill")
                                                        .foregroundStyle(.white, .red)
                                                        .padding(2)
                                                        .padding(.leading,12)
                                                        .font(.system(size: 30))
                                                    
                                                    VStack(alignment: .leading) {
                                                        Text("**Not running** from **\(stationsDict[alerts.new[destination]?.serviceAlerts.suspended?[alert]?.stations[0] ?? ""]?.short ?? "")** to **\(stationsDict[alerts.new[destination]?.serviceAlerts.suspended?[alert]?.stations[1] ?? ""]?.short ?? "")**")
                                                    }
                                                    Spacer()
                                                }
                                            }
                                            .frame(width: geometry.size.width-24,height: 60)
                                        }
                                    }
                                    // MARK: - Skipped Stations
                                    ForEach(getSkippedStationKeys(alerts.new[destination]?.serviceAlerts.skippedStations ?? [String: SkippedStations]()), id: \.self) { alert in
                                        //                                Text("\(alerts.new[destination]?.serviceAlerts.skippedStations?[alert]?.occurances ?? 0), \(Int(alerts.new[destination]?.performance.trainsInService ?? 0))")
                                        //                                Text("\(alert)")
                                        if alerts.new[destination]?.serviceAlerts.skippedStations?[alert]?.occurances ?? 0 >= Int(alerts.new[destination]?.performance.trainsInService ?? 0) * 2/3 {
                                            ExpressPanel(alerts: alerts, destination: destination, alert: alert, few: false)
                                                .frame(width: geometry.size.width-24)
                                        }
                                    }
                                    // MARK: - Local Stations
                                    ForEach(getLocalStationKeys(alerts.new[destination]?.serviceAlerts.localStations ?? [String: LocalStations]()), id: \.self) { alert in
                                        
                                        if alerts.new[destination]?.serviceAlerts.localStations?[alert]?.occurances ?? 0 >= Int(alerts.new[destination]?.performance.trainsInService ?? 0) * 2/3 {
                                            LocalPanel(alerts: alerts, destination: destination, alert: alert, few: false)
                                                .frame(width: geometry.size.width-24)
                                        }                                        
                                    }
                                    
                                }
                                Spacer().frame(height: 50)
                            }
                        }
                    }
                }
                
            }
            VStack {
                ZStack {
                    VStack {
                        Rectangle()
                            .foregroundColor(bgColor.second.value)
                            .shadow(radius: 2)
                        Spacer()
                    }
                    // MARK: - Top part
                    VStack(spacing: 0) {
                        Spacer()
                        Capsule()
                            .fill(Color("second"))
                            .frame(width: 34, height: 4.5)
                            .padding(.top, -10)
                            .onAppear {
                                apiCall().getServiceDisruption(line: line) { (alert) in
                                    self.alerts = alert
                                    loading = false
                                }
                            }
                        
                        HStack {
                            Image(line)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .shadow(radius: 2)
                                .padding()
                            HStack {
                                Button {
                                    if direction == "north" {
                                        direction = "all"
                                    } else {
                                        direction = "north"
                                    }
                                } label: {
                                    ZStack {
                                        if direction == "north" {
                                            RoundedRectangle(cornerRadius: 10)
                                                .foregroundColor(bgColor.third.value)
                                                .frame(width: textSize.width + 25, height: 40)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 13)
                                                        .stroke(.blue,lineWidth: 2)
                                                        .frame(width: textSize.width + 33, height: 48)
                                                )
                                                .shadow(radius: 2)
                                        } else {
                                            RoundedRectangle(cornerRadius: 10)
                                                .foregroundColor(bgColor.third.value)
                                                .frame(width: textSize.width + 25, height: 40)
                                                .shadow(radius: 2)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(bgColor.second.value,lineWidth: 2)
                                                        .frame(width: textSize.width + 33, height: 48)
                                                )
                                            
                                        }
                                        Text("Northbound")
                                            .foregroundColor(Color("whiteblack"))
                                    }
                                }
                                .buttonStyle(CButton())
                                Spacer().frame(width: 15)
                                Button {
                                    if direction == "south" {
                                        direction = "all"
                                    } else {
                                        direction = "south"
                                    }
                                } label: {
                                    ZStack {
                                        if direction == "south" {
                                            RoundedRectangle(cornerRadius: 10)
                                                .foregroundColor(bgColor.third.value)
                                                .frame(width: textSize.width + 25, height: 40)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 13)
                                                        .stroke(.blue,lineWidth: 2)
                                                        .frame(width: textSize.width + 33, height: 48)
                                                )
                                                .shadow(radius: 2)
                                        } else {
                                            RoundedRectangle(cornerRadius: 10)
                                                .foregroundColor(bgColor.third.value)
                                                .frame(width: textSize.width + 25, height: 40)
                                                .shadow(radius: 2)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(bgColor.second.value,lineWidth: 2)
                                                        .frame(width: textSize.width + 33, height: 48)
                                                )
                                        }
                                        Text("Southbound")
                                            .foregroundColor(Color("whiteblack"))
                                    }
                                }
                                .buttonStyle(CButton())
                                Spacer()
                                Button {
                                    if isFavorited {
                                        withAnimation(.linear(duration: 0.1)) {
                                            isFavorited = false
                                        }
                                        deleteFavorite()
                                        //                                    delete
                                    } else {
                                        withAnimation(.linear(duration: 0.1)) {
                                            isFavorited = true
                                        }
                                        addFavorite()
                                        //                                    add new instance of favorites
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
                            Spacer()
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .frame(height: 120)
                Spacer()
            }
        }
    }
    }
}

struct LineView_Previews: PreviewProvider {
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistentContainer
        serviceAlertsViewNew(line: "4", direction: "north", isFavorited: false)
                .environment(\.managedObjectContext, persistedContainer.viewContext)
    }
}
