//
//  ApresentacaoModel.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.
//

import Foundation
import SwiftData

@Model
class ApresentacaoModel {
    var folders: [PastaModel] = []
    
    init(folders: [PastaModel] = []) {
        self.folders = folders
    }
}


