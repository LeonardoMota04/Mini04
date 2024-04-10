//
//  CameraOverlayView.swift
//  Mini04
//
//  Created by luis fontinelles on 23/03/24.
//

import SwiftUI
import Vision
import Combine

struct CameraOverlayView: View {
    @EnvironmentObject var camVM: CameraViewModel
    let size: CGSize
    @State var handResultText = ""
    @State private var circlePosition: CGPoint = .zero
    @State private var circleSize: CGFloat = 0.0
    @State private var isHandTrackingActive = false // Nova variável de estado
    
    @State private var progress: Double = 0.0
    @State var consecutiveDetectionCount = 0
    @State var lastDetectedModel: String?
    @State var timer: Timer?
    @State var pauseOverlay = false

    var body: some View {
        if let points = getProcessedPoints() {
            ZStack {
                if isHandTrackingActive { // Verifica se o tracking de mão está ativo
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0))) // Limita o progresso máximo em 1.0
                        .stroke(style: StrokeStyle(lineWidth: calculateAverageDistance(points: points) * size.width / 10, lineCap: .round, lineJoin: .round))
                        .rotationEffect(.degrees(-90))
                        .foregroundColor(Color.lightOrange)
                        .frame(width: circleSize * 1.5, height: circleSize * 1.5)
                        .position(circlePosition)
                        .onAppear {
                            updateCirclePosition(points: points)
                            isHandTrackingActive = true
                            startTimer()

                        }
                        .onChange(of: points) { oldpoints, newPoints in
                            updateCirclePosition(points: newPoints)
                            resetTimer()

                        }
                        

                    imageOverlay(modelResult: handResultText)
                        .resizable()
                        .scaledToFit()
                        .frame(width: circleSize, height: circleSize)
                        .foregroundStyle(Color.lightOrange)
                        .position(circlePosition)
                    
//                    Text(handResultText)
//                        .foregroundStyle(.red)
//                        .position(circlePosition)
//                        .font(.largeTitle)
//                        .bold()
                }
            }
            .onReceive(camVM.$detectedGestureModel1, perform: { modelDetection in
                if modelDetection != "outros" && !pauseOverlay{
                    if camVM.videoFileOutput.isRecording && modelDetection == "iniciar" {
                        isHandTrackingActive = false
                    }else if !camVM.videoFileOutput.isRecording {
                        switch (modelDetection) {
                        case "topicar":
                            isHandTrackingActive = false
                        case "encerrar":
                            isHandTrackingActive = false
                        case "pausar":
                            isHandTrackingActive = false
                        case "iniciar":
                            isHandTrackingActive = true
                        default:
                            break
                        }
                    } else {
                        withAnimation(.smooth) {
                            isHandTrackingActive = true
                        }
                    }
                    handResultText = modelDetection
                    let totalConsecutiveDetections = 20
                    let progressIncrement = 1.0 / Double(totalConsecutiveDetections - 1)

                    // No código onde você incrementa o progresso
                    if modelDetection == lastDetectedModel {
                        consecutiveDetectionCount += 1
                        progress = min(progress + progressIncrement, 1.0) // Garante que o progresso não ultrapasse 1.0
                    } else {
                        // Se não for igual, resetamos o contador e atualizamos o último modelo detectado
                        consecutiveDetectionCount = 1 // Reinicia a contagem para 1
                        progress = progressIncrement // Reinicia o progresso para o incremento inicial
                        lastDetectedModel = modelDetection // Atualiza o último modelo detectado
                    }

                    if consecutiveDetectionCount >= totalConsecutiveDetections {
                        // Coloque o código que você quer executar aqui
                        camVM.finalModelDetection = modelDetection
                        // Aumenta o valor da variável progress em 2
                        progress = 1.0 // Define o progresso como completo (1.0)
                        
                        pauseOverlay = true

                        // Inicia um temporizador para definir pauseOverlay como false após 3 segundos
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            pauseOverlay = false
                        }

                        withAnimation(.easeOut(duration: 0.1)) {
                            progress = 0 // Reinicia o progresso após o preenchimento completo
                        }

                        consecutiveDetectionCount = 0 // Reinicia a contagem de detecções consecutivas
                        lastDetectedModel = nil // Reseta o último modelo detectado
                    } else if consecutiveDetectionCount == 0 {
                        // Se o contador for zerado, também zera a variável progress
                        withAnimation(.easeOut(duration: 0.1)) {
                            progress = 0 // Reinicia o progresso se não houver detecções consecutivas
                        }
                    }

                } else {
                    withAnimation(.easeOut(duration: 0.1)) {
                        isHandTrackingActive = false
                        progress = 0
                    }
                }
                
                print("final detection: \(camVM.finalModelDetection)")
                print("progress: \(progress)")
            })

            .onDisappear {
                timer?.invalidate()
            }
        }
    }

    
    func imageOverlay(modelResult: String) -> Image {
        switch(modelResult) {
        case "iniciar":
            return Image(systemName: "play.fill")
        case "pausar":
            return Image(systemName: "pause.fill")
        case "topicar":
            return Image(systemName: "stop")
        case "encerrar":
            return Image(systemName: "stop.fill")
        case "outros":
            return Image(systemName: "xmark")
        default:
            return Image(systemName: "xmark")
        }
    }

    // Funções auxiliares para controlar o temporizador
    func startTimer() {
        timer?.invalidate() // Cancela o temporizador atual se houver
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
            isHandTrackingActive = false // Define o tracking de mão como inativo após 1 segundo sem receber novos dados
        }
    }
    
    func resetTimer() {
        timer?.invalidate() // Cancela o temporizador atual se houver
        startTimer() // Reinicia o temporizador
    }

    func getProcessedPoints() -> [VNRecognizedPoint]? {
        guard let observationsBuffer = camVM.handPoseModelController?.observationsBuffer.last else {
            return nil
        }
        return try? camVM.handPoseModelController?.processPoints(from: observationsBuffer)
    }

    func calculateAverageDistance(points: [VNRecognizedPoint]) -> CGFloat {
        var distances: [CGFloat] = []

        for point1 in points {
            for point2 in points {
                let distance = sqrt(pow(point1.location.x - point2.location.x, 2) + pow(point1.location.y - point2.location.y, 2))
                distances.append(distance)
            }
        }

        return distances.reduce(0.0, +) / CGFloat(distances.count)
    }

    func updateCirclePosition(points: [VNRecognizedPoint]) {
        guard !points.isEmpty else {
            circlePosition = .zero
            circleSize = 0.0
            return
        }

        let averageX = points.reduce(0, { $0 + $1.location.x }) / CGFloat(points.count)
        let averageY = points.reduce(0, { $0 + $1.location.y }) / CGFloat(points.count)

        let maxX = size.width
        let maxY = size.height

        // Inverter a posição horizontal (eixo x) para compensar o espelhamento
        let invertedX = maxX - (averageX * maxX)

        // Inverter a posição vertical (eixo y) para compensar o espelhamento
        let invertedY = maxY - (averageY * maxY)

        if invertedX >= 0 && invertedX <= maxX && invertedY >= 0 && invertedY <= maxY {
            circlePosition = CGPoint(x: invertedX, y: invertedY)
            circleSize = calculateAverageDistance(points: points) * maxX
        } else {
            circlePosition = .zero
            circleSize = 0.0
        }

    }
}
