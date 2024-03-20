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
            
                // ABRIR PARA COMEÇAR A GRAVAR UM TREINO PASSANDO A PASTA QUE ESTAMOS
                NavigationLink {
                    RecordingVideoView(folderVM: folderVM)
                } label: {
                    Text("Novo Treino")
                }

                
//                NavigationLink("Criar treino") {
//                    let newTraining = TreinoModel(name: "\(folderVM.folder.nome) - Treino \(folderVM.folder.treinos.count + 1)")
//                    TreinoView(trainingVM: TreinoViewModel(treino: newTraining), folder: folderVM.folder)
//                }
                
                ForEach(folderVM.folder.treinos) { treino in
                    NavigationLink(treino.nome) {
                        TreinoView(trainingVM: TreinoViewModel(treino: treino))
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
