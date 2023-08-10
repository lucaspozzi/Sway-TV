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
    private var sentiments = Sentiments()
    @State private var lastSentimentTrackName: String?
    @State private var isEventsTabEnabled = false
    @State private var isAirPlayEnabled = false
    @State private var isSharePlayEnabled = false
    let featureFlags = FeatureFlags()
    private var audioUrl: URL? = URL(string: "https://stream.radio.co/s3f63d156a/listen")
    @State private var countdownSeconds = 50
    @State private var isCountdownActive = false
    @State private var isOnboarding = false
    @State private var isOnboarded = false
    
    func startCountdown() {
        isCountdownActive = true
        countdownSeconds = 50
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            countdownSeconds -= 1
            if countdownSeconds <= 0 {
                timer.invalidate()
                isCountdownActive = false
            }
        }
    }
    
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
                                    Text("Tuning...")
                                }
                                
                            } else {
                                HStack{
                                    Image(systemName: "antenna.radiowaves.left.and.right.circle.fill").foregroundColor(.green)
                                    Text("Live")
                                    
                                    AirPlayView().padding(.horizontal)
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
                                                let activity = RadioActivity(isPlaying: audioPlayer.isPlaying, sessionData: sessionData)
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
                                
                                if !isCountdownActive {
                                    
                                    Button(action: {
                                        if !isCountdownActive {
                                            startCountdown()
                                            sentiments.add(currentTrack: audioPlayer.currentTrackTitle, sentimentName: "like")
                                            lastSentimentTrackName = audioPlayer.currentTrackTitle
                                        }
                                    }) {
                                        Image(systemName: "hand.thumbsup.fill")
                                    }
                                    .disabled(audioPlayer.isLoading)
                                    .animation(.easeOut)
                                    
                                    
                                    Button(action: {
                                        if !isCountdownActive {
                                            startCountdown()
                                            sentiments.add(currentTrack: audioPlayer.currentTrackTitle, sentimentName: "figure.dance")
                                            lastSentimentTrackName = audioPlayer.currentTrackTitle
                                        }
                                    }) {
                                        Image(systemName: "figure.dance")
                                    }
                                    .disabled(audioPlayer.isLoading)
                                    .padding(.horizontal)
                                    .animation(.spring())
                                    
                                    
                                    Button(action: {
                                        if !isCountdownActive {
                                            startCountdown()
                                            sentiments.add(currentTrack: audioPlayer.currentTrackTitle, sentimentName: "figure.socialdance")
                                            lastSentimentTrackName = audioPlayer.currentTrackTitle
                                        }
                                    }) {
                                        Image(systemName: "figure.socialdance")
                                    }
                                    .disabled(audioPlayer.isLoading)
                                    .animation(.easeIn)
                                    
                                } else {
                                    HStack {
                                        Text("Sway!")
                                        Image(systemName: "\(countdownSeconds).circle")
                                    }
                                    .foregroundColor(.gray)
                                    .animation(.default)
                                }
                                
                                
                            }
                        }
                    }
                    .sheet(isPresented: $isOnboarding, onDismiss: {
                        UserDefaults.standard.set(true, forKey: "isOnboarded")
                    }) {
                        VStack {
                            Text("Welcome to Sway")
                                .font(.largeTitle)
                                .foregroundColor(.purple)
                                .padding(.top)
                            
                            Text("Free Music Radio")
                                .font(.title)
                                .foregroundColor(.purple)
                            
                            
                            Text("To start listening, press play:")
                                .font(.title2)
                                .padding(.top)
                            
                            Image(systemName: "play")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.purple)
                                .frame(width: 100, height: 100)
                            
                            Spacer()
                            
                            Text("When you really like a song, let us know how much by tapping any of these reactions:")
                                .font(.title2)
                                .padding(.horizontal)
                            
                            HStack(spacing: 25) {
                                Image(systemName: "hand.thumbsup.fill")
                                Image(systemName: "figure.dance")
                                Image(systemName: "figure.socialdance")
                            }
                            .foregroundColor(.purple)
                            .font(.system(size: 40))
                            
                            Spacer()
                            
                            Button(action: {
                                isOnboarding = false
                                UserDefaults.standard.set(true, forKey: "isOnboarded")
                            }) {
                                Text("Got It")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .frame(width: 200, height: 60)
                                    .background(Color.purple)
                                    .cornerRadius(30)
                            }
                            
                            Spacer()
                        }
                    }

                    .onAppear {
                        
                        // If user defaults isOnboarded is false or empty
                        isOnboarded = UserDefaults.standard.bool(forKey: "isOnboarded")
                        if(!isOnboarded){
                            DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                                withAnimation {
                                    isOnboarding = true
                                }
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
            
            NavigationView {
                TopTracksView()
                    .navigationTitle("Top tracks")
            }
            .tabItem {
                Image(systemName: "medal.fill")
                Text("Top Tracks")
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
