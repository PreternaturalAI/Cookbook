//
//  CameraView.swift
//  HealthApp
//
//  Created by Jared Davidson on 3/12/24.
//

import Foundation
import AVFoundation
import SwiftUIX

// MARK: - SwiftUI Camera View
struct CameraView: View {
    @State private var image: _AnyImage?
    @State private var cameraPosition: AVCaptureDevice.Position = .back
    @State private var flashMode: AVCaptureDevice.FlashMode = .off
    @State private var takePhoto: Bool = false
    @Binding var showing: Bool
    @Environment(\.presentationMode) var presentationMode
    
    var didTakePhoto: (_ photo: _AnyImage) -> Void

    var body: some View {
        VStack {
            cameraContentView
            actionButton
        }
        .background(Color.black.ignoresSafeArea())
        .onChange(of: showing) { _, newValue in
            if !newValue { image = nil }
        }
    }
    
    @ViewBuilder
    var cameraContentView: some View {
        if showing {
            RoundedRectangle(cornerRadius: 15)
                .overlay(cameraOverlay)
                .frame(maxHeight: .infinity)
                .cornerRadius(15)
                .padding(10)
        } else {
            Color.black.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    @ViewBuilder
    var cameraOverlay: some View {
        if let image = image {
            Image(image: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            CustomCameraRepresentable(
                image: $image,
                cameraPosition: $cameraPosition,
                flashMode: $flashMode,
                takePhoto: $takePhoto
            )
        }
    }
    
    @ViewBuilder
    var actionButton: some View {
        if let image = image {
            confirmButton(for: image)
        } else {
            takePhotoButton
        }
    }
    
    func confirmButton(for image: _AnyImage) -> some View {
        Button {
            didTakePhoto(image)
        } label: {
            Image(systemName: "checkmark")
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
                .background(Color.green.opacity(0.8))
                .clipShape(Circle())
                .padding(.bottom)
        }
    }
    
    var takePhotoButton: some View {
        Button(action: {
            self.takePhoto.toggle()
        }) {
            Image(systemName: "circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
                .clipShape(Circle())
                .padding(.bottom)
        }
    }
}


// MARK: - UIKit Wrapper
struct CustomCameraRepresentable: AppKitOrUIKitViewControllerRepresentable {
    @Binding var image: _AnyImage?
    @Binding var cameraPosition: AVCaptureDevice.Position
    @Binding var flashMode: AVCaptureDevice.FlashMode
    @Binding var takePhoto: Bool

    func makeAppKitOrUIKitViewController(context: Context) -> CustomCameraViewController {
        let cameraVC = CustomCameraViewController()
        cameraVC.delegate = context.coordinator
        cameraVC.desiredPosition = cameraPosition
        cameraVC.desiredFlashMode = flashMode
        return cameraVC
    }
    
    func updateAppKitOrUIKitViewController(_ viewController: CustomCameraViewController, context: Context) {
        viewController.switchCamera(to: cameraPosition)
        viewController.setFlashMode(to: flashMode)
        
        if takePhoto {
            viewController.capturePhoto()
            DispatchQueue.main.async {
                takePhoto = false // Reset the flag
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, CustomCameraViewControllerDelegate {
        var parent: CustomCameraRepresentable

        init(_ parent: CustomCameraRepresentable) {
            self.parent = parent
        }

        func didCaptureImage(_ image: _AnyImage) {
            parent.image = image
        }
    }
}

// MARK: - Custom Camera ViewController
protocol CustomCameraViewControllerDelegate: AnyObject {
    func didCaptureImage(_ image: _AnyImage)
}

class CustomCameraViewController: AppKitOrUIKitViewController, AVCapturePhotoCaptureDelegate {
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var desiredPosition: AVCaptureDevice.Position = .back
    var desiredFlashMode: AVCaptureDevice.FlashMode = .off
    weak var delegate: CustomCameraViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
    }
    
    // Helper function to determine if the app is running on a simulator
    func isRunningOnSimulator() -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    func setupCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession.beginConfiguration()

        // Check if running on a real device or simulator
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: desiredPosition) else {
            print("No camera available - running on a simulator or device without a camera.")
            return
        }

        // Setup the video input
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            if captureSession.canAddInput(videoDeviceInput) {
                captureSession.addInput(videoDeviceInput)
            } else {
                print("Could not add video device input to the session")
                return
            }
        } catch {
            print("Could not create video device input: \(error)")
            return
        }

        // Setup the photo output
        stillImageOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        } else {
            print("Could not add photo output to the session")
            return
        }
        captureSession.sessionPreset = .photo

        // Setup the preview layer
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspect
        videoPreviewLayer.connection?.videoOrientation = .portrait

        DispatchQueue.main.async { [weak self] in
            self?.view.layer?.addSublayer(self!.videoPreviewLayer)
            self?.videoPreviewLayer.frame = self!.view.bounds
        }

        // Commit configuration and start the session
        captureSession.commitConfiguration()
        
        // Check again for simulator in case running on a real device that lacks certain camera capabilities
        if !isRunningOnSimulator() {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }
    }

    override func viewDidLayout() {
        super.viewDidLayout()
        if videoPreviewLayer != nil {
            videoPreviewLayer.videoGravity = .resizeAspectFill
            videoPreviewLayer.frame = view.bounds
        }
    }


    func switchCamera(to position: AVCaptureDevice.Position) {
        guard desiredPosition != position, let videoInput = captureSession.inputs.first as? AVCaptureDeviceInput else { return }

        captureSession.beginConfiguration()
        captureSession.removeInput(videoInput)

        let newVideoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position)
        guard let newVideoInput = try? AVCaptureDeviceInput(device: newVideoDevice!) else {
            captureSession.addInput(videoInput)
            captureSession.commitConfiguration()
            return
        }

        if captureSession.canAddInput(newVideoInput) {
            captureSession.addInput(newVideoInput)
            desiredPosition = position
        } else {
            captureSession.addInput(videoInput)
        }

        captureSession.commitConfiguration()
    }

    func setFlashMode(to mode: AVCaptureDevice.FlashMode) {
        desiredFlashMode = mode
        // Note: Actual flash mode handling will be done during image capture, as flash settings are specified per capture request.
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            let capturedImage = _AnyImage(jpegData: imageData)
            delegate?.didCaptureImage(capturedImage ?? _AnyImage(.init()))
        }
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        
        // Configure the settings for your needs
        if self.desiredFlashMode == .on {
            settings.flashMode = .on
        } else {
            settings.flashMode = .off
        }

        self.stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
}
