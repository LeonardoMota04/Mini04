//
//  FoldersViewModel.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.
//

import Foundation

class FoldersViewModel: ObservableObject {
    @Published var folder: PastaModel
    
    init(folder: PastaModel) {
        self.folder = folder
    }
}
