//
//  RecordingVideoView.swift
//  Mini04
//
//  Created by luis fontinelles on 17/03/24.
//

import SwiftUI

struct RecordingVideoView: View {
    var body: some View {
        GeometryReader { reader in
            VStack {
                CameraPreview()
//                    
                HUDCameraView()
                    .frame(maxWidth: reader.size.width)
                    .frame(height: reader.size.height*0.1)
            }
        }
    }
}

struct HUDCameraView: View {
    @EnvironmentObject var cameraVC: CameraViewModel
    @State private var isRecording = false

    var body: some View {
        VStack {
            Button {
                if !isRecording {
                    cameraVC.startRecording()
                    isRecording.toggle()
                } else {
                    cameraVC.stopRecording()
                    isRecording.toggle()
                }
            } label: {
                ZStack {
                    Circle()
                        .foregroundStyle(isRecording ? .gray : .red)
                }
            }
            .buttonStyle(.borderless)
        }
        .padding(4)
    }
}

#Preview {
    RecordingVideoView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}

