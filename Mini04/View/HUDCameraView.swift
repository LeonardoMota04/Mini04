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
    @State private var newTraining: TreinoModel? // Variável de estado para armazenar o novo treino
    @Environment(\.presentationMode) var presentationMode // Para controlar o modo de apresentação
    @Binding var showTreinoViewOverlay: Bool // Adicione um Binding para controlar o overlay do TreinoView
    var body: some View {
        NavigationStack {
            ZStack {
                Button {
                    print("aaaaa: \(cameraVC.finalModelDetection)")
                    if !cameraVC.isRecording || cameraVC.finalModelDetection == "0"{
                        cameraVC.startRecording()
                    } else {
                        cameraVC.stopRecording() // para de gravar video
                        isRecording.toggle()
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

            folderVM.createNewTraining(videoURL: newVideoURL, videoScript: cameraVC.auxSpeech, videoTopics: [cameraVC.speechTopicText], videoTime: cameraVC.videoTime, topicDurationTime: cameraVC.videoTopicDuration) // Cria um novo treino com o URL do vídeo
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
