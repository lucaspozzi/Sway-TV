//
//  ContentView.swift
//  Sway TV
//
//  Created by Lucas Pozzi de Souza on 7/10/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var audioPlayer = AudioPlayer()
    private var sentiments = Sentiments()
    @State private var lastSentimentTrackName: String?
    @State private var isEventsTabEnabled = false
    @State private var isAirPlayEnabled = false
    @State private var isSharePlayEnabled = false
    let featureFlags = FeatureFlags()
    private var audioUrl: URL? = URL(string: "https://stream.radio.co/s3f63d156a/listen")
    
    var body: some View {
        TabView {
            
            HomeTabView()
                .tabItem {
//                    Image(systemName: "house")
                    if(audioPlayer.isLoading){
                        Image(systemName: "antenna.radiowaves.left.and.right.slash")
                        //                        Text("Tuning...")
                        
                    } else {
                        Image(systemName: "antenna.radiowaves.left.and.right.circle.fill").foregroundColor(.green)
                        //                        Text("Live")
                    }
                    Text("Radio")
                }
                .environmentObject(audioPlayer)
            
            RecentView()
                .tabItem {
                    Image(systemName: "music.note.list")
                    Text("Recent")
                }
            
            
            TopTracksView()
                .tabItem {
                    Image(systemName: "medal.fill")
                    Text("Top Tracks")
                }
            
            if(isEventsTabEnabled){
                EventScheduleView()
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Events")
                    }
            }
            
        }
        .onPlayPauseCommand {
            if audioPlayer.isPlaying {
                audioPlayer.stopPlayback()
            } else {
                audioPlayer.startPlayback()
            }
        }
        .onAppear {
            featureFlags.fetchFeatureFlag(named: "EventsTab") { (isEnabled) in
                self.isEventsTabEnabled = isEnabled
            }
            featureFlags.fetchFeatureFlag(named: "SharePlay") { (isEnabled) in
                self.isSharePlayEnabled = isEnabled
            }
            featureFlags.fetchFeatureFlag(named: "AirPlay") { (isEnabled) in
                self.isAirPlayEnabled = isEnabled
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
