//
//  TreinoModel.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.
//

import Foundation

struct TreinoModel: Identifiable {
    var id = UUID()
    var data: Date = Date()
    var nome: String
    /// feedback
    var video: VideoModel?

    init(name: String, video: VideoModel? = nil){
        //self.nome = "\(pasta.nome) - \(pasta.treinos.count + 1)"
        self.nome = name
        //self.pasta = pasta
        self.video = video
    }
}
