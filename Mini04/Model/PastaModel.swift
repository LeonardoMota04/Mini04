//
//  PastaModel.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.
//

import Foundation

struct PastaModel: Identifiable {
    var id: UUID = UUID()
    var nome: String = ""
    var data: Date = Date()
    var tempoDesejado: Int = 0
    var objetivoApresentacao: String = "" // ENUM????
    var treinos: [TreinoModel] = []
    
    init(nome: String, tempoDesejado: Int, objetivoApresentacao: String) {
        self.nome = nome
        self.tempoDesejado = tempoDesejado
        self.objetivoApresentacao = objetivoApresentacao
        self.treinos = []
    }
}
