//
//  AudioPlayer.swift
//  Sway TV
//
//  Created by Lucas Pozzi de Souza on 7/10/23.
//

import Foundation
import AVFoundation

class AudioPlayer: ObservableObject {
    
    @Published var isPlaying = false
    private var audioPlayer: AVPlayer?
    
    func startPlayback(audioUrl: URL) {
        audioPlayer = AVPlayer(url: audioUrl)
        audioPlayer?.play()
        isPlaying = true
    }
    
    func stopPlayback() {
        audioPlayer?.pause()
        isPlaying = false
    }
}
