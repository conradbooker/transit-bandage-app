//
//  sortedBusStop.swift
//  Service Bandage
//
//  Created by Conrad on 1/18/24.
//

import SwiftUI

struct sortedBusStop: View {
    var lines: [String]
    var times: [String: Bus_Times]
    var stop_ids: [String]
    
    var consolidatedStop: Bool {
        if stop_ids.count == 2 {
            return (busData_dictionary[stop_ids[0]]?.name ?? "" ==
                    busData_dictionary[stop_ids[1]]?.name ?? "")
        }
        return false
    }
    
    @Environment(\.colorScheme) var colorScheme
    
    func line_cleaned(_ line: String) -> String {
        if line.contains("_ltd") {
            var newLine = line
            newLine.removeLast(4)
            return newLine
        }
        return line
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(lines, id: \.self) { line in
                    Text(line_cleaned(line))
                        .font(.title)
                        .padding(2)
                        .padding(.horizontal,2)
                        .foregroundColor(getCorrectColor(route: line)[0])
                        .background(
                            getCorrectColor(route: line)[1]
                                .cornerRadius(4)
                                .shadow(radius: 2)
                            
                        )
                        .padding([.leading, .top],6)
                }
                Spacer()
            }
            Spacer().frame(height: 9)
            if stop_ids.count == 2 {
                Spacer().frame(height: 6)
                if consolidatedStop {
                    sortedBusStop_times(lines: lines, times: times, stop_ids: stop_ids)
                        .padding(.vertical, 3)
                        .padding(.bottom, -40)
                } else {
                    ForEach(stop_ids, id: \.self) { stop_id in
                        sortedBusStop_times(lines: lines, times: times, stop_ids: [stop_id])
                            .padding(.vertical, 3)
                    }
                }
            } else {
                ForEach(stop_ids, id: \.self) { stop_id in
                    sortedBusStop_times(lines: lines, times: times, stop_ids: [stop_id])
                        .padding(.vertical, 3)
                }
            }
//            Spacer()
        }
    }
}

struct sortedBusStop_previews: PreviewProvider {
    static var previews: some View {
        
        sortedBusStop(lines: ["M101", "M102"], times: defaultBusTimes_dict, stop_ids: ["401906"])
            .previewLayout(.fixed(width: 375, height: 200))
    }
}
