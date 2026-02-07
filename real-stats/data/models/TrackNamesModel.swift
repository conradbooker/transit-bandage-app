//
//  TrackNamesModel.swift
//  Transit Bandage
//
//  Created by Conrad on 3/10/24.
//

import Foundation
import SwiftUI

struct TrackNamesModel: Hashable, Codable, Identifiable {
    var id: UUID {
        return UUID()
    }
    var system: String
    var track_1: String
    var track_2: String
    var track_3: String
    var track_4: String
    var tracks: [String] {
        return [track_1, track_2, track_3, track_4]
    }
    var showTrackLabel: Bool {
        if tracks == ["","","",""] {
            return false
        }
        return true
    }
}

