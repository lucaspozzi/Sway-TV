//
//  ContentView.swift
//  Sway TV
//
//  Created by Lucas Pozzi de Souza on 7/10/23.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    
    @ObservedObject var audioPlayer = AudioPlayer()
    var audioUrl: String = "https://stream.radio.co/s3f63d156a/listen"
    
    var body: some View {
        VStack {
            Image(systemName: "radio")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Sway TV")
            
            if audioPlayer.isPlaying {
                Button(action: {
                    self.audioPlayer.stopPlayback()
                }) {
                    Text("Stop Playback")
                }
            } else {
                Button(action: {
                    if let url = URL(string: self.audioUrl) {
                        self.audioPlayer.startPlayback(audioUrl: url)
                    }
                }) {
                    Text("Start Playback")
                }
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
