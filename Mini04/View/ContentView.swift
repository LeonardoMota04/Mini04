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
    @EnvironmentObject private var camVM: CameraViewModel
    @StateObject private var searchVM = SearchViewModel() // Gerenciar a searchbar
    @StateObject private var presentationVM = ApresentacaoViewModel()
    @State private var isModalPresented = false
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var overText: UUID? = nil
    @State private var backgroundHighlitedFolder: UUID? = nil
    @State var disableTextfield = false
    @State private var columnVisibility = NavigationSplitViewVisibility.automatic

    @State var isShowingModal = false
    @State var selectedTrainingIndex: Int?
    @State var filteredTrainings: [TreinoModel] = []
    @State var apresentacaoreference: FoldersViewModel?
    @State var offsetView1: CGFloat = -2000
    @State var offsetView2: CGFloat = 0
    @State var offsetView3: CGFloat = 2000

    // PERSISTENCIA
    @Environment(\.modelContext) private var modelContext
    @Query var folders: [PastaModel]
    
    var body: some View {
        ZStack {
//             quando clicar no botao abre uma zstack sobre toda a pastaview, ou seja, a "modal"
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
//                                sombra
                                Color.black
                                    .frame(maxHeight: .infinity)
                                    .frame(width: 958)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .offset(y: 25)
                                    .offset(x: offsetView1)
                                    .zIndex(0)
                                    .blur(radius: 3)
                                    .opacity(0.6)
                                
                                TreinoView(folderVM: apresentacaoreference!, trainingVM: TreinoViewModel(treino: filteredTrainings[selectedTrainingIndex!]), isShowingModal: $isShowingModal)
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
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                offsetView1 = -2000
                                            }
                                        }
                                    }
                                Color.black
                                    .frame(maxHeight: .infinity)
                                    .frame(width: 958)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .offset(y: 25)
                                    .offset(x: offsetView2)
                                    .zIndex(0)
                                    .blur(radius: 3)
                                    .opacity(0.6)

                                TreinoView(folderVM: apresentacaoreference!, trainingVM: TreinoViewModel(treino: filteredTrainings[selectedTrainingIndex!]), isShowingModal: $isShowingModal)
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
                                Color.black
                                    .frame(maxHeight: .infinity)
                                    .frame(width: 958)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .offset(y: 25)
                                    .offset(x: offsetView3)
                                    .zIndex(0)
                                    .blur(radius: 3)
                                    .opacity(0.6)
                                TreinoView(folderVM: apresentacaoreference!, trainingVM: TreinoViewModel(treino: filteredTrainings[selectedTrainingIndex!]), isShowingModal: $isShowingModal)
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
            
            
            
            NavigationSplitView (columnVisibility: $columnVisibility){
                VStack {
                    //titulo principal
                    HStack {
                        Text("Minhas Apresentações")
                            .foregroundStyle(.black)
                            .font(.title)
                            .bold()
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    
                    //searchbar
                    HStack {
                        SearchBar(searchText: $searchText, isSearching: $isSearching, disableTextfield: $disableTextfield)
                        //roda a funcao que buscar os folders filtrados toda vez ue textfiled muda de valor
                            .onChange(of: searchText) { oldValue, newValue in
                                searchVM.searchFolders(allFolders: folders, searchText: searchText)
                            }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    
                    
                    //se estiver pesquisando aparece outro foraeach
                    if isSearching {
                        // se nao tiver vazio roda isso, se nao um texto "nenhum resultado"
                        if !searchVM.filteredFolders.isEmpty {
                            ScrollView {
                                ForEach(searchVM.filteredFolders) { folder in
                                    NavigationLink {
                                        if let folderVM = presentationVM.foldersViewModels[folder.id] {
                                            PastaView(folderVM: folderVM, isShowingModal: $isShowingModal, selectedTrainingIndex: $selectedTrainingIndex, filteredTrainings: $filteredTrainings)
                                                .onAppear(perform: {
                                                    apresentacaoreference = folderVM
                                                })

                                        } else {
                                            Text("ViewModel não encontrada para esta pasta")
                                        }
                                    } label: {
                                        SiderbarFolderComponent(foldersDate: folder.data, foldersName: folder.nome, foldersTrainingAmount: folder.treinos.count, foldersObjetiveTime: folder.tempoDesejado, foldersType: folder.objetivoApresentacao, backgroundHighlited: .constant(backgroundHighlitedFolder == folder.id))
                                            .onHover { hovering in
                                                overText = hovering ? folder.id : nil
                                                backgroundHighlitedFolder = hovering ? folder.id : nil
                                            }
                                            .contextMenu {
                                                Button {
                                                    print("menu apertado")
                                                } label: {
                                                    Text("oiiii")
                                                }
                                            }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        } else {
                            Text("Nenhum Resultado")
                                .font(.title2)
                                .bold()
                        }
                    } else {
                        //lista principal
                        if !folders.isEmpty {
                            ScrollView {
                                ForEach(folders) { folder in
                                    NavigationLink {
                                        if let folderVM = presentationVM.foldersViewModels[folder.id] {
                                            PastaView(folderVM: folderVM, isShowingModal: $isShowingModal, selectedTrainingIndex: $selectedTrainingIndex, filteredTrainings: $filteredTrainings)
                                                .onAppear(perform: {
                                                    apresentacaoreference = folderVM
                                                })
                                        } else {
                                            Text("ViewModel não encontrada para esta pasta")
                                        }
                                    } label: {
                                        SiderbarFolderComponent(foldersDate: folder.data, foldersName: folder.nome, foldersTrainingAmount: folder.treinos.count, foldersObjetiveTime: folder.tempoDesejado, foldersType: folder.objetivoApresentacao, backgroundHighlited: .constant(backgroundHighlitedFolder == folder.id))
                                            .onHover { hovering in
                                                overText = hovering ? folder.id : nil
                                                backgroundHighlitedFolder = hovering ? folder.id : nil
                                            }
                                            .contextMenu {
                                                Group {
                                                    Button {
                                                        withAnimation {
                                                            presentationVM.deleteFolder(folder)
                                                        }
                                                    } label: {
                                                        Text("Apagar")
                                                    }
                                                    Button {
                                                        print("menu apertado")
                                                    } label: {
                                                        Text("Editar")
                                                    }
                                                    Divider()
                                                    Button {
                                                        print("menu apertado")
                                                    } label: {
                                                        Text("Selecionar")
                                                    }
                                                }
                                            }
                                        
                                    }
                                    .buttonStyle(.plain)
                                    
                                }
                            }
                        } else {
                            Text("Nenhuma Apresentação")
                                .font(.title2)
                                .bold()
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        isModalPresented.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                                .foregroundStyle(.black)
                            Text("Nova apresentação")
                                .foregroundStyle(.black)
                        }
                        .padding(.horizontal, 40)
                        .padding(.vertical, 10)
                        .background(.white)
                        .containerShape(RoundedRectangle(cornerRadius: 10))
                        
                        
                    }
                    .buttonStyle(.plain)
                    
                }
                //remove aquela parada de fechar a searchbar
                .toolbar(removing: .sidebarToggle)
                .navigationSplitViewColumnWidth(min: 300, ideal: 300, max: 300)
                //remove aquele contorno azul quando esta usando algum elemento interagível
                .focusable(false)
                .background(.secondary)
                //minha intencao era quando clicar em qualquer lugar que nao seja o textfield desativa ele, mas nao funcionou e vou deixar aqui
                .onTapGesture {
                    if !isSearching {
                        disableTextfield = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            disableTextfield = false
                        }
                    }
                }
                .navigationSplitViewStyle(.balanced)
                .blur(radius: isShowingModal ? 3 : 0)
                .disabled(isShowingModal ? true : false)
                .onTapGesture {
                    if isShowingModal {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isShowingModal.toggle()
                        }
                    }
                }
            } detail: {
                
            }
        }
        //abrir a sidebar sempre
        //https://stackoverflow.com/questions/77794673/disable-collapsing-sidebar-navigationsplitview
        .onChange(of: camVM.cameraGravando, { oldValue, newValue in
                //                camVM.previewLayer.session?.isRunning
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if newValue {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        
                        columnVisibility = .detailOnly
                    }
                } else {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        
                        columnVisibility = .all
                    }
                }
            }
        })
        .onChange(of: columnVisibility, initial: true) { oldVal, newVal in
            DispatchQueue.main.async {
                if newVal == .detailOnly && !camVM.cameraGravando{
                        withAnimation(.easeInOut(duration: 0.2)) {
                            columnVisibility = .all
                    }
                }
            }
        }

        .onAppear {
            presentationVM.modelContext = modelContext
            presentationVM.fetchFolders()
        }
        .sheet(isPresented: $isModalPresented, content: {
            CreatingFolderModalView(presentationVM: presentationVM, isModalPresented: $isModalPresented)
        })
        .environmentObject(searchVM)
    }
    
}

// MARK: - ViewModel para Pesquisa
class SearchViewModel: ObservableObject {
    @Published var filteredFolders: [PastaModel] = []
    
    // Função para realizar a pesquisa e atualizar a lista filtrada
    func searchFolders(allFolders: [PastaModel], searchText: String) {
        filteredFolders = allFolders.filter { folder in
            searchText.isEmpty || folder.nome.localizedCaseInsensitiveContains(searchText)
        }
    }
}

struct SearchBar: View {
    @Binding var searchText: String
    
    @Binding var isSearching: Bool
    @Binding var disableTextfield: Bool

    var body: some View {
        ZStack {
            HStack {
                Image(systemName: "magnifyingglass")
//                    .foregroundStyle(.gray)
                    .foregroundStyle(.gray)

                    .padding(.leading, 4)
                
                //https://stackoverflow.com/questions/70828401/how-to-detect-when-a-textfield-becomes-active-in-swiftui
                TextField("Pesquisar apresentação...", text: $searchText, onEditingChanged: { changed in
                  if changed {
                    // User began editing the text field
                      isSearching = true
                  }
                  else {
                    // User tapped the return key
                      isSearching = false
                  }
                })
                .disabled(disableTextfield)
                .foregroundStyle(.black)
                .tint(.gray)
                if isSearching {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray)
                        .onTapGesture {
                            searchText = ""
                            isSearching = false
                            //ativa e desativa o textfield pra sair a interação do usuário
                            disableTextfield = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                disableTextfield = false
                            }

                        }
                        .padding(.trailing, 4)
                }
            }
            .padding(4)
            .background(.white)
            .containerShape(RoundedRectangle(cornerRadius: 5))
        }
        .onAppear {
            disableTextfield = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                disableTextfield = false
            }
        }
        
    }
    
}


