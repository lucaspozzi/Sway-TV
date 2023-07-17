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
            
            HomeTabView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .environmentObject(audioPlayer)
            
            EventScheduleView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Event Schedule")
                }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
