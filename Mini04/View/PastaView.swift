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
    
    var screenResChanged = NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)
    @State var oldScreenSize = NSSize.zero
    @State var currentScreenSize = NSSize.zero
    @State var hasSizeChanged = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack {
                    // quando clicar no botao abre uma zstack sobre toda a pastaview, ou seja, a "modal"
                    if isShowingModal {
                        HStack {
                            Spacer()
                            //botao de retornar uma view
                            Button {
                                withAnimation {
                                    if selectedTrainingIndex! < filteredTrainings.count - 1 {
                                        selectedTrainingIndex! += 1
                                    }
                                }
                            } label: {
                                Image(systemName: "chevron.backward.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                
                            }
                            .disabled(selectedTrainingIndex! == filteredTrainings.count - 1 ? true : false)
                            .buttonStyle(.plain)
                            .padding()
                            ZStack(alignment: .top) {
                                //sombra
                                //                                Color.black
                                //                                    .frame(maxHeight: .infinity)
                                //                                    .frame(width: 800)
                                //                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                //                                    .offset(y:25)
                                //                                    .blur(radius: 3)
                                
                                //                            if let selectedTrainingIndex = selectedTrainingIndex, selectedTrainingIndex < filteredTrainings.count - 1 {
                                TreinoView(folderVM: folderVM, trainingVM: TreinoViewModel(treino: filteredTrainings[selectedTrainingIndex!]), isShowingModal: $isShowingModal)
                                    .frame(maxHeight: .infinity)
                                    .frame(width: 958)
                                    .background(Color("light_LighterGray"))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .offset(y: 25)
                                    .offset(x: offsetView1)
                                    .zIndex(1)
                                    .onChange(of: selectedTrainingIndex) { oldValue, newValue in
                                        guard let previewsIndex = oldValue else { return }
                                        guard let afterIndex = newValue else { return }
                                        
                                        if previewsIndex < afterIndex {
                                            withAnimation(.easeInOut(duration: 0.5)) {
                                                offsetView1 = 0
                                            }
                                            // Aguarde um tempo para que a animação seja concluída
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                offsetView1 = -2000
                                            }
                                        }
                                        //
                                    }
                                TreinoView(folderVM: folderVM, trainingVM: TreinoViewModel(treino: filteredTrainings[selectedTrainingIndex!]), isShowingModal: $isShowingModal)
                                    .frame(maxHeight: .infinity)
                                    .frame(width: 958)
                                    .background(Color("light_LighterGray"))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .offset(y:25)
                                    .offset(x: offsetView2)
                                    .onChange(of: selectedTrainingIndex) { oldValue, newValue in
                                        guard let previewsIndex = oldValue else { return }
                                        guard let afterIndex = newValue else { return }
                                        if previewsIndex < afterIndex {
                                            
                                            withAnimation(.easeInOut(duration: 0.5)) {
                                                offsetView2 = 2000
                                            }
                                            
                                            // Aguarde um tempo para que a animação seja concluída
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                offsetView2 = 0
                                            }
                                        } else {
                                            withAnimation(.easeInOut(duration: 0.5)) {
                                                offsetView2 = -2000
                                            }
                                            
                                            // Aguarde um tempo para que a animação seja concluída
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                offsetView2 = 0
                                            }
                                        }
                                    }
                                //                            if let selectedTrainingIndex = selectedTrainingIndex, selectedTrainingIndex > 0 {
                                TreinoView(folderVM: folderVM, trainingVM: TreinoViewModel(treino: filteredTrainings[selectedTrainingIndex!]), isShowingModal: $isShowingModal)
                                    .frame(maxHeight: .infinity)
                                    .frame(width: 958)
                                    .background(Color("light_LighterGray"))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .offset(y: 25)
                                    .offset(x: offsetView3)
                                    .zIndex(1)
                                    .onChange(of: selectedTrainingIndex) { oldValue, newValue in
                                        guard let previewsIndex = oldValue else { return }
                                        guard let afterIndex = newValue else { return }
                                        
                                        if previewsIndex > afterIndex {
                                            withAnimation(.easeInOut(duration: 0.5)) {
                                                offsetView3 = 0
                                            }
                                            
                                            // Aguarde um tempo para que a animação seja concluída
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                offsetView3 = 2000
                                            }
                                        }
                                        //                                    }
                                    }
                            }
                            // botao de passar uma view
                            Button {
                                withAnimation {
                                    if selectedTrainingIndex! > 0 {
                                        selectedTrainingIndex! -= 1
                                    }
                                }
                            } label: {
                                Image(systemName: "chevron.right.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                            }
                            .buttonStyle(.plain)
                            .disabled(selectedTrainingIndex == 0  ? true : false)
                            .padding()
                            Spacer()
                        }
                        .zIndex(1)
                    }
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
                                // TODO: REAVALIAR ESSA LOGICA AQUI DA COESA NA *PASTA*
//                                if  (folderVM.folder.treinos.isEmpty || ((folderVM.folder.treinos.last?.feedback?.coherenceValues.isEmpty) != nil)) { //TODO: resolver essa logica na viewModel ou model - garatindo que nao vai crachar o app se o index nao existir
//                                    CohesionExtendView(fluidProgress: 0,
//                                                     organizationProgress: 0,
//                                                     connectionProgress: 0,
//                                                     widthFrame: geo.size.width, heightFrame: geo.size.height)
//                                } else {
//                                    CohesionExtendView(fluidProgress: folderVM.folder.treinos.last?.feedback?.coherenceValues[0] ?? 1,
//                                                       organizationProgress: folderVM.folder.treinos.last?.feedback?.coherenceValues[1] ?? 1,
//                                                       connectionProgress:  folderVM.folder.treinos.last?.feedback?.coherenceValues[2] ?? 1,
//                                                     widthFrame: geo.size.width, heightFrame: geo.size.height)
//                                }
                                CohesionExtendView(fluidProgress: folderVM.avaregeCohesionFeedback().fluid,
                                                   organizationProgress: folderVM.avaregeCohesionFeedback().organization,
                                                                  connectionProgress: folderVM.avaregeCohesionFeedback().conection,
                                                                  widthFrame: geo.size.width, heightFrame: geo.size.height)
                                ObjectiveApresentationView(allImages: folderVM.setObjetiveApresentation(objetiveApresentation: "Pitch").images, allObjText: folderVM.setObjetiveApresentation(objetiveApresentation:"Pitch").phrases, widthFrame: geo.size.width, heightFrame:  geo.size.height)
                            }
                            .padding(.top, geo.size.height * 0.1423 + 5) // padding para organizar os elementos pois estao em cima um do outro
                            HStack(alignment: .top){
                                AvaregeTimeFeedbackView(avaregeTime: folderVM.formatedAvareTime, wishTimeText: folderVM.folder.formattedGoalTime(), wishTime: folderVM.folder.tempoDesejado, treinos: folderVM.sortTreinos(), widthFrame: geo.size.width, heightFrame: geo.size.height)
                                WordRepetitionView(folderVM: folderVM, widthFrame: geo.size.width, heightFrame: geo.size.height)
                                ImproveApresentationView(widthFrame: geo.size.width, heightFrame: geo.size.height)
                            }
                        }
                        .padding(EdgeInsets(top: 40, leading: 0, bottom: 55, trailing: 0))
                        // MARK: FeedBacks -
                        
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
                    }
                    .padding(.horizontal, 55)
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
            .sheet(isPresented: $isModalPresented) {
                FolderInfoModalView(isModalPresented: $isModalPresented)
            }
            .toolbar() {
                ToolbarItem() {
                    Menu {
                        Button {
                            
                        } label: {
                            Text("Editar Apresentação")
                        }
                        Button {
                            
                        } label: {
                            Text("Excluir Apresentação")
                        }
                        Divider()
                        // ABRIR PARA COMEÇAR A GRAVAR UM TREINO PASSANDO A PASTA QUE ESTAMOS
                        Button {
                           
                        } label: {
                            Text("Adicionar novo treino")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                    }
                }
            }
            //editedName = folderVM.folder.nome
        //    folderVM.calculateAvarageTime() // TODO: arrumar isso e ver isso
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
