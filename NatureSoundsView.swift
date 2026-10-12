import SwiftUI

struct NatureSoundsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("active_nature_sound") private var activeSound: String?
    
    @State private var backgroundAssets: [(name: String, x: CGFloat, y: CGFloat, size: CGFloat)] = []
    @State private var showLicensePopup = false
    
    let sounds = [
        ("Rain", "cloud.rain", Color(hex: "A2C2E1"), "rain_sound"),
        ("Morning", "sun.max", Color(hex: "F9E2AF"), "morning_sound"),
        ("Summer Night", "moon.stars", Color(hex: "CBAACB"), "summer_night")
    ]
    
    var body: some View {
        ZStack {
            Color(red: 13/255, green: 8/255, blue: 26/255).ignoresSafeArea()
            
            ForEach(0..<backgroundAssets.count, id: \.self) { i in
                Image(backgroundAssets[i].name)
                    .resizable()
                    .scaledToFit()
                    .frame(width: backgroundAssets[i].size)
                    .opacity(0.12)
                    .position(x: backgroundAssets[i].x, y: backgroundAssets[i].y)
                    .blur(radius: 1)
            }
            
            starsBackground
            
            VStack(spacing: 20) {
                headerView
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        ForEach(sounds, id: \.0) { name, icon, color, fileName in
                            soundRow(name: name, icon: icon, color: color, fileName: fileName)
                        }
                    }
                    .padding(25)
                }
                
                VStack(spacing: 12) {
                    if activeSound != nil {
                        stopButton
                    }
                    
                    Button(action: { showLicensePopup = true }) {
                        Text("sound license & disclaimer")
                            .font(.system(size: 10))
                            .italic()
                            .underline()
                            .foregroundColor(.white.opacity(0.3))
                    }
                    .padding(.bottom, 15)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            setupBackgroundAssets()
 
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {

            }
        }
        .sheet(isPresented: $showLicensePopup) {
            licenseSheetContent
        }
    }
    
    // MARK: - Subviews
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            }
            Spacer()
            Text("Atmosphere")
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundColor(.white)
            Spacer()
            Color.clear.frame(width: 30, height: 1)
        }
        .padding(.top, 20)
        .padding(.horizontal)
    }

    func soundRow(name: String, icon: String, color: Color, fileName: String) -> some View {
        let isPlaying = activeSound == name
        
        return Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            if isPlaying {
                SoundManager.instance.stopSound()
                activeSound = nil
            } else {
                SoundManager.instance.stopSound()
                activeSound = name
                SoundManager.instance.playSound(fileName: fileName, loop: true)
            }
        }) {
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(color.opacity(isPlaying ? 0.3 : 0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(isPlaying ? color : color.opacity(0.6))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(isPlaying ? .white : .white.opacity(0.6))
                    
                    if isPlaying {
                        SoundWaveView(color: color).frame(height: 15)
                    } else {
                        Text("Quietly playing").font(.caption2).foregroundColor(.gray.opacity(0.5))
                    }
                }
                Spacer()
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 20)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white.opacity(isPlaying ? 0.08 : 0.03))
                    
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(color.opacity(0.4), lineWidth: 0.5)
                        .blur(radius: isPlaying ? 10 : 0)
                        .opacity(isPlaying ? 1 : 0)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(isPlaying ? color.opacity(0.5) : Color.white.opacity(0.05), lineWidth: 1)
            )
            .scaleEffect(isPlaying ? 1.04 : 1.0)
        }
        .buttonStyle(QuietButtonStyle())
    }

    private var stopButton: some View {
        Button(action: {
            withAnimation {
                SoundManager.instance.stopSound()
                activeSound = nil
            }
        }) {
            Text("Stop Atmosphere")
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
                .padding(.vertical, 12)
                .padding(.horizontal, 30)
                .background(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
        }
    }

    private var starsBackground: some View {
        ZStack {
            ForEach(0..<15, id: \.self) { _ in
                Circle().fill(Color.white.opacity(0.15))
                    .frame(width: 1.5, height: 1.5)
                    .position(x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                              y: CGFloat.random(in: 0...UIScreen.main.bounds.height))
            }
        }
    }
    private var licenseSheetContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("Sound Licensing")
                    .font(.title3).bold()
                    .foregroundColor(.white)
                    .padding(.bottom, 5)

                Text("The nature sounds in NoxuApp are provided by **MixKit**. This application does not claim any ownership rights over these sound effects.")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.8))

                Text("Usage Policy:")
                    .font(.footnote).bold()
                    .foregroundColor(.white)

                Text("These sounds are used under the Mixkit Sound Effects Free License. They are integrated into NoxuApp for entertainment and atmosphere purposes, creating an end product that is different in nature than the original standalone items.")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))

                Divider().background(Color.white.opacity(0.2))

                Text("Terms Summary:")
                    .font(.footnote).bold()
                    .foregroundColor(.white)

                Text("As per MixKit terms, these sounds are permitted for use in video games and applications. Redistribution of these items as standalone stock files is strictly prohibited. All rights remain with MixKit.")
                    .font(.caption)
                    .italic()
                    .foregroundColor(.white.opacity(0.6))
                
                Text("For fair use purposes only.")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.top, 10)
            }
            .padding(30)
        }
        .background(Color(red: 13/255, green: 8/255, blue: 26/255).ignoresSafeArea())
        .presentationDetents([.medium])
    }
            
    private func setupBackgroundAssets() {
        if backgroundAssets.isEmpty {
            backgroundAssets = [
                (name: "p1", x: 300, y: 134, size: 90),
                (name: "p22", x: 300, y: 245, size: 120),
                (name: "pufi_study", x: 300, y: 335, size: 110),
                (name: "pufi_worried", x: 280, y: 500, size: 200),
                (name: "p2", x: 110, y: 600, size: 150)
            ]
        }
    }
}

struct SoundWaveView: View {
    let color: Color
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<6) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(color.opacity(0.8))
                    .frame(width: 2, height: isAnimating ? CGFloat.random(in: 10...20) : 5)
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 0.5...0.8))
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.1),
                        value: isAnimating
                    )
            }
        }
        .onAppear { isAnimating = true }
    }
}

struct QuietButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.interpolatingSpring(stiffness: 300, damping: 15), value: configuration.isPressed)
    }
}
