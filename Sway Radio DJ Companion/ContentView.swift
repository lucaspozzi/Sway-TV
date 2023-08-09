//
//  ContentView.swift
//  Sway Radio DJ Companion
//
//  Created by Lucas Pozzi de Souza on 8/8/23.
//

import SwiftUI
import AVKit

struct ContentView: View {
    
//    @StateObject var audioPlayer = AudioPlayer()
    private var sentiments = Sentiments()
    @State private var lastSentimentTrackName: String?
    @State private var isEventsTabEnabled = false
    @State private var isAirPlayEnabled = false
    @State private var isSharePlayEnabled = false
    let featureFlags = FeatureFlags()
    private var audioUrl: URL? = URL(string: "https://stream.radio.co/s3f63d156a/listen")
    
    
    var body: some View {
        TabView {
            
            NavigationView {
                VStack {
                    Image(systemName: "globe")
                        .imageScale(.large)
                        .foregroundColor(.accentColor)
                    Text("Hello, world!")
                }
            }
            .tabItem {
                Image(systemName: "radio")
                Text("Radio")
            }
            
            NavigationView {
                RecentView()
                    .navigationTitle("Recently on air")
            }
            .tabItem {
                Image(systemName: "music.note.list")
                Text("Recent")
            }
            
            NavigationView {
                TopTracksView()
                    .navigationTitle("Top tracks")
            }
            .tabItem {
                Image(systemName: "medal.fill")
                Text("Top Tracks")
            }
            
            EventScheduleView()
            .tabItem {
                Image(systemName: "calendar")
                Text("Events")
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
