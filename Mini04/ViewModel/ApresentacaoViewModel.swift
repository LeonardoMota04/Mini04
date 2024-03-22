//
//  ApresentacaoViewModel.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.
//

import Foundation
import SwiftData

/*
 ApresentacaoViewModel CONTEM:
 - Modelo ApresentacaoModel
 - ViewModel das pastas
 - método de criar pasta
 */

@Observable
class ApresentacaoViewModel: ObservableObject {
    // MARK: - Modelo
    var apresentacao: ApresentacaoModel
    var modelContext: ModelContext?

    // MARK: - FoldersViewModels
    var foldersViewModels: [UUID: FoldersViewModel] = [:]
    var activeFolderViewModels: [UUID: FoldersViewModel] = [:]

    
    init(apresentacao: ApresentacaoModel = ApresentacaoModel(), modelContext: ModelContext? = nil) {
        self.apresentacao = apresentacao
        self.modelContext = modelContext
        
    }
    
    // MARK: - CRUD
    func bro() {
        for folder in apresentacao.folders {
            let folderViewModel = FoldersViewModel(folder: folder)
            foldersViewModels[folder.id] = folderViewModel
        }
    }
    // CREATE
    func createNewFolder(name: String, pretendedTime: Int, presentationGoal: String) {
        guard let modelContext = modelContext else { return }
        
        // cria nova pasta
        let newFolder = PastaModel(nome: name, tempoDesejado: pretendedTime, objetivoApresentacao: presentationGoal)

        // FoldersViewModel com a nova pasta
        //if foldersViewModels[newFolder.id] == nil {
        let newFolderViewModel = FoldersViewModel(folder: newFolder)
        foldersViewModels[newFolder.id] = newFolderViewModel
            
        //}

        // armazenar
        do {
            modelContext.insert(newFolder)
            try modelContext.save()
            apresentacao.folders.append(newFolder)
        } catch {
            print("Não conseguiu criar e salvar a pasta. \(error)")
        }
    }
    
    // READ
    func fetchFolders() {
        guard let modelContext = modelContext else { return }
        do {
            let fetchDescriptor = FetchDescriptor<PastaModel>(
                sortBy: [SortDescriptor(\PastaModel.nome)]
            )
            apresentacao.folders = try modelContext.fetch(fetchDescriptor)
            // imprimir resultados recuperados
            print("Pastas recuperadas:")
            for folder in apresentacao.folders {
                print("- Nome: \(folder.nome)")
                print("- Treinos: \(folder.treinos)")
                print("- Objetivo: \(folder.objetivoApresentacao)")
                print("- Data: \(folder.data)")
                print("\n\n\n\n")
            }
        } catch {
            print("Fetch failed: \(error)")
        }
    }
    
    // DELETE
    func deleteFolder(_ folder: PastaModel) {
        guard let modelContext = modelContext else { return }
        
        // remove a pasta do array folders
        if let index = apresentacao.folders.firstIndex(of: folder) {
            apresentacao.folders.remove(at: index)
            modelContext.delete(folder)
            
            do {
                try modelContext.save()
            } catch {
                print("Falha ao salvar após a exclusão da pasta. \(error)")
            }
        }
    }
}
