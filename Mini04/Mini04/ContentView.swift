//
//  ContentView.swift
//  Mini04
//
//  Created by Leonardo Mota on 15/03/24.
//

import SwiftUI


//    var body: some View {
//        NavigationSplitView {
//            List {
//                ForEach(items) { item in
//                    NavigationLink {
//                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
//                    } label: {
//                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
//                    }
//                }
//                .onDelete(perform: deleteItems)
//            }
//            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
//            .toolbar {
//                ToolbarItem {
//                    Button(action: addItem) {
//                        Label("Add Item", systemImage: "plus")
//                    }
//                }
//            }
//        } detail: {
//            Text("Select an item")
//        }
//    }
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



// MARK: - Pasta View
struct PastaView: View {
    @ObservedObject var folderVM: FoldersViewModel
    @State private var isModalPresented = true // Modal sempre será apresentado ao entrar na view

    var body: some View {
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
            
            Button("Criar treino") {
                let newTraining = TreinoModel(name: "\(folderVM.folder.nome) - Treino \(folderVM.folder.treinos.count + 1)")
                                folderVM.folder.treinos.append(newTraining)
            }
            ForEach(folderVM.folder.treinos) { treino in
                NavigationLink(destination: TreinoView(trainingVM: TreinoViewModel(treino: treino), folder: folderVM.folder)) {
                    Text(treino.nome)
                }
            }
            
        }
        .padding()
        .sheet(isPresented: $isModalPresented) {
            ModalView(isModalPresented: $isModalPresented)
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
