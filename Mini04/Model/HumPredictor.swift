//
//  HumPredictor.swift
//  Mini04
//
//  Created by Victor Dantas on 01/04/24.
//

import CoreML

class HumPredictor: SpeechManagerDelegate {
    
    private var model: HumClassifier?
    private var audioSampleBuffer: [Float] = []
    private var humPredictions: [String: Double] = [:]
    private var predictionCounts: [String: Int] = [:]
    
    init() {
        do {
            self.model = try HumClassifier()
        } catch {
            print("Erro ao carregar modelo de detecção de muletas linguísticas: \(error.localizedDescription)")
        }
    }
    
    // MARK: FUNC DO DELEGATE
    func didCaptureAudioSample(_ samples: [Float]) {
        
        audioSampleBuffer.append(contentsOf: samples)
        makeHumPrediction()
        
    }
    
    // MARK: - FAZER PREVISÃO
    private func makeHumPrediction() {
        
        // Transforma o audioSampleBuffer recebido do áudio em MLMultiArray para fazer a previsão com o model
        guard let mlArray = convertToMLMultiArray(audioSampleBuffer) else {
            print("Erro ao converter amostras de áudio para MLMultiArray")
            return
        }
        
        do {
            
            let input = HumClassifierInput(audioSamples: mlArray)
            let prediction = try model?.prediction(input: input)
            
            guard let prediction = prediction else {
                print("Erro ao obter previsão do modelo HumClassifier")
                return
            }
            
            print(" PREVISÃO: \n\n\n\(prediction.targetProbability)\n\n\n")
            
            for (hum, probability) in prediction.targetProbability {
                // LÓGICA DE IDENTIFICAR QUANDO O "HUM" É DITO
                // POR ENQUANTO APENAS PRINTS DE DEPURAÇÃO
                if hum == "Hum" && probability > 0.75 {
                    print("HUM MAIOR\n")
                } else {
                    print("NORMAL MAIOR\n")
                }
            }
            
        } catch {
            print("Erro ao fazer previsão: \(error.localizedDescription)")
        }
        
    }
    
    // MARK: - Função que tranforma as samples em MLMultiArray
    private func convertToMLMultiArray(_ samples: [Float]) -> MLMultiArray? {
        let desiredLength = 15600
        guard samples.count >= desiredLength,
              let mlArray = try? MLMultiArray(shape: [desiredLength] as [NSNumber], dataType: .float32) else {
            print("Número de amostras insuficiente ou falha ao criar MLMultiArray.")
            return nil
        }

        for i in 0..<desiredLength {
            mlArray[i] = NSNumber(value: samples[i])
        }

        return mlArray
    }
}
