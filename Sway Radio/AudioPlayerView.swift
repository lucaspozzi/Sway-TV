//
//  AudioPlayerView.swift
//  Sway TV
//
//  Created by Lucas Pozzi de Souza on 7/16/23.
//

import SwiftUI
import AVFoundation
import Intents


struct AudioPlayerView: View {
    @EnvironmentObject var audioPlayer: AudioPlayer
    
    
    // Pinch to Zoom
    private struct DragState {
        var translation = CGSize.zero // may be needed when pan can be added
        var zoom = CGFloat(1.0)
    }
    
    @GestureState(resetTransaction: Transaction(animation: .spring())) private var dragState = DragState()
    
    private func pinchGesture(updating gestureState: GestureState<DragState>) -> some Gesture {
        MagnificationGesture().updating(gestureState) { (value, state, transaction) in
            state.zoom = value
            transaction = Transaction(animation: .spring())
        }
    }
    
    
    var body: some View {
        
        VStack {
            
            Text(audioPlayer.currentTrackTitle)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Image(uiImage: audioPlayer.artworkImage)
                .resizable().cornerRadius(10)
                .shadow(color: .accentColor, radius: 3)
                .scaleEffect(dragState.zoom)
                .gesture(pinchGesture(updating: $dragState))
                .aspectRatio(contentMode: .fit)
                .padding(.bottom)
            
            
            if audioPlayer.isPlaying {
                
                Button(action: {
                    self.audioPlayer.stopPlayback()
                }) {
                    VuMeterView(hspacing: 61, width: 30)
                }
                
            } else {
                Button(action: {
                    self.audioPlayer.startPlayback()
                }) {
                    Image(systemName: "play")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .animation(.linear, value: audioPlayer.isLoading)
                }.disabled(audioPlayer.isLoading)
            }
            
            Spacer()
        }
    }
    
    
    
}




struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AudioPlayerView()
            .environmentObject(AudioPlayer())
    }
}
