//
//  ContentView.swift
//  Mini04
//
//  Created by Leonardo Mota on 15/03/24.
//

import SwiftUI

// MARK: - CONTENT VIEW
struct ContentView: View {
    // VM
    @StateObject private var presentationVM = ApresentacaoViewModel(apresentacao: ApresentacaoModel())
    @State private var folderViewModels: [UUID: FoldersViewModel] = [:]

    // VARIAVEIS
    @State var pastaName: String = ""
    @State var tempoDesejado: Int = 0
    @State var objetivo: String = ""
    let tempos = [5,10,15]
        
    var body: some View {
        NavigationStack {

            VStack {
                TextField(text: $pastaName) {
                    Text("Nome da pasta")
                }
                Picker("selecione", selection: $tempoDesejado) {
                    ForEach(tempos, id: \.self) { tempo in
                        Text(String(tempo))
                    }
                }

                TextField(text: $objetivo) {
                    Text("Objetivo")
                }
            }
            .padding()
            
            Button("Criar pasta") {
                let newFolder = PastaModel(nome: pastaName,
                                       tempoDesejado: tempoDesejado,
                                       objetivoApresentacao: objetivo)
                presentationVM.apresentacao.folders.append(newFolder)
                folderViewModels[newFolder.id] = FoldersViewModel(folder: newFolder)
            }
           
            List(presentationVM.apresentacao.folders) { folder in
                NavigationLink(folder.nome) {
                    PastaView(folderVM: folderViewModels[folder.id]!)
                }
            }
           
        }
    }
}

// MARK: - Pasta View
struct PastaView: View {
    @ObservedObject var folderVM: FoldersViewModel
    
    var body: some View {
        VStack {
            Text("NOME: \(folderVM.folder.nome)")
            Text("data: \(folderVM.folder.data)")
            Text("tempoDesejado: \(folderVM.folder.tempoDesejado)")
            Text("objetivo: \(folderVM.folder.objetivoApresentacao)")
            
            Button("Criar treino") {
                let newTraining = TreinoModel(name: folderVM.folder.nome)
                folderVM.folder.treinos.append(newTraining)
            }
            
            ForEach(folderVM.folder.treinos) { treino in
                NavigationLink {
                    TreinoView(trainingVM: TreinoViewModel(treino: treino), folder: folderVM.folder)
                } label: {
                    Text(treino.nome)
                }
            }
        }
    }
}

// MARK: - Treino View
struct TreinoView: View {
    @ObservedObject var trainingVM: TreinoViewModel
    var folder: PastaModel
    
    var body: some View {
        VStack {
            Text("Pertenço à pasta: \(folder.nome)")
            Text("NOME: \(trainingVM.treino.nome)")
            Text("Data: \(trainingVM.treino.data)")
        }
    }
}




#Preview {
    ContentView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
