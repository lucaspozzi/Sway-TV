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
    
    @Published var debugMessage: String = "Normal"
    
    @Published var pseudoSoundLevelLeft: CGFloat = 0.0
    @Published var pseudoSoundLevelRight: CGFloat = 0.0
    
    @Published var currentTrackTitle: String = "djclaudiof"
    @Published var currentAlbumArtUrl: String = "https://swayradio.app/audiodog.jpg"
    @Published var artworkImage: UIImage = UIImage(named: "audiodog")!
    private var alreadyLoadingMetadata: Bool = false
    
    private var audioPlayer: AVPlayer = AVPlayer()
    private var statusObserver: NSKeyValueObservation?
    private var timeControlStatusObserver: NSKeyValueObservation?
    private var nowPlayingInfo: [String : Any] = [:]
    private var audioUrl: URL? = URL(string: "https://stream.radio.co/s3f63d156a/listen")
    
    private var timerMetadata: Timer = Timer()
    private var timerAnimation: Timer = Timer()
    
    
    // init audio player with url
    override init() {
        super.init()
        
        setupAudioPlayer()
        setupAudioSessionObservers()
        setScheduledTimers()
        
        setupAudioPlayerTimeControlStatusObserver()
        
        fetchOnce()
    }
    
    func setupAudioPlayer() {
        
        self.audioPlayer.automaticallyWaitsToMinimizeStalling = true
        self.audioPlayer.allowsExternalPlayback = true
//        self.audioPlayer.usesExternalPlaybackWhileExternalScreenIsActive = true
        
        // Initialize AVPlayer with a single, specific URL
        if let url = audioUrl {
            let asset = AVURLAsset(url: url)
            let item = AVPlayerItem(asset: asset)
            item.canUseNetworkResourcesForLiveStreamingWhilePaused = false
            item.configuredTimeOffsetFromLive = item.recommendedTimeOffsetFromLive
            item.automaticallyPreservesTimeOffsetFromLive = true
            self.audioPlayer.replaceCurrentItem(with: item)
        } else {
            debugMessage = "\(String(describing: self.debugMessage)) - AVPlayer init with url failed."
        }
        
        setupAudioSession()
        setNowPlayingInfoCenter(title: "Sway Radio", artwork: artworkImage)
        setupRemoteTransportControls()
        
//        if AVAudioSession.sharedInstance().currentRoute.outputs.contains(where: { $0.portType == AVAudioSession.Port.headphones }) {
//            setupRemoteTransportControls()
//        }
//        if AVAudioSession.sharedInstance().currentRoute.outputs.contains(where: { $0.portType == AVAudioSession.Port.airPlay }) {
////            setupRemoteTransportControls()
//            // do some airplay setup
//        }
    }
    
    func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, policy: .longFormAudio, options: [])
            try audioSession.setActive(true)
        } catch {
            debugMessage = error.localizedDescription
            print("There was a problem setting up the audio session: \(error)")
        }
    }
    
    func startPlayback() {
        debugMessage = "\(String(describing: self.debugMessage)) - starting playback with url \(String(describing: self.audioUrl))"
        
        isLoading = true
        
        if audioPlayer.currentItem == nil {
            debugMessage = "\(String(describing: self.debugMessage)) - start playback on null audio player. setup anyway."
            setupAudioPlayer()
            audioPlayer.play()
        } else {
            audioPlayer.play()
        }
        
        setupRemoteTransportControls() // This function clears old targets and sets up new ones
        setNowPlayingInfoCenter(title: currentTrackTitle, artwork: artworkImage)
    }
    
    func setupAudioPlayerTimeControlStatusObserver() {
        
        timeControlStatusObserver = audioPlayer.observe(\.timeControlStatus, options: [.new, .initial]) { [weak self] _, _ in
            DispatchQueue.main.async {
                guard let strongSelf = self else {
                    return
                }
                
                switch strongSelf.audioPlayer.timeControlStatus {
                case .waitingToPlayAtSpecifiedRate:
                    self?.debugMessage = "\(String(describing: self?.debugMessage)) - waitingToPlayAtSpecifiedRate"
                    strongSelf.isLoading = true
                    strongSelf.isPlaying = false
                    if(self?.audioPlayer.currentItem == nil){
                        self?.debugMessage = "\(String(describing: self?.debugMessage)) - Found nil player"
                        self?.setupAudioPlayer()
                    }
                    if(self?.audioPlayer.reasonForWaitingToPlay == .noItemToPlay){
                        self?.debugMessage = "\(String(describing: self?.debugMessage)) - No item to play"
                        self?.setupAudioPlayer()
                    }
                    if(self?.audioPlayer.reasonForWaitingToPlay == .evaluatingBufferingRate){
                        self?.debugMessage = "\(String(describing: self?.debugMessage)) - evaluatingBufferingRate"
                    }
                    if(self?.audioPlayer.reasonForWaitingToPlay == .waitingForCoordinatedPlayback){
                        self?.debugMessage = "\(String(describing: self?.debugMessage)) - waitingForCoordinatedPlayback"
                    }
                    if(self?.audioPlayer.reasonForWaitingToPlay == .toMinimizeStalls){
                        self?.debugMessage = "\(String(describing: self?.debugMessage)) - toMinimizeStalls"
                    }
                    if(self?.audioPlayer.reasonForWaitingToPlay == nil){
                        self?.debugMessage = "\(String(describing: self?.debugMessage)) - nil..."
                    }
                case .playing:
                    self?.debugMessage = "\(String(describing: self?.debugMessage)) - playing"
                    strongSelf.isLoading = false
                    strongSelf.isPlaying = true
                case .paused:
                    self?.debugMessage = "paused"
                    strongSelf.isLoading = false
                    strongSelf.isPlaying = false
                default:
                    self?.debugMessage = "\(String(describing: self?.debugMessage)) - default"
                    break
                }
            }
        }
    }
    
    
    
    deinit {
        
        debugMessage = "deinit"
        stopPlayback()
        
        // Remove remote control event handlers
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.removeTarget(nil)
        commandCenter.pauseCommand.removeTarget(nil)
        commandCenter.togglePlayPauseCommand.removeTarget(nil)
        
        statusObserver?.invalidate()
        timeControlStatusObserver?.invalidate()
        timerAnimation.invalidate()
        timerMetadata.invalidate()
        
        NotificationCenter.default.removeObserver(AVAudioSession.interruptionNotification)
        NotificationCenter.default.removeObserver(AVAudioSession.routeChangeNotification)
        NotificationCenter.default.removeObserver(AVAudioSession.mediaServicesWereResetNotification)
        
        audioPlayer.replaceCurrentItem(with: nil)
        
        debugMessage = "deinit"
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
            stopPlayback()
        case .ended:
            if let interruptionOptionsRawValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let interruptionOptions = AVAudioSession.InterruptionOptions(rawValue: interruptionOptionsRawValue)
                if interruptionOptions.contains(.shouldResume) {
                    // Resume the audio playback after the interruption.
                    startPlayback()
                }
            }
        @unknown default:
            break
        }
    }
    
    func setupAudioSessionObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(_:)), name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange(_:)), name: AVAudioSession.routeChangeNotification, object: nil)
        NotificationCenter.default.addObserver(forName: AVAudioSession.mediaServicesWereResetNotification, object: nil, queue: nil){ [unowned self] _ in
            //            self.setupAudioSession()
            //            self.startPlayback()
//            setupAudioPlayer()
            setupAudioSession()
            startPlayback()
        }
        NotificationCenter.default.addObserver(forName: AVAudioSession.mediaServicesWereLostNotification, object: nil, queue: nil){ [unowned self] _ in
            //            self.setupAudioSession()
            //            self.startPlayback()
//            setupAudioPlayer()
            setupAudioSession()
            startPlayback()
        }
    }
    
    @objc func handleRouteChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue:reasonValue) else {
            return
        }

        switch reason {
        case .newDeviceAvailable:
            let session = AVAudioSession.sharedInstance()
            for output in session.currentRoute.outputs where output.portType == AVAudioSession.Port.headphones {
                debugMessage = "\(String(describing: self.debugMessage)) - headphones"
                setupRemoteTransportControls()
                break
            }
            for output in session.currentRoute.outputs where output.portType == AVAudioSession.Port.airPlay {
                debugMessage = "\(String(describing: self.debugMessage)) - airplay"
                startPlayback()
                break
            }
            for output in session.currentRoute.outputs where output.portType == AVAudioSession.Port.builtInSpeaker {
                debugMessage = "\(String(describing: self.debugMessage)) - builtInSpeaker"
                startPlayback()
                break
            }
        default:
            startPlayback()
        }
    }

    
    func fetchOnce() {
        
        if(alreadyLoadingMetadata){
            return
        }
        alreadyLoadingMetadata = true
        fetchRadioStationMetadata { result in
            
            switch result {
            case .success(let metadata):
                if(self.currentAlbumArtUrl != metadata.currentTrack.artworkURLLarge){
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
        alreadyLoadingMetadata = false
    }
    
    
    
    func setNowPlayingInfoCenter(title: String, artwork: UIImage) {
//        debugMessage = "setup now playing info center"
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: artwork.size) { _ in artwork }
        nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = NSNumber(1)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    
    func setupRemoteTransportControls() {
        // Get the shared command center
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Remove old targets
        commandCenter.playCommand.removeTarget(nil)
        commandCenter.pauseCommand.removeTarget(nil)
        commandCenter.togglePlayPauseCommand.removeTarget(nil)

        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.audioPlayer.rate == 0.0 {
                self.startPlayback()
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.audioPlayer.rate == 1.0 {
                self.stopPlayback()
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.togglePlayPauseCommand.addTarget { [unowned self] event in
            // Your play/pause toggle logic goes here.
            if self.audioPlayer.rate == 0.0 {
                self.startPlayback()
                return .success
            } else if self.audioPlayer.rate == 1.0 {
                self.stopPlayback()
                return .success
            }
            return .commandFailed
        }
    }

    

    
    func stopPlayback() {
        audioPlayer.pause()
        isPlaying = false
    }
    
    func setScheduledTimers() {
        timerMetadata = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            self?.fetchOnce()
        }
        timerAnimation = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            // Generate a pseudo-random sound level between 0.0 and 1.0 for each channel
            self?.pseudoSoundLevelLeft = CGFloat.random(in: 0.55...0.90)
            self?.pseudoSoundLevelRight = CGFloat.random(in: 0.60...1.00)
        }
    }
    
}
