//
//  VideoPlayerView.swift
//  Sway TV
//
//  Created by Lucas Pozzi de Souza on 7/16/23.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    private let videoPlayer = AVQueuePlayer()
    private let playerLooper: AVPlayerLooper
    
    init() {
        let videoUrl = Bundle.main.url(forResource: "wave", withExtension: "mp4")!
        let videoPlayerItem = AVPlayerItem(url: videoUrl)
        playerLooper = AVPlayerLooper(player: videoPlayer, templateItem: videoPlayerItem)
    }
    
    var body: some View {
        VideoPlayer(player: videoPlayer).aspectRatio(contentMode: .fill)
            .onAppear{
                videoPlayer.play()
            }
            .onDisappear{
                videoPlayer.pause()
            }
            .onReceive(NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)){ _ in
                self.videoPlayer.seek(to: .zero)
                self.videoPlayer.play()
            }
    }
}

struct VideoPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayerView()
    }
}
