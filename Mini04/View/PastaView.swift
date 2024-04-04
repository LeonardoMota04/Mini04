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
    
    // EDITAR NOME DA PASTA
    @State private var editedName: String = ""
    @State private var isShowingModal = false
    
    @State private var selectedTrainingIndex: Int?
    @State var filteredTrainings: [TreinoModel] = []
    @State var offsetView1: CGFloat = -2000
    @State var offsetView2: CGFloat = 0
    @State var offsetView3: CGFloat = 2000
    
    var body: some View {
        NavigationStack {
            ZStack {
                // quando clicar no botao abre uma zstack sobre toda a pastaview, ou seja, a "modal"
                if isShowingModal {
                    ZStack(alignment: .top) {
                        //sombra
                        Color.black
                            .frame(maxHeight: .infinity)
                            .frame(width: 800)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .offset(y:25)
                            .blur(radius: 3)

                        TreinoView(folderVM: folderVM, trainingVM: TreinoViewModel(treino: selectedTraining!), isShowingModal: $isShowingModal)
                            .frame(maxHeight: .infinity)
                            .background(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .offset(y:25)
                    }
                    .zIndex(1)
                }
                
                
                
                VStack {
                    // infos da pasta
                    // NOME DA PASTA
                    HStack {
                        //TextField("Nome da pasta", text: $editedName)
                        Text(folderVM.folder.nome)
                            .font(.title)
                        Spacer()
                        Button("Salvar Alterações") {
                            saveChanges()
                        }
                    }
                    HStack {
                        HStack {
                            Image(systemName: "calendar")
                            Text("\(folderVM.folder.data)")
                        }
                        HStack {
                            Image(systemName: "video.badge.waveform.fill")
                            Text("\(folderVM.folder.treinos.count) Treinos")
                        }
                        HStack {
                            Image(systemName: "handbag.fill")
                            Text("Objetivo: \(folderVM.folder.objetivoApresentacao)")
                        }
                        Text("Tempo Desejado: \(folderVM.folder.tempoDesejado)")
                    }
                    HStack(alignment: .top){
                        ExpandableView(thumbnail: ThumbnailView(content: {
                            TimeFeedBackView(avaregeTime: folderVM.formatedAvareTime, wishTime: Double(folderVM.folder.tempoDesejado), treinos: folderVM.folder.treinos)
                        }), expanded: ExpandedView(content: {
                            TimeFeedBackViewExpand(avaregeTime: folderVM.formatedAvareTime, wishTime: Double(folderVM.folder.tempoDesejado), treinos: folderVM.folder.treinos)
                        }))
                        WordRepetitionView(folderVM: folderVM)
                        //                    ExpandableView(thumbnail: ThumbnailView(content: {
                        //                        TimeFeedBackView(avaregeTime: folderVM.formatedAvareTime, wishTime: Double(folderVM.folder.tempoDesejado), treinos: folderVM.folder.treinos)
                        //                    }), expanded: ExpandedView(content: {
                        //                        WordRepetitionView(folderVM: folderVM)
                        //                    }))
                    }
                    
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
                    // exibe todos os treinos
                    MyTrainingsView(folderVM: folderVM, filteredTrainings: $filteredTrainings, isShowingModal: $isShowingModal, selectedTrainingIndex: $selectedTrainingIndex)
                }
                .blur(radius: isShowingModal ? 3 : 0)
                .disabled(isShowingModal ? true : false)
                .onTapGesture {
                    if isShowingModal {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isShowingModal.toggle()
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear {
            folderVM.modelContext = modelContext
            do {
                try folderVM.modelContext?.save()
            } catch {
                print("Nao salvou")
            }
            //editedName = folderVM.folder.nome
            folderVM.calculateAvarageTime()
        }
        .onChange(of: folderVM.folder) { _, _ in
            // quando adicionar um novo treino atualiza o valor do tempo medio dos treinos
            folderVM.calculateAvarageTime()
            
            // quando trocar de pasta, passa de novo o contexto
            folderVM.modelContext = modelContext
        }
        .sheet(isPresented: $isModalPresented) {
            FolderInfoModalView(isModalPresented: $isModalPresented)
        }
    }
    // UPDATE Nome da pasta e seus treinos
    func saveChanges() {
        // Atualiza o nome da pasta
        //folderVM.folder.nome = editedName
        
        for training in folderVM.folder.treinos {
            if !training.changedTrainingName {
                if let index = folderVM.folder.treinos.firstIndex(where: { $0.id == training.id }) {
                    training.nome = "Treino \(index + 1)"
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
