//
//  MyTrainingsView.swift
//  Mini04
//
//  Created by Leonardo Mota on 30/03/24.
//

import SwiftUI

struct MyTrainingsView: View {
    @ObservedObject var folderVM: FoldersViewModel
    
    let trainingFilters: [TreinoModel.TrainingFilter] =  TreinoModel.TrainingFilter.allCases
    @State private var selectedFilter: TreinoModel.TrainingFilter = .newerToOlder
    
    @Binding var isShowingModal: Bool
    @Binding var selectedTraining: TreinoModel?
    @State private var selectedFavoriteOption: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Meus Treinos")
                    .font(.title2)
                    .bold()
                Spacer()
                
                CustomPickerView(selectedSortByOption: $selectedFilter, selectedFavoriteOption: $selectedFavoriteOption)
                    .frame(maxWidth: 220)
            }
            TrainingCellsView(folderVM: folderVM, selectedFilter: selectedFilter, isShowingModal: $isShowingModal, selectedTraining: $selectedTraining)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TrainingCellsView: View {
    @ObservedObject var folderVM: FoldersViewModel
    var selectedFilter: TreinoModel.TrainingFilter?
    @State private var filteredTrainings: [TreinoModel] = []
    
    @Binding var isShowingModal: Bool
    @Binding var selectedTraining: TreinoModel?

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
            .padding(.leading, 40)
            .padding(.bottom, 10)
            
            ForEach(filteredTrainings, id: \.self) { training in
                Button {
                    selectedTraining = training
                    isShowingModal.toggle()

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
                            .onTapGesture { training.isFavorite.toggle() }
                            .font(.system(size: 15))
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 25)
                    .padding(.vertical, 15)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(.gray)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .contextMenu {
                    Button("Apagar") {
                        folderVM.deleteTraining(training)
                    }
                }
            }
        }
        .padding(.top, 25)
        // ATUALIZAR A LISTA FILTRADA DE TREINOS
        /// ao abrir, ele atualiza a lista de treinos
        .onAppear {
            withAnimation {
                updateFilteredTrainings()
            }
        }
        /// ao trocar de filtro, ele atualiza a lista de treinos
        .onChange(of: selectedFilter) { _, _ in
            withAnimation {
                updateFilteredTrainings()
            }
        }
        /// ao trocar de pasta ele atualiza a lista de treinos
        .onChange(of: folderVM.folder) { _, _ in
            withAnimation {
                updateFilteredTrainings()
            }
        }
        .onChange(of: folderVM.folder.treinos.count) { oldValue, newValue in
            withAnimation {
                updateFilteredTrainings()
            }
        }
    }
    
    private func updateFilteredTrainings() {
        switch selectedFilter {
        // Mais recente para mais antigo
        case .newerToOlder:
            filteredTrainings = folderVM.folder.treinos.sorted(by: { $0.data > $1.data })
    
        // Mais antigo para mais recente
        case .olderToNewer:
            filteredTrainings = folderVM.folder.treinos.sorted(by: { $0.data < $1.data })
            
        // Mais longo para mais rápido
        case .longerToFaster:
            filteredTrainings = folderVM.folder.treinos.sorted(by: { ($0.video?.videoTime ?? 0) > ($1.video?.videoTime ?? 0) })
    
        // Mais rápido para mais longo
        case .fasterToLonger:
            filteredTrainings = folderVM.folder.treinos.sorted(by: { ($0.video?.videoTime ?? 0) < ($1.video?.videoTime ?? 0) })
        
        // Favoritos
        case .favorites:
            filteredTrainings = folderVM.folder.treinos.filter { $0.isFavorite }
        default:
            filteredTrainings = folderVM.folder.treinos
        }
    }
}

//
//#Preview {
//    MyTrainingsView(folderVM: FoldersViewModel(folder: PastaModel(nome: "Nome Pasta", tempoDesejado: 10, objetivoApresentacao: "Objetivo")))
//    //TrainingCellsView()
//}
