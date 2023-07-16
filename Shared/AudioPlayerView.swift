//
//  AudioPlayerView.swift
//  Sway TV
//
//  Created by Lucas Pozzi de Souza on 7/16/23.
//

import SwiftUI
import AVFoundation

struct AudioPlayerView: View {
    @ObservedObject var audioPlayer = AudioPlayer()
    @State private var artworkImage: UIImage? = nil
    @State private var artworkImageDefault: String = "audiodog"
    @State private var currentTrackTitle: String = "Loading track title..."
    let audioUrl: String = "https://stream.radio.co/s3f63d156a/listen"
    @State private var timer: Timer?
    
    var body: some View {
        HStack {
            
            
            if audioPlayer.isPlaying {
                Button(action: {
                    self.audioPlayer.stopPlayback()
                }) {
                    VStack {
                        Image(systemName: "pause")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        Text("Pause Audio")
                    }.foregroundColor(.purple)
                }
                .frame(width: 500, height: 500)
            } else {
                Button(action: {
                    if let url = URL(string: self.audioUrl) {
                        self.audioPlayer.startPlayback(audioUrl: url)
                    }
                }) {
                    VStack {
                        Image(systemName: "play")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        Text("Start Listening to Radio")
                    }.foregroundColor(.purple)
                }
                .frame(width: 500, height: 500)
            }
            
            VStack {
                Text("Live now:")
                Text(currentTrackTitle).font(.headline)
            }
            
            ZStack {
                if let artworkImage = artworkImage {
                    Image(uiImage: artworkImage)
                        .resizable().cornerRadius(10)
                        .frame(width: 500, height: 500)
                } else {
                    Image(artworkImageDefault)
                        .resizable()
                        .frame(width: 500, height: 500)
                }
            }
        }
        .onAppear{
            fetchOnce()
            startFetching()
        }
        .onDisappear{
            stopFetching()
        }
    }
    
    func fetchOnce() {
        fetchRadioStationMetadata { result in
            switch result {
            case .success(let metadata):
                DispatchQueue.global().async {
                    if let url = URL(string: metadata.currentTrack.artworkURLLarge),
                       let data = try? Data(contentsOf: url),
                       let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            artworkImage = image
                        }
                    }
                    
                }
                DispatchQueue.main.async {
                    currentTrackTitle = metadata.currentTrack.title
                }
            case .failure(let error):
                print("Error \(error)")
            }
            
        }
    }
    
    func startFetching() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            fetchOnce()
        }
    }
    
    func stopFetching(){
        timer?.invalidate()
        timer = nil
    }
}

struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AudioPlayerView()
    }
}
