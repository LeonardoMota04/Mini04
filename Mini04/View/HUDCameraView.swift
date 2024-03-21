//
//  HUDCameraView.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.
//

import SwiftUI


struct HUDCameraView: View {
    @EnvironmentObject var cameraVC: CameraViewModel
    @ObservedObject var folderVM: FoldersViewModel // pasta que estamos gravando
    @State private var isRecording = false
    @Binding var isPreviewShowing: Bool
    @State var isSaveButtonDisabled = true
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                HStack {
                    Spacer()
                    Button {
                        isPreviewShowing.toggle()
                        
                    } label: {
                        Text("save")
                    }
                    .disabled(isSaveButtonDisabled)
                }
                Button {
                    if !cameraVC.isRecording {
                        cameraVC.startRecording()
//                        cameraVC.isRecording.toggle()
                    } else {
                        cameraVC.stopRecording() // para de gravar video
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            if let videoURL = cameraVC.urltemp {

                                folderVM.createNewTraining(videoURL: videoURL, videoScript: cameraVC.auxSpeech, videoTopics: [cameraVC.speechTopicText], videoTime: cameraVC.videoTime, topicDurationTime: cameraVC.videoTopicDuration) // cria novo treino com o URL do vídeo
                                isRecording.toggle()
                                isSaveButtonDisabled.toggle()
                            } else {
                                print("URL do vídeo é nil.")
                            }
                        }
                        cameraVC.isRecording.toggle()
                        isSaveButtonDisabled.toggle()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .foregroundStyle(cameraVC.isRecording ? .gray : .red)
                    }
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(4)

    }
}


//#Preview {
//    HUDCameraView(isPreviewShowing: .constant(false))
//}
