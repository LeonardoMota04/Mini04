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
    var videoTime: TimeInterval
    var videoTopics: [String]
    var topicsDuration: [TimeInterval]
    
    init(id: UUID = UUID(), videoURL: URL, script: String, videoTime: TimeInterval, videoTopics: [String], topicsDuration: [TimeInterval]) {
        self.id = id
        self.videoURL = videoURL
        self.script = script
        self.videoTime = videoTime
        self.videoTopics = videoTopics
        self.topicsDuration = topicsDuration
    }
    
    // Formata duração do treino para: "10:55"
    func formattedTime() -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        
        if let formattedString = formatter.string(from: videoTime) {
            return formattedString
        } else {
            return "00:00"
        }
    }
}
