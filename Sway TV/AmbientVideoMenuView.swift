import SwiftUI
import AVKit

struct AmbientVideoMenuView: View {
    var body: some View {
        
        VStack {
            Text("Ambient Videos")
            ScrollView(.horizontal, showsIndicators: true) {
                HStack {
                    Spacer()
                    Button(action: {
                        playVideoFullScreen(url: "https://drive.google.com/uc?export=download&id=1XmcoSiJX8cdxu0VXKUlusb-J-PlyR4PB")
                    }) {
                        VStack {
                            Image("videoplaceholder").resizable().aspectRatio(contentMode: .fill)
                            Text("Ocean")
                        }
                    }.buttonStyle(.card)
                    .padding()
                    
                    Button(action: {
                        playVideoFullScreen(url: "https://drive.google.com/uc?export=download&id=1S7iftvd2JOy9ZV2bg6uXGRK4DLPKPJgq")
                    }) {
                        VStack {
                            Image("videoplaceholder")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                            Text("Rings")
                        }
                    }.buttonStyle(.card)
                    .padding()
                    
                    Button(action: {
                        playVideoFullScreen(url: "https://drive.google.com/uc?export=download&id=1CjPjhEA79bQFIl3KfWng-4A4YrDtCmOB")
                    }) {
                        VStack {
                            Image("videoplaceholder")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                            Text("Triangles")
                        }
                    }.buttonStyle(.card)
                    .padding()
                    Spacer()
                }
            }
        }
        .frame(height: 500)
    }
    
    private func playVideoFullScreen(url: String) {
        guard let videoUrl = URL(string: url) else { return }
//        let videoUrl = Bundle.main.url(forResource: "wave", withExtension: "mp4")!
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
