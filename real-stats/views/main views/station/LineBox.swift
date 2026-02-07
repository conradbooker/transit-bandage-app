//
//  LineBox.swift
//  Transit Bandage
//
//  Created by Conrad on 6/18/24.
//

import SwiftUI

struct LineBox: View {
    var line: String
    var first: [String]
    
    @State var selectedDisruption: DisruptionItem?
    
    @State private var fromFavorites = false
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(entity: FavoriteLine.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var favoriteLines: FetchedResults<FavoriteLine>
    
    let persistentContainer = CoreDataManager.shared.persistentContainer

    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ZStack {
                    Button {
                        selectedDisruption = DisruptionItem(line: line, direction: "all")
                        for favoriteLine in favoriteLines {
                            if favoriteLine.line == line {
                                fromFavorites = true
                                break
                            }
                            fromFavorites = false
                        }
                    } label: {
                        HStack {
                            Image(line)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                            Spacer()
                        }
                    }
                    .buttonStyle(CButton())
                    VStack {
                        Spacer()
                        ZStack {
                            if first.count < 2 {
                                RoundedRectangle(cornerRadius: 6)
                                    .frame(height: 20)
                                    .frame(width: 20)
                                    .foregroundColor(bgColor.fifth.value)
                                    .shadow(radius: 2)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(bgColor.first.value, lineWidth: 2)
                                    )
                            } else {
                                RoundedRectangle(cornerRadius: 6)
                                    .frame(height: 20)
                                    .frame(width: 40)
                                    .foregroundColor(bgColor.fifth.value)
                                    .shadow(radius: 2)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(bgColor.first.value, lineWidth: 2)
                                    )
                            }
                            HStack(spacing: 2) {
                                if first.first ?? "" == "good_service" {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.footnote)
                                        .foregroundColor(.green)
                                } else if first.first ?? "" == "no_service" {
                                    Image(systemName: "xmark.octagon.fill")
                                        .font(.footnote)
                                        .foregroundColor(.red)
                                } else {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.footnote)
                                        .foregroundStyle(.black,.yellow)
                                }
                                if first.count >= 2 {
                                    Text("\(first.count)+")
                                        .font(.footnote)
                                }
                            }
                        }
                        
                    }
                    .padding(.top, 10)
                    .padding(.bottom, -10)
                    .padding(.leading, 20)

                }
            }
            Spacer()
        }
        .frame(width: 60,height: 55)
        .sheet(item: $selectedDisruption) { disruption in
            ZStack {
                if fromFavorites {
                    serviceAlertsViewNew(line: disruption.line, direction: disruption.direction, isFavorited: true)
                        .environment(\.managedObjectContext, persistentContainer.viewContext)
                } else {
                    serviceAlertsViewNew(line: disruption.line, direction: disruption.direction, isFavorited: false)
                        .environment(\.managedObjectContext, persistentContainer.viewContext)
                }
                CloseSheet()
            }
            .syncLayoutOnDissappear()
        }
    }
}

struct LineBox_Previews: PreviewProvider {
    static var previews: some View {
        LineBox(line: "A",
                first: ["suspended","delays","behind_schedule","skipped","express", "local"])
        .previewLayout(.sizeThatFits)
    }
}
