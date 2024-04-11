//
//  PastaModel.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.
//

import Foundation
import SwiftData

@Model
class PastaModel: Identifiable {
    var id: UUID = UUID()
    var creationDate: Date = Date()
    var treinos: [TreinoModel] = []
    var avaregeTime: Double = 0
    
    // INFOS NA HORA DE CRIAR A PASTA
    var nome: String
    var dateOfPresentation: Date
    var tempoDesejado: Int
    var objetivoApresentacao: String
    
    init(nome: String, dateOfPresentation: Date, tempoDesejado: Int, objetivoApresentacao: String) {
        self.nome = nome
        self.dateOfPresentation = dateOfPresentation
        self.tempoDesejado = tempoDesejado
        self.objetivoApresentacao = objetivoApresentacao
    }
    
    // Método para formatar o tempo desejado em minutos e segundos (mm:ss)
    func formattedGoalTime() -> String {
        let minutes = tempoDesejado / 60
        let seconds = tempoDesejado % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}


// objetivo da apresentação
enum ObjectiveApresentation: String, Identifiable, CaseIterable {
    var id: Self { self }
    case pitch
    case seles
    case event
    case project
    case informative
}
