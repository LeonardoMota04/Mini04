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
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        } detail: {
            // MESMA COISA AQUI
        }
        .onAppear {
            presentationVM.modelContext = modelContext
            presentationVM.fetchFolders()
        }
        .sheet(isPresented: $isModalPresented) {
            CreatingFolderModalView(presentationVM: presentationVM,
                                    isModalPresented: $isModalPresented)
        }
    }
}


// MARK: - MODAL DE CRIAR PASTA
struct CreatingFolderModalView: View {
    // CRIAR PASTA (modularizar)
    @ObservedObject var presentationVM: ApresentacaoViewModel
    @State var pastaName: String = ""
    @State var tempoDesejado: Int = 1
    @State var objetivo: String = ""
    @Binding var isModalPresented: Bool
    let tempos = [5,10,15]
    
    var body: some View {
        VStack {
            TextField("Nome da pasta", text: $pastaName)
                .padding()
            Picker("Selecione o tempo desejado", selection: $tempoDesejado) {
                ForEach(tempos, id: \.self) { tempo in
                    Text(String(tempo))
                }
            }
            .padding()
            Picker("Selecione o objetivo da pasta", selection: $objetivo) {
                ForEach(ObjectiveApresentation.allCases, id: \.self) { objective in
                    Text(String(describing: objective))
                }
            }
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

#Preview {
    ContentView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
