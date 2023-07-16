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
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        guard let topViewController = UIApplication.shared.windows.first?.rootViewController else { return }
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
