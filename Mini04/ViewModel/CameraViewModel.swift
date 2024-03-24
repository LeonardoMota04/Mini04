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
    
    var previewLayer =  AVCaptureVideoPreviewLayer()
    @Published var videoFileOutput = AVCaptureMovieFileOutput()
    @Published var videoDataOutput = AVCaptureVideoDataOutput()
    @Published var audioOutput = AVCaptureAudioDataOutput()
    @Published var captureSession =  AVCaptureSession()
    
    @Published var isRecording = false
    
    @Published var handPoseModelController: HandGestureController?
    @Published var detectedGestureModel1: String = "" {
        // Quando detectar a mudanca de valor (uma mao na tela) ele chama a funcao de topicos
        didSet {
            self.createTopics(handPoseResult: detectedGestureModel1)
        }
    }
    
    var urltemp: URL?
    
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
    
    // Video Player
    var videoPlayer: AVPlayer?
    
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
    
    func startSession() {
        guard !captureSession.isRunning else {
            return
        }
        
        DispatchQueue.global().async {
            self.captureSession.startRunning()
            print("sessão iniciada")
        }
    }
    
    func stopSession() {
        guard captureSession.isRunning else {
            return
        }
        
        DispatchQueue.global().async {
            self.captureSession.stopRunning()
            print("sessão finalizada")
        }
    }
    
    // MARK: - Session Configuration
    func configureSession() {
        captureSession.beginConfiguration()
        
        // Remove existing inputs and outputs before reconfiguring
        captureSession.inputs.forEach { input in
            captureSession.removeInput(input)
        }
        
        captureSession.outputs.forEach { output in
            captureSession.removeOutput(output)
        }
        
        setupInputs()
        
        if captureSession.canAddOutput(audioOutput) {
            captureSession.addOutput(audioOutput)
        }
        
        if captureSession.canAddOutput(videoFileOutput) {
            captureSession.addOutput(videoFileOutput)
        }
        
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
        }
        
        
        self.videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        captureSession.commitConfiguration()
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
    func createTopics(handPoseResult: String) {
        if handPoseResult == "0" {
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
    
    // Formata uma string com segundo minutos e horas
        func FormatVideoDuration(from path: URL) -> String {
            let asset = AVURLAsset(url: path)
            let duration: CMTime = asset.duration
            
            let totalSeconds = CMTimeGetSeconds(duration)
            let hours = Int(totalSeconds / 3600)
            let minutes = Int((totalSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
            let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
            
            if hours > 0 {
                return String(format: "%i:%02i:%02i", hours, minutes, seconds)
            } else {
                return String(format: "%02i:%02i", minutes, seconds)
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

// MARK: - VIDEO RECORDING
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
        isRecording.toggle()


        // Contagem antes de iniciar a gravar
        // Timer para contagem regressiva de 3 segundos
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] timer in
            if self.countdownNumber > 0 {
                print(countdownNumber)
                countdownNumber -= 1
            } else {
                isRecording = true
                
                // reiniciando as variaveis
                deinitVariables()
                print("começou a gravar")
                let tempURL = NSTemporaryDirectory() + "\(Date()).mov"
                videoFileOutput.startRecording(to: URL(filePath: tempURL), recordingDelegate: self)
                
                timer.invalidate()
            }
        }
        
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
            }
        } catch {
            print(error)
        }
        
        // iniciando o timer para saber o momento de cada topico
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { time in
            self.currentTime += 1
        })
    }
    
    func stopRecording() {
        isRecording.toggle()
        // variavel para armazenar o scrip (quando da stop ele deixa a string "" e fica impossivel salva-la)
        auxSpeech = speechText
        speechManager.stopRecording()

        guard videoFileOutput.isRecording else {
            print("Nenhuma gravação em andamento.")
            return
        }
        videoFileOutput.stopRecording()
        print("Speech Normal: \(speechText)")
        print("Speech Topicos: " + speechTopicText)
        
        // parando o timer e reiniciando ele
        timer?.invalidate()
        timer = nil
        currentTime = 0
    }
    
    func seekPlayerVideo(topic: Int){
        let targetTime = CMTime(value: CMTimeValue(topicTime[topic]), timescale: 1)
        videoPlayer?.seek(to: targetTime)
    }
    
    func stopRecording() {
        isRecording = false
        // variavel para armazenar o scrip (quando da stop ele deixa a string "" e fica impossivel salva-la)
        auxSpeech = speechText
        speechManager.stopRecording()

        guard videoFileOutput.isRecording else {
            print("Nenhuma gravação em andamento.")
            return
        }
        videoFileOutput.stopRecording()
        print("Speech Normal: \(speechText)")
        print("Speech Topicos: " + speechTopicText)
        
        // parando o timer e reiniciando ele
        timer?.invalidate()
        timer = nil
        currentTime = 0
    }
    

    func getURLVideo(url: URL) {
        self.videoPlayer = AVPlayer(url: url)
    }

    func seekPlayerVideo(topic: Int){
        let targetTime = CMTime(value: CMTimeValue(topicTime[topic]), timescale: 1)
        videoPlayer?.seek(to: targetTime)
    }
    
    // Formata uma string com segundo minutos e horas
    func FormatVideoDuration(from path: URL) -> String {
        let asset = AVURLAsset(url: path)
        let duration: CMTime = asset.duration
        
        let totalSeconds = CMTimeGetSeconds(duration)
        let hours = Int(totalSeconds / 3600)
        let minutes = Int((totalSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
    
    // Retorna o tempo do video MARK: o certo seria fazer com uma funcao assincrona e load
    func getVideoDuration(from path: URL) -> TimeInterval {
        let asset = AVURLAsset(url: path)
        let duration: CMTime = asset.duration
        
        let totalSeconds = CMTimeGetSeconds(duration)
        
        return totalSeconds
    }
    
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

extension CameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //handPoseModelController?.performHandPoseRequest(sampleBuffer: sampleBuffer)
        handPoseModelController?.performHandPoseRequestShort(sampleBuffer: sampleBuffer)
        
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
    }
}

struct CameraOverlayView: View {
    @EnvironmentObject var camVM: CameraViewModel
    let size: CGSize
    
    @State private var previousPosition: CGPoint = .zero
    @State private var previousSize: CGFloat = 0.0
    
    var body: some View {
        ZStack {
            if let observationsBuffer = self.camVM.handPoseModelController?.observationsBuffer.last,
               let allPoints = try? self.camVM.handPoseModelController?.processPoints(from: observationsBuffer) {
                
                let averageDistance = calculateAverageDistance(allPoints: allPoints)
                
                let averageX = allPoints.reduce(0, { $0 + $1.location.x }) / CGFloat(allPoints.count)
                let averageY = allPoints.reduce(0, { $0 + $1.location.y }) / CGFloat(allPoints.count)
                
                Circle()
                    .stroke(lineWidth: averageDistance * size.width / 10)
                    .foregroundColor(.red)
                    .frame(width: averageDistance * size.width * 2, height: averageDistance * size.height * 2)
                    .position(x: averageX * size.width, y: averageY * size.height)
                    .onAppear {
                        previousPosition = CGPoint(x: averageX * size.width, y: averageY * size.height)
                        previousSize = averageDistance * size.width
                    }
                    .onChange(of: averageX)  { oldx, newX in
                        withAnimation {
                            previousPosition.x = newX * size.width
                        }
                    }
                    .onChange(of: averageY) { oldY, newY in
                        withAnimation {
                            previousPosition.y = newY * size.height
                        }
                    }
                    .onChange(of: averageDistance){ oldDistance, newDistance in
                        withAnimation {
                            previousSize = newDistance * size.width
                        }
                    }
                    .animation(.easeInOut, value: 0.3) // Adjust duration as needed
            }
        }
    }
    
    func calculateAverageDistance(allPoints: [VNRecognizedPoint]) -> CGFloat {
        var distances: [CGFloat] = []
        
        for point1 in allPoints {
            for point2 in allPoints {
                let distance = sqrt(pow(point1.location.x - point2.location.x, 2) + pow(point1.location.y - point2.location.y, 2))
                distances.append(distance)
            }
        }
        
        return distances.reduce(0.0, +) / CGFloat(distances.count)
    }
}












