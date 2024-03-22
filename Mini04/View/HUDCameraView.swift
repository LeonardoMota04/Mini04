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
                .overlay {
                    if isTreinoViewPresented {
                        TreinoView(trainingVM: TreinoViewModel(treino: newTraining!))
                            .background(Color.white) // Opcional: adicione um fundo branco para a TreinoView
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .edgesIgnoringSafeArea(.all)
                            .onAppear {
                                // Aqui, definimos a variável showTreinoViewOverlay como true para exibir o overlay na PastaView
                                showTreinoViewOverlay = true
                            }
                    }
                }
            }
            
        }
        .padding(4)
        .onChange(of: cameraVC.urltemp) { oldvalue, newValue in
            if let newVideoURL = newValue {
                folderVM.createNewTraining(videoURL: newVideoURL)
                if let lastTraining = folderVM.folder.treinos.last {
                    newTraining = lastTraining
                    isTreinoViewPresented = true // Exibir a TreinoView

                    // Fechar a HUDCameraView e seu overlay
                    presentationMode.wrappedValue.dismiss()
                }
            } else {
                print("URL do vídeo é nil.")
            }
        }
    }
}
