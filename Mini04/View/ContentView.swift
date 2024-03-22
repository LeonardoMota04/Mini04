//
//  ContentView.swift
//  Mini04
//
//  Created by Leonardo Mota on 15/03/24.
//

import SwiftUI
import SwiftData

// MARK: - CONTENT VIEW
struct ContentView: View {
    // VM
    @StateObject private var presentationVM = ApresentacaoViewModel()
    @State private var isModalPresented = false
    
    // PERSISTENCIA
    @Environment(\.modelContext) private var modelContext
    @Query var folders: [PastaModel]
    
    // CRIAR PASTA (modularizar)
    @State var pastaName: String = ""
    @State var tempoDesejado: Int = 0
    @State var objetivo: String = ""
    let tempos = [5,10,15]
    
    var body: some View {

        NavigationSplitView {
            NavigationLink("Minhas Apresentações") {
                // MESMA COISA AQUI
                if presentationVM.apresentacao.folders.isEmpty {
                    ContentUnavailableView("Adicione sua primeira pasta.", systemImage: "folder.badge.questionmark")
                    Button("Criar pasta") {
                        isModalPresented.toggle()
                    }
                } else {
                    Button("Criar pasta") {
                        isModalPresented.toggle()
                    }
                    List {
//                        ForEach(presentationVM.apresentacao.folders.indices, id: \.self) { index in
//                            NavigationLink(presentationVM.apresentacao.folders[index].nome) {
//                                PastaView(folderVM: FoldersViewModel(folder: presentationVM.apresentacao.folders[index]))
//                            }
//                        }
//                        ForEach(presentationVM.apresentacao.folders) { folder in
//                            NavigationLink(folder.nome) {
//                                if let folderVM = presentationVM.foldersViewModels[folder.id] {
//                                    PastaView(folderVM: folderVM)
//                                } else {
//                                    // Caso a instância de FoldersViewModel para a pasta não exista
//                                    Text("ViewModel não encontrada para esta pasta")
//                                }
//                            }
//                        }

                        Divider()
                        // exibir todas as pastas
                        ForEach(folders) { folder in
                            // pastas + apagar
                            HStack {
                                NavigationLink(folder.nome) {
                                    if let folderVM = presentationVM.foldersViewModels[folder.id] {
                                        PastaView(folderVM: folderVM)
                                    } else {
                                        Text("ViewModel não encontrada para esta pasta")
                                    }
                                }
                                Button("Apagar \(folder.nome)") {
                                    presentationVM.deleteFolder(folder)
                                }
                            }
                        }
//                        ForEach(presentationVM.apresentacao.folders) { folder in
//                            NavigationLink(folder.nome) {
//                                PastaView(folderVM: presentationVM.foldersViewModels[folder.id]!)
//                            }
//                        }
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            
        } detail: {
//            // MESMA COISA AQUI
//            if presentationVM.apresentacao.folders.isEmpty {
//                ContentUnavailableView("Adicione sua primeira pasta.", systemImage: "folder.badge.questionmark")
//                Button("Criar pasta") {
//                    isModalPresented.toggle()
//                }
//            } else {
//                List {
////                    ForEach(presentationVM.apresentacao.folders) { folder in
////                        NavigationLink(folder.nome) {
////                            //PastaView(folderVM: presentationVM.foldersViewModel)
////                            PastaView(folderVM: FoldersViewModel(folder: folder))
////
////                        }
////                    }
//                    ForEach(folders) { folder in
//                        NavigationLink(folder.nome) {
//                            PastaView(folderVM: FoldersViewModel(folder: folder))
//                            //PastaView(folderVM: presentationVM.foldersViewModels[folder.id]!)
//                        }
//                    }
//                }
//            }
        }
        .onAppear {
            presentationVM.modelContext = modelContext
            presentationVM.fetchFolders()
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
                    presentationVM.createNewFolder(name: pastaName, pretendedTime: tempoDesejado, presentationGoal: objetivo)
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

//extension ContentView {
//    @Observable
//    class
//}

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
