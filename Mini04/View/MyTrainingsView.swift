//
//  MyTrainingsView.swift
//  Mini04
//
//  Created by Leonardo Mota on 30/03/24.
//

import SwiftUI

struct MyTrainingsView: View {
    @ObservedObject var folderVM: FoldersViewModel
    
    let trainingFilters = ["Mais antigo para mais novo", 
                           "Mais rápido para mais longo",
                           "Mais longo para mais rápido",
                           "Favoritos"]
    @State private var selectedFilter: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Meus Treinos")
                    .font(.title2)
                    .bold()
                Spacer()
                Picker("", selection: $selectedFilter) {
                    ForEach(trainingFilters, id: \.self) { objetivo in
                        Text(objetivo)
                    }
                }
                .frame(maxWidth: 220)
                .onChange(of: selectedFilter) { _, _ in
                    // Recarregar a view quando o filtro é alterado
                    folderVM.objectWillChange.send()
                }
            }
            TrainingCellsView(folderVM: folderVM, selectedFilter: selectedFilter)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TrainingCellsView: View {
    @ObservedObject var folderVM: FoldersViewModel
    var selectedFilter: String
    @State private var filteredTrainings: [TreinoModel] = []
    
    var body: some View {
        ScrollView {
            HStack {
                Text("Nº do Treino")
                    Spacer()
                Text("Feito em")
                    Spacer()
                Image(systemName: "timer")
                Text("Duração")
                    Spacer()
            }
            .font(.footnote)
            .padding(.horizontal, 30)
            .padding(.bottom, 10)
            
            ForEach(filteredTrainings, id: \.self) { training in
                NavigationLink {
                    TreinoView(folderVM: folderVM, trainingVM: TreinoViewModel(treino: training))
                } label: {
                    HStack {
                        Image(systemName: "video.badge.waveform.fill")
                        Text(training.nome)
                            .bold()
                        
                        Spacer()
                        
                        // Data de criação
                        Text(training.formattedCreationDate())
                        
                        Spacer()
                        
                        // Duração do treino
                        Text((training.video?.formattedTime())!)
                        
                        Spacer()
                        
                        Image(systemName: training.isFavorite ? "heart.fill" : "heart")
                            .onTapGesture {
                                training.isFavorite.toggle()
                            }
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 25)
                    .padding(.vertical, 15)
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundStyle(.gray)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.top, 25)
        .onAppear {
            updateFilteredTrainings()
        }
        .onChange(of: selectedFilter) { _, _ in
            withAnimation {
                updateFilteredTrainings()
            }
        }
    }
    
    private func updateFilteredTrainings() {
        switch selectedFilter {
        case "Mais antigo para mais novo":
            filteredTrainings = folderVM.folder.treinos.sorted(by: { $0.data < $1.data })
        case " Mais longo para mais rápido":
            filteredTrainings = folderVM.folder.treinos.sorted(by: { ($0.video?.videoTime ?? 0) < ($1.video?.videoTime ?? 0) })
        case "Mais rápido para mais longo":
            filteredTrainings = folderVM.folder.treinos.sorted(by: { ($0.video?.videoTime ?? 0) > ($1.video?.videoTime ?? 0) })
        case "Favoritos":
            filteredTrainings = folderVM.folder.treinos.filter { $0.isFavorite }
        default:
            filteredTrainings = folderVM.folder.treinos
        }
    }
}


#Preview {
    MyTrainingsView(folderVM: FoldersViewModel(folder: PastaModel(nome: "Nome Pasta", tempoDesejado: 10, objetivoApresentacao: "Objetivo")))
    //TrainingCellsView()
}
