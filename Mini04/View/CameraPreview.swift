//
//  CameraPreview.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.
//

import SwiftUI

struct CameraPreview : View {
    @EnvironmentObject var cameraVC: CameraViewModel
    @State private var gestureTimer: Timer?
    @State private var lastDetectedGesture: String = ""
    @State private var isGestureStable: Bool = false

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack {
                CameraRepresentable(size: size)
                CameraOverlayView(size: size)
                // Overlay em cima da mao

                if cameraVC.countdownNumber > 0 {
                    Text("\(cameraVC.countdownNumber)")
                        .font(.largeTitle)
                }
            }
        }
        .onAppear {
            cameraVC.configureSession()
            cameraVC.startSession()
        }
        .onDisappear {
            cameraVC.stopSession()
        }

        .onReceive(cameraVC.$detectedGestureModel1, perform: { result in
            print(result)
            if result == lastDetectedGesture {
                // O mesmo gesto foi detectado novamente
                if !isGestureStable {
                    // Inicia o temporizador para verificar a estabilidade do gesto
                    isGestureStable = true
                    gestureTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                        // O gesto permaneceu estável por 1 segundo
                        cameraVC.finalModelDetection = result
                        isGestureStable = false
                    }
                }
            } else {
                // Um novo gesto foi detectado, reinicia o temporizador
                lastDetectedGesture = result
                gestureTimer?.invalidate()
                isGestureStable = false
            }
        })
    }
}
