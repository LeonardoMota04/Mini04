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
            Text("Tempo do vídeo: )")
            ScrollView {
                VStack {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(0..<cameraVC.topicTime.count, id: \.self) { index in
                                VStack {
                                    Text("Titulo tópico: \(index)")
                                    Button {
                                        cameraVC.seekPlayerVideo(topic: index)
                                    } label: {
                                        Text("Time topico: \(index)")
                                    }
                                }
                            }
                        }
                    }
                    Text("Script da apresentação: " + (trainingVM.treino.video?.script ?? ""))
                        .padding()
                    ForEach(0..<(trainingVM.treino.video?.topics.count ?? 0), id: \.self) { index in
                        Text("Topicos da apresentação: " + (trainingVM.treino.video?.topics[index] ?? ""))
                    }
                    Text("Tempo da apresesentação: \(trainingVM.treino.video?.time ?? 0)")
                        .font(.title)
                        .foregroundStyle(.green)
                    Text("Duração em cada tópico: ")
                        .font(.title)
                    ForEach(0..<(trainingVM.treino.video?.topicDurationTime.count ?? 0), id: \.self) { index in
                        Text("Tópico \(index): \(trainingVM.treino.video?.topicDurationTime[index] ?? 0)")
                    }
                }
            }
        }
        .onAppear() {
            print(trainingVM.treino)
            cameraVC.getURLVideo(url: self.trainingVM.treino.video!.videoURL)
//            self.videoTime = cameraVC.getVideoDuration(from: self.trainingVM.treino.video!.videoURL)
        }
    }
}
// AVPlayer(url: trainingVM.treino.video!.videoURL)
//#Preview {
//    TreinoView()
//}
