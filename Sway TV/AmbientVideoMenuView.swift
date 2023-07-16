import SwiftUI
import AVKit

struct AmbientVideoMenuView: View {
    var body: some View {
        HStack {
            Button(action: {
                playVideoFullScreen()
            }) {
                VStack {
                    Image("videoplaceholder").resizable().aspectRatio(contentMode: .fit)
                    Text("Start Ambient Video One")
                }
                
            }
            
            Button(action: {
                playVideoFullScreen()
            }) {
                VStack {
                    Image("videoplaceholder").resizable().aspectRatio(contentMode: .fit)
                    Text("Start Ambient Video Two")
                }
            }
        }
    }
    
    private func playVideoFullScreen() {
//        guard let url = URL(string: videoURL) else { return }
        let videoUrl = Bundle.main.url(forResource: "wave", withExtension: "mp4")!
        let player = AVPlayer(url: videoUrl)
        player.actionAtItemEnd = .none
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil) { _ in
            player.seek(to: .zero)
            player.play()
        }
        
        let playerViewController = AVPlayerViewController()
        playerViewController.modalPresentationStyle = .fullScreen
        playerViewController.showsPlaybackControls = false
        playerViewController.player = player
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let topViewController = windowScene.windows.first?.rootViewController else {
            return
        }
        
        topViewController.present(playerViewController, animated: true) {
            playerViewController.player?.play()
        }
    }
}

struct AmbientVideoMenuView_Previews: PreviewProvider {
    static var previews: some View {
        AmbientVideoMenuView()
    }
}
