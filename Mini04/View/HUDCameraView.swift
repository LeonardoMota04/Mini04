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
    @State private var isTreinoViewPresented = false
    @State private var newTraining: TreinoModel? // Variável de estado para armazenar o novo treino
    @Environment(\.presentationMode) var presentationMode // Para controlar o modo de apresentação
    @Binding var showTreinoViewOverlay: Bool // Adicione um Binding para controlar o overlay do TreinoView

    var body: some View {
        NavigationStack {
            ZStack {
                Button {
                    if !cameraVC.isRecording {
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
            guard let newVideoURL = newValue else {
                print("URL do vídeo é nil.")
                return
            }

            folderVM.createNewTraining(videoURL: newVideoURL, videoScript: cameraVC.auxSpeech, videoTopics: [cameraVC.speechTopicText], videoTime: cameraVC.videoTime, topicDurationTime: cameraVC.videoTopicDuration) // Cria um novo treino com o URL do vídeo

            if let lastTraining = folderVM.folder.treinos.last {
                // Define o novo treino e exibe a TreinoView
                newTraining = lastTraining
                isTreinoViewPresented = true

                // Fecha a HUDCameraView e seu overlay
                presentationMode.wrappedValue.dismiss()
                showTreinoViewOverlay = true // Ativa o overlay na PastaView com a nova TreinoView
            }
        }

    }
}
