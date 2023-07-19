//
//  ContentView.swift
//  Sway TV
//
//  Created by Lucas Pozzi de Souza on 7/10/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var audioPlayer = AudioPlayer()
    let audioUrl: String = "https://stream.radio.co/s3f63d156a/listen"
    
    var body: some View {
        TabView {
            
            NavigationView {
                HomeTabView()
                    .environmentObject(audioPlayer)
                    .navigationTitle("Sway Radio")
            }
            .tabItem {
                Image(systemName: "radio")
                Text("Radio")
            }
            
            NavigationView {
                RecentView()
                    .navigationTitle("Recently played")
            }
            .tabItem {
                Image(systemName: "music.note.list")
                Text("Recent")
            }
            
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
