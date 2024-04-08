//
//  HandGestureController.swift
//  speechToText
//
//  Created by luis fontinelles on 29/02/24.
//

import CoreML
import Vision
import AVFoundation


class HandGestureController: ObservableObject {
    
    var model1: HandPoseV1?
    let handPoseRequest = VNDetectHumanHandPoseRequest()
    var observationsBuffer: [VNHumanHandPoseObservation] = []
    var onUpdatePoints: (([VNRecognizedPoint]) -> Void)?
    @Published var resulHandPoseModel: String = "" {
        didSet {
            self.onResultModel1Changed?(self.resulHandPoseModel)
        }
    }
    
    @Published var isHandIdentified: Bool = false {
        didSet {
            self.onHandIdentificationChanged?(self.isHandIdentified)
        }
    }
    var onHandIdentificationChanged: ((Bool) -> Void)?
    
    var onResultModel1Changed: ((String) -> Void)?

    
    init() {
        handPoseRequest.maximumHandCount = 1
        setupModel1()
    }
    
    private func setupModel1() {
        do {
            model1 = try HandPoseV1(configuration: MLModelConfiguration())
            print("Model1 successfully configured.")
        } catch {
            print("Failed to load ML model1: \(error)")
        }
    }

    func performHandPoseRequest(sampleBuffer: CMSampleBuffer) {
        
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        do {
            try handler.perform([handPoseRequest])
            guard let observation = handPoseRequest.results?.first as? VNHumanHandPoseObservation else {
                return
            }
            
            observationsBuffer.append(observation)
            if observationsBuffer.count > 1 {
                observationsBuffer.removeFirst(observationsBuffer.count - 1)
            }
            
            guard observationsBuffer.count == 1 else { return }
            
            
            let multiArray = try MLMultiArray(shape: [1, 3, 21], dataType: .float32)
            for (frameIndex, frameObservation) in observationsBuffer.enumerated() {
                let processedPoints = try processPoints(from: frameObservation)
                for (index, point) in processedPoints.enumerated() {
                    let x = point.location.x
                    let y = point.location.y
                    let confidence = point.confidence
                    
                    multiArray[[frameIndex, 0, index] as [NSNumber]] = NSNumber(value: x)
                    multiArray[[frameIndex, 1, index] as [NSNumber]] = NSNumber(value: y)
                    multiArray[[frameIndex, 2, index] as [NSNumber]] = NSNumber(value: confidence)
                }
            }
            
            if let onUpdatePoints = self.onUpdatePoints {
                do {
                    let processedPoints = try processPoints(from: observation)
                    onUpdatePoints(processedPoints)
                } catch {
                    print("Error processing points: \(error)")
                }
            }
            
            if let model = model1 {
                let input = HandPoseV1Input(poses: multiArray)
                let result = try model.prediction(input: input)
                DispatchQueue.main.async {
                    let formattedProbabilities = result.labelProbabilities.map { label, probability in
                        return "\(label): \(String(format: "%.2f%%", probability * 100))"
                    }.joined(separator: ", ")
                    print("Label: \(result.label), Label Probabilities: \(formattedProbabilities)")
                    print(type(of: result.label))
                    self.resulHandPoseModel = result.label
                }
            }
            
        } catch {
            print("Error during hand pose request: \(error)")
        }
    }
    
    func processPoints(from observation: VNHumanHandPoseObservation) throws -> [VNRecognizedPoint] {
        let pointsOfInterest: [VNHumanHandPoseObservation.JointName] = [
            .wrist,
            .thumbCMC, .thumbMP, .thumbIP, .thumbTip,
            .indexMCP, .indexPIP, .indexDIP, .indexTip,
            .middleMCP, .middlePIP, .middleDIP, .middleTip,
            .ringMCP, .ringPIP, .ringDIP, .ringTip,
            .littleMCP, .littlePIP, .littleDIP, .littleTip
        ]
        
        var extractedPoints: [VNRecognizedPoint] = []
        
        for jointName in pointsOfInterest {
            let point = try observation.recognizedPoint(jointName)
            
            guard point.confidence > 0.1 else {
                throw NSError(domain: "com.example.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Point \(jointName) has low confidence. Confidence: \(point.confidence)"])
            }
            extractedPoints.append(point)
        }
        
        guard extractedPoints.count == pointsOfInterest.count else {
            throw NSError(domain: "com.example.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not all points were found."])
        }
        
        return extractedPoints
    }
    
    func performHandPoseRequestShort(sampleBuffer: CMSampleBuffer) {
        
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                return
            }
            
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .down, options: [:])
            do {
                try handler.perform([handPoseRequest])
                // observation sao os pontos que ele detecta
                guard let observation = handPoseRequest.results?.first as? VNHumanHandPoseObservation else {
                    return
                }
                
                observationsBuffer.append(observation)
                
                guard let keypointsMultiArray = try? observation.keypointsMultiArray() else { return }
                
                if let model = model1 {
                    let handPosePrediction = try model.prediction(poses: keypointsMultiArray)
                    let confidence = handPosePrediction.labelProbabilities[handPosePrediction.label]
                    
                    if confidence != nil {
                        renderHandPoseEffect(name: handPosePrediction.label)
                        print("Result Hand: \(handPosePrediction.label)")
                    }
                }
            } catch {
                print("Error during hand pose request: \(error)")
            }
    }
    
    func renderHandPoseEffect(name: String) {
        switch name {
        case "iniciar":
            self.resulHandPoseModel = "iniciar"
            print("Result Model HandPose: iniciar")
        case "pausar":
            self.resulHandPoseModel = "pausar"
            print("Result Model HandPose: pausar")
        case "topicar":
            self.resulHandPoseModel = "topicar"
            print("Result Model HandPose: topicar")
        case "encerrar":
            self.resulHandPoseModel = "encerrar"
            print("Result Model HandPose: encerrar")
        case "outros":
            self.resulHandPoseModel = "outros"
            print("Result Model HandPose: outros")
        default:
            self.resulHandPoseModel = "outros"
            print("Result Model HandPose: outros")
        }
    }
}

