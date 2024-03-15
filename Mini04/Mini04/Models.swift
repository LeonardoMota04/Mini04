//
//  Models.swift
//  Mini04
//
//  Created by Leonardo Mota on 15/03/24.
//

import Foundation
import SwiftUI

struct Apresentacoes {
    var pastas: [PastaModel]
}

struct PastaModel: Identifiable {
    var id: UUID = UUID()
    var nome: String
    var data: Date
    var tempoDesejado: Int
    var treinos: [TreinoModel]
    var objetivoApresentacao: String // ENUM????
    
    init(nome: String, data: Date, tempoDesejado: Int, objetivoApresentacao: String) {
        self.nome = nome
        self.data = data
        self.tempoDesejado = tempoDesejado
        self.objetivoApresentacao = objetivoApresentacao
        self.treinos = []
    }
}

struct TreinoModel: Identifiable {
    var id = UUID()
    // feedback
    var data: Date
    var nome: String
    //var video: VideoModel
    var pasta: PastaModel? //pasta pertencente
    
    init(data: Date, pasta: PastaModel) {
        // Nome dos treinos originais da pasta
        var nomes: String = ""
        for i in 0 ..< pasta.treinos.count {
            nomes = "Treino \(i+1)"
        }
        
        self.data = Date()
        self.nome = "\(pasta.nome) - \(nomes)"
        //self.video = video
        self.pasta = pasta
    }
    
    mutating func editarNome(novoNome: String) {
        self.nome = novoNome
    }
}


struct VideoModel: Identifiable, Hashable {
    var id = UUID()
    var videoURL: URL
    var script: String
    
    init(id: UUID = UUID(), videoURL: URL, script: String) {
        self.id = id
        self.videoURL = videoURL
        self.script = script
    }
}

