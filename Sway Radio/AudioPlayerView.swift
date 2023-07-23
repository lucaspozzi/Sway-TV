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
                .font(.largeTitle)
                .multilineTextAlignment(.center)
            
            Image(uiImage: audioPlayer.artworkImage)
                .resizable().cornerRadius(10)
                .background(
                    ZStack {
                        Circle()
                            .fill(Color.purple)
                            .blur(radius: 15)
                            .offset(x: 0, y: 0)
                    }
                )
                .scaleEffect(dragState.zoom)
                .gesture(pinchGesture(updating: $dragState))
                .aspectRatio(contentMode: .fit)
                .padding(.bottom)
            
            
            if audioPlayer.isPlaying {
                
                Button(action: {
                    self.audioPlayer.stopPlayback()
                }) {
                    HStack(spacing: 61) {
                        ForEach(0..<2) { index in
                            GeometryReader { geometry in
                                ZStack(alignment: .bottom) {
                                    Rectangle()  // Grey rectangle in the background
                                        .fill(Color.gray.opacity(0.2))
                                        .cornerRadius(15)
                                    
                                    // Colored rectangle in the foreground, its height changes with sound level
                                    Rectangle()
                                        .fill(LinearGradient(gradient: Gradient(colors: [Color.red, Color.yellow, Color.green]), startPoint: .top, endPoint: .bottom))
                                        .frame(height: geometry.size.height * (index == 0 ? CGFloat(audioPlayer.pseudoSoundLevelLeft) : CGFloat(audioPlayer.pseudoSoundLevelRight)))
                                        .cornerRadius(15)
                                        .animation(.default)
                                }
                            }
                            .frame(width: 30)  // Width of each bar
                        }
                    }
                    .padding()
                }
                
            } else {
                Button(action: {
                    DispatchQueue.main.async {
                        self.audioPlayer.isLoading = true
                        self.audioPlayer.startPlayback()
                    }
                }) {
                    Image(systemName: "play")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .animation(audioPlayer.isLoading ? Animation.easeInOut(duration: 1).repeatForever(autoreverses: true) : .default)
                }.disabled(audioPlayer.isLoading)
            }
            
            Spacer()
            
            //            CustomSlider(value: $audioPlayer.currentVolume)
            //                .foregroundColor(.accentColor)
            //                .padding()
            //                .aspectRatio(contentMode: .fill).disabled(true)
            //
            //            Spacer()
        }
    }
    
}

struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AudioPlayerView()
            .environmentObject(AudioPlayer())
    }
}
