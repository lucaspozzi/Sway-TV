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
    @State private var artworkImage: UIImage = UIImage(named: "audiodog")!
    @State private var currentTrackTitle: String = "djclaudiof"
    @State private var timer: Timer?
    
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
            
            Image(uiImage: artworkImage)
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
            
            
            Spacer()
            
            Text("Live now:")
            Text(currentTrackTitle)
                .font(.headline).lineLimit(2).padding()
                .multilineTextAlignment(.center)
            
            
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
                    .padding(.horizontal)
                }

                
                
            } else {
                Button(action: {
                    DispatchQueue.main.async {
                        self.audioPlayer.isLoading = true
                        self.audioPlayer.startPlayback(title: self.currentTrackTitle, artwork: artworkImage)
                    }
                }) {
                    Image(systemName: "play")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .animation(audioPlayer.isLoading ? Animation.easeInOut(duration: 1).repeatForever(autoreverses: true) : .default)
                }.disabled(audioPlayer.isLoading)
            }
            
            Spacer()
            
        }
        .onAppear{
            fetchOnce()
            startFetching()
            
        }
        .onDisappear{
            stopFetching()
        }
    }
    
    func fetchOnce() {
        
        fetchRadioStationMetadata { result in
            switch result {
            case .success(let metadata):
                DispatchQueue.global().async {
                    if let url = URL(string: metadata.currentTrack.artworkURLLarge),
                       let data = try? Data(contentsOf: url),
                       let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            artworkImage = image
                        }
                    }
                    
                }
                DispatchQueue.main.async {
                    currentTrackTitle = metadata.currentTrack.title
                }
            case .failure(let error):
                print("Error \(error)")
            }
            
        }
    }
    
    func startFetching() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            fetchOnce()
        }
    }
    
    func stopFetching(){
        timer?.invalidate()
        timer = nil
    }
}

struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AudioPlayerView()
            .environmentObject(AudioPlayer())
    }
}
