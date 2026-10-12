import Foundation
import AVFoundation

class SoundManager {
    static let instance = SoundManager()
    var player: AVAudioPlayer?

    enum SoundOption: String {
        case rain = "rain_sound"
        case forest = "forest_birds"
        case ocean = "ocean_waves"
    }

    func playSound(fileName: String, loop: Bool = false) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Ses oturumu (Audio Session) başlatılamadı: \(error)")
        }
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "wav") ??
                        Bundle.main.url(forResource: fileName, withExtension: "mp3") ??
                        Bundle.main.url(forResource: fileName, withExtension: "m4a") else {
            print("Ses dosyası bulunamadı: \(fileName)")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = loop ? -1 : 0
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("Ses çalma hatası: \(error.localizedDescription)")
        }
    }

    func stopSound() {
        player?.stop()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
