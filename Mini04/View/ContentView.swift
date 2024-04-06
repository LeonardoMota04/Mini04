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
    @StateObject private var searchVM = SearchViewModel() // Gerenciar a searchbar
    @StateObject private var presentationVM = ApresentacaoViewModel()
    @State private var isModalPresented = false
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var overText: UUID? = nil
    @State private var backgroundHighlitedFolder: UUID? = nil
    @State var disableTextfield = false
    @State private var columnVisibility = NavigationSplitViewVisibility.automatic

    // PERSISTENCIA
    @Environment(\.modelContext) private var modelContext
    @Query var folders: [PastaModel]
    
    var body: some View {
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
                                        PastaView(folderVM: folderVM)
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
                                        PastaView(folderVM: folderVM)
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
                            ForEach(searchVM.filteredFolders) { folder in
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

        } detail: {
            VStack {
                ForEach(folders) { folder in
                    NavigationLink {
                        if let folderVM = presentationVM.foldersViewModels[folder.id] {
                            PastaView(folderVM: folderVM)
                        } else {
                            Text("ViewModel não encontrada para esta pasta")
                        }

                    } label: {
//                        SiderbarFolderComponent(foldersDate: folder.data, foldersName: folder.nome, foldersTrainingAmount: folder.treinos.count, foldersObjetiveTime: folder.tempoDesejado, foldersType: folder.objetivoApresentacao)
                    }
                    .buttonStyle(.plain)
                    
                }
            }
//            .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 300)

        }
        //abrir a sidebar sempre
        //https://stackoverflow.com/questions/77794673/disable-collapsing-sidebar-navigationsplitview
        .onChange(of: columnVisibility, initial: true) { oldVal, newVal in
            if newVal == .detailOnly {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    columnVisibility = .all
                }
            }
        }

        .onAppear {
            presentationVM.modelContext = modelContext
            presentationVM.fetchFolders()
        }
        .sheet(isPresented: $isModalPresented, content: {
            //CreatingFolderModalView2(presentationVM: presentationVM, isModalPresented: $isModalPresented)
        })
        .environmentObject(searchVM)
    }
    
}
// MARK: - MODAL DE CRIAR PASTA
struct CreatingFolderModalView2: View {
    //@ObservedObject var presentationVM: ApresentacaoViewModel
    @Binding var isModalPresented: Bool
    @State private var isEditing: Bool = false
    
    @State var pastaName: String = ""
    @State var tempoDesejado: Int = 1
    @State var objetivo: String = ""
    @State var presentationDate: Date = Date()
    let goal = ["Apresentação de Vendas", "Apresentação de Eventos", "Apresentação de Pitch", "Apresentação de Projetos", "Apresentação Acadêmica"]
    let goalsImages = ["dollarsign.circle.fill", "hands.clap.fill", "megaphone.fill", "briefcase.fill", "graduationcap.fill"]
    
    var isFormValid: Bool {
        !pastaName.isEmpty && !objetivo.isEmpty //&& tempos.contains(tempoDesejado)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Nova Apresentação")
                .font(.title)
                .bold()
                .padding(.bottom, 40)
    
            // NOME + DATA
            HStack {
                // NOME DA APRESENTACAO
                VStack(alignment: .leading, spacing: 3) {
                    Text("Título da sua Apresentação")
                        .font(.body)
                    TextField("", text: $pastaName)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 16)
                        .textFieldStyle(.plain)
                        .background(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.gray, lineWidth: 2))
                }
                
                // DATA DA APRESENTAÇÃO
                VStack(alignment: .leading, spacing: 3) {
                    Text("Data da Apresentação")
                        .font(.body)
                    DatePicker("DD/MM/AAAA", selection: $presentationDate, displayedComponents: .date)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 16)
                        .background(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.gray, lineWidth: 2))
                    
                }
            }
            
            // DURAÇÃO + TIPO
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Duração da Apresentação")
                        .font(.body)
                    CustomDurationPickerView(selectedSortByOption: $tempoDesejado)
                }
                .padding()
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("Tipo de Apresentação")
                        .font(.body)
                    Menu {
                        Section(header: Text("Sugestões")) {
                            ForEach(goal.indices, id: \.self) { index in
                                Button {
                                    self.objetivo = goal[index]
                                } label: {
                                    HStack {
                                        Image(systemName: goalsImages[index]) // Acessando a imagem correspondente
                                        Text(goal[index])
                                    }
                                }
                            }
                        }
                    } label: {
                        Text(objetivo)
                    }
                    .menuStyle(.borderlessButton)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 16)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundStyle(.gray)
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.black.opacity(0.5), lineWidth: 2)
                        }
                    )
              }
                
                

            }
            HStack {
                Spacer()
                Button("Salvar") {
                    if isFormValid {
                        withAnimation {
                           // presentationVM.createNewFolder(name: pastaName, pretendedTime: tempoDesejado, presentationGoal: objetivo)
                        }
                        //isModalPresented.toggle()
                    } else {
                        // Exibir uma mensagem ou alerta informando que os campos estão vazios
                    }
                }
                .foregroundColor(.white)
                .padding()
                .frame(width: 100)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.blue)
                )
                //.buttonStyle(PlainButtonStyle())
                //.disabled(!isFormValid) // Desabilita o botão se o formulário não estiver válido
                Spacer()
            }
            
        }
        .padding(30)
        .frame(width: 750, height: 532)
    }
}

struct CustomDurationPickerView: View {
    let timeStamps = [5, 8, 10, 15, 20]
    @Binding var selectedSortByOption: Int
    @State private var customTime: String = ""
    
    var body: some View {
        let formattedTime = formatTime(selectedSortByOption)
        
        ZStack (alignment: .trailing){
            HStack {
                TextField(formattedTime, text: $customTime)
                    .textFieldStyle(.plain)
                Spacer()
                Image(systemName: "timer")
                    .foregroundStyle(.black.opacity(0.3))
                    .bold()
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(.gray)
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.black.opacity(0.5), lineWidth: 2)
                }
            )
            
            // MENU
            Menu {
                Section(header: Text("Sugestões")) {
                    ForEach(timeStamps, id: \.self) { time in
                        Button("\(String(time)) minutos") {
                            selectedSortByOption = time
                        }
                    }
                }
            } label: {
                EmptyView()
            }
            .frame(width: 50, height: 50)
            .background(Color.clear)
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .padding(.trailing, 5)
        }
    }
    
    func formatTime(_ time: Int) -> String {
        let minutes = time
        let formattedMinutes = String(format: "%02d", minutes)
        return "\(formattedMinutes):00"
    }
}



#Preview {
    CreatingFolderModalView2(isModalPresented: .constant(true))
}

// MARK: - MODAL DE CRIAR PASTA
struct CreatingFolderModalView: View {
    // CRIAR PASTA (modularizar)
    @ObservedObject var presentationVM: ApresentacaoViewModel
    @State var pastaName: String = ""
    @State var tempoDesejado: Int = 1
    @State var objetivo: String = ""
    @Binding var isModalPresented: Bool
    let tempos = [5, 10, 15]
    let objetivos = ["pitch", "sales", "event", "project", "informative"]
    
    var isFormValid: Bool {
        !pastaName.isEmpty && !objetivo.isEmpty && tempos.contains(tempoDesejado)
    }
    
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
                ForEach(objetivos, id: \.self) { objetivo in
                    Text(objetivo)
                }
            }
            .padding()
            Spacer()
                .padding()
        }
        .background(Color.white)
        .toolbar {
            ToolbarItem() {
                Button("Cancelar") {
                    isModalPresented.toggle()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Criar pasta") {
                    if isFormValid {
                        withAnimation {
                            presentationVM.createNewFolder(name: pastaName, pretendedTime: tempoDesejado, presentationGoal: objetivo)
                        }
                        isModalPresented.toggle()
                    } else {
                        // Exibir uma mensagem ou alerta informando que os campos estão vazios
                    }
                }
                .disabled(!isFormValid) // Desabilitar o botão se o formulário não estiver válido
            }
        }
        .frame(width: 750, height: 532)
    }
}

#Preview {
    ContentView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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


