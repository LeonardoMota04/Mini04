//
//  TreinoModel.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.

import Foundation
import SwiftData

@Model
class TreinoModel: Identifiable {
    
    var id = UUID()
    var isFavorite: Bool = false
    var feedback: FeedbackModel?
    var data: Date = Date()
    var nome: String = ""
    var changedTrainingName: Bool = false
    var video: VideoModel?

    init(name: String = "", changedTrainingName: Bool = false, video: VideoModel? = nil, feedback: FeedbackModel? = nil) {
        self.nome = name
        self.changedTrainingName = changedTrainingName
        self.video = video
        self.feedback = feedback
    }
    
    // Formata data de criação para: "12 de out. de 2023"
    func formattedCreationDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d 'de' MMM. 'de' yyyy"
        let formattedDate = dateFormatter.string(from: data)
        return formattedDate
    }
    
    // Filtros para treinos
    enum TrainingFilter: String, CaseIterable {
        case newerToOlder = "Mais recente para mais antigo"
        case olderToNewer = "Mais antigo para mais recente"
        case fasterToLonger = "Mais rápido para mais longo"
        case longerToFaster = "Mais longo para mais rápido"
        case favorites = "Favoritos"
    }
}

@Model
class FeedbackModel {
    var coerencia: Int
    var repeatedWords: [RepeatedWordsModel] = [] // palavras repetidas com seus sinonimos
    var coherenceValues: [CGFloat] = [] // porcentagens da coesao

    init(coherence: Int, repeatedWords: [RepeatedWordsModel], coherenceValues: [CGFloat]) {
        self.coerencia = coherence
        self.repeatedWords = repeatedWords
        self.coherenceValues = coherenceValues
    }
}

@Model
class RepeatedWordsModel {
    let word: String // palavra repetida
    let repetitionCount: Int // conta quantas vezes aquela palavra foi repetida
    let numSynonyms: Int
    let numContexts: Int
    var synonymContexts: [[String]] // Array de arrays de String

    init(word: String, repetitionCount: Int = 0, numSynonyms: Int, numContexts: Int, synonymContexts: [[String]] = []) {
        self.word = word
        self.repetitionCount = repetitionCount
        self.numSynonyms = numSynonyms
        self.numContexts = numContexts
        self.synonymContexts = synonymContexts
    }
}
