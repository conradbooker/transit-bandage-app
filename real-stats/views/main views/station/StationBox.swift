//
//  FavoriteBox.swift
//  real-stats
//
//  Created by Conrad on 3/13/23.
//

import SwiftUI
import WrappingStack

struct StationBox: View {
    var complex: Complex
    
    private func allLines() -> [String] {
        var lines = [String]()
        
        for station in complex.stations {
            for line in station.weekdayLines {
                lines.append(line)
            }
        }
        
        return lines
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: -10) {
            HStack {
                Text(complex.complexName)
                    .padding([.leading,.top], 5)
                    .lineSpacing(-10)
//                    .font(.callout)
                Spacer()
//                if complex.stations[0].ADA > 0 {
//                    Image("ADA")
//                        .resizable()
//                        .frame(width: 20, height: 20)
//                        .padding([.trailing,.top], 5)
//                }
            }
//            Text(complex.stations[0].short2)
//                .padding(.leading, 5)
//                .font(.caption)
            Spacer()
//                .frame(height: 20)
            WrappingHStack(id: \.self, alignment: .leading, horizontalSpacing: 2) {
                ForEach(allLines(), id: \.self) { line in
                    if line == "PATH" {
                        Image(line)
                            .resizable()
                            .frame(width: 28, height: 14)
    //                        .shadow(radius: 2)
                            .padding(.bottom, 2.0)
                    } else {
                        Image(line)
                            .resizable()
                            .frame(width: 14, height: 14)
    //                        .shadow(radius: 2)
                            .padding(.bottom, 2.0)
                    }
                }
            }
            .frame(width: 150)
            .padding([.leading,.top],5)
//            .padding(.bottom, 1.5)
            
            Spacer()
        }
        .padding(.leading, 5)
    }
}

struct StationBox_Previews: PreviewProvider {
    static var previews: some View {
        StationBox(complex: complexData[428])
            .previewLayout(.fixed(width: 152, height: 90))
    }
}
