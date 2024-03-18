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
                CameraViewRepresentable()
                HUDCameraView()
                    .frame(maxWidth: reader.size.width)
                    .frame(height: reader.size.height*0.1)
            }
        }
    }
}

#Preview {
    RecordingVideoView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}

struct HUDCameraView: View {
    @EnvironmentObject var cameraVC: CameraViewController
    @State var isRecording = false
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
                    if isRecording {
                        Circle()
                            .foregroundStyle(.red)

                    }else {
                        Circle()
                            .foregroundStyle(.gray)

                    }
                    Circle()
                        .foregroundStyle(isRecording ? .gray : .red)
                }
            }
            .buttonStyle(.borderless)
            
        }
        .background(Color.clear)
        .padding(4)
        
    }
}
