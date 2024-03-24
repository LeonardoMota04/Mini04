//
//  TreinoModel.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.
//

import Foundation
import SwiftData

@Model
class TreinoModel: Identifiable {
    @Attribute(.unique) var id = UUID()
    var data: Date = Date()
    var nome: String
    var changedTrainingName: Bool = false
    /// feedback
    var video: VideoModel?

    init(name: String = "", changedTrainingName: Bool = false, video: VideoModel? = nil){
        //self.nome = "\(pasta.nome) - \(pasta.treinos.count + 1)"
        self.nome = name
        self.changedTrainingName = changedTrainingName
        self.video = video
    }
}
