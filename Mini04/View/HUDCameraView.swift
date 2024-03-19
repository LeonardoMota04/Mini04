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
    @State var isSaveButtonDisabled = true
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                HStack {
                    Spacer()
                    Button {
                        isPreviewShowing.toggle()
                        
                    }label: {
                        Text("save")
                    }
                    .disabled(isSaveButtonDisabled)
                }
                Button {
                    if !isRecording {
                        cameraVC.startRecording()
                        isRecording.toggle()
                    } else {
                        cameraVC.stopRecording()
                        isRecording.toggle()
                        isSaveButtonDisabled.toggle()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .foregroundStyle(isRecording ? .gray : .red)
                    }
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(4)

    }
}


#Preview {
    HUDCameraView(isPreviewShowing: .constant(false))
}
