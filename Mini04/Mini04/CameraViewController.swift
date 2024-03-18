//
//  CameraViewController.swift
//  Mini04
//
//  Created by luis fontinelles on 17/03/24.
//

import AppKit
import AVFoundation
import SwiftUI

class CameraViewController: NSViewController, ObservableObject {
    // MARK: - Vars
    var captureSession: AVCaptureSession!
    var cameraDevice: AVCaptureDevice!
    var inputDevice: AVCaptureInput!
    var micInput : AVCaptureInput!
    var micDevice : AVCaptureDevice!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var videoOutput: AVCaptureVideoDataOutput! //esse aqui pega cada frame e vai rodando num buffer
    var movieFileOutput = AVCaptureMovieFileOutput() //esse aqui é pra manipular o url de um arquivo

    var urltemp: URL?
    
    @Published var isRecording = false


    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //nao sei se setar a sessao da camera é melhor em didload ou did appear
//        setupAndStartCaptureSession()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        //permissao da camera nao é necessária no macOS 🤷‍♂️
        
        setupAndStartCaptureSession()
    }

    // MARK: - Camera Setup
    func setupAndStartCaptureSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession = AVCaptureSession()
            self.captureSession.beginConfiguration()

            if self.captureSession.canSetSessionPreset(.photo) {
                self.captureSession.sessionPreset = .photo
            }

            self.setupInputs()

            DispatchQueue.main.async {
                self.setupPreviewLayer()
            }

            self.setupOutput()
            self.captureSession.sessionPreset = .high
            self.captureSession.commitConfiguration()
            self.captureSession.startRunning()
        }
    }

    func setupInputs() {
        // solution insiped Jim Fisher's post: https://jameshfisher.com/2020/07/31/devicesfor-was-deprecated-in-macos-1015-use-avcapturedevicediscoverysession-instead/
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)
        // **********************************
        
        // discoverySession retorna um array de devices, eu pego o primeiro.
        if let device = discoverySession.devices.first {
            cameraDevice = device
        } else {
            fatalError("No front camera available")
        }
                
        guard let videoInput = try? AVCaptureDeviceInput(device: cameraDevice) else {
            fatalError("Could not create input device from camera")
        }
        inputDevice = videoInput
        
        if let microphoneDevice = AVCaptureDevice.default(for: .audio) {
            micDevice = microphoneDevice
        } else {
            fatalError("no mic")
        }
        
        guard let mInput = try? AVCaptureDeviceInput(device: micDevice) else {
            fatalError("no input mic")
        }
        micInput = mInput
        
        if !captureSession.canAddInput(micInput) {
            print("could not add mic input")
            return
        }

        if !captureSession.canAddInput(inputDevice) {
            fatalError("Could not add camera input to capture session")
        }

        captureSession.addInput(inputDevice)
        captureSession.addInput(micInput)

    }


    func setupOutput() {
        videoOutput = AVCaptureVideoDataOutput()
        let videoQueue = DispatchQueue(label: "videoQueue", qos: .userInteractive)
        
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        if captureSession.canAddOutput(movieFileOutput) {
            captureSession.addOutput(movieFileOutput)
        }
    }

    func setupPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer?.addSublayer(previewLayer)
        previewLayer.frame = self.view.frame
        // Espelhar horizontalmente a camada de pré-visualização
        previewLayer.connection?.automaticallyAdjustsVideoMirroring = false
        if previewLayer.connection?.isVideoMirroringSupported == true {
            previewLayer.connection?.isVideoMirrored = true
        }
    }
    
    func startRecording() {
        print("começou a gravar")
        let tempURL = NSTemporaryDirectory() + "\(Date()).mov"
        movieFileOutput.startRecording(to: URL(filePath: tempURL), recordingDelegate: self)
    }
    
    func stopRecording() {
//        speechManager.stopRecording()
        guard movieFileOutput.isRecording else {
            print("Nenhuma gravação em andamento.")
            return
        }
        
        movieFileOutput.stopRecording()
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Handle captured video frames here
    }
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        print("nome do arquivo: \(outputFileURL)")
        
        self.urltemp = outputFileURL
    }
    
}

struct CameraViewRepresentable: NSViewControllerRepresentable {
    @EnvironmentObject var cameraVC: CameraViewController

    func makeNSViewController(context: Context) -> CameraViewController {
        let viewController = CameraViewController()
        return viewController
    }

    func updateNSViewController(_ nsViewController: CameraViewController, context: Context) {}

    typealias NSViewControllerType = CameraViewController
}
