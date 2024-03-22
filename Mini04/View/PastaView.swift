//
//  PastaView.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.
//

import SwiftUI
import SwiftData

struct PastaView: View {
    // VM
    @ObservedObject var folderVM: FoldersViewModel
    @State private var isModalPresented = true // Modal sempre será apresentado ao entrar na view
    
    // PERSISTENCIA
    @Environment(\.modelContext) private var modelContext
    @Query private var trainings: [TreinoModel] // read de treinos

    var body: some View {
        NavigationStack {
            VStack {
                // infos da pasta
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
                
                // exibe todos os treinos
//                ForEach(trainings) { training in
//                    // treinos + apagar
//                    HStack {
//                        NavigationLink(training.nome) {
//                            TreinoView(trainingVM: TreinoViewModel(treino: training))
//                        }
//                        Button("Apagar \(training.nome)") {
//                            folderVM.deleteTraining(training)
//                        }
//                    }
//                }
                Divider()
                ForEach(folderVM.folder.treinos) { training in
                    // treinos + apagar
                    HStack {
                        NavigationLink(training.nome) {
                            TreinoView(trainingVM: TreinoViewModel(treino: training))
                        }
                        Button("Apagar \(training.nome)") {
                            folderVM.deleteTraining(training)
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear {
            folderVM.modelContext = modelContext
        }
        .sheet(isPresented: $isModalPresented) {
            ModalView(isModalPresented: $isModalPresented)
        }
    }
}
//
//#Preview {
//    PastaView()
//}
