//
//  RecordingVideoView.swift
//  Mini04
//
//  Created by luis fontinelles on 17/03/24.
//

import SwiftUI

struct RecordingVideoView: View {
    @EnvironmentObject var camVM: CameraViewModel
    @State private var isShowingModal: Bool = true  // modal informacoes da apresentacao (NOME, OBJETIVO, TEMPO)
    @ObservedObject var folderVM: FoldersViewModel // pasta que estamos gravando
    
    @Environment(\.presentationMode) var presentationMode
    @State var isPreviewShowing = false
    @State private var showLoadingView: Bool = false
    
    var body: some View {
        GeometryReader { reader in
            ZStack {
                VStack {
                    CameraPreview()
                    
                    HUDCameraView(folderVM: folderVM, isPreviewShowing: $isPreviewShowing, isShowingModal: $isShowingModal)
                        .frame(maxWidth: reader.size.width)
                        .frame(height: reader.size.height*0.1)
                }
                if self.showLoadingView { // Controla a visibilidade da loading view
                    LoadingView()
                }
            }
            .sheet(isPresented: $isShowingModal) {
                trainingPresentationInfos(folderVM: folderVM, isShowingModal: $isShowingModal)
            }
        }
        .background(Color.black)
        .onChange(of: folderVM.showLoadingView) { oldeValue, newValue in // Atualiza showLoadingView com base em folderVM.showLoadingView
            withAnimation() {
                self.showLoadingView = newValue
            }
            // caso o ultimo valor seja verdadeiro entao ele ta mostrandoa tela de loading
            if oldeValue {
                sleep(1)
                presentationMode.wrappedValue.dismiss()
            }
        }
        .background(Color.lightLighterGray)
        .navigationBarBackButtonHidden(true)
//        .onAppear {
//            camVM.videoFileOutput.stopRecording()
//        }
//        .onDisappear {
//            camVM.stopRecording()
//        }
    }

    //        .overlay(content: {
    //            if let url = camVM.urltemp, isPreviewShowing {
    //                FinalPreview(url: url)
    //                    .transition(.move(edge: .trailing))
    //            }
    //        })
    //        .animation(.easeInOut, value: isPreviewShowing)
}

struct trainingPresentationInfos: View {
    
    @ObservedObject var folderVM: FoldersViewModel // pasta que estamos gravando
    @Binding var isShowingModal: Bool
    @State var hasProceeded: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            
            let size = geometry.size
            
            VStack {
                
                VStack(alignment: .leading) {
                    HStack {
                        Button {
                            isShowingModal = false
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundStyle(.gray)
                        }
                        .buttonStyle(.plain)
                        .focusable(false)
                        .padding()
                        
                        Spacer()
                    }
                    
                    Text(hasProceeded ? "Controle sua gravação:" : "Relembre alguns detalhes:")
                        .font(.title)
                        .bold()
                        .padding(.horizontal)
                    
                    Text(hasProceeded ? "Utilize gestos simples para iniciar, pausar, encerrar ou separar um novo tópico, durante a gravação dos seus ensaios, permitindo que você se concentre completamente no conteúdo da apresentação." : "Mantendo esses detalhes em mente durante seus ensaios, você estará mais preparado e confiante para oferecer uma apresentação memorável.")
                        .font(.callout)
                        .frame(width: 500)
                        .padding(.horizontal)
                }
                
                // MARK: Relembrar detalhes
                if !hasProceeded {
                    VStack(alignment: .center) {
                        // DURAÇÃO e TIPO
                        HStack {
                            CustomNameView(folderVM: folderVM)
                                .frame(width: size.width / 2.5, height: size.height / 5.5)
                            CustomDurationView(folderVM: folderVM)
                                .frame(width: size.width / 2.5, height: size.height / 5.5)
                        }
                        
                        // NOME e DATA
                        HStack {
                            CustomDateView(folderVM: folderVM)
                                .frame(width: size.width / 2.5, height: size.height / 5.5)
                            CustomTypeView(folderVM: folderVM)
                                .frame(width: size.width / 2.5, height: size.height / 5.5)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 48)
                    
                    // MARK: Conhecer gestos
                } else {
                    HStack {
                        thumbsUpView()
                            .frame(width: size.height / 4, height: size.height / 4)
                        
                        PauseView()
                            .frame(width: size.height / 4, height: size.height / 4)
                        
                        TopicoView()
                            .frame(width: size.height / 4, height: size.height / 4)
                        
                        EncerrarView()
                            .frame(width: size.height / 4, height: size.height / 4)
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 48)
                }
                
            }
            .padding(.horizontal, 20)
            .preferredColorScheme(.light)
            
            VStack {
                
                Spacer()
                
                HStack {
                    Spacer()
                    Button {
                        
                        if !hasProceeded {
                            hasProceeded = true
                        } else {
                            isShowingModal = false
                        }
                        
                        
                    } label: {
                        RoundedRectangle(cornerRadius: 16)
                            .frame(width: size.width / 4, height: size.height / 10)
                            .foregroundColor(.lightDarkerGreen)
                            .overlay {
                                Text(hasProceeded ? "Iniciar Treino" : "Prosseguir")
                                    .font(.title3)
                                    .bold()
                            }
                    }
                    .buttonStyle(.plain)
                    .focusable(false)
                    .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.bottom, size.height / 10)
            }
           
        }
        .frame(width: 730, height: 520)
        .background(Color.lightLighterGray)
    }
}

// MARK: - CÉLULAS INFO DA APRESENTAÇÃO
struct CustomDurationView: View {
    
    @ObservedObject var folderVM: FoldersViewModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12.5)
                .fill(.white)
                .stroke(Color("light_Orange"), lineWidth: 1)
            
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text("Duração da Apresentação")
                        .foregroundStyle(.gray)
                    .font(.body)
                    
                    Spacer()
                }
                .padding(.leading)
                .padding(.top, 6)
                
                Spacer()
                
                HStack {
                    Text(folderVM.folder.formattedGoalTime())
                        .font(.title3)
                        .foregroundStyle(Color("light_Orange"))
                    .bold()
                }
                .padding(.leading)
                
                Spacer()
            }
        }
    }
}

struct CustomNameView: View {
    
    @ObservedObject var folderVM: FoldersViewModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12.5)
                .fill(.white)
                .stroke(Color("light_Orange"), lineWidth: 1)
            
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text("Nome da Apresentação")
                        .foregroundStyle(.gray)
                    .font(.body)
                    
                    Spacer()
                }
                .padding(.leading)
                .padding(.top, 6)
                
                Spacer()
                
                HStack {
                    Text(folderVM.folder.nome)
                        .font(.title3)
                        .foregroundStyle(Color("light_Orange"))
                    .bold()
                }
                .padding(.leading)
                
                Spacer()
            }
        }
    }
}

struct CustomDateView: View {
    
    @ObservedObject var folderVM: FoldersViewModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12.5)
                .fill(.white)
                .stroke(Color("light_Orange"), lineWidth: 1)
            
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text("Data da Apresentação")
                        .foregroundStyle(.gray)
                    .font(.body)
                    
                    Spacer()
                }
                .padding(.leading)
                .padding(.top, 6)
                
                Spacer()
                
                HStack {
                    Text("\(folderVM.folder.dateOfPresentation)")
                        .font(.title3)
                        .foregroundStyle(Color("light_Orange"))
                    .bold()
                }
                .padding(.leading)
                
                Spacer()
            }
        }
    }
}

struct CustomTypeView: View {
    
    @ObservedObject var folderVM: FoldersViewModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12.5)
                .fill(.white)
                .stroke(Color("light_Orange"), lineWidth: 1)
            
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text("Tipo de Apresentação")
                        .foregroundStyle(.gray)
                        .font(.body)
                    
                    Spacer()
                }
                .padding(.leading)
                .padding(.top, 6)
                
                Spacer()
                
                HStack {
                    Text(folderVM.folder.objetivoApresentacao)
                        .font(.title3)
                        .foregroundStyle(Color("light_Orange"))
                    .bold()
                }
                .padding(.leading)
                
                Spacer()
            }
        }
    }
}

// MARK: - CÉLULAS GESTOS DE MÃO
struct thumbsUpView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12.5)
                .fill(.white)
                .stroke(Color("light_Orange"), lineWidth: 1)
            
            VStack {
                VStack(alignment: .leading) {
                    Text("Iniciar gravação")
                        .foregroundStyle(.gray)
                        .font(.body)
                    
                }
                
                Image("iniciar")
                
            }
        }
    }
}

struct PauseView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12.5)
                .fill(.white)
                .stroke(Color("light_Orange"), lineWidth: 1)
            
            VStack {
                VStack(alignment: .leading) {
                    Text("Pausar gravação")
                        .foregroundStyle(.gray)
                        .font(.body)
                }
                
                Image("pausar")
                
            }
        }
    }
}

struct TopicoView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12.5)
                .fill(.white)
                .stroke(Color("light_Orange"), lineWidth: 1)
            
            VStack {
                VStack(alignment: .leading) {
                    Text("Iniciar novo tópico")
                        .foregroundStyle(.gray)
                        .font(.body)
                }
                
                Image("topicar")
                
            }
        }
    }
}

struct EncerrarView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12.5)
                .fill(.white)
                .stroke(Color("light_Orange"), lineWidth: 1)
            
            VStack {
                VStack(alignment: .leading) {
                    Text("Encerrar gravação")
                        .foregroundStyle(.gray)
                        .font(.body)
                }
                
                Image("encerrar")
                
            }
        }
    }
}

#Preview {
    trainingPresentationInfos(folderVM: FoldersViewModel(folder: PastaModel(nome: "Apresentação", dateOfPresentation: Date(), tempoDesejado: 480, objetivoApresentacao: "Apresentação de Pitch")), isShowingModal: .constant(true))
}
