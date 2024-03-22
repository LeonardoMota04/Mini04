//
//  RecordingVideoView.swift
//  Mini04
//
//  Created by luis fontinelles on 17/03/24.
//

import SwiftUI

// View para gravar vídeo de treino
struct RecordingVideoView: View {
    @EnvironmentObject var camVM: CameraViewModel
    @State private var isShowingModal: Bool = true  // modal informacoes da apresentacao (NOME, OBJETIVO, TEMPO)
    @ObservedObject var folderVM: FoldersViewModel // pasta que estamos gravando
    @Binding var showTreinoViewOverlay: Bool
    @State var isPreviewShowing = false
    
    var body: some View {
        GeometryReader { reader in
            VStack {
                CameraPreview()
                    
                HUDCameraView(folderVM: folderVM, showTreinoViewOverlay: $showTreinoViewOverlay)
                    .frame(maxWidth: reader.size.width)
                    .frame(height: reader.size.height*0.1)
            }
            .sheet(isPresented: $isShowingModal) {
                trainingPresentationInfos(folderVM: folderVM, isShowingModal: $isShowingModal)
            }
        }
    }
}

struct trainingPresentationInfos: View {
    @ObservedObject var folderVM: FoldersViewModel // pasta que estamos gravando
    @Binding var isShowingModal: Bool
    
    var body: some View {
        VStack {
            Text("Nome da pasta: \(folderVM.folder.nome)")
            Text("Objetivo do seu treino: \(folderVM.folder.objetivoApresentacao)")
            Text("Tempo desejado: \(folderVM.folder.tempoDesejado)")
            .padding()
        }
        .toolbar {
            ToolbarItem {
                Button("Cancelar") {
                    isShowingModal.toggle()
                }
            }
        }
    }
}
