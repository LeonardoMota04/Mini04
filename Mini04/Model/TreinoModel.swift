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
    var data: Date = Date()
    var nome: String = ""
    var changedTrainingName: Bool = false
    var feedback: FeedbackModel?
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
    var palavrasRepetidas5vezes: [SynonymsInfo] = []

    init(coherence: Int, palavrasRepetidas5vezes: [SynonymsInfo] = []) {
        self.coerencia = coherence
        self.palavrasRepetidas5vezes = palavrasRepetidas5vezes
    }
}

@Model
class SynonymsInfo {
    let word: String // palavra repetida
    let numSynonyms: Int
    let numContexts: Int
    var synonymContexts: [SynonymContext]

    init(word: String, numSynonyms: Int, numContexts: Int, synonymContexts: [SynonymContext]) {
        self.word = word
        self.numSynonyms = numSynonyms
        self.numContexts = numContexts
        self.synonymContexts = synonymContexts
    }
}

@Model
class SynonymContext {
    let context: String
    let synonyms: [String]

    init(context: String, synonyms: [String]) {
        self.context = context
        self.synonyms = synonyms
    }
}

