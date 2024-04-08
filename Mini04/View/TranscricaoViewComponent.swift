//
//  TranscricaoViewComponent.swift
//  Mini04
//
//  Created by Victor Dantas on 02/04/24.
//

import SwiftUI
import AVFoundation
struct TranscricaoViewComponent: View {
    
    @State var showMessage: Bool = false
    @State var dicionario: [String: TimeInterval] = [:]
    @ObservedObject var trainingVM: TreinoViewModel
    var player: AVPlayer?
    
    var speeches: [String]
    var times: [TimeInterval]
    
    var body: some View {
        GeometryReader { geometry in
            
            let size = geometry.size
            
            if !showMessage {
                VStack {
                    
                    // Keys em ordem
                    let sortedKeys = dicionario.keys.sorted(by: { dicionario[$0]! < dicionario[$1]! })
                    
                    ForEach(sortedKeys, id: \.self) { key in
                        TranscricaoItem(transcriptionText: key, transcriptionTime: dicionario[key] ?? 0, trainingVM: trainingVM, player: player)
                            .padding()
                    }
                }
                .onAppear {
                    // Verifica se os arrays de speech e time têm o mesmo comprimento
                    guard speeches.count == times.count else {
                        showMessage = true
                        return
                    }
                    
                    // Preenche o dicionário com as entradas correspondentes
                    for (index, speechText) in speeches.enumerated() {
                        dicionario[speechText] = times[index]
                    }
                }
                .frame(height: size.height / 2)
            } else {
                Text("Não foi possível fazer a transcrição do vídeo")
                    .foregroundStyle(.black)
            }
        }
    }
}


struct TranscricaoItem: View {
    
    var transcriptionText: String
    var transcriptionTime: TimeInterval
    @ObservedObject var trainingVM: TreinoViewModel
    @EnvironmentObject var camVM: CameraViewModel
    var player: AVPlayer?
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            
            HStack(alignment: .center) {
                
                Button {
                    
                    guard let avPlayer = player else {return }
                    trainingVM.seek(to: Int(transcriptionTime), player: avPlayer)
                    print("VAI TMAR NO CU ORATO")
                    
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: size.width / 20)
                            .foregroundStyle(.blue)
                            .opacity(0.5)
                            .padding()
                        
                        Text(formatTimeInterval(transcriptionTime))
                            .font(.callout)
                            .bold()
                            .foregroundStyle(.orange)
                    }
                    .frame(width: size.width / 8)
                    .foregroundStyle(.lightOrange)
                }
                
                Text(transcriptionText)
                    .fontWeight(.semibold)
                    .lineLimit(2, reservesSpace: true)
                    .foregroundStyle(.black)
            }
        }
    }
    
    // Função para converter um TimeInterval em formato mm:ss
    func formatTimeInterval(_ timeInterval: TimeInterval) -> String {
        let time = Int(timeInterval)
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

//#Preview {
//    TranscricaoViewComponent(speeches: ["Olá tudo bem", "Meu nome é Victor Hugo", "Eu tenho 20 anos de idade"], times: [1, 4, 7])
//}
