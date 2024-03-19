//
//  ContentView.swift
//  Mini04
//
//  Created by Leonardo Mota on 15/03/24.
//

import SwiftUI

// MARK: - CONTENT VIEW
struct ContentView: View {
    @StateObject private var presentationVM = ApresentacaoViewModel(apresentacao: ApresentacaoModel())
    @State private var isModalPresented = false
    @State private var folderViewModels: [UUID: FoldersViewModel] = [:]
    
    @State var pastaName: String = ""
    @State var tempoDesejado: Int = 0
    @State var objetivo: String = ""
    let tempos = [5,10,15]
    var body: some View {

        NavigationSplitView {
            NavigationLink("Minhas Apresentações") {
                // MESMA COISA AQUI
                if presentationVM.apresentacao.folders.isEmpty {
                    Text("Adicione uma apresentação para começar")
                        .padding()
                    Button("Criar pasta") {
                        isModalPresented.toggle()
                    }
                } else {
                    Button("Criar pasta") {
                        isModalPresented.toggle()
                    }
                    List {
                        ForEach(presentationVM.apresentacao.folders) { folder in
                            NavigationLink(folder.nome) {
                                PastaView(folderVM: folderViewModels[folder.id]!)
                            }
                        }
                    }
                }
                
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            
        } detail: {
            // MESMA COISA AQUI
            if presentationVM.apresentacao.folders.isEmpty {
                Text("Adicione uma apresentação para começar")
                    .padding()
                Button("Criar pasta") {
                    isModalPresented.toggle()
                }
            } else {
                List {
                    ForEach(presentationVM.apresentacao.folders) { folder in
                        NavigationLink(folder.nome) {
                            PastaView(folderVM: folderViewModels[folder.id]!)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isModalPresented) {
            VStack {
                TextField("Nome da pasta", text: $pastaName)
                    .padding()
                Picker("Selecione o tempo desejado", selection: $tempoDesejado) {
                    ForEach(tempos, id: \.self) { tempo in
                        Text(String(tempo))
                    }
                }
                .padding()
                TextField("Objetivo", text: $objetivo)
                    .padding()
                Spacer()
                Button("Criar pasta") {
                    let newFolder = PastaModel(nome: pastaName,
                                               tempoDesejado: tempoDesejado,
                                               objetivoApresentacao: objetivo)
                    presentationVM.apresentacao.folders.append(newFolder)
                    folderViewModels[newFolder.id] = FoldersViewModel(folder: newFolder)
                    isModalPresented.toggle()
                }
                .padding()
            }
            .toolbar {
                ToolbarItem {
                    Button("Cancelar") {
                        isModalPresented.toggle()
                    }
                }
            }
            
        }
    }
}


struct ModalView: View {
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


#Preview {
    ContentView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
