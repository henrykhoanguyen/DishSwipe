import AVFoundation
import SwiftUI
import UIKit

struct LoopingVideoPlayer: UIViewRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> PlayerView {
        let view = PlayerView()
        view.backgroundColor = .black
        context.coordinator.load(url)
        view.player = context.coordinator.player
        return view
    }

    func updateUIView(_ view: PlayerView, context: Context) {
        context.coordinator.load(url)
        view.player = context.coordinator.player
    }

    static func dismantleUIView(_ view: PlayerView, coordinator: Coordinator) {
        coordinator.player.pause()
        coordinator.looper = nil
        coordinator.player.removeAllItems()
    }

    final class Coordinator {
        let player = AVQueuePlayer()
        var looper: AVPlayerLooper?
        private var currentURL: URL?

        init() {
            player.isMuted = true
            player.actionAtItemEnd = .none
        }

        func load(_ url: URL) {
            guard currentURL != url else {
                player.play()
                return
            }
            currentURL = url
            looper = nil
            player.removeAllItems()
            let item = AVPlayerItem(url: url)
            looper = AVPlayerLooper(player: player, templateItem: item)
            player.play()
        }
    }
}

final class PlayerView: UIView {
    override static var layerClass: AnyClass { AVPlayerLayer.self }

    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }

    var player: AVPlayer? {
        get { playerLayer.player }
        set {
            playerLayer.player = newValue
            playerLayer.videoGravity = .resizeAspectFill
        }
    }
}
