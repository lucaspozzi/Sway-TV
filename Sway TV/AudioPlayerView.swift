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
    @State private var countdownSeconds = 50
    @State private var isCountdownActive = false
    
    
    func startCountdown() {
        isCountdownActive = true
        countdownSeconds = 50
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            countdownSeconds -= 1
            if countdownSeconds <= 0 {
                timer.invalidate()
                isCountdownActive = false
            }
        }
    }
    
    var body: some View {
        
        HStack {
            
            VStack {
                if audioPlayer.isPlaying {
                    
                    Button(action: {
                        audioPlayer.stopPlayback()
                    }) {
                        VuMeterView(hspacing: 91, width: 70)
                        .padding()
                    }.frame(height: 490).buttonStyle(PlainButtonStyle())
                    
                } else {
                    Button(action: {
                        audioPlayer.startPlayback()
                    }) {
                        Image(systemName: "play")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .animation(.default, value: audioPlayer.isLoading)
                    }.disabled(audioPlayer.isLoading)
                        .frame(height: 490)
                        .foregroundColor(audioPlayer.isLoading ? .gray : Color.init("AccentColor"))
                        .buttonStyle(.plain)

                }
                
                HStack {
                    
                    
                    if !isCountdownActive {
                        
                        Button(action: {
                            if !isCountdownActive {
                                startCountdown()
                                sentiments.add(currentTrack: audioPlayer.currentTrackTitle, sentimentName: "like")
                                sentiments.addToPrivateDatabaseOrUpdateTime(currentTrack: audioPlayer.currentTrackTitle, sentimentName: "like", artUrl: audioPlayer.currentAlbumArtUrl)
                                lastSentimentTrackName = audioPlayer.currentTrackTitle
                            }
                        }) {
                            Image(systemName: "hand.thumbsup.fill")
                        }
                        .disabled(audioPlayer.isLoading)
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(audioPlayer.isLoading ? .gray : Color.init("AccentColor"))
                        
                        Button(action: {
                            if !isCountdownActive {
                                startCountdown()
                                sentiments.add(currentTrack: audioPlayer.currentTrackTitle, sentimentName: "figure.dance")
                                sentiments.addToPrivateDatabaseOrUpdateTime(currentTrack: audioPlayer.currentTrackTitle, sentimentName: "figure.dance", artUrl: audioPlayer.currentAlbumArtUrl)
                                lastSentimentTrackName = audioPlayer.currentTrackTitle
                            }
                        }) {
                            Image(systemName: "figure.dance")
                        }
                        .disabled(audioPlayer.isLoading)
                        .padding(.horizontal, 35)
                        .buttonStyle(.plain)
                        .foregroundColor(audioPlayer.isLoading ? .gray : Color.init("AccentColor"))
                        
                        Button(action: {
                            if !isCountdownActive {
                                startCountdown()
                                sentiments.add(currentTrack: audioPlayer.currentTrackTitle, sentimentName: "figure.socialdance")
                                sentiments.addToPrivateDatabaseOrUpdateTime(currentTrack: audioPlayer.currentTrackTitle, sentimentName: "figure.socialdance", artUrl: audioPlayer.currentAlbumArtUrl)
                                lastSentimentTrackName = audioPlayer.currentTrackTitle
                            }
                        }) {
                            Image(systemName: "figure.socialdance")
                        }
                        .disabled(audioPlayer.isLoading)
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(audioPlayer.isLoading ? .gray : Color.init("AccentColor"))
                        
                    } else {
                        Text("Sway!").foregroundColor(.gray).animation(.default).padding()
                    }
                }.padding(.top)
                
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
                    }
                }.buttonStyle(.card)
                    .aspectRatio(contentMode: .fit)
//                    .padding()
                    .frame(width: 880)
                
                
                Text(audioPlayer.currentTrackTitle)
                    .font(.headline)
                    .padding(.top)
                    .lineLimit(nil) // Allows as many lines as needed
                    .fixedSize(horizontal: false, vertical: true) // This ensures the text view grows vertically
                    .multilineTextAlignment(.center)
                
            }.padding(.top)
            
            
        }
        .padding(.top, 100)
        .frame(height: 740)
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
