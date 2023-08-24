//
//  HomeTabView.swift
//  Sway TV
//
//  Created by Lucas Pozzi de Souza on 7/16/23.
//

import SwiftUI

struct HomeTabView: View {
    @EnvironmentObject var audioPlayer: AudioPlayer
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        VStack {
            AudioPlayerView()
                .environmentObject(audioPlayer)
        }
        .background(content: {
            if colorScheme == .light {
                Image(uiImage: audioPlayer.artworkImage)
                    .resizable()
                    .scaledToFill()
                    .opacity(0.2)
                    .blur(radius: 10)
            }
        })
    }
}

struct HomeTabView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabView()
    }
}
