//
//  TreinoViewModel.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.
//

import Foundation

class TreinoViewModel: ObservableObject {
    @Published var treino: TreinoModel
    init(treino: TreinoModel = TreinoModel(name: "")) {
        self.treino = treino
    }
    
    
    
}
