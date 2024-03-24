//
//  FoldersViewModel.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.
//

import Foundation
import SwiftData
import AVFoundation

@Observable
class FoldersViewModel: ObservableObject {
    // MARK: - Modelo
    var folder: PastaModel
    var modelContext: ModelContext?

    // MARK: - ViewModel
    //var trainingVM: TreinoViewModel
    
    init(folder: PastaModel, modelContext: ModelContext? = nil) {
        self.folder = folder
        self.modelContext = modelContext
        fetchTrainings()
    }
        
    // MARK: - CRUD
    // CREATE
    func createNewTraining(videoURL: URL, videoScript: String, videoTopics: [String], videoTime: TimeInterval, topicDurationTime: [TimeInterval]) {
        guard let modelContext = modelContext else { return }
        
        // cria novo treino
        let newTraining = TreinoModel(name: "\(folder.nome) - Treino \(folder.treinos.count + 1)", video: VideoModel(videoURL: videoURL, script: videoScript, topics: videoTopics, time: videoTime, topicDuration: topicDurationTime))
        
        // modelContext
        do {
            modelContext.insert(newTraining)
            try modelContext.save()
            folder.treinos.append(newTraining)
//            print(newTraining.video?.videoURL.description)
        } catch {
            print("Não conseguiu criar e salvar o treino. \(error)")
        }
    }
    // READ
       func fetchTrainings() {
           guard let modelContext = modelContext else { return }
           do {
               let fetchDescriptor = FetchDescriptor<TreinoModel>(
                   sortBy: [SortDescriptor(\TreinoModel.nome)]
               )
               folder.treinos = try modelContext.fetch(fetchDescriptor)
               
               // imprimir resultados recuperados
               print("Treinos recuperados:")
               for training in folder.treinos {
                   print("- Nome: \(training.nome)")
                   print("- Data: \(training.data)")
                   print("- Video: \(String(describing: training.video?.videoURL)) ?? nao tem vídeo nesse treino")
                   print("\n\n\n\n")
               }
           } catch {
               print("Fetch failed: \(error)")
           }
       }

    // DELETE
    func deleteTraining(_ training: TreinoModel) {
        guard let modelContext = modelContext else { return }

        if let index = folder.treinos.firstIndex(of: training) {
            folder.treinos.remove(at: index)
            modelContext.delete(training)
            
            do {
                try modelContext.save()
            } catch {
                print("Falha ao salvar após a exclusão do treino. \(error)")
            }
        }
    }
}
