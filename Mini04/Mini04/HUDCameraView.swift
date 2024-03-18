//
//  HUDCameraView.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.
//

import SwiftUI


struct HUDCameraView: View {
    @EnvironmentObject var cameraVC: CameraViewModel
    @State private var isRecording = false
    @Binding var isPreviewShowing: Bool
    @State var isPreviewButtonDisabled = true
    
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                Button {
                    isPreviewShowing.toggle()
                    
                }label: {
                    Text("preview")
                }
                .disabled(isPreviewButtonDisabled)
            }
            Button {
                if !isRecording {
                    cameraVC.startRecording()
                    isRecording.toggle()
                } else {
                    cameraVC.stopRecording()
                    isRecording.toggle()
                    isPreviewButtonDisabled.toggle()
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
    HUDCameraView(isPreviewShowing: .constant(false))
}
