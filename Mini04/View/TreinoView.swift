//
//  TreinoView.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.
//

import SwiftUI

struct TreinoView: View {
    @ObservedObject var trainingVM: TreinoViewModel
    var folder: PastaModel
    
    var body: some View {
        VStack {
            Text("Pertenço à pasta: \(folder.nome)")
            Text("NOME: \(trainingVM.treino.nome)")
            Text("Data: \(trainingVM.treino.data)")
        }
    }
}

//#Preview {
//    TreinoView()
//}
