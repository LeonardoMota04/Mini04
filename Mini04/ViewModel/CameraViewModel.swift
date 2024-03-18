//
//  File.swift
//  Mini04
//
//  Created by luis fontinelles on 18/03/24.
//

import SwiftUI
import AVFoundation
import AppKit

class CameraViewModel: NSObject, ObservableObject {
    var cameraDevice: AVCaptureDevice!
    var cameraInput: AVCaptureInput!
    var micDevice: AVCaptureDevice!
    var micInput: AVCaptureInput!
    
    var previewLayer =  AVCaptureVideoPreviewLayer()
    @Published var videoFileOutput = AVCaptureMovieFileOutput()
    @Published var audioOutput = AVCaptureAudioDataOutput()
    @Published var captureSession =  AVCaptureSession()

    @Published var isRecording = false

    var urltemp: URL?
    
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
    }
    
    func startRecording() {
        isRecording = true
        print("começou a gravar")
        let tempURL = NSTemporaryDirectory() + "\(Date()).mov"
        videoFileOutput.startRecording(to: URL(filePath: tempURL), recordingDelegate: self)
    }
    
    func stopRecording() {
        isRecording = false
        guard videoFileOutput.isRecording else {
            print("Nenhuma gravação em andamento.")
            return
        }
        
        videoFileOutput.stopRecording()
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
            view.layer?.addSublayer(self.camVM.previewLayer)
        }

        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        // Atualizações de visualização, se necessário
    }
}

