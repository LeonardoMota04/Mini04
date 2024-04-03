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

//                TimeCircularFeedback(title: trainingVM.treino.video?.formattedTime() ?? "", subtitle: "Tempo Total", objetiveTime: folderVM.folder.tempoDesejado, bodyText: "Embora o tempo médio esteja próximo do desejado, considere ajustes pontuais para garantir que cada parte da apresentação receba a atenção adequada.", frameWidth: 442, frameHeight: 154, progress: CGFloat(trainingVM.treino.video?.videoTime ?? 1), totalProgress: CGFloat(folderVM.folder.tempoDesejado * 60))
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

// MARK: - QUADRO COM SINONIMOS
struct SynonymsFrameBoardView: View {
    let repeatedWordsArray: [RepeatedWordsModel]
    @State private var selectedWord: String? // para armazenar a palavra repetida clicada
    @State private var repeatedTimes: Int = 0
    
    var body: some View {
           
           VStack(alignment: .leading, spacing: 0) { // vstack geral
               
               HStack(spacing: 15) { // hstack para palavras repetidas
                   // MARK: - PALAVRAS REPETIDAS LISTADAS (MAIS REPETIDA PARA MENOS)
                   ForEach(repeatedWordsArray.sorted(by: { $0.repetitionCount > $1.repetitionCount}), id: \.self) { repeatedWord in
                       Text(repeatedWord.word)
                           .bold(selectedWord == repeatedWord.word ? true : false)
                           .foregroundStyle(selectedWord == repeatedWord.word ? .white : .black)
                           .padding(selectedWord == repeatedWord.word ? 14 : 8)
                           .background(selectedWord == repeatedWord.word ? .gray : .white)
                           .clipShape(selectedWord == repeatedWord.word ? UnevenRoundedRectangle(cornerRadii: .init(topLeading: 6, topTrailing: 6)) : UnevenRoundedRectangle(cornerRadii: .init(topLeading: 6, bottomLeading: 6, bottomTrailing: 6, topTrailing: 6)))
                           .onTapGesture {
                               selectedWord = repeatedWord.word
                               repeatedTimes = repeatedWord.repetitionCount
                           }
                           .overlay {
                               VStack {
                                   HStack {
                                       Spacer()
                                       Text("\(repeatedWord.repetitionCount)") // Bola em cima mostrando quantas vezes foi repetida
                                           .foregroundStyle(.white)
                                           .padding(6)
                                           .background(.ultraThickMaterial)
                                           .clipShape(Circle())
                                           .offset(x: 10, y: -10)
                                   }
                                   Spacer()
                               }
                           }
                   }
               }
            
            // MARK: - QUADRO DE SINONIMOS
               UnevenRoundedRectangle(cornerRadii: .init(bottomLeading: 6, bottomTrailing: 6, topTrailing: 6))
                   .foregroundStyle(.gray)
                   .overlay {
                       VStack(alignment: .leading) {
                           Text("Você repetiu essa palavra \(Text(String(repeatedTimes)).bold()) vezes.")
                               .font(.body)
                           
                           Divider()
                               .padding(.trailing, 40)
                               .padding(.vertical, 5)
                               .foregroundStyle(.black.opacity(0.8))
                           
                           Text("Possíveis sinônimos:")
                               .foregroundStyle(.ultraThickMaterial)
                               .font(.body)
                               .bold()
                          
                           // CONTEXTO COM (3) SINONIMOS
                           // Verifica se a palavra clicada está presente no array de palavras repetidas
                           if let repeatedWord = repeatedWordsArray.first(where: { $0.word == selectedWord }) {
                               HStack(alignment: .top, spacing: 100) {
                                   // Ordenar os contextos com base no número de sinônimos
                                   let sortedContexts = repeatedWord.synonymContexts.sorted { $0.count > $1.count }
                                   
                                   // Primeira coluna com até 3 contextos e sinônimos
                                   VStack(alignment: .leading, spacing: 34) {
                                       ForEach(sortedContexts.prefix(3), id: \.self) { contextWithSynonyms in
                                           VStack(alignment: .leading) {
                                               // CONTEXTO
                                               if let context = contextWithSynonyms.first {
                                                   Text(context)
                                                       .font(.footnote)
                                                       .foregroundStyle(.ultraThinMaterial)
                                               }
                                               // SINONIMOS
                                               HStack {
                                                   ForEach(contextWithSynonyms.dropFirst(), id: \.self) { synonym in
                                                       Text(synonym)
                                                           .font(.subheadline)
                                                           .foregroundStyle(.white)
                                                           .padding(8)
                                                           .background(.black.opacity(0.6))
                                                           .clipShape(RoundedRectangle(cornerRadius: 6))
                                                   }
                                               }
                                           }
                                           .padding([.top, .leading], 10)
                                       }
                                   }
                                   
                                   // Segunda coluna para contextos e sinônimos adicionais, se houver
                                   if repeatedWord.numContexts > 3 {
                                       VStack(alignment: .leading, spacing: 34) {
                                           ForEach(sortedContexts.dropFirst(3), id: \.self) { contextWithSynonyms in
                                               VStack(alignment: .leading) {
                                                   // CONTEXTO
                                                   if let context = contextWithSynonyms.first {
                                                       Text(context)
                                                           .font(.footnote)
                                                           .foregroundStyle(.ultraThinMaterial)
                                                   }
                                                   // SINONIMOS
                                                   HStack {
                                                       ForEach(contextWithSynonyms.dropFirst(), id: \.self) { synonym in
                                                           Text(synonym)
                                                               .font(.subheadline)
                                                               .foregroundStyle(.white)
                                                               .padding(8)
                                                               .background(.black.opacity(0.6))
                                                               .clipShape(RoundedRectangle(cornerRadius: 6))
                                                       }
                                                   }
                                               }
                                               .padding([.top, .leading], 10)
                                           }
                                       }
                                   }
                               }
                           }


                           Spacer() // para jogar o que esta dentro do quadrão para cima
                       }
                       .padding([.horizontal, .top])
                   }

        }
        .padding([.horizontal, .bottom], 20)
        .onAppear {
            selectedWord = repeatedWordsArray[0].word
            repeatedTimes = repeatedWordsArray[0].repetitionCount
        }
    }
}

// MARK: - SINONIMOS FEEDBACK TREINO VIEW
struct SynonymsFeedbackTrainingView: View {
    // recebe um array de palavras repetidas naquele treino
    let repeatedWordsArray: [RepeatedWordsModel]

    var body: some View {
        ZStack (alignment: .leading){
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(.gray.opacity(0.5)) // cor do fundao
            
            VStack(alignment: .leading, spacing: 0) {
                
                // HEADER
                VStack (alignment: .leading, spacing: 5) {
                    let stringPalavras = repeatedWordsArray.count > 1 ? "Palavras" : "Palavra"
                    let stringRepetidas = repeatedWordsArray.count > 1 ? "Repetidas" : "Repetida"
                    Text("\(repeatedWordsArray.count) \(stringPalavras)")
                        .font(.title2)
                        .foregroundStyle(.black)
                        .bold()
                    
                    Text("\(stringRepetidas) em excesso")
                        .foregroundStyle(.ultraThinMaterial)
                        .font(.footnote)
                }
                .padding(20)
                
                SynonymsFrameBoardView(repeatedWordsArray: repeatedWordsArray)
            }
        }
    }
}


//#Preview {
//    SynonymsFeedbackTrainingView()//(synonymsInfo: RepeatedWordsModel(word: "palavra", numSynonyms: 10, numContexts: 5))
//        .frame(width: 840, height: 500)
//        //.frame(maxWidth: .infinity, maxHeight: .infinity)
//}
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

