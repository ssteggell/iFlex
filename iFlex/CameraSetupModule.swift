//
//  CameraSetupModule.swift
//  iFlex
//
//  Created by Spencer Steggell on 11/13/24.
//

//import Foundation
//import UIKit
//import AVFoundation
//
//class CameraSetupModule {
//    
//    
//    func setupCameraSession() {
//        captureSession = AVCaptureSession()
//        captureSession.sessionPreset = .photo
//        
//        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
//            print("Unable to access back camera!")
//            return
//        }
//        
//        do {
//            let input = try AVCaptureDeviceInput(device: backCamera)
//            if captureSession.canAddInput(input) {
//                captureSession.addInput(input)
//            }
//            
//            capturePhotoOutput = AVCapturePhotoOutput()
//            if captureSession.canAddOutput(capturePhotoOutput) {
//                captureSession.addOutput(capturePhotoOutput)
//            }
//            
//            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//            videoPreviewLayer.videoGravity = .resizeAspectFill
//            videoPreviewLayer.frame = view.layer.bounds
//            view.layer.addSublayer(videoPreviewLayer)
//            
//            captureSession.startRunning()
//        } catch {
//            print("Error setting up camera: \(error)")
//        }
//    }
//    
//    func setupUIElements() {
//        // Take Photo Button
//        takePhotoButton.setImage(UIImage(systemName: "circle.fill"), for: .normal)
//        takePhotoButton.tintColor = .lightGray
//        takePhotoButton.translatesAutoresizingMaskIntoConstraints = false
//        takePhotoButton.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
//        takePhotoButton.contentVerticalAlignment = .fill
//        takePhotoButton.contentHorizontalAlignment = .fill
//        view.addSubview(takePhotoButton)
//        
//        // Flip Camera Button
//        flipCameraButton.setImage(UIImage(systemName: "camera.rotate"), for: .normal)
//        flipCameraButton.translatesAutoresizingMaskIntoConstraints = false
//        flipCameraButton.tintColor = .lightGray
//        flipCameraButton.addTarget(self, action: #selector(flipCamera), for: .touchUpInside)
//        flipCameraButton.contentVerticalAlignment = .fill
//        flipCameraButton.contentHorizontalAlignment = .fill
//        view.addSubview(flipCameraButton)
//        
//        // Delay Photo Button
//        delayPhotoButton.setImage(UIImage(systemName: "timer"), for: .normal)
//        delayPhotoButton.tintColor = .lightGray
//        delayPhotoButton.translatesAutoresizingMaskIntoConstraints = false
//        delayPhotoButton.addTarget(self, action: #selector(delayPhoto), for: .touchUpInside)
//        delayPhotoButton.contentVerticalAlignment = .fill
//        delayPhotoButton.contentHorizontalAlignment = .fill
//        view.addSubview(delayPhotoButton)
//        
//        // Slider
//        slider.translatesAutoresizingMaskIntoConstraints = false
//        slider.tintColor = .lightGray
//        slider.minimumValue = 0.0
//        slider.maximumValue = 0.5
//        slider.value = 0.25
//        view.addSubview(slider)
//        
//        setupConstraints()
//    }
//    
//    func setupConstraints() {
//        NSLayoutConstraint.activate([
//            takePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            takePhotoButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
//            takePhotoButton.widthAnchor.constraint(equalToConstant: 80),
//            takePhotoButton.heightAnchor.constraint(equalToConstant: 80),
//            
//            flipCameraButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
//            flipCameraButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            
//            flipCameraButton.widthAnchor.constraint(equalToConstant: 50),
//            flipCameraButton.heightAnchor.constraint(equalToConstant: 40),
//            
//            delayPhotoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            delayPhotoButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
//            delayPhotoButton.widthAnchor.constraint(equalToConstant: 40),
//            delayPhotoButton.heightAnchor.constraint(equalToConstant: 40),
//            
//            slider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            slider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            slider.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
//        ])
//    }
//    
//}
