//
//  WhatsNew.swift
//  Service Bandage
//
//  Created by Conrad on 8/27/23.
//

import SwiftUI

struct WhatsNew: View {
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            Text(String(format: NSLocalizedString("whats-new", comment: ""), appVersion ?? ""))
                .font(.title)
                .fontWeight(.bold)
                .padding()
            VStack(alignment: .leading,spacing: 10) {
//                HStack(spacing: 0) {
//                    Spacer()
//                    LineBox(line: "A", first: ["good_service"])
//                    LineBox(line: "1", first: ["no_service"])
//                    LineBox(line: "7", first: ["d"])
//                    LineBox(line: "4", first: ["q","2"])
//                    LineBox(line: "N", first: ["a","a","a","a","a","a","a","a","a","a","a","a","a","a","a","a","a"])
//                    LineBox(line: "B", first: ["good_service"])
//                    Spacer()
//                }
//                .padding()
                VStack(alignment: .center, spacing: 10) {
                    Text("Not much, just bug fixes :)")
                }
                .padding(.leading)
            }
            Spacer()
            Button {
                dismiss()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: UIScreen.screenWidth-50,height: 70)
                    Text("Continue")
                        .foregroundColor(.white)
                        .font(.title3)
                }
            }
            .padding()
//                .
        }
        .padding()
        .frame(width: UIScreen.screenWidth)
        .interactiveDismissDisabled()
    }
}

struct WhatsNew_Previews: PreviewProvider {
    static var previews: some View {
        WhatsNew()
    }
}
