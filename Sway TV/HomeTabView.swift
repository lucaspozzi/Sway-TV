//
//  HomeTabView.swift
//  Sway TV
//
//  Created by Lucas Pozzi de Souza on 7/16/23.
//

import SwiftUI

struct HomeTabView: View {
    @EnvironmentObject var audioPlayer: AudioPlayer
    
    var body: some View {
        
        ScrollView {
            VStack {
                AudioPlayerView()
                    .environmentObject(audioPlayer)
                HStack {
                    AmbientVideoMenuView()
                }
            }
        }
    }
}

struct HomeTabView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabView()
    }
}
