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
    
    // EDITAR NOME DA PASTA
    @State private var editedName: String = ""

    var body: some View {
        NavigationStack {
            VStack {
                // infos da pasta
                // NOME DA PASTA
                HStack {
                    TextField("Nome da pasta", text: $editedName)
                        .font(.title)
                    Spacer()
                    Button("Salvar Alterações") {
                        saveChanges()
                    }
                }
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
                            TreinoView(folderVM: folderVM, trainingVM: TreinoViewModel(treino: training))
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
            editedName = folderVM.folder.nome
        }
        .sheet(isPresented: $isModalPresented) {
            FolderInfoModalView(isModalPresented: $isModalPresented)
        }
    }
    // UPDATE Nome da pasta e seus treinos
    func saveChanges() {
        // Atualiza o nome da pasta
        folderVM.folder.nome = editedName
        
        for training in folderVM.folder.treinos {
            if !training.changedTrainingName {
                if let index = folderVM.folder.treinos.firstIndex(where: { $0.id == training.id }) {
                    training.nome = "\(editedName) - Treino \(index + 1)"
                }
            }
            
        }
    }

}

// MARK: - MODAL DE INFORMACOES
struct FolderInfoModalView: View {
    @Binding var isModalPresented: Bool
    var body: some View {
        VStack {
            Text("Instruções:")
                .font(.title)
                .padding()

            Text("pipipipi")
                .padding()

            Button("Fechar") {
                isModalPresented = false
            }
            .padding()
        }
    }
}
