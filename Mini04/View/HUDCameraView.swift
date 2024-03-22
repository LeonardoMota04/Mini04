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
    
    
    @ObservedObject var folderVM: FoldersViewModel // pasta que estamos gravando
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

            folderVM.createNewTraining(videoURL: newVideoURL) // Cria um novo treino com o URL do vídeo
            presentationMode.wrappedValue.dismiss()
        }
    }
}


//#Preview {
//    HUDCameraView(isPreviewShowing: .constant(false))
//}
