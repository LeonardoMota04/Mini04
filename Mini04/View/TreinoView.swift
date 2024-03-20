//
//  TreinoView.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.
//

import SwiftUI
import AVKit

struct TreinoView: View {
    @ObservedObject var trainingVM: TreinoViewModel
    
    var body: some View {
        VStack {
            VideoPlayer(player: AVPlayer(url: trainingVM.treino.video!.videoURL))
            Text("Pertenço à pasta: \(trainingVM.treino.nome)")
            Text("NOME: \(trainingVM.treino.nome)")
            Text("Data: \(trainingVM.treino.data)")
        }
    }
}

//#Preview {
//    TreinoView()
//}
