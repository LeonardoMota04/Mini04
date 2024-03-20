//
//  FoldersViewModel.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.
//

import Foundation

class FoldersViewModel: ObservableObject {
    // MARK: - Modelo
    @Published var folder: PastaModel
    
    // MARK: - ViewModel
    @Published var trainingVM: TreinoViewModel
    
    init(folder: PastaModel) {
        self.folder = folder
        self.trainingVM = TreinoViewModel()
    }
    
    // MARK: - Métodos
    // Criar treino
    func createNewTraining(videoURL: URL) {
        let newTraining = TreinoModel(name: "\(folder.nome) - Treino \(folder.treinos.count + 1)", video: VideoModel(videoURL: videoURL))
        folder.treinos.append(newTraining)
    }
    
}
