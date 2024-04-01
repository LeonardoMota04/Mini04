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
    @Binding var isShowingModal: Bool
    @State private var editedName: String = ""
    @State private var avPlayer: AVPlayer = AVPlayer()
    
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
                    .frame(height: size.height / 5)
                
                // Verifica se o feedback está disponível
                // Feedbacks
                Text(String("TempoVideo: \(trainingVM.treino.video!.videoTime)"))
                Text(String("TOPICS: \(trainingVM.treino.video!.videoTopics)"))
                ForEach((trainingVM.treino.video?.topicsDuration.indices)!, id: \.self) { index in
                    Text(String((trainingVM.treino.video?.topicsDuration[index])!))
                }
                Text("SCRIPT: \(trainingVM.treino.video?.script ?? "nao achou o script")")
                
                // Tem feedbacks ACHO QUE NAO PRECISA, POIS PARA ENTRAR AQUI ELES DEVEM ESTAR CARREGADOS JÁ
                Text("Palavras repetidas:")
                if let feedback = trainingVM.treino.feedback {
                    ForEach(feedback.repeatedWords, id: \.word) { synonymsModel in
                        SynonymsListView(synonymsInfo: synonymsModel)
                        Text(synonymsModel.word)
                    }
                } else {
                    ProgressView("Carregando Feedback")
                }
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

// LISTA DE SINONIMOS
struct SynonymsListView: View {
    let synonymsInfo: RepeatedWordsModel

    var body: some View {
        List {
            Section(header: Text("Palavra: \(synonymsInfo.word)").font(.headline)) {
                ForEach(synonymsInfo.synonymContexts, id: \.self.first) { contextAndSynonyms in
                    VStack(alignment: .leading, spacing: 10) {
                        if let context = contextAndSynonyms.first {
                            Text("Contexto: \(context)").font(.subheadline)
                        }
                        ForEach(contextAndSynonyms.dropFirst(), id: \.self) { synonym in
                            Text("Sinônimo: \(synonym)").font(.subheadline)
                        }
                    }
                    .padding(.vertical, 5)
                    .background(Color.gray.opacity(0.2))
                }
            }
            .padding(.vertical, 10)
        }
    }
}

