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
    @EnvironmentObject var cameraVC: CameraViewModel
    @State var videoTime: String = ""
    var body: some View {
        VStack {
            VideoPlayer(player: cameraVC.videoPlayer)
            Text("Pertenço à pasta: \(trainingVM.treino.nome)")
            Text("NOME: \(trainingVM.treino.nome)")
            Text("Data: \(trainingVM.treino.data)")
            Text(String("TempoVideo: \(trainingVM.treino.video?.videoTime)"))
            Text("SCRIPT: \(trainingVM.treino.video?.script ?? "nao achou o script")")
            Text(String("TOPICS: \(trainingVM.treino.video?.videoTopics)"))
            ForEach((trainingVM.treino.video?.topicsDuration.indices)!, id: \.self) { index in
                Text(String((trainingVM.treino.video?.topicsDuration[index])!))
            }
        }
    }
}
// AVPlayer(url: trainingVM.treino.video!.videoURL)
//#Preview {
//    TreinoView()
//}
