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
                        .foregroundStyle(.gray)
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
                            .buttonStyle(.plain)
                            .frame(width: 38, height: 38)
                            .padding(.trailing, 5)
                            .alert("Você tem certeza?", isPresented: $isAlert) {
                                Button("Cancelar", role: .cancel) { isAlert = false }
                                Button("Deletar", role: .destructive) {
                                    // deletar treino
                                    isShowingModal = false
                                    DispatchQueue.main.async {
                                        withAnimation { self.folderVM.deleteTraining(trainingVM.treino) }
                                    }
                                }
                            } message: {
                                Text("Esse treino (incluindo a gravação, transcrição e os feedbacks individuais) será permanentemente excluído.")
                            }
                        }
                        VStack(alignment: .leading) {
                        Text("Gravação")
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
                                
                                if let speech = trainingVM.treino.video?.cutSpeeches,
                                   let time = trainingVM.treino.video?.speechStart {
                                    TranscricaoViewComponent(trainingVM: trainingVM, player: avPlayer, speeches: speech, times: time)
                                        .frame(height: size.height / 3.25)
                                }
                                    
                            }
                            .foregroundStyle(.white)
                        }
                   
                        // MARK: feedbacks -
                            VStack(alignment: .leading) {
                                Text("Feedbacks")
                                    .foregroundStyle(.black)
                                    .font(.title3)
                                    .bold()
                                
                                // 3 FEEDBACKS JUNTOS
                                HStack(alignment: .center) {
                                    VStack {
                                        RoundedRectangle(cornerRadius: 16, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                                            .stroke(Color("light_Orange"), lineWidth: 1)
                                            .fill(.white)
                                            .frame(width: 442, height: 184)
                                            .overlay {
                                                Text("Em breve")
                                                    .font(.title)
                                                    .foregroundStyle(Color("light_Orange"))
                                            }
                                        TimeCircularFeedback(
                                            title: trainingVM.treino.video?.formattedTime() ?? "",
                                            subtitle: "Tempo Total",
                                            objetiveTime: folderVM.folder.formattedGoalTime(), // Chama o método formattedTime() para obter o tempo formatado
                                            bodyText: "Embora o tempo médio esteja próximo do desejado, considere ajustes pontuais para garantir que cada parte da apresentação receba a atenção adequada.",
                                            widthFrame: 442,
                                            heightFrame: 154,
                                            progress: CGFloat(trainingVM.treino.video?.videoTime ?? 1),
                                            totalProgress: CGFloat(folderVM.folder.tempoDesejado) // em segundos
                                        )
                                    }
                                        CohesionFeedback(fluidProgress: trainingVM.treino.feedback?.coherenceValues[0] ?? 1,
                                                         organizationProgress: trainingVM.treino.feedback?.coherenceValues[1] ?? 1,
                                                         connectionProgress: trainingVM.treino.feedback?.coherenceValues[2] ?? 1,
                                                         widthFrame: 380,
                                                         heightFrame: 350)
                                }
                                // Verifica se o feedback está disponível
                                // FEEDBACK DE BAIXO
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


