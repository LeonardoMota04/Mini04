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
import Combine

@Observable
class FoldersViewModel: ObservableObject {
    // MARK: - Modelo
    var folder: PastaModel
    var modelContext: ModelContext?
    private var cancellables = Set<AnyCancellable>()
    
    // variaveis utilizaveis para salvar os dados
    var objetiveApresentation: String = ""
    var avaregeTime: TimeInterval = 0
    var formatedAvareTime: String = ""
    
    init(folder: PastaModel, modelContext: ModelContext? = nil) {
        self.folder = folder
        self.modelContext = modelContext
        fetchTrainings()
    }
    
    // MARK: - CRUD
    // CREATE
    func createNewTraining(videoURL: URL, videoScript: String, videoTime: TimeInterval, videoTopics: [String], topicsDuration: [TimeInterval]) {
        guard let modelContext = modelContext else { return }
        
        DispatchQueue.main.async {
            self.processFeedbacks(videoScript: videoScript) { [self] feedback in
                let newTraining = TreinoModel(name: "\(folder.nome) - Treino \(folder.treinos.count + 1)",
                                              video: VideoModel(videoURL: videoURL,
                                                                script: videoScript,
                                                                videoTime: videoTime,
                                                                videoTopics: videoTopics,
                                                                topicsDuration: topicsDuration),
                                              feedback: feedback)
                
                do {
                    folder.treinos.append(newTraining)
                    modelContext.insert(newTraining)
                    try modelContext.save()
                } catch {
                    print("Não conseguiu criar e salvar o treino. \(error)")
                }
            }
        }
    }
    
    // MARK: - FEEDBACKS
    func processFeedbacks(videoScript: String, completion: @escaping (FeedbackModel) -> Void) {
        let repeatedWords = filterRepeatedWordsOverFiveTimes(videoScript: videoScript)
        
        var repeatedWordFeedbacks: [SynonymsModel] = []
        let group = DispatchGroup()
        
        for word in repeatedWords {
            group.enter()
            
            fetchSynonyms(for: word)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in }) { synonymsModel in
                    if let synonymsModel = synonymsModel {
                        repeatedWordFeedbacks.append(synonymsModel)
                    }
                    group.leave()
                }
                .store(in: &cancellables)
        }
        
        group.notify(queue: .main) {
            let feedback = FeedbackModel(coherence: 0, palavrasRepetidas5vezes: repeatedWordFeedbacks)
            completion(feedback)
        }
    }
    
    // Função para buscar os sinônimos de uma palavra
    func fetchSynonyms(for word: String) -> AnyPublisher<SynonymsModel?, Never> {
        return Future<SynonymsModel?, Never> { promise in
            NetworkManager.fetchData(for: word) { result in
                switch result {
                case .success(let data):
                    HTMLParser.parseHTML(data: data, word: word.lowercased()) { result in
                        switch result {
                        case .success(let synonymsInfo):
                            promise(.success(synonymsInfo))
                        case .failure:
                            promise(.success(nil))
                        }
                    }
                case .failure:
                    promise(.success(nil))
                }
            }
        }
        .eraseToAnyPublisher()
    }


    // filtra palavras e separa as repetidas 5 vezes
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
            do {
                folder.treinos.remove(at: index)
                modelContext.delete(training)
                try modelContext.save()
            } catch {
                print("Falha ao salvar após a exclusão do treino. \(error)")
            }
        }
    }
    
    // coloca o objetivo da pessoa (pitch, vendas, etc)
    func folderObjectiveSet(objetive: String) {
        self.objetiveApresentation = objetive
    }
    
    func calculateAvarageTime() {
        guard let modelContext = modelContext else { return }
        var totalTime: TimeInterval = 0
        // interando todos os treinos para conseguir o valor total do tempo gasto
        for treino in folder.treinos {
            totalTime += treino.video?.videoTime ?? 0
        }
    // calculando a media - media = total / quantidade
        self.avaregeTime = totalTime / Double(folder.treinos.count)
        // Atribuindo o valor a persistencia e salvando em seguida
        self.folder.avaregeTime = avaregeTime
        do {
            try modelContext.save()
        } catch {
            print("error ao salvar o tempo medio do folderVM")
        }
        // formatando o valor em uma string para ficar mais facil de colocar no UI - verificando se não é nulo pois cria a pasta com ele null
        if folder.avaregeTime != 0 {
            self.formatedAvareTime = formatVideoDuration(time: self.folder.avaregeTime)
        }
    }
    
    // Formata uma string com segundo minutos e horas
    func formatVideoDuration(time: TimeInterval) -> String {
            
            let totalSeconds = time
        guard !(totalSeconds.isNaN || totalSeconds.isInfinite) else {
            return "00:00" // or do some error handling - cai aqui primeira vez que a pasta é criada
        }
            let hours = Int(totalSeconds / 3600)
            let minutes = Int((totalSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
            let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
            
            if hours > 0 {
                return String(format: "%i:%02i:%02i", hours, minutes, seconds)
            } else {
                return String(format: "%02i:%02i", minutes, seconds)
            }
        }

    
    func calculateTreinoTime(videoTime: Double) -> CGFloat {
      return CGFloat(videoTime) / CGFloat(folder.tempoDesejado) * 54
    }

}
