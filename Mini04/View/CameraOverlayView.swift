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
    @State private var timer: Timer? // Temporizador para controlar a transição de estado
    @State private var constantDetectionTimer: Timer? // Temporizador para detectar detecções constantes
    @State private var lastDetectionValue: String? // Último valor de detecção
    @State private var timerPublisher = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    @State private var progress: Double = 0.0
    let animationDuration: Double = 2 // Duração da animação de preenchimento do trim
    @State var isAnimating = false
    @State private var tempDetectionValue: String? // Variável temporária para armazenar o valor de modelDetection

    var body: some View {
        if let points = getProcessedPoints() {
            ZStack {
                if isHandTrackingActive { // Verifica se o tracking de mão está ativo
                    Circle()
                        .trim(from: 0.0, to: CGFloat(self.progress))
                        .stroke(style: StrokeStyle(lineWidth: calculateAverageDistance(points: points) * size.width / 10, lineCap: .round, lineJoin: .round))
                        .rotationEffect(.degrees(-90))
                        .foregroundColor(.red)
                        .frame(width: circleSize * 1.5, height: circleSize * 1.5)
                        .position(circlePosition)
                        .onAppear {
                            updateCirclePosition(points: points)
                            isHandTrackingActive = true
                            startTimer()
                        }
                        .onChange(of: points) { oldpoints, newPoints in
                            updateCirclePosition(points: newPoints)
                            resetTimer() // Reinicia o temporizador ao receber novos pontos
                        }
                        .onReceive(timerPublisher) { _ in
                            constantDetectionTimer?.invalidate()
                            constantDetectionTimer = Timer.scheduledTimer(withTimeInterval: animationDuration, repeats: false) { _ in
                                camVM.finalModelDetection = lastDetectionValue ?? "aaaaa"
                            }
                        }

                    Text(handResultText)
                        .foregroundStyle(.red)
                        .position(circlePosition)
                        .font(.largeTitle)
                        .bold()
                }
            }
            .onReceive(camVM.$detectedGestureModel1, perform: { modelDetection in
                if modelDetection != "Other" {
                    handResultText = modelDetection
                    isHandTrackingActive = true
                    startTimer()
                    isAnimating = true

                    if let lastValue = lastDetectionValue {
                        if modelDetection == lastValue {
                            tempDetectionValue = modelDetection
                        } else {
                            tempDetectionValue = nil
                            isAnimating = false

                        }
                    } else {
                        lastDetectionValue = modelDetection
                        isAnimating = true
                        progress = 0
                    }
                } else {
                    isHandTrackingActive = false
                    isAnimating = false
                }

                if isAnimating && modelDetection != camVM.finalModelDetection{
                    withAnimation(Animation.linear(duration: 3).repeatForever(autoreverses: false)) {
                        self.progress = 1.0
                    }
                } else {
                    isHandTrackingActive = false
                    progress = 0
                }

                print("final detection: \(camVM.finalModelDetection)")
            })
            .onReceive(timerPublisher) { _ in
                if let tempValue = tempDetectionValue {
                    camVM.finalModelDetection = tempValue
                    lastDetectionValue = tempValue
                    tempDetectionValue = nil
                }
            }
        }
    }

    // Funções auxiliares para controlar o temporizador
    func startTimer() {
        timer?.invalidate() // Cancela o temporizador atual se houver
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
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

        if averageX >= 0 && averageX <= maxX && averageY >= 0 && averageY <= maxY {
            circlePosition = CGPoint(x: averageX * maxX, y: averageY * maxY)
            circleSize = calculateAverageDistance(points: points) * maxX
        } else {
            circlePosition = .zero
            circleSize = 0.0
        }
    }
}
