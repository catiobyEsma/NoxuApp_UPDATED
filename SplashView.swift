import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var opacity = 0.0
    @State private var textOffset = 20.0
    @State private var starPoints: [CGPoint] = []
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                Image("Background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                ZStack {
                    ForEach(0..<starPoints.count, id: \.self) { i in
                        Circle()
                            .fill(Color.white)
                            .frame(width: CGFloat.random(in: 1...2.5))
                            .position(starPoints[i])
                            .opacity(Double.random(in: 0.3...0.7))
                    }
                }
                .ignoresSafeArea()
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                RadialGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.6)]),
                    center: .center,
                    startRadius: 100,
                    endRadius: 500
                )
                .ignoresSafeArea()
                VStack(spacing: 20) {
                    Image("pufi_social")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 280, height: 280)
                        .shadow(color: Color(hex: "#8793f5").opacity(0.8), radius: 30)
                        .scaleEffect(opacity == 1.0 ? 1.0 : 0.9)
                    
                    VStack(spacing: 10) {
                        Text("NOXUAPP")
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .italic()
                            .foregroundColor(.white)
                            .tracking(10)
                            .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
                        
                        Text("your night companion")
                            .font(.system(size: 16, weight: .light, design: .serif))
                            .italic()
                            .foregroundColor(.white.opacity(0.8))
                            .tracking(2)
                    }
                    .offset(y: textOffset)
                    
                    Spacer().frame(height: 30)
                    
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(
                            LinearGradient(colors: [Color(hex: "#8793f5"), .white], startPoint: .leading, endPoint: .trailing),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 35, height: 35)
                        .rotationEffect(Angle(degrees: opacity == 1.0 ? 360 : 0))
                        .animation(.linear(duration: 1.2).repeatForever(autoreverses: false), value: opacity)
                }
                .opacity(opacity)
            }
            .onAppear {
                generateStars()
                
                withAnimation(.easeOut(duration: 1.2)) {
                    self.opacity = 1.0
                    self.textOffset = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        self.isActive = true
                    }
                }
            }
        }
    }
    func generateStars() {
        if starPoints.isEmpty {
            for _ in 0..<80 {
                let x = CGFloat.random(in: 0...UIScreen.main.bounds.width)
                let y = CGFloat.random(in: 0...UIScreen.main.bounds.height)
                starPoints.append(CGPoint(x: x, y: y))
            }
        }
    }
}
