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
    
    @State private var timerAnimation: Timer? = nil
    @State var pseudoSoundLevelLeft: CGFloat = 0.0
    @State var pseudoSoundLevelRight: CGFloat = 0.0
    
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
                    invalidateTimers()
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
                                        .frame(height: geometry.size.height * (index == 0 ? CGFloat(pseudoSoundLevelLeft) : CGFloat(pseudoSoundLevelRight)))
                                        .cornerRadius(15)
                                        .animation(.default)
                                }
                            }
                            .frame(width: 30)  // Width of each bar
                        }
                    }
//                    .padding()
                }
                
            } else {
                Button(action: {
                    self.audioPlayer.startPlayback()
                    setupTimers()
                }) {
                    Image(systemName: "play")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .animation(audioPlayer.isLoading ? Animation.easeInOut(duration: 1).repeatForever(autoreverses: true) : .default)
                }.disabled(audioPlayer.isLoading)
            }
            
            Spacer()
        }
        .onAppear(perform: setupTimers)
        .onDisappear(perform: invalidateTimers)
    }
    
    func invalidateTimers() {
        pseudoSoundLevelLeft = 0.0
        pseudoSoundLevelRight = 0.0
        timerAnimation?.invalidate()
    }
    
    func setupTimers() {
        timerAnimation = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            // Generate a pseudo-random sound level between 0.0 and 1.0 for each channel
            if(audioPlayer.isPlaying){
                DispatchQueue.main.async {
                    self.pseudoSoundLevelLeft = CGFloat.random(in: 0.55...0.90)
                    self.pseudoSoundLevelRight = CGFloat.random(in: 0.60...1.00)
                }
                
            } else {
                pseudoSoundLevelLeft = 0.0
                pseudoSoundLevelRight = 0.0
            }
        }
    }
}

struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AudioPlayerView()
            .environmentObject(AudioPlayer())
    }
}
