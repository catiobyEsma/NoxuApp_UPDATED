import SwiftUI
struct ActiveConstellation: Identifiable {
    let id = UUID()
    let points: [CGPoint]
    var opacity: Double = 0.0
    var scale: CGFloat = 0.5
}

struct WorriedPage: View {
    @Environment(\.dismiss) var dismiss
    @State private var thoughtText: String = ""
    @State private var activeConstellations: [ActiveConstellation] = []
    @State private var usedPoints: [CGPoint] = []
    @FocusState private var isTextFieldFocused: Bool
    
    let templates: [[CGPoint]] = [
        [CGPoint(x: 0, y: 0), CGPoint(x: 20, y: -30), CGPoint(x: 50, y: -40), CGPoint(x: 70, y: -10), CGPoint(x: 40, y: 20)],
        [CGPoint(x: 0, y: 0), CGPoint(x: 35, y: 10), CGPoint(x: 60, y: 0), CGPoint(x: 45, y: -35)],
        [CGPoint(x: 0, y: 0), CGPoint(x: -20, y: 40), CGPoint(x: 20, y: 60), CGPoint(x: 50, y: 30)],
        [CGPoint(x: 0, y: 0), CGPoint(x: 25, y: 25), CGPoint(x: 50, y: 5), CGPoint(x: 75, y: 35)]
    ]

    var body: some View {
        ZStack {
            Color(hex: "#050B18").ignoresSafeArea()
            StaticStarsView()
            ZStack {
                ForEach(activeConstellations) { constellation in
                    ConstellationView(points: constellation.points)
                        .opacity(constellation.opacity)
                        .scaleEffect(constellation.scale)
                }
            }
            
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2.bold())
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Spacer()
                }
                Spacer()
                
                VStack(spacing: 25) {
                    Text("Give your worry a place in the sky")
                        .font(.system(.subheadline, design: .serif))
                        .foregroundColor(.white.opacity(0.7))
                        .italic()
                    
                    TextField("What is on your mind?", text: $thoughtText)
                        .focused($isTextFieldFocused)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white.opacity(0.1)))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button(action: createConstellation) {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Turn into a Star")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 240, height: 50)
                        .background(
                            ZStack {
                                Capsule().fill(Color.blue.opacity(0.2))
                                Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1)
                            }
                        )
                    }
                    .disabled(thoughtText.isEmpty)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    func createConstellation() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let minDistance: CGFloat = activeConstellations.count > 15 ? 60 : 100
        
        var newAnchor = CGPoint.zero
        var foundSpot = false
        for _ in 0..<20 {
            let potentialAnchor = CGPoint(
                x: CGFloat.random(in: 40...(screenWidth - 100)),
                y: CGFloat.random(in: 100...(screenHeight - 350))
            )
            
            let tooClose = usedPoints.contains { existing in
                let distance = sqrt(pow(existing.x - potentialAnchor.x, 2) + pow(existing.y - potentialAnchor.y, 2))
                return distance < minDistance
            }
            
            if !tooClose {
                newAnchor = potentialAnchor
                foundSpot = true
                break
            }
        }
        if !foundSpot {
            newAnchor = CGPoint(
                x: CGFloat.random(in: 40...(screenWidth - 100)),
                y: CGFloat.random(in: 100...(screenHeight - 350))
            )
        }
        
        usedPoints.append(newAnchor)
        let template = templates.randomElement() ?? templates[0]
        let positionedPoints = template.map { CGPoint(x: $0.x + newAnchor.x, y: $0.y + newAnchor.y) }
        let newConstellation = ActiveConstellation(points: positionedPoints)
        activeConstellations.append(newConstellation)
        
        withAnimation(.easeOut(duration: 3.0)) {
            if let index = activeConstellations.firstIndex(where: { $0.id == newConstellation.id }) {
                activeConstellations[index].opacity = 1.0
                activeConstellations[index].scale = 1.0
            }
        }
        
        thoughtText = ""
        isTextFieldFocused = false
    }
}
struct ConstellationView: View {
    let points: [CGPoint]
    @State private var twinkle = false
    var body: some View {
        ZStack {
            Path { path in
                guard let first = points.first else { return }
                path.move(to: first)
                for point in points.dropFirst() { path.addLine(to: point) }
            }.stroke(Color.white.opacity(0.15), lineWidth: 0.8)
            
            ForEach(0..<points.count, id: \.self) { i in
                Circle()
                    .fill(Color.white)
                    .frame(width: i == 0 ? 4 : 2.5)
                    .shadow(color: .white.opacity(twinkle ? 0.7 : 0.2), radius: twinkle ? 4 : 1)
                    .position(points[i])
            }
        }.onAppear {
            withAnimation(.easeInOut(duration: Double.random(in: 1.5...3.0)).repeatForever(autoreverses: true)) {
                twinkle = true
            }
        }
    }
}

struct StaticStarsView: View {
    struct Star: Identifiable {
        let id = UUID()
        let position: CGPoint
        let size: CGFloat
        let opacity: Double
    }
    
    @State private var stars: [Star] = []

    var body: some View {
        ZStack {
            ForEach(stars) { star in
                Circle()
                    .fill(Color.white)
                    .frame(width: star.size)
                    .position(star.position)
                    .opacity(star.opacity)
            }
        }
        .onAppear {
            createStars()
        }
    }
    
    func createStars() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        var newStars: [Star] = []
        for _ in 0..<70 {
            let star = Star(
                position: CGPoint(
                    x: CGFloat.random(in: 0...screenWidth),
                    y: CGFloat.random(in: 0...screenHeight)
                ),
                size: CGFloat.random(in: 0.8...2.0),
                opacity: Double.random(in: 0.2...0.5)
            )
            newStars.append(star)
        }
        self.stars = newStars
    }
}

#Preview {
    WorriedPage()
}
