//  AudioPlayer.swift
//  Sway TV
//
//  Created by Lucas Pozzi de Souza on 7/10/23.

import Foundation
import AVFoundation
import MediaPlayer

@objc class AudioPlayer: NSObject, ObservableObject {
    
    @Published var isPlaying = false
    @Published var isLoading = false
    private var audioPlayer: AVPlayer?
    private var statusObserver: NSKeyValueObservation?
    private var timeControlStatusObserver: NSKeyValueObservation?
    private var nowPlayingInfo: [String : Any] = [:]
    
    deinit {
        statusObserver?.invalidate()
        timeControlStatusObserver?.invalidate()
    }
    
    func startPlayback(audioUrl: URL, title: String, artwork: UIImage) {
        
        self.isLoading = true
        
        audioPlayer = AVPlayer(url: audioUrl)
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("There was a problem setting up the audio session: \(error)")
        }
        
        setupRemoteTransportControls()
        
        // Set the now playing info
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: artwork.size) { _ in artwork }
        
        updatePlaybackDuration()
        
        statusObserver = audioPlayer?.currentItem?.observe(\.status, options: [.new, .initial]) { [weak self] item, _ in
            DispatchQueue.main.async {
                switch item.status {
                case .readyToPlay:
                    self?.audioPlayer?.play()
                    self?.isLoading = false
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
        
        timeControlStatusObserver = audioPlayer?.observe(\.timeControlStatus, options: [.new, .initial]) { [weak self] _, _ in
            DispatchQueue.main.async {
                self?.isPlaying = self?.audioPlayer?.timeControlStatus == .playing
                self?.isLoading = self?.audioPlayer?.timeControlStatus == .waitingToPlayAtSpecifiedRate
            }
        }
    }
    
    func setupRemoteTransportControls() {
        // Get the shared command center
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.audioPlayer?.rate == 0.0 {
                self.audioPlayer?.play()
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.audioPlayer?.rate == 1.0 {
                self.audioPlayer?.pause()
                return .success
            }
            return .commandFailed
        }
    }
    
    
    func updatePlaybackDuration() {
        guard let duration = audioPlayer?.currentItem?.asset.duration else {
            return
        }
        
        let durationInSeconds = CMTimeGetSeconds(duration)
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = durationInSeconds
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }


    
    @objc func stopPlayback() {
        audioPlayer?.pause()
        isPlaying = false
    }
    
}
