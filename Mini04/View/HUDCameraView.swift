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
    
    var body: some View {
        NavigationStack {
            ZStack {
                Button {
                    if !cameraVC.videoFileOutput.isRecording {
                        cameraVC.startRecording()
                    } else {
                        cameraVC.stopRecording() // para de gravar video
                        cameraVC.finalModelDetection = ""

                    }
                } label: {
                    if cameraVC.videoFileOutput.isRecording {
                        withAnimation {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(lineWidth: 2)
                                    .foregroundStyle(Color.lightOrange)
                                Image(systemName: "square.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(Color.lightOrange)
                                    .padding(4)
                            }
                            .frame(width: 50, height: 50)

                        }
                    } else {
                        withAnimation {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(lineWidth: 2)
                                    .foregroundStyle(Color.lightOrange)
                                Image(systemName: "play.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(Color.lightOrange)
                                    .padding(4)

                            }
                            .frame(width: 50, height: 50)
                        }
                    }
                }
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
                if !cameraVC.videoFileOutput.isRecording {
                    cameraVC.startRecording()
                }
            case "encerrar":
                if cameraVC.videoFileOutput.isRecording {
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
