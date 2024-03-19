//
//  PastaView.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.
//

import SwiftUI

struct PastaView: View {
    @ObservedObject var folderVM: FoldersViewModel
    @State private var isModalPresented = true // Modal sempre será apresentado ao entrar na view

    var body: some View {
        NavigationStack {
            VStack {
                Text("NOME: \(folderVM.folder.nome)")
                Text("Data: \(folderVM.folder.data)")
                Text("Tempo Desejado: \(folderVM.folder.tempoDesejado)")
                Text("Objetivo: \(folderVM.folder.objetivoApresentacao)")
                
                Spacer()
                
                if folderVM.folder.treinos.isEmpty {
                    Text("Adicione um treino para começar")
                }
                
                Spacer()
                NavigationLink {
                    RecordingVideoView()
                } label: {
                    Text("Novo Treino")
                }

//                Button("Criar treino") {
//                    let newTraining = TreinoModel(name: "\(folderVM.folder.nome) - Treino \(folderVM.folder.treinos.count + 1)")
//                    folderVM.folder.treinos.append(newTraining)
//                }
                ForEach(folderVM.folder.treinos) { treino in
                    NavigationLink(treino.nome) {
                        TreinoView(trainingVM: TreinoViewModel(treino: treino), folder: folderVM.folder)
                    }
                }
                
            }
        }
        .padding()
        .sheet(isPresented: $isModalPresented) {
            ModalView(isModalPresented: $isModalPresented)
        }
    }
}
//
//#Preview {
//    PastaView()
//}
