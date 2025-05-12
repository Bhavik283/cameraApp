//
//  CameraListView.swift
//  cameraApp
//
//  Created by Bhavik Goyal on 11/05/25.
//

import AVFoundation
import SwiftUI

struct CameraSelectorView: View {
    @StateObject private var cameraManager = CameraDeviceManager()
    @State private var selectedDevice: AVCaptureDevice?

    var body: some View {
        VStack {
            Picker("Select Camera", selection: $selectedDevice) {
                ForEach(cameraManager.availableDevices, id: \.uniqueID) { device in
                    Text(device.localizedName).tag(Optional(device))
                }
            }
            .onChange(of: selectedDevice) { _, newDevice in
                if let device = newDevice {
                    cameraManager.startSession(with: device)
                }
            }
            .padding()

            if let session = cameraManager.session {
                VideoCaptureView(session: session)
                    .frame(height: 400)
                    .background(Color.black)
            } else {
                Text("No Camera Selected")
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            selectedDevice = cameraManager.availableDevices.first
            if let device = selectedDevice {
                cameraManager.startSession(with: device)
            }
        }
        .padding()
    }
}
