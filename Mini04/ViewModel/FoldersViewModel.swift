//
//  FoldersViewModel.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.
//

import Foundation
import SwiftData
import AVFoundation
import SwiftUI

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
    func createNewTraining(videoURL: URL, videoScript: String, videoTime: TimeInterval, videoTopics: [String], topicsDuration: [TimeInterval]) {
        guard let modelContext = modelContext else { return }
        
        // cria novo treino
        let newTraining = TreinoModel(name: "\(folder.nome) - Treino \(folder.treinos.count + 1)",
                                      video: VideoModel(videoURL: videoURL,
                                                        script: videoScript,
                                                        videoTime: videoTime,
                                                        videoTopics: videoTopics,
                                                        topicsDuration: topicsDuration),
                                      feedback: processFeedbacks(videoScript: videoScript))
        
        // modelContext
        do {
            modelContext.insert(newTraining)
            try modelContext.save()
            folder.treinos.append(newTraining)
        } catch {
            print("Não conseguiu criar e salvar o treino. \(error)")
        }
    }
    
    // Função para processar os feedbacks usando o script de vídeo
        func processFeedbacks(videoScript: String) -> FeedbackModel {
            var normalizedText: [String: [String]] = [:]
            var repeatedWords: [String: Int] = [:]
            var repeatedWords_5: [String] = []
            var feedback = FeedbackModel(coherence: 0, palavrasRepetidas5vezes: [])
            
            // Conta as palavras e normaliza o texto
            let words = videoScript.components(separatedBy: .whitespacesAndNewlines)
            for word in words {
                if !word.isEmpty {
                    let normalizedWord = word.lowercased().folding(options: .diacriticInsensitive, locale: .current)
                    if normalizedText[normalizedWord] == nil {
                        normalizedText[normalizedWord] = [word]
                    } else {
                        normalizedText[normalizedWord]?.append(word)
                    }
                }
            }

            // Conta as palavras repetidas
            for (_, words) in normalizedText {
                guard let firstWord = words.first else { continue }
                repeatedWords[firstWord, default: 0] += words.count
            }

            // Filtra as palavras repetidas mais de 5 vezes
            repeatedWords_5 = repeatedWords.filter { $0.value >= 5 }.map { $0.key }

            // Processa os feedbacks para cada palavra repetida mais de 5 vezes
            var repeatedWordFeedbacks: [SynonymsInfo] = []
            let group = DispatchGroup()
            for word in repeatedWords_5 {
                group.enter()
                fetchSynonyms(for: word) { synonymsModel in
                    if let synonymsModel = synonymsModel {
                        let feedback = SynonymsInfo(word: word,
                                                    numSynonyms: synonymsModel.numSynonyms,
                                                    numContexts: synonymsModel.numContexts,
                                                    synonymContexts: synonymsModel.synonymContexts)
                        repeatedWordFeedbacks.append(feedback)
                    }
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                // Cria o modelo de feedback com os resultados
                feedback = FeedbackModel(coherence: 0, palavrasRepetidas5vezes: repeatedWordFeedbacks)
            }
            return feedback
        }
    
    // MARK: - FEEDBACKS
    func filterRepeatedWordsOverFiveTimes(videoScript: String) -> [String] {
        var normalizedText: [String: [String]] = [:]
        var repeatedWords: [String: Int] = [:]
        
        // Conta as palavras e normaliza o texto
        let words = videoScript.components(separatedBy: .whitespacesAndNewlines)
        for word in words {
            if !word.isEmpty {
                let normalizedWord = word.lowercased().folding(options: .diacriticInsensitive, locale: .current)
                if normalizedText[normalizedWord] == nil {
                    normalizedText[normalizedWord] = [word]
                } else {
                    normalizedText[normalizedWord]?.append(word)
                }
            }
        }

        // Conta as palavras repetidas
        for (_, words) in normalizedText {
            guard let firstWord = words.first else { continue }
            repeatedWords[firstWord, default: 0] += words.count
        }

        // Filtra as palavras repetidas mais de 5 vezes
        let repeatedWords_5 = repeatedWords.filter { $0.value >= 5 }.map { $0.key }

        return repeatedWords_5
    }

    // Função para processar os feedbacks usando o script de vídeo
    func processFeedbacks(repeatedWords: [String]) -> FeedbackModel {
        var repeatedWordFeedbacks: [SynonymsInfo] = []

        for word in repeatedWords {
            //group.enter()
            fetchSynonyms(for: word) { synonymsModel in
                if let synonymsModel = synonymsModel {
                    let feedback = SynonymsInfo(word: word,
                                                numSynonyms: synonymsModel.numSynonyms,
                                                numContexts: synonymsModel.numContexts,
                                                synonymContexts: synonymsModel.synonymContexts)
                    repeatedWordFeedbacks.append(feedback)
                }
                //group.leave()
            }
        }
        //group.notify(queue: .main) {
        let feedback = FeedbackModel(coherence: 0, palavrasRepetidas5vezes: repeatedWordFeedbacks)
        // }
        return feedback
    }
    
    // Função para buscar os sinônimos de uma palavra
    func fetchSynonyms(for word: String, completion: @escaping (SynonymsInfo?) -> Void) {
        // CHAMADA DE REDE
        NetworkManager.fetchData(for: word) { result in
            switch result {
            case .success(let data):
                // PARSE HTML
                HTMLParser.parseHTML(data: data, word: word.lowercased()) { result in
                    switch result {
                    case .success(let synonymsInfo):
                        let synonymsModel = SynonymsInfo(word: synonymsInfo.word,
                                                         numSynonyms: synonymsInfo.numSynonyms,
                                                         numContexts: synonymsInfo.numContexts,
                                                         synonymContexts: synonymsInfo.synonymContexts)
                        completion(synonymsModel)
                    case .failure:
                        completion(nil)
                    }
                }
            case .failure:
                completion(nil)
            }
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
