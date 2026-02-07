//
//  closeSheet.swift
//  Transit Bandage
//
//  Created by Conrad on 3/21/24.
//

import SwiftUI

struct CloseSheet: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                if UIScreen.screenHeight <= 736 {
                    Button {
                        dismiss()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(bgColor.fifth.value)
                                .shadow(radius: 2)
                            Image(systemName: "xmark")
                                .font(.title)
                            
                        }
                        .frame(width: 50, height: 50)
                    }
                    .buttonStyle(CButton())
                    .padding(.trailing, 15)
                } else {
                    Button {
                        dismiss()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(bgColor.fifth.value)
                                .shadow(radius: 2)
                            Image(systemName: "xmark")
                                .font(.title)
                            
                        }
                        .frame(width: 50, height: 50)
                    }
                    .buttonStyle(CButton())
                    .padding(.trailing, 30)
                }
            }
            if UIScreen.screenHeight <= 736 {
                Spacer().frame(height: 15)
            }
        }
    }
}

struct OpenInSafari: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Link(destination: URL(string: "https://ko-fi.com/conradbooker")!) {
                    if UIScreen.screenHeight <= 736 {
                        ZStack {
                            Circle()
                                .fill(bgColor.fifth.value)
                                .shadow(radius: 2)
                            Image(systemName: "safari")
                                .font(.title)
                            
                        }
                        .frame(width: 50, height: 50)
                        .buttonStyle(CButton())
                        .padding(.leading, 15)
                    } else {
                        ZStack {
                            Circle()
                                .fill(bgColor.fifth.value)
                                .shadow(radius: 2)
                            Image(systemName: "safari")
                                .font(.title)
                            
                        }
                        .frame(width: 50, height: 50)
                        .buttonStyle(CButton())
                        .padding(.leading, 30)
                    }
                }
                Spacer()
            }
            if UIScreen.screenHeight <= 736 {
                Spacer().frame(height: 15)
            }
        }
    }
}

#Preview {
    CloseSheet()
}
