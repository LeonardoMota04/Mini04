//
//  ApresentacaoViewModel.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.
//

import Foundation

/*
 ApresentacaoViewModel CONTEM:
 - Modelo ApresentacaoModel
 - ViewModel das pastas
 - método de criar pasta
 */

class ApresentacaoViewModel: ObservableObject {
    // Modelo
    @Published var apresentacao: ApresentacaoModel
    
    // Pasta
    @Published var foldersViewModels: [UUID: FoldersViewModel] = [:]

    
    init(apresentacao: ApresentacaoModel = ApresentacaoModel()) {
        self.apresentacao = apresentacao
    }
    
    // métodos
    /// CRIAR PASTA
    func createNewFolder(name: String, pretendedTime: Int, presentationGoal: String) {
        let newFolder = PastaModel(nome: name, tempoDesejado: pretendedTime, objetivoApresentacao: presentationGoal)
        apresentacao.folders.append(newFolder)
        
        // FoldersViewModel com a nova pasta
        if foldersViewModels[newFolder.id] == nil {
            let newFolderViewModel = FoldersViewModel(folder: newFolder)
            foldersViewModels[newFolder.id] = newFolderViewModel
        }
        //let newFolderViewModel = FoldersViewModel(folder: newFolder)
        //self.foldersViewModels.append(newFolderViewModel)
    }
}
