//
//  VideoModel.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.
//

import Foundation
import SwiftData

@Model
class VideoModel: Identifiable, Hashable {
    var id = UUID()
    var videoURL: URL
//    var script: String
    
    init(id: UUID = UUID(), videoURL: URL/*, script: String*/) {
        self.id = id
        self.videoURL = videoURL
//        self.script = script
    }
}
