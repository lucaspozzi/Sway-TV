//
//  SettingsView.swift
//  Sway TV
//
//  Created by Lucas Pozzi de Souza on 8/25/23.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    
    @State private var streamingQuality = UserDefaults.standard.integer(forKey: "useLowQuality")
    @EnvironmentObject var audioPlayer: AudioPlayer
    @State var isReviewEnabled: Bool = true
    
    func getCurrentVersion() -> String {
        // Get the current bundle version for the app
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        return appVersion
    }
    
    func checkReviewedVersions() {
        
        let currentVersion = getCurrentVersion()
        
        // Get last prompted version
        let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: "lastVersionPromptedForReviewKey")
        
        if(currentVersion == lastVersionPromptedForReview){
            isReviewEnabled = false
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Streaming"), footer: Text("Choose normal sound quality if you are having connection issues.")) {
                Picker("Sound Quality", selection: $streamingQuality) {
                    Text("High").tag(0)
                    Text("Normal").tag(1)
                }
                .pickerStyle(.automatic)
            }
            
            Section(header: Text("Share"), footer: Text("We appreciate it!")) {
                ShareLink("Send Sway to a friend", item: "https://apps.apple.com/us/app/sway-music-radio/id6451124668", message: Text("You will love Sway Music Radio. Viva los DJs!"))
            }
            
            Section(header: Text("Review"), footer: Text("Your feedback makes the app better and helps other listeners find Sway in the App Store.")) {
                Button(action:{
                    DispatchQueue.main.async {
                        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                            SKStoreReviewController.requestReview(in: scene)
                        }
                    }
                    UserDefaults.standard.set(getCurrentVersion(), forKey: "lastVersionPromptedForReviewKey")
                }){
                    Text("Review in the App Store")
                }.disabled(!isReviewEnabled)
            }
            
        }
        .onChange(of: streamingQuality) { //oldValue, newValue in
            UserDefaults.standard.set(streamingQuality, forKey: "useLowQuality")
            audioPlayer.handleStreamingQualityChange()
        }
        .onAppear(perform: checkReviewedVersions)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
