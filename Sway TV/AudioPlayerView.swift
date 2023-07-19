//
//  AudioPlayerView.swift
//  Sway TV
//
//  Created by Lucas Pozzi de Souza on 7/16/23.
//

import SwiftUI
import AVFoundation
import Intents

struct AudioPlayerView: View {
    @EnvironmentObject var audioPlayer: AudioPlayer
    @State private var artworkImage: UIImage = UIImage(named: "audiodog")!
    @State private var currentTrackTitle: String = "djclaudiof"
    @State private var timer: Timer?
    @State private var isShowingModal = false
    let audioUrl: String = "https://stream.radio.co/s3f63d156a/listen"
    
    var body: some View {
        
        HStack {
            
            VStack {
                if audioPlayer.isPlaying {
                    Button(action: {
                        self.audioPlayer.stopPlayback()
                    }) {
                        HStack {
                            Image(systemName: "pause")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                            Text("Pause Radio")
                        }
                    }
                    .frame(height: 190)
                } else {
                    Button(action: {
                        if let url = URL(string: self.audioUrl) {
                            self.audioPlayer.startPlayback(audioUrl: url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "play")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                            Text("Listen to Radio")
                        }
                    }
                    .frame(height: 190)
                }
                
                Text(currentTrackTitle).font(.headline)
                
            }
            .aspectRatio(contentMode: .fit)
            .padding()
            .frame(width: 880)
            
            Button(action: {
                isShowingModal = true
            }) {
                VStack {
                    Image(uiImage: artworkImage)
                        .resizable().cornerRadius(10)
                    Text("View album artwork")
                }
            }
            .aspectRatio(contentMode: .fit)
            .padding()
            .frame(width: 880)
            
        }
        .frame(height: 740)
        .onAppear{
            fetchOnce()
            startFetching()
        }
        .onDisappear{
            stopFetching()
        }
        .sheet(isPresented: $isShowingModal) {
            Image(uiImage: artworkImage)
                .resizable().cornerRadius(10)
                .aspectRatio(contentMode: .fit)
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
            .environmentObject(AudioPlayer())
    }
}
