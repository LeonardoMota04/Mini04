//
//  FoldersViewModel.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.
//

import Foundation
import AVFoundation

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
    func createNewTraining(videoURL: URL, videoScript: String, videoTopics: [String], videoTime: TimeInterval, topicDurationTime: [TimeInterval]) {
        let newTraining = TreinoModel(name: "\(folder.nome) - Treino \(folder.treinos.count + 1)", video: VideoModel(videoURL: videoURL, script: videoScript, topics: videoTopics, time: videoTime, topicDuration: topicDurationTime))
        folder.treinos.append(newTraining)
    }
    


 

    
}
