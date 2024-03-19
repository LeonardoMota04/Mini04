//
//  ApresentacaoViewModel.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.
//

import Foundation

// VIEW MODEL
class ApresentacaoViewModel: ObservableObject {
    @Published var apresentacao: ApresentacaoModel
    init(apresentacao: ApresentacaoModel) {
        self.apresentacao = apresentacao
    }
}
