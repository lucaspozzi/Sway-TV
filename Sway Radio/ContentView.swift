//
//  ContentView.swift
//  Sway TV
//
//  Created by Lucas Pozzi de Souza on 7/10/23.
//

import SwiftUI
import AVKit

struct ContentView: View {
    
    @StateObject var audioPlayer = AudioPlayer()
    @State private var isEventsTabEnabled = false
    @State private var isAirPlayEnabled = false
    @State private var isSharePlayEnabled = false
    let featureFlags = FeatureFlags()
    private var audioUrl: URL? = URL(string: "https://stream.radio.co/s3f63d156a/listen")

    
    var body: some View {
        TabView {
            
            NavigationView {
                HomeTabView()
                    .environmentObject(audioPlayer)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            if(audioPlayer.isLoading){
                                HStack {
                                    Image(systemName: "antenna.radiowaves.left.and.right.slash")
                                    Text("Tunning...")
                                }
                                
                            } else {
                                HStack{
                                    Image(systemName: "antenna.radiowaves.left.and.right.circle.fill").foregroundColor(.red)
                                    Text("Live")
                                }
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            HStack {
                                
                                if(isSharePlayEnabled){
                                    Button(action: {
                                        Task {
                                            if let url = self.audioUrl {
                                                let sessionData = RadioActivity.SessionData(url: url)
                                                let activity = RadioActivity(sessionData: sessionData)
                                                do {
                                                    try await activity.activate()
                                                } catch {
                                                    // handle error
                                                    print("Failed to activate activity: \(error)")
                                                }
                                            }
                                        }
                                    }) {
                                        Image(systemName: "shareplay")
                                    }
                                }
                                
                                AirPlayView().padding(.horizontal)
                                
                            }
                        }
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
            
            if(isEventsTabEnabled){
                NavigationView {
                    EventScheduleView()
                        .navigationTitle("Event Schedule")
                }
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Events")
                }
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
