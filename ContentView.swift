import SwiftUI
import UIKit

struct ContentView: View {
    var body: some View {
        ContTwowWrapper()
            .ignoresSafeArea()
        
    }
}

struct ContTwowWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ContTwowViewController {
        ContTwowViewController()
    }
    func updateUIViewController(_ uiViewController: ContTwowViewController, context: Context) {}
}

final class ContTwowViewController: UIViewController {

    private let mainContainer = UIView()
    private let backgroundLayer = CAGradientLayer()
    private let button = UIButton(type: .custom)
    private let subtitle = UILabel()
    private var titleLabel: GradientLabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupCloudGroups()
        setupMainContainer()
        setupStars()
        setupAvatar()
        setupTopBar()
        setupTexts()
        setupButton()
        
        typeWriterEffect(to: subtitle, text: "Every Day Deserves Relaxing Time...")
    }

    private func setupBackground() {
        backgroundLayer.colors = [
            UIColor(hex: "#14153D").cgColor,
            UIColor(hex: "#24245A").cgColor,
            UIColor(hex: "#4A4A8E").cgColor
        ]
        backgroundLayer.frame = view.bounds
        view.layer.insertSublayer(backgroundLayer, at: 0)
    }
    private func setupCloudGroups() {
        for _ in 0..<5 {
            let cloudGroup = UIView()
            let startX = CGFloat.random(in: -100...view.bounds.width)
            let startY = CGFloat.random(in: 100...700)
            cloudGroup.frame = CGRect(x: startX, y: startY, width: 200, height: 100)

            for i in 0..<4 {
                let circle = UIView()
                let size = CGFloat.random(in: 60...120)
                let offsetX = CGFloat(i * 30)
                let offsetY = CGFloat.random(in: -20...20)
                
                circle.frame = CGRect(x: offsetX, y: offsetY, width: size, height: size)
                circle.backgroundColor = UIColor.white.withAlphaComponent(0.07)
                circle.layer.cornerRadius = size / 2

                let blur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
                blur.frame = circle.bounds
                blur.layer.cornerRadius = size / 2
                blur.clipsToBounds = true
                circle.addSubview(blur)
                
                cloudGroup.addSubview(circle)
            }
            
            view.insertSubview(cloudGroup, at: 1)

            let duration = Double.random(in: 20...35)
            UIView.animate(withDuration: duration, delay: 0, options: [.autoreverse, .repeat, .curveEaseInOut]) {
                cloudGroup.frame.origin.x += 150
            }
        }
    }

    private func setupMainContainer() {
        mainContainer.frame = view.bounds
        view.addSubview(mainContainer)
    }

    private func setupAvatar() {
        let glowContainer = UIView()
        glowContainer.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
        glowContainer.center = CGPoint(x: view.bounds.midX, y: 240)
        mainContainer.addSubview(glowContainer)

        let radialGradient = CAGradientLayer()
        radialGradient.type = .radial
        radialGradient.frame = glowContainer.bounds
        radialGradient.colors = [
            UIColor(hex: "#8793f5").withAlphaComponent(0.4).cgColor,
            UIColor(hex: "#A5B4FC").withAlphaComponent(0.1).cgColor,
            UIColor.clear.cgColor
        ]
        radialGradient.locations = [0.0, 0.6, 1.0]
        radialGradient.startPoint = CGPoint(x: 0.5, y: 0.5)
        radialGradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        glowContainer.layer.addSublayer(radialGradient)

        let imageView = UIImageView(image: UIImage(named: "pufi_social"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        mainContainer.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: mainContainer.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: mainContainer.topAnchor, constant: 120),
            imageView.widthAnchor.constraint(equalToConstant: 240),
            imageView.heightAnchor.constraint(equalToConstant: 240)
        ])
        
        UIView.animate(withDuration: 4.0, delay: 0, options: [.autoreverse, .repeat, .curveEaseInOut]) {
            imageView.transform = CGAffineTransform(translationX: 0, y: -25)
        }
    }

    private func setupTexts() {
        let welcomeLabel = UILabel()
        welcomeLabel.text = "Welcome To:"; welcomeLabel.font = .systemFont(ofSize: 16, weight: .medium)
        welcomeLabel.textColor = UIColor(hex: "#A5B4FC").withAlphaComponent(0.8)
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel = GradientLabel(colors: [UIColor.white, UIColor(hex: "#8793f5")])
        titleLabel.text = "PufiCloud"; titleLabel.font = .systemFont(ofSize: 75, weight: .black)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.textColor = .white.withAlphaComponent(0.7); subtitle.textAlignment = .center
        subtitle.font = .italicSystemFont(ofSize: 17); subtitle.numberOfLines = 0

        mainContainer.addSubview(welcomeLabel); mainContainer.addSubview(titleLabel); mainContainer.addSubview(subtitle)

        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: mainContainer.topAnchor, constant: 400),
            welcomeLabel.centerXAnchor.constraint(equalTo: mainContainer.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: -5),
            titleLabel.centerXAnchor.constraint(equalTo: mainContainer.centerXAnchor),
            subtitle.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitle.centerXAnchor.constraint(equalTo: mainContainer.centerXAnchor),
            subtitle.widthAnchor.constraint(equalTo: mainContainer.widthAnchor, multiplier: 0.8)
        ])
    }

    private func setupButton() {
        button.setTitle("Into the Sky ✨", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = UIColor(hex: "#8793f5").withAlphaComponent(0.2)
        button.layer.cornerRadius = 30
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleButtonPress), for: .touchUpInside)
        
        mainContainer.addSubview(button)
        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: mainContainer.bottomAnchor, constant: -100),
            button.centerXAnchor.constraint(equalTo: mainContainer.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 260),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    @objc private func handleButtonPress() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        UIView.animate(withDuration: 1.0, animations: {
            self.mainContainer.alpha = 0
            self.mainContainer.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            let vc = UIHostingController(rootView: firstpage())
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true)
        }
    }

    private func setupStars() {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        emitter.emitterSize = view.bounds.size
        emitter.emitterShape = .rectangle
        let cell = CAEmitterCell()
        cell.birthRate = 2.5
        cell.lifetime = 12
        cell.scale = 0.012
        cell.contents = createStarImage()?.cgImage
        emitter.emitterCells = [cell]
        view.layer.insertSublayer(emitter, at: 2)
    }

    private func createStarImage() -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 20, height: 20)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        UIColor.white.setFill(); UIBezierPath(ovalIn: rect).fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext(); return image
    }

    private func setupTopBar() {
        let bar = UILabel()
        bar.text = "☁️ DREAM MODE ACTIVE ☁️"
        bar.font = .systemFont(ofSize: 10, weight: .black)
        bar.textColor = UIColor(hex: "#A5B4FC").withAlphaComponent(0.5)
        bar.translatesAutoresizingMaskIntoConstraints = false
        mainContainer.addSubview(bar)
        NSLayoutConstraint.activate([
            bar.topAnchor.constraint(equalTo: mainContainer.topAnchor, constant: 60),
            bar.centerXAnchor.constraint(equalTo: mainContainer.centerXAnchor)
        ])
    }

    private func typeWriterEffect(to label: UILabel, text: String) {
        label.text = ""
        for (index, char) in text.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.06) {
                label.text?.append(char)
            }
        }
    }
}
final class GradientLabel: UILabel {
    private let gradientLayer = CAGradientLayer()
    init(colors: [UIColor]) {
        super.init(frame: .zero)
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0); gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.addSublayer(gradientLayer)
    }
    required init?(coder: NSCoder) { fatalError() }
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        let mask = CATextLayer()
        mask.string = text; mask.font = font; mask.fontSize = font.pointSize; mask.alignmentMode = .center
        mask.frame = bounds; mask.contentsScale = UIScreen.main.scale
        gradientLayer.mask = mask
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexSanitized.hasPrefix("#") { hexSanitized.remove(at: hexSanitized.startIndex) }
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        self.init(red: CGFloat((rgb >> 16) & 0xFF) / 255.0,
                  green: CGFloat((rgb >> 8) & 0xFF) / 255.0,
                  blue: CGFloat(rgb & 0xFF) / 255.0, alpha: 1.0)
    }
}

struct ContTwow_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().ignoresSafeArea().preferredColorScheme(.dark)
    }
}
