//
//  HUDCameraView.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.
//

import SwiftUI


struct HUDCameraView: View {
    @EnvironmentObject var cameraVC: CameraViewModel
    @Environment(\.presentationMode) var presentationMode // Para controlar o modo de apresentação
    @State private var isRecording = false

    
    @ObservedObject var folderVM: FoldersViewModel // pasta que estamos gravando
    @Binding var isPreviewShowing: Bool
    @State var isSaveButtonDisabled = true
    
    @State var isRecordingButtonTapped = false
    @State var isrecTapped = false
    
    @State var isCountingDown = false
    @State private var countdownSeconds = 3
    @State var timer: Timer? // Adicione um timer opcional
    @Binding var isShowingModal: Bool
    var body: some View {
        NavigationStack {
            ZStack {
                HStack {
                    //crie um temporizador 00:00:00
                    
                    Spacer()
                    
                    Button {
                        isShowingModal.toggle()
                    } label: {
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundStyle(Color.lightWhite)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                }
                
                Button {
                    if !cameraVC.isRecording {
                        isrecTapped = true
                        isCountingDown = true
                        countdownSeconds = 3 // Reinicia o contador para 3 segundos
                        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                            if countdownSeconds > 0 {
                                countdownSeconds -= 1 // Decrementa o contador a cada segundo
                            } else {
                                timer?.invalidate() // Invalida o timer quando o contador chega a 0
                                timer = nil
                                isrecTapped = false
                                cameraVC.startRecording {}
                                isCountingDown = false
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                            cameraVC.startRecording {
                                isrecTapped = false
                            }
                            isCountingDown = false
                        })
                    } else {
                        cameraVC.stopRecording() // para de gravar video
                        cameraVC.finalModelDetection = ""

                    }
                } label: {
                    if cameraVC.isRecording {
                        withAnimation {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(lineWidth: 2)
                                    .foregroundStyle(Color.lightOrange)
                                    Image(systemName: "square.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundStyle(Color.lightOrange)
                                        .padding(10)
                            }
                            .frame(width: 50, height: 50)

                        }
                    } else {
                        withAnimation {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(lineWidth: 2)
                                    .foregroundStyle(Color.lightOrange)
                                if isCountingDown {
                                    Text(String(countdownSeconds))
                                        .foregroundStyle(Color.lightOrange)
                                        .font(.title)
                                        .bold()
                                } else {
                                    
                                    Image(systemName: "play.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundStyle(Color.lightOrange)
                                        .padding(10)
                                }
                            }
                            .frame(width: 50, height: 50)
                        }
                    }
                }
                .disabled(isrecTapped ? true : false)
//                .disabled(isRecordingButtonTapped ? false : true)
                .buttonStyle(.borderless)
            }
        }
        .padding(4)
        .onChange(of: cameraVC.urltemp) { oldValue, newValue in
            // veririca se o novo vídeo gravado é igual ao último
            guard let newVideoURL = newValue else {
                print("same video")
                return
            }
            
            // Cria um novo treino com o URL do vídeo
            folderVM.createNewTraining(videoURL: newVideoURL,
                                       videoScript: cameraVC.auxSpeech,
                                       videoTime: cameraVC.getVideoDuration(from: newVideoURL),
                                       videoTopics: cameraVC.speechTopicText.components(separatedBy: "//"),
                                       topicsDuration: cameraVC.videoTopicDuration,
                                       cutSpeeches: cameraVC.speeches,
                                       speechStart: cameraVC.startedSpeechTimes)
        }
        .onReceive(cameraVC.$finalModelDetection, perform: { result in
            switch (result) {
            case "iniciar":
                if !cameraVC.isRecording {
                    isrecTapped = true
                    isCountingDown = true
                    countdownSeconds = 3 // Reinicia o contador para 3 segundos
                    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                        if countdownSeconds > 0 {
                            countdownSeconds -= 1 // Decrementa o contador a cada segundo
                        } else {
                            timer?.invalidate() // Invalida o timer quando o contador chega a 0
                            timer = nil
                            cameraVC.startRecording{}
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                        cameraVC.startRecording{}
                        isrecTapped = false
                        isCountingDown = false
                    })
                }
            case "encerrar":
                if cameraVC.isRecording {
                    cameraVC.stopRecording()
                    cameraVC.finalModelDetection = ""

                }
            case "topicar":
                cameraVC.createTopics()
            default:
                break
            }
            
        })
        .onAppear {
            isRecordingButtonTapped = true
        }
        .onDisappear {
            isRecordingButtonTapped = true

        }
    }
}


//#Preview {
//    HUDCameraView(isPreviewShowing: .constant(false))
//}
