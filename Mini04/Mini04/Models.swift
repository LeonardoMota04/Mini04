//
//  FolderModel.swift
//  Mini04
//
//  Created by Leonardo Mota on 17/03/24.
//

import Foundation
// MARK: - APRESENTACOES
    // MODEL
    struct ApresentacaoModel {
        var folders: [PastaModel] = []
    }
    // VIEW MODEL
    class ApresentacaoViewModel: ObservableObject {
        @Published var apresentacao: ApresentacaoModel
        
        init(apresentacao: ApresentacaoModel) {
            self.apresentacao = apresentacao
        }
    }

// MARK: - PASTAS
    // MODEL
    struct PastaModel: Identifiable {
        var id: UUID = UUID()
        var nome: String = ""
        var data: Date = Date()
        var tempoDesejado: Int = 0
        var objetivoApresentacao: String = "" // ENUM????
        var treinos: [TreinoModel] = []
        
        init(nome: String, tempoDesejado: Int, objetivoApresentacao: String) {
            self.nome = nome
            self.tempoDesejado = tempoDesejado
            self.objetivoApresentacao = objetivoApresentacao
            self.treinos = []
        }
    }

    // VIEW MODEL
    class FoldersViewModel: ObservableObject {
        @Published var folder: PastaModel
        
        init(folder: PastaModel) {
            self.folder = folder
        }
    }

// MARK: - TREINOS
    // MODEL
    struct TreinoModel: Identifiable {
        var id = UUID()
        var data: Date = Date()
        var nome: String
        /// feedback
        /// var video: VideoModel

        init(name: String){//, pasta: PastaModel) {
            //self.nome = "\(pasta.nome) - \(pasta.treinos.count + 1)"
            self.nome = "\(name) - treino"
            //self.pasta = pasta
            ///self.video = video
        }
    }

    // VIEWMODEL
    class TreinoViewModel: ObservableObject {
        @Published var treino: TreinoModel
        init(treino: TreinoModel) {
            self.treino = treino
        }
    }

// MARK: - VIDEOS
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
