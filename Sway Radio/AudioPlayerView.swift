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
    @State private var smallScreen = false
    let audioUrl: String = "https://stream.radio.co/s3f63d156a/listen"
    
    var body: some View {
        
        VStack {
            
            if(smallScreen){
                Button(action: {
                    isShowingModal = true
                }) {
                    Image(uiImage: artworkImage)
                        .resizable().cornerRadius(10).frame(width: 200, height: 200, alignment: .center)
                        .background(
                            ZStack {
                                Circle()
                                    .fill(Color.purple)
                                    .blur(radius: 15)
                                    .offset(x: 0, y: 0)
                            }
                        )
                }
                .aspectRatio(contentMode: .fit)
            } else {
                Button(action: {
                    isShowingModal = true
                }) {
                    Image(uiImage: artworkImage)
                        .resizable().cornerRadius(10)
                        .background(
                            ZStack {
                                Circle()
                                    .fill(Color.purple)
                                    .blur(radius: 15)
                                    .offset(x: 0, y: 0)
                            }
                        )
                }
                .aspectRatio(contentMode: .fit)
            }
            
            
            
            Spacer()
            Text("Live now:")
            Text(currentTrackTitle)
                .font(.headline).lineLimit(2).padding()
                .multilineTextAlignment(.center)
            
            
            if audioPlayer.isPlaying {
                Button(action: {
                    self.audioPlayer.stopPlayback()
                }) {
                    Image(systemName: "pause")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            } else {
                Button(action: {
                    if let url = URL(string: self.audioUrl) {
                        self.audioPlayer.startPlayback(audioUrl: url, title: self.currentTrackTitle, artwork: artworkImage)
                    }
                }) {
                    Image(systemName: "play")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }.disabled(audioPlayer.isLoading)
            }
            
            Spacer()
            
        }
        .onAppear{
            fetchOnce()
            startFetching()
            
            let screenHeight = UIScreen.main.bounds.size.height
            let screenWidth = UIScreen.main.bounds.size.width
            
            if screenHeight == 568 && screenWidth == 320 {
                smallScreen = true
            }
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
