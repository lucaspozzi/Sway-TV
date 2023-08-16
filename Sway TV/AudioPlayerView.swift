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
    @State private var isShowingModal = false
    private var sentiments = Sentiments()
    @State private var lastSentimentTrackName: String?
    
    var body: some View {
        
        HStack {
            
            VStack {
                if audioPlayer.isPlaying {
                    
                    Button(action: {
                        self.audioPlayer.stopPlayback()
                    }) {
                        HStack(spacing: 91) {
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
                                .frame(width: 70)  // Width of each bar
                            }
                        }
                        .padding()
                    }.frame(height: 490)
                    
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
                        .frame(height: 490)
                        .foregroundColor(audioPlayer.isLoading ? .gray : Color.init("AccentColor"))

                }
                
                HStack {
                    
                    
                    if audioPlayer.currentTrackTitle != lastSentimentTrackName {
                        
                        Button(action: {
                            if audioPlayer.currentTrackTitle != lastSentimentTrackName {
                                sentiments.add(currentTrack: audioPlayer.currentTrackTitle, sentimentName: "like")
                                sentiments.addToPrivateDatabaseOrUpdateTime(currentTrack: audioPlayer.currentTrackTitle, sentimentName: "like", artUrl: audioPlayer.currentAlbumArtUrl)
                                lastSentimentTrackName = audioPlayer.currentTrackTitle
                            }
                        }) {
                            Image(systemName: "hand.thumbsup.fill")
                        }
                        .disabled(audioPlayer.isLoading)
                        
                        Button(action: {
                            if audioPlayer.currentTrackTitle != lastSentimentTrackName {
                                sentiments.add(currentTrack: audioPlayer.currentTrackTitle, sentimentName: "figure.dance")
                                sentiments.addToPrivateDatabaseOrUpdateTime(currentTrack: audioPlayer.currentTrackTitle, sentimentName: "figure.dance", artUrl: audioPlayer.currentAlbumArtUrl)
                                lastSentimentTrackName = audioPlayer.currentTrackTitle
                            }
                        }) {
                            Image(systemName: "figure.dance")
                        }
                        .disabled(audioPlayer.isLoading)
                        .padding(.horizontal)
                        
                        
                        Button(action: {
                            if audioPlayer.currentTrackTitle != lastSentimentTrackName {
                                sentiments.add(currentTrack: audioPlayer.currentTrackTitle, sentimentName: "figure.socialdance")
                                sentiments.addToPrivateDatabaseOrUpdateTime(currentTrack: audioPlayer.currentTrackTitle, sentimentName: "figure.socialdance", artUrl: audioPlayer.currentAlbumArtUrl)
                                lastSentimentTrackName = audioPlayer.currentTrackTitle
                            }
                        }) {
                            Image(systemName: "figure.socialdance")
                        }
                        .disabled(audioPlayer.isLoading)
                        
                    } else {
                        Text("Sway!").foregroundColor(.gray).animation(.default).padding()
                    }
                }
                
            }
            .aspectRatio(contentMode: .fit)
            .padding()
            .frame(width: 880)
            
            VStack {
                Button(action: {
                    isShowingModal = true
                }) {
                    VStack {
                        Image(uiImage: audioPlayer.artworkImage)
                            .resizable().cornerRadius(10)
                        Text("View album artwork")
                    }
                    .shadow(color: .purple, radius: 1, x: 0, y: 1)
                }.buttonStyle(.card)
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .frame(width: 880)
                
                
                Text(audioPlayer.currentTrackTitle)
                    .font(.headline)
                    .padding(.top)
                    .lineLimit(nil) // Allows as many lines as needed
                    .fixedSize(horizontal: false, vertical: true) // This ensures the text view grows vertically
                    .multilineTextAlignment(.center)
                
                
            }
            
            
        }
        .frame(height: 740)
//        .onAppear{
//            fetchOnce()
//            startFetching()
//        }
//        .onDisappear{
//            stopFetching()
//        }
        .sheet(isPresented: $isShowingModal) {
            Image(uiImage: audioPlayer.artworkImage)
                .resizable().cornerRadius(10)
                .aspectRatio(contentMode: .fit)
        }
    }
    
    
}

struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AudioPlayerView()
            .environmentObject(AudioPlayer())
    }
}
