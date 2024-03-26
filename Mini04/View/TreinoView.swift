//
//  TreinoView.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.
//

import SwiftUI
import AVKit

struct TreinoView: View {
    // VM
    @ObservedObject var folderVM: FoldersViewModel
    @ObservedObject var trainingVM: TreinoViewModel
    @EnvironmentObject var cameraVC: CameraViewModel
    
    @State private var editedName: String = ""
    @State private var avPlayer: AVPlayer = AVPlayer()
    @State private var feedback: FeedbackModel? // FeedbackModel agora é um estado

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            
            VStack {
                // NOME DO TREINO
                HStack {
                    TextField("Nome", text: $editedName)
                        .font(.title)
                    Spacer()
                    Button("Salvar Alterações") {
                        saveChanges()
                    }
                }
                Text("Você está treinando na pasta \(folderVM.folder.nome)")
                Text("Data de criação: \(trainingVM.treino.data)")
                
                VideoPlayer(player: avPlayer)
                    .onAppear {
                        if let videoURL = trainingVM.treino.video?.videoURL {
                            avPlayer.replaceCurrentItem(with: AVPlayerItem(url: videoURL))
                        }
                    }
                    .frame(height: size.height / 2)
                                
                // Feedbacks
                Text(String("TempoVideo: \(trainingVM.treino.video!.videoTime)"))
                Text(String("TOPICS: \(trainingVM.treino.video!.videoTopics)"))
                ForEach((trainingVM.treino.video?.topicsDuration.indices)!, id: \.self) { index in
                    Text(String((trainingVM.treino.video?.topicsDuration[index])!))
                }
                Text("SCRIPT: \(trainingVM.treino.video?.script ?? "nao achou o script")")
                Text(String(describing: trainingVM.treino.feedback?.palavrasRepetidas5vezes))

            }
        }
        .onAppear {
            editedName = trainingVM.treino.nome
        }
    }
    
    // UPDATE Nome do treino
    func saveChanges() {
        trainingVM.treino.nome = editedName
        trainingVM.treino.changedTrainingName = true
    }
}
