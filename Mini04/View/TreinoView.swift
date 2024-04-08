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
    @State private var videoPlayer = VideoPlayer(player: AVPlayer())
    @State var videoTapped = false
    // Define outro DateFormatter para formatar a data de outra maneira
    
    @State var isAlert: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            VStack(alignment: .leading) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isShowingModal.toggle()
                    }
                } label: {
                    Image(systemName: "xmark")
                }
                .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 0))
                .buttonStyle(.plain)
                ScrollView {
                    // BOTAO FECHAR A MODAL
                    VStack(alignment: .leading) {
                        //DATA DO TREINO
                        let formatedDate: DateFormatter = {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "EEEE, MMM d, yyyy"
                            return formatter
                        }()
                        HStack {
                            VStack(alignment: .leading) { // Title Stack
                                Text(formatedDate.string(from: trainingVM.treino.data))
                                    .foregroundStyle(.black)
                                    .font(.callout)
                                //NOME DO TREINO
                                Text(trainingVM.treino.nome)
                                    .foregroundStyle(.black)
                                    .font(.largeTitle)
                                    .bold()
                            }
                            Spacer()
                            Button() {
                                isAlert.toggle()
                            } label: {
                                RoundedRectangle(cornerRadius: 8)
                                    .frame(width: 38, height: 38)
                                    .foregroundStyle(.orange)
                                    .overlay {
                                        Image(systemName: "trash.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 18)
                                    }
                            }
                            .frame(width: 38, height: 38)
                            .padding(.trailing, 5)
                            .alert("Você tem certeza?", isPresented: $isAlert) {
                                Button("Cancelar", role: .cancel) { }
                                Button("Deletar", role: .destructive) {
                                    // deletar treino
                                    folderVM.deleteTraining(trainingVM.treino)
                                }
                            } message: {
                                Text("Esse treino (incluindo a gravação, transcrição e os feedbacks individuais) serão permanentemente excluídos.")
                            }
                        }
                        VStack(alignment: .leading) {
                        Text("Gravaçao")
                            .foregroundStyle(.black)
                            .font(.title3)
                            .bold()
                        HStack {
                            // PLAYER DE VÍDEO
                            VideoPlayer(player: AVPlayer(url: trainingVM.treino.video!.videoURL))
                                .frame(width: 496, height: 279)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding(.trailing, 3)
                            VStack(alignment: .leading) {
                                Text("Transcrição")
                                    .foregroundStyle(.black)
                                    .font(.title3)
                                    .bold()
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 316, height: 251)
                            }
                            .foregroundStyle(.white)
                        }
                   
                        // MARK: feedbacks -
                            VStack(alignment: .leading) {
                                Text("Feedbacks")
                                    .foregroundStyle(.black)
                                    .font(.title3)
                                    .bold()
                                HStack(alignment: .center) {
                                    VStack {
                                        RoundedRectangle(cornerRadius: 16, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                                            .frame(width: 442, height: 184)
                                        // .padding(.bottom, 10)
                                            .overlay {
                                                Text("Em breve")
                                                    .font(.title)
                                            }
                                        TimeCircularFeedback(title: trainingVM.treino.video?.formattedTime() ?? "", subtitle: "Tempo Total", objetiveTime: folderVM.folder.tempoDesejado, bodyText: "Embora o tempo médio esteja próximo do desejado, considere ajustes pontuais para garantir que cada parte da apresentação receba a atenção adequada.", widthFrame: 442, heightFrame: 154, progress: CGFloat(trainingVM.treino.video?.videoTime ?? 1), totalProgress: CGFloat(folderVM.folder.tempoDesejado * 60))
                                    }
                                    if  ((trainingVM.treino.feedback?.coherenceValues.isEmpty) != nil) { //TODO: resolver essa logica na viewModel ou model - garatindo que nao vai crachar o app se o index nao existir
                                        CohesionFeedback(fluidProgress: 1,
                                                         organizationProgress: 1,
                                                         connectionProgress: 1,
                                                         widthFrame: 380,
                                                         heightFrame: 350)
                                    } else {
                                        CohesionFeedback(fluidProgress: trainingVM.treino.feedback?.coherenceValues[0] ?? 1,
                                                         organizationProgress: trainingVM.treino.feedback?.coherenceValues[1] ?? 1,
                                                         connectionProgress: trainingVM.treino.feedback?.coherenceValues[2] ?? 1,
                                                         widthFrame: 380,
                                                         heightFrame: 350)
                                    }
                                }
                                // Verifica se o feedback está disponível
//                                Text(String("TempoVideo: \(trainingVM.treino.video!.videoTime)"))
//                                Text(String("TOPICS: \(trainingVM.treino.video!.videoTopics)"))
//                                ForEach((trainingVM.treino.video?.topicsDuration.indices)!, id: \.self) { index in
//                                    Text(String((trainingVM.treino.video?.topicsDuration[index])!))
//                                }
                               // Text("SCRIPT: \(trainingVM.treino.video?.script ?? "nao achou o script")")
                                // Tem feedbacks ACHO QUE NAO PRECISA, POIS PARA ENTRAR AQUI ELES DEVEM ESTAR CARREGADOS JÁ
                                if let feedback = trainingVM.treino.feedback {
                                    // REPETIU PALAVRAS
                                    if feedback.repeatedWords.count > 0 {
                                        SynonymsFeedbackTrainingView(repeatedWordsArray: feedback.repeatedWords)
                                            .frame(height: 500)
                                            .padding(.top)
                                        
                                        ForEach(feedback.repeatedWords, id: \.self) { repeatedWord in
                                            
                                        }
                                    } else {
                                        Text("Não repetiu palavras")
                                    }
                                    
                                } else {
                                    ProgressView("Carregando Feedback")
                                }
                            }
                            .padding(.top, 49)
                        }
                        .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 0))
                    }
                    .padding(EdgeInsets(top: 32, leading: 52, bottom: 32, trailing: 52))
                }
                .onAppear {
                    editedName = trainingVM.treino.nome
                }
            }
        }
    }
    
    // UPDATE Nome do treino
    func saveChanges() {
        trainingVM.treino.nome = editedName
        trainingVM.treino.changedTrainingName = true
    }
}


