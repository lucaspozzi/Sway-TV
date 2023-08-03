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
    
    @Published var currentTrackTitle: String = "djclaudiof"
    @Published var artworkImage: UIImage = UIImage(named: "audiodog")!
    
    let featureFlags = FeatureFlags()
    private var updateAlbumArt: Bool = false
    private var currentAlbumArtUrl: String = ""

    private var audioPlayer: AVPlayer?
    private var statusObserver: NSKeyValueObservation?
    private var timeControlStatusObserver: NSKeyValueObservation?
    private var nowPlayingInfo: [String : Any] = [:]
    private var audioUrl: URL? = URL(string: "https://stream.radio.co/s3f63d156a/listen")
    
    private var timerMetadata: Timer = Timer()
    private var timerAnimation: Timer = Timer()
    
    
    // init audio player with url
    override init() {
        super.init()
        
        // Initialize AVPlayer with a single, specific URL
        if let url = audioUrl {
            self.audioPlayer = AVPlayer(url: url)
        }
        setupAudioSessionObservers()
        
        // Set the now playing info
        setNowPlayingInfoCenter(title: "Sway Radio", artwork: artworkImage)
        
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
        
        timerAnimation = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            // Generate a pseudo-random sound level between 0.0 and 1.0 for each channel
            self?.pseudoSoundLevelLeft = CGFloat.random(in: 0.55...0.90)
            self?.pseudoSoundLevelRight = CGFloat.random(in: 0.60...1.00)
        }
        
        featureFlags.fetchFeatureFlag(named: "UpdateAlbumArt") { (isEnabled) in
            self.updateAlbumArt = isEnabled
        }
        
        fetchOnce()
        timerMetadata = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            self.fetchOnce()
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
        timerAnimation.invalidate()
        timerMetadata.invalidate()
        audioPlayer?.pause()
    }
    
    @objc func handleInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let interruptionTypeRawValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let interruptionType = AVAudioSession.InterruptionType(rawValue: interruptionTypeRawValue) else {
            return
        }
        
        switch interruptionType {
        case .began:
            // Handle audio interruption (e.g., pause the playback).
            audioPlayer?.pause()
        case .ended:
            if let interruptionOptionsRawValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let interruptionOptions = AVAudioSession.InterruptionOptions(rawValue: interruptionOptionsRawValue)
                if interruptionOptions.contains(.shouldResume) {
                    // Resume the audio playback after the interruption.
                    audioPlayer?.play()
                }
            }
        @unknown default:
            break
        }
    }
    
    func setupAudioSessionObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(_:)), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    func fetchOnce() {
        
        fetchRadioStationMetadata { result in
            
            switch result {
            case .success(let metadata):
                if(self.updateAlbumArt && self.currentAlbumArtUrl != metadata.currentTrack.artworkURLLarge){
                    DispatchQueue.global().async {
                        if let url = URL(string: metadata.currentTrack.artworkURLLarge),
                           let data = try? Data(contentsOf: url),
                           let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self.artworkImage = image
                                self.currentAlbumArtUrl = metadata.currentTrack.artworkURLLarge
                            }
                        }
                        
                    }
                }
                if(self.currentTrackTitle != metadata.currentTrack.title){
                    DispatchQueue.main.async {
                        self.currentTrackTitle = metadata.currentTrack.title
                    }
                }
                
                self.setNowPlayingInfoCenter(title: metadata.currentTrack.title, artwork: self.artworkImage)
            case .failure(let error):
                print("Error \(error)")
            }
        }
    }
    
    
    
    func startPlayback() {
        isLoading = true
        setupRemoteTransportControls()
        updatePlaybackDuration()
        audioPlayer?.play()
        
        // Set the now playing info
        setNowPlayingInfoCenter(title: currentTrackTitle, artwork: artworkImage)
    }
    
    func setNowPlayingInfoCenter(title: String, artwork: UIImage) {
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: artwork.size) { _ in artwork }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
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
