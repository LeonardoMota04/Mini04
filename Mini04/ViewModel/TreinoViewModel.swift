//
//  TreinoViewModel.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.
//

import Foundation
import AVFoundation

class TreinoViewModel: ObservableObject {
    @Published var treino: TreinoModel
    
    init(treino: TreinoModel = TreinoModel()) {
        self.treino = treino
    }
    
    
    func seek(to time: Int, player: AVPlayer) {
        let targetTime = Float64(time)
        player.seek(to: CMTimeMakeWithSeconds(targetTime, preferredTimescale: 60000))
        
    }
}
