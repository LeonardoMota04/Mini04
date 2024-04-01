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
                HStack {
                    HStack {
                        Image(systemName: "calendar")
                        Text("\(folderVM.folder.data.formatted())")
                        Text("|")
                    }
                    HStack {
                        Image(systemName: "video.badge.waveform.fill")
                        Text("\(folderVM.folder.treinos.count) Treinos")
                        Text("|")
                    }
                    HStack {
                        Image(systemName: "handbag.fill")
                        Text("Objetivo: \(folderVM.folder.objetivoApresentacao)")
                        
                    }
                    Text("Tempo Desejado: \(folderVM.folder.tempoDesejado)")
                }
//                ZStack {
//                    RoundedRectangle(cornerRadius: 16)
//                        .frame(width: 350, height: 140)
//                    HStack{
//                        VStack(alignment: .leading) {
//                            Text("\(folderVM.folder.avaregeTime)")
//                                .font(.title2)
//                                .bold()
//                                .foregroundStyle(.black)
//                            Text("Tempo médio próximo do desejado. ")
//                                .multilineTextAlignment(.leading)
//                                .frame(maxWidth: 135)
//                                .foregroundStyle(.black)
//                            Spacer()
//                        }
//                        Spacer()
//                        VStack(alignment: .leading) {
//                            Text("Tempo desejado - \(folderVM.folder.tempoDesejado)")
//                            HStack {
//                                ForEach(folderVM.folder.treinos.suffix(8)) { treino in // sufix 8 para mostrar os ultimos 8 treinos
//                                    VStack {
//                                        ZStack(alignment: .bottom) {
//                                            RoundedRectangle(cornerRadius: 10)
//                                                .frame(width: 10, height: 54)
//                                            RoundedRectangle(cornerRadius: 10)
//                                                .frame(width: 10, height: Double(treino.video?.videoTime ?? 0) > Double(folderVM.folder.tempoDesejado) ? 54 :  folderVM.calculateTreinoTime(videoTime: treino.video?.videoTime ?? 1))
//                                                .foregroundStyle(Double(treino.video?.videoTime ?? 0) > Double(folderVM.folder.tempoDesejado) ? .red : .blue)
//                                            
//                                        }
//                                        Text("T\(folderVM.folder.treinos.count + 1)")
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
                HStack(alignment: .top) {
                    ExpandableView(thumbnail: ThumbnailView(content: {
                        TimeFeedBackView(avaregeTime: folderVM.formatedAvareTime, wishTime: Double(folderVM.folder.tempoDesejado), treinos: folderVM.folder.treinos)
                            .frame(maxWidth: .infinity)
                            .frame(height: 135)
                    }), expanded: ExpandedView(content: {
                        TimeFeedBackViewExpand(avaregeTime: folderVM.formatedAvareTime, wishTime: Double(folderVM.folder.tempoDesejado), treinos: folderVM.folder.treinos)
                            .frame(maxWidth: .infinity)
                            .frame(height: 280)
                    }))
                    ExpandableView(thumbnail: ThumbnailView(content: {
                        TimeFeedBackView(avaregeTime: folderVM.formatedAvareTime, wishTime: Double(folderVM.folder.tempoDesejado), treinos: folderVM.folder.treinos)
                            .frame(maxWidth: .infinity)
                            .frame(height: 135)
                    }), expanded: ExpandedView(content: {
                        TimeFeedBackViewExpand(avaregeTime: folderVM.formatedAvareTime, wishTime: Double(folderVM.folder.tempoDesejado), treinos: folderVM.folder.treinos)
                            .frame(maxWidth: .infinity)
                            .frame(height: 280)
                    }))
                    ExpandableView(thumbnail: ThumbnailView(content: {
                        TimeFeedBackView(avaregeTime: folderVM.formatedAvareTime, wishTime: Double(folderVM.folder.tempoDesejado), treinos: folderVM.folder.treinos)
                            .frame(maxWidth: .infinity)
                            .frame(height: 135)
                    }), expanded: ExpandedView(content: {
                        TimeFeedBackViewExpand(avaregeTime: folderVM.formatedAvareTime, wishTime: Double(folderVM.folder.tempoDesejado), treinos: folderVM.folder.treinos)
                            .frame(maxWidth: .infinity)
                            .frame(height: 280)
                    }))
                }
                HStack {
                    ObjetiveFeedBackView()
                        .frame(minWidth: 300, maxWidth: 400)
                        .frame(height: 135)
                        Spacer()
                }
                Spacer()
                if folderVM.folder.treinos.isEmpty {
                    Text("Adicione um treino para começar")
                }
                Spacer()
                // ScrollView dos treinos
                VStack {
                    ScrollView() {
                        ForEach(folderVM.folder.treinos) { treino in
                            TreinoVisualComponent(treinoName: treino.nome, treinoDate: "MUDAR", treinoDuration: "06:66")
                            
                        }
                    }
                }
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
            folderVM.calculateAvarageTime()
        }
        .onChange(of: folderVM.folder) {
            // quando adicionar um novo treino atualiza o valor do tempo medio dos treinos
            folderVM.calculateAvarageTime()
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


#Preview{
    PastaView(folderVM: FoldersViewModel(folder: PastaModel(nome: "Euu", tempoDesejado: 10, objetivoApresentacao: "pitch")))
}
    
