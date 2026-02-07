//
//  WebKitView.swift
//  Transit Bandage
//
//  Created by Conrad on 4/8/24.
//

import SwiftUI

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    // 1
    let url: URL

    // 2
    func makeUIView(context: Context) -> WKWebView {

        return WKWebView()
    }
    
    // 3
    func updateUIView(_ webView: WKWebView, context: Context) {

        let request = URLRequest(url: url)
        webView.load(request)
    }
}
