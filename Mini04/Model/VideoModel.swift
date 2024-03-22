//
//  VideoModel.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.
//

import Foundation
import SwiftData
import AVFoundation

@Model
class VideoModel: Identifiable {
    var id = UUID()
    var videoURL: URL
    var script: String
    var topics: [String]
    var time: TimeInterval
    var topicDurationTime: [TimeInterval]
    
    init(id: UUID = UUID(), videoURL: URL, script: String, topics: [String], time: TimeInterval, topicDuration: [TimeInterval]) {
        self.id = id
        self.videoURL = videoURL
        self.script = script
        self.topics = topics
        self.time = time
        self.topicDurationTime = topicDuration
    }
}
