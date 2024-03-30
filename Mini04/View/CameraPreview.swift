//
//  CameraPreview.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.
//

import SwiftUI

struct CameraPreview : View {
    @EnvironmentObject var cameraVC: CameraViewModel
    @State private var isCameraConfigured = false

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack {
                CameraRepresentable(size: size)
                //pverlay em cima da mao
                CameraOverlayView(size: size)
                if isCameraConfigured {
                    if cameraVC.countdownNumber > 0 {
                        Text("\(cameraVC.countdownNumber)")
                            .font(.largeTitle)
                            .bold()
                            .scaleEffect(2)
                    }
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
        }
        
        .onAppear {
            // depois que condigure session é rodada que incia a sessao
            cameraVC.configureSession {
                isCameraConfigured = true
                cameraVC.startSession()
            }
        }
        .onDisappear {
            cameraVC.stopSession()
        }
    }
}
