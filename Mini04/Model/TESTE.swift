//
//  TESTE.swift
//  Mini04
//
//  Created by Leonardo Mota on 01/04/24.
//

import SwiftUI
struct CustomPickerView: View {
    let trainingFilters: [TreinoModel.TrainingFilter] =  TreinoModel.TrainingFilter.allCases

    @Binding var selectedSortByOption: TreinoModel.TrainingFilter
    @Binding var selectedFavoriteOption: Bool
    
    var body: some View {
        Menu {
            Section(header: Text("Classificar por")) {
                ForEach(trainingFilters.filter { $0.rawValue != "Favoritos"}, id: \.self) { filter in
                    Button(filter.rawValue) {
                        selectedSortByOption = filter
                    }
                }
            }
            
            Section(header: Text("Filtrar por")) {
                Toggle(isOn: $selectedFavoriteOption) {
                    Text("Favoritos")
                }
                .toggleStyle(.button)
            }
        } label: {
            Text(selectedSortByOption == .favorites ? "Favoritos" : selectedSortByOption.rawValue)
                .font(.body)
                .foregroundStyle(.primary)
        }
        .menuStyle(.borderlessButton)
        .background {
            RoundedRectangle(cornerRadius: 5)
                .foregroundStyle(.clear)
                .frame(height: 22)
        }
    }
}
