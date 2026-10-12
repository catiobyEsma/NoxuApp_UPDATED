import SwiftUI
import CoreHaptics

extension Color {
    func interpolateTo(_ color: Color, fraction: Double) -> Color {
        let f = CGFloat(max(0, min(1, fraction)))
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

        let uiColor1 = UIColor(self)
        let uiColor2 = UIColor(color)
        
        uiColor1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        uiColor2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return Color(
            red: Double(r1 + (r2 - r1) * f),
            green: Double(g1 + (g2 - g1) * f),
            blue: Double(b1 + (b2 - b1) * f),
            opacity: Double(a1 + (a2 - a1) * f)
        )
    }
}
struct PhysicalPainDetailView: View {
    @Environment(\.dismiss) var dismiss
    let gender: PhysicalPainStartView.Gender
    @Binding var isRootActive: Bool
    
    @State private var countdown = 5
    @State private var isPressing = false
    @State private var timer: Timer? = nil
    @State private var touchLocation: CGPoint? = nil
    @State private var isFinished = false
    @State private var colorTransition: Double = 0.0
    @State private var engine: CHHapticEngine?
    
    var body: some View {
        a()
    }
    @ViewBuilder
    func a() -> some View {
        ZStack {
            Color(hex: "#0D081A").ignoresSafeArea()
            StaticBackgroundStarsView()
            
            VStack(spacing: 20) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2.bold())
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Spacer()
                }
                .padding(.horizontal)
                VStack(spacing: 12) {
                    if isFinished {
                        Text("Session Completed")
                            .font(.system(size: 24, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                        Text("You've released some psychological tension.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    } else {
                        Text("Hold and press for 5 seconds to the exact location that you feel tension while your eyes closed.")
                            .font(.system(size: 18, weight: .medium, design: .serif))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .lineSpacing(4)
                        
                        Text("Again, this is not a cure or medical action.")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.5))
                            .italic()
                    }
                }
                .frame(height: 120)
                
                Spacer()
                ZStack {
                    Image(gender.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 40)
                        .opacity(isFinished ? 0.2 : (isPressing ? 1.0 : 0.6))
                        .animation(.easeInOut, value: isPressing)
                    
                    if !isFinished {
                        GeometryReader { geo in
                            Color.clear
                                .contentShape(Rectangle())
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { value in
                                            if !isPressing {
                                                touchLocation = value.location
                                                startSequence()
                                            }
                                        }
                                        .onEnded { _ in
                                            if !isFinished { stopSequence() }
                                        }
                                )
                        }
                    }
                    
                    if let pos = touchLocation {
                        circleProgressView
                            .position(pos)
                    }
                    
                    if isFinished {
                        completionButtons
                    }
                }
                .frame(maxHeight: UIScreen.main.bounds.height * 0.5)
                if isPressing && !isFinished {
                    Text("\(countdown)")
                        .font(.system(size: 80, weight: .black, design: .monospaced))
                        .foregroundColor(currentProgressColor)
                        .transition(.scale)
                }
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear { prepareHaptics() }
    }
    private var circleProgressView: some View {
        ZStack {
            Circle()
                .stroke(currentProgressColor, lineWidth: 4)
                .frame(width: 90, height: 90)
                .scaleEffect(isPressing ? 1.2 : 0.8)
            
            Circle()
                .fill(currentProgressColor)
                .frame(width: 40, height: 40)
                .shadow(color: currentProgressColor.opacity(0.8), radius: 15)
        }
    }
    
    private var completionButtons: some View {
        VStack(spacing: 20) {
            Button(action: {
                isRootActive = false
            }) {
                Text("Go Back to Menu")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 220, height: 60)
                    .background(LinearGradient(colors: [Color(hex: "#4232a8"), Color(hex: "#8793f5")], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(20)
            }
            
            Button(action: { resetExercise() }) {
                Text("Do Again")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
    private var currentProgressColor: Color {
        return Color.red.interpolateTo(Color(hex: "#007AFF"), fraction: colorTransition)
    }
    
    func startSequence() {
        isPressing = true
        countdown = 5
        colorTransition = 0.0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if countdown > 1 {
                countdown -= 1
                withAnimation(.linear(duration: 1.0)) {
                    colorTransition += 0.25
                }
                triggerDynamicHaptic(intensity: Float(6 - countdown) * 0.2)
            } else {
                completeSequence()
            }
        }
    }
    
    func stopSequence() {
        isPressing = false
        timer?.invalidate()
        timer = nil
        colorTransition = 0.0
        touchLocation = nil
    }
    
    func completeSequence() {
        isFinished = true
        isPressing = false
        timer?.invalidate()
        colorTransition = 1.0
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    func resetExercise() {
        withAnimation {
            isFinished = false
            touchLocation = nil
            colorTransition = 0.0
            countdown = 5
        }
    }
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do { engine = try CHHapticEngine(); try engine?.start() } catch { }
    }
    
    func triggerDynamicHaptic(intensity: Float) {
        let hapticIntensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [hapticIntensity], relativeTime: 0)
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            try engine?.makePlayer(with: pattern).start(atTime: 0)
        } catch { }
    }
}
