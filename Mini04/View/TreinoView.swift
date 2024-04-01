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
    
    @Binding var isShowingModal : Bool
    var body: some View {
        VStack {
            ZStack {
                Text(trainingVM.treino.nome)
                    .font(.title)
                HStack {
                    Button {
                        isShowingModal.toggle()
                        
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
            }
            .frame(height: 30)
            .padding(.horizontal)
            ScrollView {
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
                
                // Verifica se o feedback está disponível
                if let feedback = folderVM.folder.treinos.first?.feedback {
                    // Feedbacks
                    Text(String("TempoVideo: \(trainingVM.treino.video!.videoTime)"))
                    Text(String("TOPICS: \(trainingVM.treino.video!.videoTopics)"))
                    ForEach((trainingVM.treino.video?.topicsDuration.indices)!, id: \.self) { index in
                        Text(String((trainingVM.treino.video?.topicsDuration[index])!))
                    }
                    Text("SCRIPT: \(trainingVM.treino.video?.script ?? "nao achou o script")")
                    
                    // Exibir a lista de sinônimos se disponível
                    if !feedback.RepeatedWords.isEmpty {
                        ForEach(feedback.RepeatedWords, id: \.word) { synonymsModel in
                            SynonymsListView(synonymsInfo: synonymsModel)
                        }
                    } else {
                        Text("Não há feedback disponível")
                    }
                } else {
                    ProgressView("Carregando feedback...")
                }

                ForEach(1...50, id: \.self) { _ in
                    VStack {
                        Text("preenchimento de espaço pra ver como o heigh dessa view se comporta")
                    }
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
    let synonymsInfo: SynonymsModel

    var body: some View {
        List {
            Section(header: Text("Palavra: \(synonymsInfo.word)").font(.headline)) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Número de Sinônimos: \(synonymsInfo.numSynonyms)")
                    Text("Número de Contextos: \(synonymsInfo.numContexts)")

                    Text("Contexto: \(synonymsInfo.synonymContexts[0])")
                    ForEach(1..<synonymsInfo.synonymContexts.count) { index in
                        Text("Sinônimo: \(synonymsInfo.synonymContexts[index])")
                    }
                }
                .padding(.vertical, 10)
            }
        }
    }
}

