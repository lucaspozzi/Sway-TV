//
//  AudioPlayer.swift
//  Sway TV
//
//  Created by Lucas Pozzi de Souza on 7/10/23.
//

import Foundation
import AVFoundation
import MediaPlayer

@objc class AudioPlayer: NSObject, ObservableObject {
    
    @Published var isPlaying = false
    @Published var isLoading = false
    private var audioPlayer: AVPlayer?
    private var statusObserver: NSKeyValueObservation?
    private var playCommandTarget: Any?
    private var pauseCommandTarget: Any?
    
    deinit {
        statusObserver?.invalidate()
    }
    
    func startPlayback(audioUrl: URL, title: String, artwork: UIImage) {
        audioPlayer = AVPlayer(url: audioUrl)
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.interruptSpokenAudioAndMixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("There was a problem setting up the audio session: \(error)")
        }
        
        isLoading = true
        statusObserver = audioPlayer?.currentItem?.observe(\.status, options: [.new, .initial]) { [weak self] item, _ in
            DispatchQueue.main.async {
                switch item.status {
                case .readyToPlay:
                    self?.isLoading = false
                    self?.audioPlayer?.play()
                    self?.isPlaying = true
                case .failed:
                    self?.isLoading = false
                    // todo handle error
                case .unknown:
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    
    @objc func stopPlayback() {
        audioPlayer?.pause()
        isPlaying = false
    }
    
}
