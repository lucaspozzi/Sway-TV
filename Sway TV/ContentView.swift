//
//  ContentView.swift
//  Sway TV
//
//  Created by Lucas Pozzi de Souza on 7/10/23.
//

import SwiftUI
import AVFoundation

class AudioPlayer: ObservableObject {
    private var audioPlayer: AVPlayer?
    
    func startPlayback(audioUrl: URL) {
        audioPlayer = AVPlayer(url: audioUrl)
        audioPlayer?.play()
    }
    
    func stopPlayback() {
        audioPlayer?.pause()
    }
}

struct ContentView: View {
    
    @ObservedObject var audioPlayer = AudioPlayer()
    var audioUrl: String = "https://s3.voscast.com:11098/stream"
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            
            Button(action: {
                if let url = URL(string: self.audioUrl) {
                    self.audioPlayer.startPlayback(audioUrl: url)
                }
            }) {
                Text("Start Playback")
            }
            
            Button(action: {
                self.audioPlayer.stopPlayback()
            }) {
                Text("Stop Playback")
            }
            
            Button(action: {
                if let url = Bundle.main.url(forResource: "squeaky", withExtension: "mp3") {
                    let session: AVAudioSession = AVAudioSession.sharedInstance()
                    do {
                        try session.setCategory(.playback)
                        try session.setActive(true)
                    } catch {
                        print("Couldn't override output audio port: \(error)")
                    }
                    
                    self.audioPlayer.startPlayback(audioUrl: url)
                } else {
                    print("URL not found")
                }
                
            }) {
                Text("Squeaky")
            }

        }
        .padding()
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
