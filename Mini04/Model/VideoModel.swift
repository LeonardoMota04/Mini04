//
//  VideoModel.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.
//

import Foundation
import AVFoundation

struct VideoModel: Identifiable, Hashable {
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
