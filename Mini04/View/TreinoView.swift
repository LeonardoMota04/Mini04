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

     // Define outro DateFormatter para formatar a data de outra maneira

    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            
            VStack {
                // BOTAO FECHAR A MODAL
                HStack {
                    Button {
                        isShowingModal.toggle()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                }
                .padding(.bottom)
                .padding(.leading, -5)

                
                    //DATA DO TREINO
                    HStack {
                        let formatedDate: DateFormatter = {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "EEEE, MMM d, yyyy"
                            return formatter
                        }()
                        Text(formatedDate.string(from: trainingVM.treino.data))
                            .foregroundStyle(.black)
                            .font(.callout)
                        Spacer()
                    }
                    //NOME DO TREINO
                    HStack {
                        Text(trainingVM.treino.nome)
                            .foregroundStyle(.black)
                            .font(.largeTitle)
                            .bold()
                        Spacer()
                    }
                
                    VStack {
                        HStack {
                            Text("Gravaçao")
                                .foregroundStyle(.black)
                                .font(.title3)
                                .bold()
                            Spacer()
                        }
                        HStack {
                            // PLAYER DE VÍDEO
                            VideoPlayer(player: avPlayer)
                                .onAppear {
                                    if let videoURL = trainingVM.treino.video?.videoURL {
                                        avPlayer.replaceCurrentItem(with: AVPlayerItem(url: videoURL))
                                    }
                                }
                                .frame(width: 400)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            VStack {
                                HStack {
                                    Text("Transcrição")
                                        .foregroundStyle(.black)
                                        .font(.title3)
                                        .bold()
                                    Spacer()
                                }
                                RoundedRectangle(cornerRadius: 10)
                            }
                                .foregroundStyle(.white)
                        }
                        .frame( height: 225)
                        
                        //feedbacks
                        HStack {
                            Text("Feedbacks")
                                .foregroundStyle(.black)
                                .font(.title3)
                                .bold()
                            Spacer()
                        }
                    }
                    .padding()
                    
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
            .padding()
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

