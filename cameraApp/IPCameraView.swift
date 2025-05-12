//
//  IPCameraView.swift
//  cameraApp
//
//  Created by Bhavik Goyal on 11/05/25.
//

import AVKit
import SwiftUI


struct IPCameraView: View {
    let streamURL: URL
    @State private var player: AVPlayer? = nil

    var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                player = AVPlayer(url: streamURL)
                player?.play()
            }
            .onDisappear {
                player?.pause()
            }
            .frame(minHeight: 300)
    }
}

struct IPStreamInputView: View {
    @State private var ipAddress = ""
    @State private var showPlayer = false

    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter IP Camera URL", text: $ipAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Play Stream") {
                showPlayer = true
            }

            if showPlayer, let url = URL(string: ipAddress) {
                IPCameraView(streamURL: url)
            }
        }
        .padding()
    }
}
