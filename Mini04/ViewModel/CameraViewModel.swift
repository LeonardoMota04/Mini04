//
//  File.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.
//

import SwiftUI
import AVFoundation
import AppKit
import Vision

class CameraViewModel: NSObject, ObservableObject {
    var cameraDevice: AVCaptureDevice!
    var cameraInput: AVCaptureInput!
    var micDevice: AVCaptureDevice!
    var micInput: AVCaptureInput!
    
    @Published var previewLayer =  AVCaptureVideoPreviewLayer()
    @Published var videoFileOutput = AVCaptureMovieFileOutput()
    @Published var videoDataOutput = AVCaptureVideoDataOutput()
    @Published var audioOutput = AVCaptureAudioDataOutput()
    @Published var captureSession =  AVCaptureSession()
    
    @Published var isRecording = false
    
    @Published var handPoseModelController: HandGestureController?
    @Published var detectedGestureModel1: String = "" 
    //variável que recebe o resultado do model se for constante durante um tempo
    @Published var finalModelDetection = ""

    var urltemp: URL?
    
    //sessao secundário feita somente para a camera
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private var isConfigured = false // sessao configurada

    // numero de contagem
    @Published var countdownNumber: Int = 3
    
    // Speech To Text
    var speechManager = SpeechManager()
    @Published var speechText: String = ""
    @Published var speechTopicText: String = ""
    var auxSpeech: String = ""
    var timer: Timer? // timer inicia junto com o video
    @Published var currentTime: TimeInterval = 0
    var topicTime: [TimeInterval] = [] // momentos em que foi feito o tópico
    @Published var videoTime: TimeInterval = 0 // tempo do video
    @Published var videoTopicDuration: [TimeInterval] = [] // duração de cada tópico
    
    @Published var cameraGravando = false
    // Video Player
    var videoPlayer: AVPlayer?
    
    // Transcrições
    var speeches: [String] = [] // Guardará os speeches
    var startedSpeechTimes: [TimeInterval] = [] // Guardará o tempo de cada speech
    var wordsArray: [String] = [] // Guardará todas as palavras do speech separadas
    var allWordsTime: [TimeInterval] = [] // Guardará o tempo de todas as palavras faladas
    
    override init() {
        super.init()
        self.handPoseModelController = HandGestureController()
        self.handPoseModelController?.onResultModel1Changed = { [weak self] resultModel in
            DispatchQueue.main.async {
                self?.detectedGestureModel1 = resultModel
            }
        }
    }
    
    // MARK: - Start/Stop Session
    
    func startSession(completion: @escaping () -> Void) {
        sessionQueue.async {
            guard !self.captureSession.isRunning else { return }
            self.captureSession.startRunning()
            print("sessão iniciada")
            completion()

        }
    }
    
    func stopSession() {
        self.isConfigured = false

        sessionQueue.async {
            guard self.captureSession.isRunning else { return }
            self.captureSession.stopRunning()
            print("sessão finalizada")
        }
    }
    
    // MARK: - Session Configuration
    func configureSession(completion: @escaping () -> Void) {
        sessionQueue.async {
            guard !self.isConfigured else { return }
            
            self.captureSession.beginConfiguration()
            self.captureSession.inputs.forEach { input in
                self.captureSession.removeInput(input)
            }
            self.captureSession.outputs.forEach { output in
                self.captureSession.removeOutput(output)
            }
            self.setupInputs()
            if self.captureSession.canAddOutput(self.audioOutput) {
                self.captureSession.addOutput(self.audioOutput)
            }
            if self.captureSession.canAddOutput(self.videoFileOutput) {
                self.captureSession.addOutput(self.videoFileOutput)
            }
            if self.captureSession.canAddOutput(self.videoDataOutput) {
                self.captureSession.addOutput(self.videoDataOutput)
            }
            self.videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            self.captureSession.commitConfiguration()
            
            DispatchQueue.main.async {
                self.isConfigured = true
                completion()
            }
        }
    }

    
    func setupInputs(){
        // setting devices
        if let device = AVCaptureDevice.default(for: .video) {
            cameraDevice = device
        } else {
            fatalError("Cant catch camera device")
        }
        
        
        if let microphoneDevice = AVCaptureDevice.default(for: .audio) {
            micDevice = microphoneDevice
        } else {
            fatalError("no mic")
        }
        
        //setting inputs
        if let audioInput = try? AVCaptureDeviceInput(device: micDevice) {
            micInput = audioInput
        } else {
            fatalError("no input mic")
        }
        
        if let cInput = try? AVCaptureDeviceInput(device: cameraDevice) {
            cameraInput = cInput
        } else {
            fatalError("could not create input device from back camera")
        }
        
        // conficurar os devices na sessão
        captureSession.addInput(micInput)
        captureSession.addInput(cameraInput)
    }
    
    // função para colocar o // no scrpit e criar topico
    func createTopics() {
        if speechTopicText.isEmpty {
            speechTopicText = speechText + " //"
            auxSpeech = speechText
            // adicionando o tempo do topico
            self.topicTime.append(self.currentTime)
            
        }  else {
            // caso o texto nao seja o mesmo para evitar repeticoes
            if auxSpeech != speechText {
                let newSpeechText = substractionString(speechText, auxSpeech)
                // adiciona as novas palavras e atualiza o texto atual na variavel auxiliar
                speechTopicText += " //" + (newSpeechText ?? "")
                auxSpeech = speechText
                // adicionando o tempo do topico
                self.topicTime.append(self.currentTime)
                
            }
        }
        
    }
    
    // PEGA TEXTO PÓS TOPICO
    func substractionString(_ strA: String, _ strB: String) -> String? {
        // percorre os caracteres até o count da string comparada
        if strA.count > strB.count {
            let index = strA.index(strA.startIndex, offsetBy: strB.count)
            return String(strA[index...])
        } else if strB.count > strA.count {
            let index = strB.index(strB.startIndex, offsetBy: strA.count)
            return String(strB[index...])
        } else {
            return nil // or handle the case where both strings have equal lengths
        }
    }
    
        
        // Retorna o tempo do video MARK: o certo seria fazer com uma funcao assincrona e load
        func getVideoDuration(from path: URL) -> TimeInterval {
            let asset = AVURLAsset(url: path)
            let duration: CMTime = asset.duration
            
            let totalSeconds = CMTimeGetSeconds(duration)
            
            return totalSeconds
        }
        
        // Calcula tempo gastado em cada tópico
        func timeSpentOnTopic(){
            // guard let topicTime = self.topicTime else { return print("Topicos nao foram criados")}
            for index in 0..<self.topicTime.count {
                if index == 0 {
                    // Caso seja o primeiro elemento ele pega o tempo do primeiro topico
                    self.videoTopicDuration.append(topicTime[0])
                } else if index == self.topicTime.count - 1 {
                    // Caso seja o ultimo elemento da array ele diminu o tempo de video com o ultimo topico
                    self.videoTopicDuration.append(self.videoTime - (self.videoTopicDuration.last ?? 0))
                } else {
                    self.videoTopicDuration.append(topicTime[index + 1] - topicTime[index])
                }
            }
        }

        
        func deinitVariables() {
            // reinciando as variaveis para conseguir limpar os dados
            self.auxSpeech = ""
            self.speechTopicText = ""
            self.speechText = ""
            self.topicTime = []
            self.videoTopicDuration = []
            self.videoTime = 0
        }
    
    
}

/// MARK: VIDEO RECORDING
extension CameraViewModel: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        print("nome do arquivo: \(outputFileURL)")
        
        self.urltemp = outputFileURL
        // passando url par o player local
        if let url = urltemp {
            self.videoPlayer = AVPlayer(url: url)
            self.timeSpentOnTopic()
        }
    }
    
    func startRecording() {
        isRecording = true
        
        var hasFinishedCountdown = false
        
        // Contagem antes de iniciar a gravar
        // Timer para contagem regressiva de 3 segundos
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] timer in
            if self.countdownNumber > 0 {
                print(countdownNumber)
                countdownNumber -= 1
            } else {
                
                // reiniciando as variaveis
                deinitVariables()
                print("começou a gravar")
                let tempURL = NSTemporaryDirectory() + "\(Date()).mov"
                videoFileOutput.startRecording(to: URL(filePath: tempURL), recordingDelegate: self)
                
                timer.invalidate()
                
                hasFinishedCountdown = true
                
                if hasFinishedCountdown {
                    self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { time in
                        self.currentTime += 1
                        print("Tempo atual de vídeo: \(self.currentTime)")
                    })
                    
                    // Inciando o SpeechToText
                    do {
                        try self.speechManager.startRecording { text, error in
                            // verificando se o script falado nao esta vazio
                            guard let text = text else {
                                print("String SpeechToText vazia/nil")
                                return
                            }
                            self.speechText = text
                            print(text)
                            
                            // Função das transcrições
                            self.getFirstWordTime(speech: self.speechText)
                            
                        }
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    func stopRecording() {
        
        // Transcrição
        separateStringsFromSpeech(speech: speechText) // Separa as strings de 10 em 10 palavras
        checkIfThereIsAnyWordsLeft()                  // checa se existem palavras restantes que não formaram um speech de 10 palavras
        eliminateSimilarTimes()                       // Elimina tempos duplos caso o speech corrija a primeira palavra de algum speech
        wordsArray.removeAll()                        // Remove todos os elementos de wordsArray para a próxima transcrição
        
        isRecording = false
        // variavel para armazenar o scrip (quando da stop ele deixa a string "" e fica impossivel salva-la)
        auxSpeech = speechText
        speechManager.stopRecording()
        
        guard videoFileOutput.isRecording else {
            print("Nenhuma gravação em andamento.")
            return
        }
        videoFileOutput.stopRecording()
        
        // parando o timer e reiniciando ele
        timer?.invalidate()
        timer = nil
        currentTime = 0
    }
    
    func seekPlayerVideo(topic: Int){
        let targetTime = CMTime(value: CMTimeValue(topicTime[topic]), timescale: 1)
        videoPlayer?.seek(to: targetTime)
    }
    
}

extension CameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        handPoseModelController?.performHandPoseRequest(sampleBuffer: sampleBuffer)
        handPoseModelController?.performHandPoseRequestShort(sampleBuffer: sampleBuffer)
        
    }
}

// MARK: - Tudo relacionado à criação de transcrições está na extension abaixo

extension CameraViewModel {
    
    // Função que elimina tempos duplicados por correções do SpeechToText
    func eliminateSimilarTimes() {
        
        if speeches.count != startedSpeechTimes.count {
            // Ordena os tempos em ordem crescente
            startedSpeechTimes.sort()
            
            // Inicializa variáveis para armazenar os índices dos tempos a serem removidos
            var indicesToRemove: [Int] = []
            
            // Itera sobre os tempos para encontrar e marcar os tempos extras
            
            guard !wordsArray.isEmpty && !startedSpeechTimes.isEmpty else { return }
            
            for i in 0..<(startedSpeechTimes.count - 1) {
                let time1 = startedSpeechTimes[i]
                let time2 = startedSpeechTimes[i + 1]
                let timeDifference = abs(time2 - time1)
                
                // Verifica se a diferença entre os tempos é no máximo 2 segundos
                if timeDifference <= 1.5 || time1 == time2 {
                    // Marca o índice do próximo tempo igual para remoção
                    indicesToRemove.append(i + 1)
                }
            }
            
            // Remove todos os tempos extras da array startedSpeechTimes pelos índices marcados
            startedSpeechTimes = startedSpeechTimes.enumerated().filter { !indicesToRemove.contains($0.offset) }.map { $0.element }
            
            print("Número de speeches: \(speeches.count)\nNúmero de tempos: \(startedSpeechTimes.count)")
        }
        
    }
    
    // MARK: Função para pegar o tempo da primeira palavra de cada discurso
    func getFirstWordTime(speech: String) {
        
        var wordsArray = speech.components(separatedBy: " ") // Cria um array de string com cada palavra do discurso sendo uma string
        
        // Caso seja a primeira palavra do discurso, pega seu tempo
        if wordsArray.count == 1 || wordsArray.count % 10 == 1 {
            if currentTime == 0 {
                startedSpeechTimes.append(currentTime)
            } else {
                startedSpeechTimes.append(currentTime - 1)
            }
        }
    }
    
    // MARK: Funções chamadas APÓS já ter o speech completo
    // Checa se o número de palavras totais do discurso é igual ao número de palavras presentes na transcrição, para identificar se sobraram palavras
    func checkIfThereIsAnyWordsLeft() {
        
        var partialSpeechesCount: Int = 0 // Número de palavras que foram guardadas (de 10 em 10) do discurso. Ex.: 46 palavras ao total no discurso, essa variável guardaria 40
        
        for string in speeches {
            partialSpeechesCount += string.components(separatedBy: " ").count // Número total de palavras nos speeches
        }
        print("Número de palavras no discurso inteiro: \(wordsArray.count)\nNúmero de palavras adicionadas até agora nos speeches: \(partialSpeechesCount)")
        
        // Cria uma nova string com essa "sobra", subtraindo o número de palavras das strings de 10 do número total de palavras do speech
        if wordsArray.count != partialSpeechesCount {
            
            wordsArray.remove(atOffsets: IndexSet(integersIn: 0..<partialSpeechesCount))
            let finalSpeech = wordsArray.joined(separator: " ")
            self.speeches.append(finalSpeech)
            
        }
    }
    
    // Forma as strings de 10 palavras APÓS ter o speech completo.
    func separateStringsFromSpeech(speech: String) {
        
        wordsArray = speech.components(separatedBy: " ")
        
        var strings: [String] = []
        var currentString: [String] = []
        
        // Caso onde são ditas menos de 10 palavras
        if wordsArray.count < 10 {
            
            let currentStringText = wordsArray.joined(separator: " ")
            strings.append(currentStringText)
            
            // Casos onde há mais de 10 palavras
        } else {
            
            for word in wordsArray {
                currentString.append(word)
                
                if currentString.count == 10 {
                    
                    let currentStringText = currentString.joined(separator: " ")
                    strings.append(currentStringText)
                    
                    currentString = []
                }
            }
        }
        
        speeches.append(contentsOf: strings)
        
    }
}

struct CameraRepresentable: NSViewRepresentable {
    @EnvironmentObject var camVM: CameraViewModel
    var size: CGSize
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: size.width, height: size.height))
        view.wantsLayer = true // Certifique-se de que a view tenha uma camada
        
        DispatchQueue.main.async {
            self.camVM.previewLayer = AVCaptureVideoPreviewLayer(session: self.camVM.captureSession)
            self.camVM.previewLayer.frame = view.bounds
            self.camVM.previewLayer.videoGravity = .resizeAspect
            self.camVM.previewLayer.connection?.automaticallyAdjustsVideoMirroring = false
            self.camVM.previewLayer.connection?.isVideoMirrored = true // Espelhando horizontalmente
            view.layer?.addSublayer(self.camVM.previewLayer)
        }
        
        
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        // Atualizações de visualização, se necessário
        self.camVM.previewLayer.frame = NSRect(x: 0, y: 0, width: size.width, height: size.height)
    }
}
