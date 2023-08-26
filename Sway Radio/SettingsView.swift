//
//  SettingsView.swift
//  Sway TV
//
//  Created by Lucas Pozzi de Souza on 8/25/23.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    
    @State private var streamingQuality = UserDefaults.standard.integer(forKey: "useLowQuality")
    @EnvironmentObject var audioPlayer: AudioPlayer
    
    var body: some View {
        Form {
            Section(header: Text("Streaming"), footer: Text("Choose normal sound quality if you are having connection issues.")) {
                Picker("Sound Quality", selection: $streamingQuality) {
                    Text("High").tag(0)
                    Text("Normal").tag(1)
                }
                .pickerStyle(.automatic)
            }
            
            Section(header: Text("Share"), footer: Text("We appreciate it!")) {
                ShareLink("Send Sway to a friend", item: "https://apps.apple.com/us/app/sway-music-radio/id6451124668", message: Text("You will love Sway Music Radio, Viva los DJs!"))
            }
            
        }
        .onChange(of: streamingQuality) { newValue in
            UserDefaults.standard.set(newValue, forKey: "useLowQuality")
            audioPlayer.handleStreamingQualityChange()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
