//
//  CameraViewController.swift
//  iFlex
//
//  Created by Spencer Steggell on 11/13/24.
//

import Foundation
import UIKit
import AVFoundation


class CameraViewController: UIViewController {
    
    //MARK: Properties
    
    weak var albums: FitnessAlbum!
    
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var capturePhotoOutput: AVCapturePhotoOutput!
    var backgroundPreviewLayer: AVCaptureVideoPreviewLayer!
    var previewContainerView = UIView()
    var backgroundContainerView = UIView()
    
    var takePhotoButton = UIButton()
    var flipCameraButton = UIButton()
    var delayPhotoButton = UIButton()
    var slider = UISlider()
    
    var overlayImageView: UIImageView?
    var overlayImage: UIImage?
    var isUsingFrontCamera: Bool = true
    var gradientLayer: CAGradientLayer!
    
    var timerEnabled = false
    var countdownLabel = UILabel()
    var countdownTimer: Timer?
    var countdownValue = 5
    
    //MARK: ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPreviewContainerView()
        //setupCameraSession()
        checkCameraAuthorizationStatus()
        setupUIElements()
        setupCountdownLabel()
        
        if let overlayImage = overlayImage {
            setupOverlayImageView(with: overlayImage)
            flipOverlayImage()
            slider.isHidden = false
        }
        else {
            slider.isHidden = true
        }
        
        navigationController?.isToolbarHidden = true
        
        if let gradientImage = ColorManager.shared.createGradientImage(size: view.bounds.size) {
            view.backgroundColor = UIColor(patternImage: gradientImage)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let captureSession = captureSession, captureSession.isRunning {
            captureSession.stopRunning()
        }
        navigationController?.isToolbarHidden = false
    }
    
    //MARK: Setup Methods - Camera
    
    func setupCameraSession() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        do {
            var defaultVideoDevice: AVCaptureDevice?
            
            // Choose the back dual camera, if available, otherwise default to a wide angle camera.
            if let dualCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                defaultVideoDevice = dualCameraDevice
            } else if let dualWideCameraDevice = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back) {
                // If a rear dual camera is not available, default to the rear dual wide camera.
                defaultVideoDevice = dualWideCameraDevice
            } else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                // If a rear dual wide camera is not available, default to the rear wide angle camera.
                defaultVideoDevice = backCameraDevice
            } else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                // If the rear wide angle camera isn't available, default to the front wide angle camera.
                defaultVideoDevice = frontCameraDevice
            }
            guard let videoDevice = defaultVideoDevice
            else {
                print("Default device not available")
                captureSession.commitConfiguration()
                return
            }
            
            let input = try AVCaptureDeviceInput(device: videoDevice)
            
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            capturePhotoOutput = AVCapturePhotoOutput()
            if captureSession.canAddOutput(capturePhotoOutput) {
                captureSession.addOutput(capturePhotoOutput)
            }
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer.videoGravity = .resizeAspect
            videoPreviewLayer.frame = view.layer.bounds
            //videoPreviewLayer.frame = previewContainerView.bounds
            //view.layer.addSublayer(videoPreviewLayer)
            previewContainerView.layer.addSublayer(videoPreviewLayer)
            view.bringSubviewToFront(previewContainerView)
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        } catch {
            print("Error setting up camera: \(error)")
        }
    }
    
    
    
    //MARK: Setup Methods - Views
    
    func setupPreviewContainerView() {
        previewContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(previewContainerView)
        
        NSLayoutConstraint.activate([
            previewContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            previewContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        view.bringSubviewToFront(previewContainerView)
    }
    
    func setupBackgroundContainerView() {
        backgroundContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundContainerView)
        
        NSLayoutConstraint.activate([
            backgroundContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    //MARK: Setup Methods - UI
    
    func setupUIElements() {
        // Take Photo Button
        takePhotoButton.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        //takePhotoButton.tintColor = .systemCyan
        takePhotoButton.translatesAutoresizingMaskIntoConstraints = false
        takePhotoButton.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        takePhotoButton.contentVerticalAlignment = .fill
        takePhotoButton.contentHorizontalAlignment = .fill
        view.addSubview(takePhotoButton)
        
        // Flip Camera Button
        flipCameraButton.setImage(UIImage(systemName: "camera.rotate"), for: .normal)
        flipCameraButton.translatesAutoresizingMaskIntoConstraints = false
        //flipCameraButton.tintColor = .systemCyan
        flipCameraButton.addTarget(self, action: #selector(flipCamera), for: .touchUpInside)
        flipCameraButton.contentVerticalAlignment = .fill
        flipCameraButton.contentHorizontalAlignment = .fill
        view.addSubview(flipCameraButton)
        
        // Delay Photo Button
        delayPhotoButton.setImage(UIImage(systemName: "timer"), for: .normal)
        delayPhotoButton.tintColor = .lightGray
        delayPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        delayPhotoButton.addTarget(self, action: #selector(delayPhoto), for: .touchUpInside)
        delayPhotoButton.contentVerticalAlignment = .fill
        delayPhotoButton.contentHorizontalAlignment = .fill
        view.addSubview(delayPhotoButton)
        
        // Slider
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(sliderDidChange), for: .valueChanged)
        slider.maximumValue = 0.5
        slider.value = 0.25
        view.addSubview(slider)
        
        setupConstraints()
        view.bringSubviewToFront(takePhotoButton)
        view.bringSubviewToFront(flipCameraButton)
        view.bringSubviewToFront(delayPhotoButton)
        view.bringSubviewToFront(slider)
    }
    
    
    //MARK: Setup Methods - Constraints
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            takePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            takePhotoButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            takePhotoButton.widthAnchor.constraint(equalToConstant: 80),
            takePhotoButton.heightAnchor.constraint(equalToConstant: 80),
            
            flipCameraButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            flipCameraButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            flipCameraButton.widthAnchor.constraint(equalToConstant: 50),
            flipCameraButton.heightAnchor.constraint(equalToConstant: 40),
            
            delayPhotoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            delayPhotoButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            delayPhotoButton.widthAnchor.constraint(equalToConstant: 40),
            delayPhotoButton.heightAnchor.constraint(equalToConstant: 40),
            
            slider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            slider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            slider.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
        ])
    }
    
    func setupOverlayImageView(with image: UIImage) {
        
        overlayImageView = UIImageView(image: image)
        overlayImageView?.translatesAutoresizingMaskIntoConstraints = false
        overlayImageView?.contentMode = .scaleAspectFit
        overlayImageView?.alpha = CGFloat(slider.value)// Make it semi-transparent to compare easily
        overlayImageView?.isUserInteractionEnabled = false
        view.addSubview(overlayImageView!)
        
        NSLayoutConstraint.activate([
            overlayImageView!.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayImageView!.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayImageView!.topAnchor.constraint(equalTo: view.topAnchor),
            overlayImageView!.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.bringSubviewToFront(takePhotoButton)
        view.bringSubviewToFront(flipCameraButton)
        view.bringSubviewToFront(delayPhotoButton)
        view.bringSubviewToFront(slider)
    }
    
    //MARK: User Actions
    
    @objc func takePhoto() {
        if timerEnabled {
            startCountdown()
            
        } else {
            capturePhotoNow()
        }
    }
    func capturePhotoNow(){
        flashAnimation()
        let settings = AVCapturePhotoSettings()
        capturePhotoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    
    @objc func flipCamera() {
        print("Flipping cmaera...")
        flippingCameraAnimation()
        flipOverlayImage()
        // Use a background queue to reconfigure the camera session
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.beginConfiguration()
            
            guard let currentInput = self.captureSession.inputs.first as? AVCaptureDeviceInput else {
                DispatchQueue.main.async {
                    print("Failed to get current input.")
                }
                return
            }
            
            // Remove the current input
            self.captureSession.removeInput(currentInput)
            
            let newCameraDevice: AVCaptureDevice?
            if currentInput.device.position == .back {
                newCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
                self.isUsingFrontCamera = true
            } else {
                newCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
                self.isUsingFrontCamera = false
            }
            
            do {
                if let newCameraDevice = newCameraDevice {
                    let newInput = try AVCaptureDeviceInput(device: newCameraDevice)
                    if self.captureSession.canAddInput(newInput) {
                        self.captureSession.addInput(newInput)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    print("Error switching cameras: \(error)")
                }
            }
            self.captureSession.commitConfiguration()
        }
    }
    
    @objc func delayPhoto() {
        timerEnabled.toggle()
        delayPhotoButton.tintColor = timerEnabled ? .accent : .lightGray
        print("Timer enabled: \(timerEnabled)")
    }
    
    @objc func sliderDidChange(_ slider: UISlider) {
        print("slider value: \(slider.value)")
        overlayImageView?.alpha = CGFloat(slider.value)
    }
    
    
    // MARK: - Helper Methods
    
    func checkCameraAuthorizationStatus() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCameraSession()
            setupUIElements()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else {
                    self?.exitCameraView()
                    return
                }
                DispatchQueue.main.async {
                    self?.setupCameraSession()
                    self?.setupUIElements()
                }
            }
        case .denied, .restricted:
            exitCameraView()
        @unknown default:
            exitCameraView()
        }
    }
    
    
    func exitCameraView() {
        let alertController = UIAlertController(
            title: "Camera Access Required",
            message: "To use the camera features of iFlex, please enable camera access in your device settings.",
            preferredStyle: .alert
        )
        
        // Add the "Settings" action that takes the user to the settings
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(appSettings) {
                    UIApplication.shared.open(appSettings)
                }
            }
        }
        
        // Add a "Cancel" action that dismisses the view controller
        let cancelAction = UIAlertAction(title: "OK", style: .default) { (_) in
            if let navigationController = self.navigationController {
                navigationController.popViewController(animated: true)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        // Add actions to the alert controller
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        // Present the alert controller
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    //    func exitCameraView() {
    //        DispatchQueue.main.async {
    //                   self.navigationController?.popViewController(animated: true)
    //               }
    //    }
    
    
    func setupCountdownLabel() {
        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        countdownLabel.textColor = .white
        countdownLabel.font = UIFont(name: "Black Ops One", size: 100)
        countdownLabel.textAlignment = .center
        countdownLabel.alpha = 0.0 // Initially hidden
        view.addSubview(countdownLabel)
        
        NSLayoutConstraint.activate([
            countdownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countdownLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // Timer Countdown Animation
    func startCountdown() {
        countdownValue = 5
        countdownLabel.text = "\(countdownValue)"
        countdownLabel.alpha = 0.75
        
        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
    }
    
    @objc func updateCountdown() {
        countdownValue -= 1
        countdownLabel.text = "\(countdownValue)"
        
        if countdownValue == 0 {
            countdownTimer?.invalidate()
            countdownLabel.alpha = 0.0
            capturePhotoNow()
            countdownValue = 5
            countdownLabel.text = "\(countdownValue)"
        }
    }
    
    
    func flipOverlayImage() {
        guard let currentImage = overlayImageView?.image else {
            print("No overlay image to flip.")
            return
        }
        
        // Flip the image horizontally
        let flippedImage = currentImage.withHorizontallyFlippedOrientation().imageFlippedForRightToLeftLayoutDirection()
        
        // Update the overlay image view with the flipped image
        overlayImageView?.image = flippedImage
    }
    
    
    
    //MARK: Animations
    
    func flippingCameraAnimation() {
        // Adding the flip transition animation for the camera view
        if overlayImageView != nil{
            UIView.transition(with: overlayImageView!, duration: 1.5, options: .transitionFlipFromLeft, animations: nil)
        }
        UIView.transition(with: previewContainerView, duration: 1.5, options: .transitionFlipFromLeft, animations: {
        }) { finished in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                // Updating overlay image alpha after the flip animation
                self.overlayImageView?.alpha = CGFloat(self.slider.value)
                
                // Bringing the UI elements back to the front to ensure they're interactive
                self.view.bringSubviewToFront(self.takePhotoButton)
                self.view.bringSubviewToFront(self.flipCameraButton)
                self.view.bringSubviewToFront(self.delayPhotoButton)
                self.view.bringSubviewToFront(self.slider)
            }
        }
    }
    
    func flashAnimation() {
        let flashView = UIView(frame: previewContainerView.frame)
        flashView.backgroundColor = .white
        flashView.alpha = 0.0
        view.addSubview(flashView)
        
        UIView.animate(withDuration: 0.1, animations: {
            flashView.alpha = 1.0
            AudioServicesPlayAlertSound(1108)
        }) {_ in
            UIView.animate(withDuration: 0.1, animations: {
                flashView.alpha = 0.0
            }) {_ in
                flashView.removeFromSuperview()
            }
        }
    }
}

//MARK: Camera Delegate

//Taking a photo:

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let photoData = photo.fileDataRepresentation() else {
            return
        }
        
        guard let image = UIImage(data: photoData) else {
            return
        }
        let newImage = rotateImage(image: image)
        savePhotoToAlbum(image: (newImage)!)
    }
    
    func savePhotoToAlbum(image: UIImage) {
        guard let album = albums else {
            print("Album is not set")
            return
        }
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        context.perform {
            let newPhoto = ProgressPhotos(context: context)
            newPhoto.creationDate = Date()
            newPhoto.imageData = image.jpegData(compressionQuality:   0.8)
            newPhoto.album = self.albums
            
            if album.coverPhoto == nil || album.photos?.count == 0 {
                album.coverPhoto = newPhoto.imageData
            }
            
            album.addToPhotos(newPhoto)
            // Update the cover photo for the album if this is the latest photo
            album.coverPhoto = image.jpegData(compressionQuality: 0.8)
            
            do {
                try context.save()
                
                
                print("Photo successfully saved to album.")
                let photoCount = album.photos?.count ?? 0
                print("Album \(album.name!) now has \(photoCount) photos.")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
            } catch {
                print("Failed to save photo to album: \(error)")
            }
        }
    }
    
    //Photo saves in wrong orientation, rotate image when savied so overlay can properly display
    func rotateImage(image: UIImage) -> UIImage? {
        if (image.imageOrientation == UIImage.Orientation.up ) {
            return image
        }
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        let copy = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return copy
    }
}
