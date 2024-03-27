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
}

@Model
class FeedbackModel {
    var coerencia: Int
    var RepeatedWords: [SynonymsModel] = [] // palavras repetidas com seus sinonimos

    init(coherence: Int, palavrasRepetidas5vezes: [SynonymsModel]) {
        self.coerencia = coherence
        self.RepeatedWords = palavrasRepetidas5vezes
    }
}

@Model
class SynonymsModel {
    let word: String // palavra repetida
    let numSynonyms: Int
    let numContexts: Int
    var synonymContexts: [String]

    init(word: String, numSynonyms: Int, numContexts: Int, synonymContexts: [String] = []) {
        self.word = word
        self.numSynonyms = numSynonyms
        self.numContexts = numContexts
        self.synonymContexts = synonymContexts
    }
}

//@Model
//class SynonymContext {
//    let synonymsWithContext: [String]
//
//    init(synonymsWithContext: [String]) {
//        self.synonymsWithContext = synonymsWithContext
//    }
//}

//@Model
//class SynonymsModel {
//    let word: String // palavra repetida
//    let numSynonyms: Int
//    let numContexts: Int
//    var synonymContexts: [(context: String, synonyms: [String])] // Array de tuplas
//
//    init(word: String, numSynonyms: Int, numContexts: Int, synonymContexts: [(context: String, synonyms: [String])] = []) {
//        self.word = word
//        self.numSynonyms = numSynonyms
//        self.numContexts = numContexts
//        self.synonymContexts = synonymContexts
//    }
//}
