//
//  VideoDeviceViewModel.swift
//  cameraApp
//
//  Created by Bhavik Goyal on 11/05/25.
//

import AVFoundation
import Combine

class CameraDeviceManager: ObservableObject {
    @Published var availableDevices: [AVCaptureDevice] = []
    @Published var session: AVCaptureSession?

    private var deviceDiscoverySession: AVCaptureDevice.DiscoverySession
    private var cancellables = Set<AnyCancellable>()

    init() {
        deviceDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.external, .builtInWideAngleCamera],
            mediaType: .video,
            position: .unspecified
        )
        updateDevices()

        NotificationCenter.default.publisher(for: AVCaptureDevice.wasConnectedNotification)
            .sink { [weak self] _ in self?.updateDevices() }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: AVCaptureDevice.wasDisconnectedNotification)
            .sink { [weak self] _ in self?.updateDevices() }
            .store(in: &cancellables)
    }

    private func updateDevices() {
        DispatchQueue.main.async {
            self.availableDevices = self.deviceDiscoverySession.devices
        }
    }

    func startSession(with device: AVCaptureDevice) {
        // Stop any existing session before starting a new one
        session?.stopRunning()
        session = AVCaptureSession()

        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session?.canAddInput(input) == true {
                session?.addInput(input)

                let previewLayer = AVCaptureVideoPreviewLayer(session: session!)
                previewLayer.videoGravity = .resizeAspectFill

                // Assuming you have a view in the UI to show the video preview
                // (this is handled in `VideoCaptureView` later)
                session?.startRunning()
            }
        } catch {
            print("Error setting up camera session: \(error)")
        }
    }
}
