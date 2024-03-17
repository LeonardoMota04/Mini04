//
//  CameraViewController.swift
//  Mini04
//
//  Created by luis fontinelles on 17/03/24.
//

import AppKit
import AVFoundation
import SwiftUI

class CameraViewController: NSViewController {
    // MARK: - Vars
    var captureSession: AVCaptureSession!
    var cameraDevice: AVCaptureDevice!
    var inputDevice: AVCaptureInput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var videoOutput: AVCaptureVideoDataOutput!

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        checkPermissions()
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

            self.captureSession.commitConfiguration()
            self.captureSession.startRunning()
        }
    }

    func setupInputs() {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)
        if let device = discoverySession.devices.first {
            cameraDevice = device
        } else {
            fatalError("No front camera available")
        }

        guard let videoInput = try? AVCaptureDeviceInput(device: cameraDevice) else {
            fatalError("Could not create input device from camera")
        }
        inputDevice = videoInput

        if !captureSession.canAddInput(inputDevice) {
            fatalError("Could not add camera input to capture session")
        }

        captureSession.addInput(inputDevice)
    }


    func setupOutput() {
        videoOutput = AVCaptureVideoDataOutput()
        let videoQueue = DispatchQueue(label: "videoQueue", qos: .userInteractive)
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)

        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        } else {
            fatalError("Could not add video output")
        }
    }

    func setupPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer?.addSublayer(previewLayer)
        previewLayer.frame = self.view.frame
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Handle captured video frames here
    }
}

struct CameraViewRepresentable: NSViewControllerRepresentable {
    func makeNSViewController(context: Context) -> CameraViewController {
        let viewController = CameraViewController()
        return viewController
    }

    func updateNSViewController(_ nsViewController: CameraViewController, context: Context) {}

    typealias NSViewControllerType = CameraViewController
}

/// MARK: - authorization
extension CameraViewController {
    //MARK: - Permissions
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case.authorized:
//            configureSession()
            return
        case.notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (status) in
                if status {
//                    self.configureSession()
                }
            }
        case.denied:
//            self.alert.toggle()
            return
        default:
            return
        }
    }
}
