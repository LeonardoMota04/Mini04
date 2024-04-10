//
//  PastaView.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.
//

import SwiftUI
import SwiftData

struct PastaView: View {
    @Environment(\.dismiss) private var dismiss
    
    // VM
    @ObservedObject var folderVM: FoldersViewModel
    
    // PERSISTENCIA
    @Environment(\.modelContext) private var modelContext
    
    // EDITAR NOME DA PASTA
    @State private var editedName: String = ""
    
    @State private var isShowingEditingModal = false
    
    // DELETAR PASTA
    // SABER QUAL PASTA ESTAMOS
    @Binding var selectedFolderID: UUID?
    // ALERTA DE DELETAR
    @State private var isShowingAlert = false
    
    @Binding var isShowingModal: Bool
    @Binding var selectedTrainingIndex: Int?
    @Binding var filteredTrainings: [TreinoModel]
    
    var screenResChanged = NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)
    @State var oldScreenSize = NSSize.zero
    @State var currentScreenSize = NSSize.zero
    @State var hasSizeChanged = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                VStack(alignment:.leading) {
                    // infos da pasta
                    // NOME DA PASTA
                    HStack(alignment: .bottom) {
                        //TextField("Nome da pasta", text: $editedName)
                        Text(folderVM.folder.nome)
                            .font(.title)
                            .bold()
                        Spacer()
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                            Text(folderVM.formatterDate(date: folderVM.folder.dateOfPresentation))
                                .font(.title3)
                            Text("|")
                                .font(.title2)
                            Image(systemName: "video.badge.waveform.fill")
                            Text("\(folderVM.folder.treinos.count) Treinos")
                                .font(.title3)
                            Text("|")
                                .font(.title2)
                            Image(systemName: "handbag.fill")
                            Text("Objetivo: \(folderVM.folder.objetivoApresentacao)")
                                .font(.title3)
                            //                                Button("Salvar Alterações") {
                            //                                    saveChanges()
                            //                                }
                        }
                        .padding(.trailing, 20)
                    }
                    //MARK: FeedBacks -
                    // Colocando os elemebtos de baixo orimeiro na Stack apra que ele consigam ser sobrepostos
                    ZStack(alignment: .topLeading) {
                        MyTrainingsView(folderVM: folderVM, filteredTrainings: $filteredTrainings, isShowingModal: $isShowingModal, selectedTrainingIndex: $selectedTrainingIndex)
                            .padding(.top, geo.size.height * 0.35706)
                        HStack(alignment: .top){
                            Color(.clear) // colocando algo tranparente para ficar ao lado da AvaregeTimeFeedBackView
                                .frame(maxWidth: geo.size.width * 0.21, maxHeight: 10)
                            CohesionExtendView(fluidProgress: folderVM.avaregeCohesionFeedback().fluid,
                                               organizationProgress: folderVM.avaregeCohesionFeedback().organization,
                                               connectionProgress: folderVM.avaregeCohesionFeedback().conection,
                                               widthFrame: geo.size.width, heightFrame: geo.size.height)
                            ObjectiveApresentationView(allImages: folderVM.setObjetiveApresentation(objetiveApresentation: folderVM.folder.objetivoApresentacao).images, allObjText: folderVM.setObjetiveApresentation(objetiveApresentation: folderVM.folder.objetivoApresentacao).phrases, widthFrame: geo.size.width, heightFrame: geo.size.height)
                        }
                        .padding(.top, geo.size.height * 0.1423 + 7) // padding para organizar os elementos pois estao em cima um do outro
                        HStack(alignment: .top){
                            AvaregeTimeFeedbackView(avaregeTime: folderVM.formatedAvareTime, wishTimeText: folderVM.folder.formattedGoalTime(), wishTime: folderVM.folder.tempoDesejado, treinos: folderVM.folder.treinos, widthFrame: geo.size.width, heightFrame: geo.size.height)
                            WordRepetitionView(folderVM: folderVM, widthFrame: geo.size.width, heightFrame: geo.size.height)
                            ImproveApresentationView(widthFrame: geo.size.width, heightFrame: geo.size.height)
                        }
                    }
                    .padding(EdgeInsets(top: 40, leading: 0, bottom: 0, trailing: 0))
                    
                    
                    HStack {
                        Spacer()
                        if folderVM.folder.treinos.isEmpty {
                            ContentUnavailableView("Adicione um treino para começar", systemImage: "folder.fill.badge.questionmark")
                                .padding(.bottom, 80)
                        }
                        Spacer()
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 55)
                .blur(radius: isShowingModal ? 3 : 0)
                .disabled(isShowingModal ? true : false)
                .onTapGesture {
                    if isShowingModal || isShowingEditingModal {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isShowingModal = false
                            isShowingEditingModal = false
                        }
                    }
                }
            }
            .padding()
            
            .sheet(isPresented: $isShowingEditingModal) {
                EditingFolderModalView(folderVM: folderVM, isModalPresented: $isShowingEditingModal)
            }
            .alert("Você tem certeza?", isPresented: $isShowingAlert) {
                Button("Cancelar", role: .cancel) { isShowingAlert = false }
                Button("Deletar", role: .destructive) {
                    // deletar treino
                    selectedFolderID = nil
                }
            } message: {
                Text("Essa Apresentação (incluindo os treinos e os feedbacks) será permanentemente excluída.")
            }
            
            .toolbar() {
                ToolbarItem() {
                    Menu {
                        Button { isShowingEditingModal = true } label: { Text("Editar Apresentação") }
                        Button { isShowingAlert = true } label: { Text("Excluir Apresentação") }
                        Divider()
                        // ABRIR PARA COMEÇAR A GRAVAR UM TREINO PASSANDO A PASTA QUE ESTAMOS
                        NavigationLink { RecordingVideoView(folderVM: folderVM) } label: { Text("Adicionar novo treino") }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                    }
                    .menuIndicator(.hidden)
                }
            }
            
            
            .onChange(of: selectedFolderID) { _, newValue in
                if newValue == nil {
                    dismiss()
                }
            }
            .onAppear {
                selectedFolderID = folderVM.folder.id
                
                // resizeble
                currentScreenSize = (NSScreen.main?.visibleFrame.size)!
                oldScreenSize = currentScreenSize
                folderVM.modelContext = modelContext
                
                do {
                    try folderVM.modelContext?.save()
                } catch {
                    print("Nao salvou")
                }
                //editedName = folderVM.folder.nome
                folderVM.calculateAvarageTime()
            }
            .onChange(of: folderVM.folder) {
                // quando adicionar um novo treino atualiza o valor do tempo medio dos treinos
                folderVM.calculateAvarageTime()
            }.onReceive(screenResChanged, perform: { newValue in
                //the screensize has changed.
                // newValue contains userInfo. Incase you want to do anything with it
                let tempScreenSize = NSScreen.main?.visibleFrame.size
                if (tempScreenSize != oldScreenSize){
                    hasSizeChanged = true
                    currentScreenSize = tempScreenSize ?? NSSize.zero
                }
            })
        }
        .background(Color.lightLighterGray)
        .onChange(of: folderVM.folder) { _, _ in
            // quando adicionar um novo treino atualiza o valor do tempo medio dos treinos
            folderVM.calculateAvarageTime()
            
            // quando trocar de pasta, passa de novo o contexto
            folderVM.modelContext = modelContext
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


