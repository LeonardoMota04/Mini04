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
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color("light_Orange"), lineWidth: 2)
                        .fill(Color("light_White"))
                    
                    ScrollView {
                        VStack {
                            // Keys em ordem
                            let sortedKeys = dicionario.keys.sorted(by: { dicionario[$0]! < dicionario[$1]! })
                            
                            ForEach(sortedKeys, id: \.self) { key in
                                TranscricaoItem(transcriptionText: key, transcriptionTime: dicionario[key] ?? 0, trainingVM: trainingVM, player: player)
                                    .padding(.top)
                                    .padding(.leading)
                            }
                        }
                        .padding(.bottom, 32)
                    }
//                    .frame(height: size.height * 1.15)
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
                
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color("light_Orange"))
                        .fill(Color("light_White"))
                    
                    Text("Não foi possível fazer a transcrição do vídeo")
                        .foregroundStyle(.black)
                }
            }
        }
        .padding(.top)
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
                    
                    // MARK: - NAO ESTA FUNCIONANDO
                    guard let avPlayer = player else {return }
                    trainingVM.seek(to: Int(transcriptionTime), player: avPlayer)
                    print("VAI TMAR NO CU ORATO")
                    
                } label: {
                    
                    Text(formatTimeInterval(transcriptionTime))
                        .font(.system(size: 10))
                        .foregroundStyle(Color("light_Orange"))
                        .frame(width: size.width / 10, alignment: .center)
                    
                }
                .background(Color("light_LighterOrange"))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Text(transcriptionText)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(2, reservesSpace: true)
                    .foregroundStyle(.gray)
            }
            .padding(.bottom)
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
