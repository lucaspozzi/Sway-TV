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
        
        VStack {
            AudioPlayerView()
                .environmentObject(audioPlayer)
        }
        .background(content: {
            Image(uiImage: audioPlayer.artworkImage)
                .resizable()
                .scaledToFill()
                .opacity(0.3)
                .blur(radius: 10)
        })
    }
}

struct HomeTabView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabView()
    }
}
