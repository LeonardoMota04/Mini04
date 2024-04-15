//
//  SpeechManager.swift
//  Mini04
//
//  Created by João Victor Bernardes Gracês on 20/03/24.
//

import Foundation
import Speech

class SpeechManager: ObservableObject {

    private let speechRecognizer: SFSpeechRecognizer?  // Realiza o reconhecimento da fala real
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest? // Para alocar o discurto como o usuário fala em tempo real e controlar o armazenamento em buffer
    private var recognitionTask: SFSpeechRecognitionTask? // Usado para gerenciar, cancelar ou interromper a tarefa de reconhecimento atual
    private let audioEngine: AVAudioEngine = AVAudioEngine() // Dará atualizações quando o microfone receber áudio e processará o fluxo de áudio
    private var speechResult: SFSpeechRecognitionResult = SFSpeechRecognitionResult() // Guarda o resultado obtido do reconhecimento
    
    var isRecording = false
    
    var delegate: HumPredictor?

    init() {
        /// por padrão, detectará a localizacao do dispositivo, ideal deixar ele opcional
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "pt-BR"))
        self.requestPermission()
        self.delegate = HumPredictor()
    }
    
    func startRecording(callback: @escaping callback) throws {
        if !audioEngine.isRunning {
            guard let speechRecognizer = speechRecognizer else {
                callback(nil, NSError())
                return
            }
            
            if !speechRecognizer.isAvailable {
                callback(nil, NSError())
                return
            }
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            
            let inputNode = audioEngine.inputNode
            guard let recognitionRequest = recognitionRequest else {
                callback(nil, NSError())
                return
            }
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                recognitionRequest.append(buffer)
                self.processAudioBuffer(buffer)
            }
            
            recognitionRequest.shouldReportPartialResults = true
                
            // Nesse trecho é onde se recebe o resultado do reconhecimento e responde utilizando o closure, e também é quando se executa o audioEngine.start(), método que realmente inicia o reconhecimento de voz
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
                if let result = result {
                    self.speechResult = result
                    
                    DispatchQueue.main.async {
                        callback(result.bestTranscription.formattedString, nil)
                    }
                }
                
                // caso algo aconteca errado
                if error != nil {
                    // parar o reconhecimento
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    
                    self.recognitionRequest = nil
                    self.recognitionTask?.cancel()
                    self.recognitionTask = nil
                    
                    callback(nil, error)
                }
            }
            
            audioEngine.prepare()
            try audioEngine.start()
        }
    }
    
    func stopRecording() {
        audioEngine.outputNode.removeTap(onBus: 0)
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }

    }
    
    func requestPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            OperationQueue.main.addOperation {
                switch status {
                case .authorized:
                    print("Speech Recognition autorizado")
                case .notDetermined:
                    print("Speech Recognition não foi determinado")
                case .denied:
                    print("Usuário negou acesso ao Speech Recognition")
                case .restricted:
                    print("Speech Recognition restrito à esse dispositivo")
                    break
                @unknown default:
                    fatalError()
                }
            }
        }
    }
    
    func convertAudioToText(url: URL, completion: @escaping (String?) -> Void) {
        guard let recognizer = speechRecognizer else {
            completion(nil)
            return
        }

        do {
            let audioFile = try AVAudioFile(forReading: url)
            let request = SFSpeechURLRecognitionRequest(url: url)
            recognitionTask = recognizer.recognitionTask(with: request) { result, error in
                guard let result = result else {
                    completion(nil)
                    return
                }
                if result.isFinal {
                    completion(result.bestTranscription.formattedString)
                }
            }

            let audioFormat = audioFile.processingFormat
            let audioFrameCount = UInt32(audioFile.length)
            let audioFileBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount)

            try audioFile.read(into: audioFileBuffer!)

            recognitionRequest?.append(audioFileBuffer!)
        } catch {
            print("Error reading audio file: \(error.localizedDescription)")
            completion(nil)
        }
    }
    
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {

        guard let channelData = buffer.floatChannelData else {
            print("[AudioCaptureManager - processAudioBuffer] Erro: Dados do canal de áudio não disponíveis")
            return
        }

        let channelDataPointer = channelData.pointee
        let frameLength = Int(buffer.frameLength)

        var audioSamplesArray: [Float] = []
        for i in 0..<frameLength {
            audioSamplesArray.append(channelDataPointer[i])
        }

        guard let delegate = delegate else { return }
        
        delegate.didCaptureAudioSample(audioSamplesArray)
    }

}

protocol SpeechManagerDelegate {
    func didCaptureAudioSample(_ samples: [Float])
}

typealias callback = (_ text: String?, _ error: Error?) -> Void
typealias completionPermission = (_ status: Bool, _ message: String) -> Void
