//  AudioPlayer.swift
//  Sway TV
//
//  Created by Lucas Pozzi de Souza on 7/10/23.

import Foundation
import AVFoundation
import MediaPlayer
import GroupActivities

@objc class AudioPlayer: NSObject, ObservableObject {
    
    @Published var isPlaying = false
    @Published var isLoading = false
    
    @Published var pseudoSoundLevelLeft: CGFloat = 0.0
    @Published var pseudoSoundLevelRight: CGFloat = 0.0

    private var audioPlayer: AVPlayer?
    private var statusObserver: NSKeyValueObservation?
    private var timeControlStatusObserver: NSKeyValueObservation?
    private var nowPlayingInfo: [String : Any] = [:]
    private var audioUrl: URL? = URL(string: "https://stream.radio.co/s3f63d156a/listen")
    private var artwork: UIImage = UIImage(named: "audiodog")!
    
    
    // init audio player with url
    override init() {
        super.init()
        
        // Initialize AVPlayer with a single, specific URL
        if let url = audioUrl {
            self.audioPlayer = AVPlayer(url: url)
        }
        
        // Set the now playing info
        nowPlayingInfo[MPMediaItemPropertyTitle] = "Sway Radio"
        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: artwork.size) { _ in self.artwork }
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, policy: .longFormAudio, options: [])
            try audioSession.setActive(true)
        } catch {
            print("There was a problem setting up the audio session: \(error)")
        }
        
        timeControlStatusObserver = audioPlayer?.observe(\.timeControlStatus, options: [.new, .initial]) { [weak self] _, _ in
            DispatchQueue.main.async {
                guard let strongSelf = self else {
                    return
                }
                
                switch strongSelf.audioPlayer?.timeControlStatus {
                case .waitingToPlayAtSpecifiedRate:
                    strongSelf.isLoading = true
                    strongSelf.isPlaying = false
                case .playing:
                    strongSelf.isLoading = false
                    strongSelf.isPlaying = true
                case .paused:
                    strongSelf.isLoading = false
                    strongSelf.isPlaying = false
                default:
                    break
                }
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            // Generate a pseudo-random sound level between 0.0 and 1.0 for each channel
            self?.pseudoSoundLevelLeft = CGFloat.random(in: 0.55...0.90)
            self?.pseudoSoundLevelRight = CGFloat.random(in: 0.60...1.00)
        }

//        Task {
//            for session in GroupSession<RadioActivity>. {
//                self.startPlayback(title: "Sway Radio", artwork: UIImage(named: "audiodog")!)
//            }
//        }
        
    }
    
    deinit {
        statusObserver?.invalidate()
        timeControlStatusObserver?.invalidate()
    }
    
    
    func startPlayback(title: String, artwork: UIImage) {
        self.isLoading = true
        self.setupRemoteTransportControls()
        self.updatePlaybackDuration()
        self.audioPlayer?.play()
        
        // Set the now playing info
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: artwork.size) { _ in artwork }
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
