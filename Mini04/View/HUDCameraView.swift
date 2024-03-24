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
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Button {
                    if !cameraVC.videoFileOutput.isRecording {
                        cameraVC.startRecording()
                    } else {
                        cameraVC.stopRecording() // para de gravar video
                    }
                } label: {
                    ZStack {
                        Circle()
                            .foregroundStyle(cameraVC.videoFileOutput.isRecording ? .gray : .red)
                    }
                }
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
                                       topicsDuration: cameraVC.videoTopicDuration)
            presentationMode.wrappedValue.dismiss()
        }
        .onReceive(cameraVC.$finalModelDetection, perform: { result in
            if result == "0" && !isRecording{
                cameraVC.startRecording()
                isRecording.toggle()
            }
        })
    }
}


//#Preview {
//    HUDCameraView(isPreviewShowing: .constant(false))
//}
