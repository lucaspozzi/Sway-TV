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
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.playback, mode: .default, options: [.interruptSpokenAudioAndMixWithOthers, .allowAirPlay])
        try? audioSession.setActive(true)
        audioPlayer?.play()
        isPlaying = true
    }
    
    func stopPlayback() {
        audioPlayer?.pause()
        isPlaying = false
    }
}
