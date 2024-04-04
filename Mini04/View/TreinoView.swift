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
            
            ScrollView {
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

                TimeCircularFeedback(title: trainingVM.treino.video?.formattedTime() ?? "", subtitle: "Tempo Total", objetiveTime: folderVM.folder.tempoDesejado, bodyText: "Embora o tempo médio esteja próximo do desejado, considere ajustes pontuais para garantir que cada parte da apresentação receba a atenção adequada.", frameWidth: 442, frameHeight: 154, progress: CGFloat(trainingVM.treino.video?.videoTime ?? 1), totalProgress: CGFloat(folderVM.folder.tempoDesejado * 60))
                
                // Feedbacks
                // Tem feedbacks ACHO QUE NAO PRECISA, POIS PARA ENTRAR AQUI ELES DEVEM ESTAR CARREGADOS JÁ
                if let feedback = trainingVM.treino.feedback {
                    // REPETIU PALAVRAS
                    if feedback.repeatedWords.count > 0 {
                        SynonymsFeedbackTrainingView(repeatedWordsArray: feedback.repeatedWords)
                            .frame(height: 500)
                        ForEach(feedback.repeatedWords, id: \.self) { repeatedWord in
                            
                        }
                    } else {
                        Text("Não repetiu palavras")
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


