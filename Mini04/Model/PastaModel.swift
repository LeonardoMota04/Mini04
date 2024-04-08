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
    var nome: String = ""
    var data: Date = Date()
    var tempoDesejado: Int = 0
    var objetivoApresentacao: String = "" // ENUM????
    var treinos: [TreinoModel] = []
    var avaregeTime: Double = 0
    
    init(nome: String, tempoDesejado: Int, objetivoApresentacao: String) {
        self.nome = nome
        self.tempoDesejado = tempoDesejado
        self.objetivoApresentacao = objetivoApresentacao
    }
    
    // Formata tempo desejado para: "00:00"
    func formattedGoalTime(_ time: Int) -> String {
            let minutes = time
            let formattedMinutes = String(format: "%02d", minutes)
            return "\(formattedMinutes):00"
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
