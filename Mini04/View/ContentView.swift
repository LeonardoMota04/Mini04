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
    @State private var selectedPresentationID: UUID?
    
    //variável que abre a modal de treino por cima do app todo
    @State var isShowingModal = false
    //referencia do indice do bauglho
    @State var selectedTrainingIndex: Int?
    @State var filteredTrainings: [TreinoModel] = []
    //cria uma referencia de foldervm pra isntanciar o treinoview em contentview
    @State var apresentacaoreference: FoldersViewModel?
    
    
    // PERSISTENCIA
    @Environment(\.modelContext) private var modelContext
    @Query var folders: [PastaModel]
    
    var body: some View {
        ZStack {
            if isShowingModal {
                ModalTreinoView(isShowingModal: $isShowingModal, selectedTrainingIndex: $selectedTrainingIndex, filteredTrainings: $filteredTrainings, apresentacaoreference: $apresentacaoreference)
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
                            .shadow(radius: 2)
                        
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
                                            PastaView(folderVM: folderVM, selectedFolderID: $selectedPresentationID, isShowingModal: $isShowingModal, selectedTrainingIndex: $selectedTrainingIndex, filteredTrainings: $filteredTrainings)
                                                .onAppear(perform: {
                                                    apresentacaoreference = folderVM
                                                })
                                        } else {
                                            Text("ViewModel não encontrada para esta pasta")
                                        }
                                    } label: {
                                        SiderbarFolderComponent(foldersDate: folder.dateOfPresentation,
                                                                foldersName: folder.nome,
                                                                foldersTrainingAmount: folder.treinos.count,
                                                                foldersObjetiveTime: folder.tempoDesejado,
                                                                foldersType: folder.objetivoApresentacao,
                                                                backgroundHighlited: .constant(backgroundHighlitedFolder == folder.id))
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
                                            PastaView(folderVM: folderVM, selectedFolderID: $selectedPresentationID, isShowingModal: $isShowingModal, selectedTrainingIndex: $selectedTrainingIndex, filteredTrainings: $filteredTrainings)
                                                .onAppear(perform: {
                                                    apresentacaoreference = folderVM
                                                })
                                        } else {
                                            Text("ViewModel não encontrada para esta pasta")
                                        }
                                    } label: {
                                        SiderbarFolderComponent(foldersDate: folder.dateOfPresentation,
                                                                foldersName: folder.nome,
                                                                foldersTrainingAmount: folder.treinos.count,
                                                                foldersObjetiveTime: folder.tempoDesejado,
                                                                foldersType: folder.objetivoApresentacao,
                                                                backgroundHighlited: .constant(backgroundHighlitedFolder == folder.id))
                                        .onHover { hovering in
                                            overText = hovering ? folder.id : nil
                                            backgroundHighlitedFolder = hovering ? folder.id : nil
                                        }
                                        .contextMenu {
                                            Group {
                                                Button {
                                                    if let selectedPresentationID = selectedPresentationID, selectedPresentationID == folder.id {
                                                        self.selectedPresentationID = nil
                                                    }
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
                            Text("Nova apresentação")
                        }
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(Color.lightDarkerGreen)
                        .containerShape(RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(Color.lightWhite)
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom)
                    
                }
                .background(Color.lightWhite)
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
        // ao trocar o ID da pasta selecionada e ele for NIL é para apagar ela
        .onChange(of: selectedPresentationID) { oldValue, newValue in
            if newValue == nil {
                if let folderID = oldValue {
                    // Encontrar a pasta correspondente ao ID na fonte de dados
                    if let folderIndex = folders.firstIndex(where: { $0.id == folderID }) {
                        let folderToDelete = folders[folderIndex]
                        
                        // Excluir a pasta
                        presentationVM.deleteFolder(folderToDelete)
                        
                    }
                }
            }
        }
        
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
                
                    .foregroundStyle(.gray)
                    .padding(.leading, 4)
                
                TextField("Pesquisar apresentação...", text: $searchText)
                    .disabled(disableTextfield)
                    .foregroundColor(.black) // Define a cor do texto como preto
                    .background(Color.white) // Define o estilo de fundo do TextField como branco
                    .onChange(of: searchText) { _, newValue in
                        isSearching = !searchText.isEmpty
                    }
                
                if isSearching {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .onTapGesture {
                            searchText = ""
                            isSearching = false
                            disableTextfield = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                disableTextfield = false
                            }
                        }
                        .padding(.trailing, 4)
                }
            }
            .padding(4)
            .background(Color.white)
            .cornerRadius(5)
            .shadow(radius: 4) // Adiciona uma sombra à barra de pesquisa
        }
    }
}



