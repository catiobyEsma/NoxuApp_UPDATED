import SwiftUI

struct Sheep: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat = -100
    var velocity: CGFloat = 0
}

struct SheepCounterView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var sheeps: [Sheep] = []
    @State private var score = 0
    @State private var isGameOver = false
    @State private var showInstructions = true
    @State private var showGoodnight = false
    @State private var spawnInterval: Double = 7.0
    @State private var lastSpawnTime: Double = 0
    @State private var gameTime: Double = 0
    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    let gravity: CGFloat = 0.2
    let jumpStrength: CGFloat = -7
    let sheepSize: CGFloat = 55
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(hex: "#0D081A").ignoresSafeArea()
                StaticBackgroundStarsView()
                
                if showGoodnight {
                    goodnightOverlay
                } else {
                    VStack {
                        HStack {
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title).foregroundColor(.white.opacity(0.2))
                            }
                            Spacer()
                            Text("Score: \(score)")
                                .font(.title2.bold()).foregroundColor(.white)
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: "timer")
                                Text(String(format: "%.1fs", spawnInterval))
                            }
                            .font(.caption.bold())
                            .foregroundColor(Color(hex: "#6bb09d"))
                        }
                        .padding()
                        Spacer()
                    }
                    ForEach(sheeps) { sheep in
                        Text("🐑")
                            .font(.system(size: sheepSize))
                            .position(x: sheep.x, y: geometry.size.height / 2 + sheep.y)
                            .onTapGesture {
                                jump(sheepId: sheep.id)
                            }
                    }
                    if showInstructions {
                        instructionOverlay
                    }
                    if isGameOver {
                        gameOverView
                    }
                }
            }
            .onReceive(timer) { _ in
                guard !isGameOver && !showInstructions && !showGoodnight else { return }
                updateGame(in: geometry)
            }
        }
        .navigationBarHidden(true)
    }
    
    func updateGame(in geo: GeometryProxy) {
        gameTime += 0.02
        if gameTime - lastSpawnTime >= spawnInterval {
            let randomX = CGFloat.random(in: 50...(geo.size.width - 50))
            sheeps.append(Sheep(x: randomX))
            lastSpawnTime = gameTime
            if spawnInterval > 2.0 {
                spawnInterval -= 0.5
            }
        }
        for index in sheeps.indices {
            sheeps[index].velocity += gravity
            sheeps[index].y += sheeps[index].velocity
        }
        let limit = geo.size.height / 2
        sheeps.removeAll { $0.y > limit }
        if sheeps.isEmpty && gameTime > 1.0 {
            isGameOver = true
        }
    }
    
    func jump(sheepId: UUID) {
        if let index = sheeps.firstIndex(where: { $0.id == sheepId }) {
            sheeps[index].velocity = jumpStrength
            score += 1
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
    
    func startGame() {
        sheeps = [Sheep(x: UIScreen.main.bounds.width / 2)]
        score = 0
        gameTime = 0
        lastSpawnTime = 0
        spawnInterval = 7.0
        isGameOver = false
        showInstructions = false
    }
    var instructionOverlay: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            VStack(spacing: 25) {
                Text("🐑").font(.system(size: 80))
                Text("Keepy Uppy!").font(.title.bold()).foregroundColor(.white)
                Text("Tap the sheep to keep them in the air.\nNew sheep will appear faster and faster!\nDon't let the screen get empty.")
                    .font(.subheadline).multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.7)).padding(.horizontal)
                
                Button(action: { startGame() }) {
                    Text("Start Game").font(.headline).foregroundColor(.white)
                        .frame(width: 200, height: 50).background(Color(hex: "#6bb09d")).cornerRadius(15)
                }
            }
        }
    }
    
    var gameOverView: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            VStack(spacing: 30) {
                Text("All sheep are gone...").font(.title2.bold()).foregroundColor(.white)
                Text("Final Score: \(score)").font(.title).foregroundColor(Color(hex: "#6bb09d"))
                
                VStack(spacing: 15) {
                    Button(action: { startGame() }) {
                        Label("Retry", systemImage: "arrow.clockwise")
                            .font(.headline).foregroundColor(.white)
                            .frame(width: 220, height: 50).background(Color(hex: "#6bb09d")).cornerRadius(15)
                    }
                    
                    Button(action: { withAnimation { showGoodnight = true } }) {
                        Label("Sleep Now", systemImage: "moon.stars.fill")
                            .font(.headline).foregroundColor(.white.opacity(0.9))
                            .frame(width: 220, height: 50).background(Color.white.opacity(0.1)).cornerRadius(15)
                    }
                }
            }
        }
    }
    
    var goodnightOverlay: some View {
        VStack(spacing: 20) {
            Text("🌙").font(.system(size: 100))
            Text("Goodnight!").font(.system(size: 40, weight: .bold, design: .rounded)).foregroundColor(.white)
            Text("Your sleep assistant is closing...").font(.subheadline).foregroundColor(.white.opacity(0.5))
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                dismiss()
            }
        }
    }
}
