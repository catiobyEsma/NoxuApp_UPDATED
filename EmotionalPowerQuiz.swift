import SwiftUI

// MARK: - MODELS (Aynı kalıyor)
struct EmotionalQuestion {
    let question: String
    let options: [EmotionalOption]
}

struct EmotionalOption {
    let text: String
    let index: Int
}

enum EmotionalPower: String {
    case empathy = "Infinite Empathy"
    case resilience = "Iron Resilience"
    case intuition = "Deep Intuition"
    case optimism = "Radiant Optimism"
    case wisdom = "Ancient Wisdom"
    case serenity = "Quiet Serenity"
}

struct EmotionalPowerQuizView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentQuestionIndex = 0
    @State private var counts: [Int: Int] = [1: 0, 2: 0, 3: 0, 4: 0]
    @State private var showResult = false
    @State private var finalResult: EmotionalPower = .empathy
    
    let mascotImages = ["p11", "p22", "p33", "p44"]

    let questions: [EmotionalQuestion] = [
        EmotionalQuestion(question: "When a friend is sad, what is your first instinct?", options: [
            EmotionalOption(text: "Listening and feeling their pain", index: 1),
            EmotionalOption(text: "Giving them a motivational talk", index: 2),
            EmotionalOption(text: "Analyzing why they feel this way", index: 3),
            EmotionalOption(text: "Just sitting with them in silence", index: 4)
        ]),
        EmotionalQuestion(question: "How do you react to unexpected changes?", options: [
            EmotionalOption(text: "I try to understand everyone's feelings", index: 1),
            EmotionalOption(text: "I adapt and keep moving forward", index: 2),
            EmotionalOption(text: "I trust my gut feeling to guide me", index: 3),
            EmotionalOption(text: "I remain calm and focused", index: 4)
        ]),
        EmotionalQuestion(question: "Which of these sounds most like you?", options: [
            EmotionalOption(text: "I can read the room instantly", index: 3),
            EmotionalOption(text: "I am the 'rock' for my loved ones", index: 2),
            EmotionalOption(text: "I always find the silver lining", index: 1),
            EmotionalOption(text: "I have a peaceful inner world", index: 4)
        ]),
        EmotionalQuestion(question: "In a difficult conflict, you usually...", options: [
            EmotionalOption(text: "Seek a compromise that hurts no one", index: 1),
            EmotionalOption(text: "Stand firm and handle the pressure", index: 2),
            EmotionalOption(text: "Know exactly what is left unsaid", index: 3),
            EmotionalOption(text: "Observe carefully before speaking", index: 4)
        ]),
        EmotionalQuestion(question: "What recharges your soul the most?", options: [
            EmotionalOption(text: "Deep conversations with others", index: 1),
            EmotionalOption(text: "Overcoming a personal challenge", index: 2),
            EmotionalOption(text: "Time alone to reflect and dream", index: 3),
            EmotionalOption(text: "Meditation or a quiet walk", index: 4)
        ]),
        EmotionalQuestion(question: "Your friends often come to you for...", options: [
            EmotionalOption(text: "Unconditional support", index: 1),
            EmotionalOption(text: "A push to be stronger", index: 2),
            EmotionalOption(text: "Advice that hits the mark", index: 3),
            EmotionalOption(text: "Peace and grounding", index: 4)
        ]),
        EmotionalQuestion(question: "What do you value most in yourself?", options: [
            EmotionalOption(text: "My kind heart", index: 1),
            EmotionalOption(text: "My inner strength", index: 2),
            EmotionalOption(text: "My sharp instincts", index: 3),
            EmotionalOption(text: "My mental clarity", index: 4)
        ]),
        EmotionalQuestion(question: "When you look at the stars, you feel...", options: [
            EmotionalOption(text: "Connected to all living beings", index: 1),
            EmotionalOption(text: "Ready to conquer the world", index: 2),
            EmotionalOption(text: "There is more than meets the eye", index: 3),
            EmotionalOption(text: "A sense of absolute peace", index: 4)
        ]),
        EmotionalQuestion(question: "Pick a color that feels 'powerful':", options: [
            EmotionalOption(text: "Soft Rose", index: 1),
            EmotionalOption(text: "Electric Orange", index: 2),
            EmotionalOption(text: "Deep Violet", index: 3),
            EmotionalOption(text: "Sky Blue", index: 4)
        ]),
        EmotionalQuestion(question: "Finally, what is your main goal in life?", options: [
            EmotionalOption(text: "To love and be loved", index: 1),
            EmotionalOption(text: "To build something lasting", index: 2),
            EmotionalOption(text: "To discover hidden truths", index: 3),
            EmotionalOption(text: "To live in total harmony", index: 4)
        ])
    ]

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 15/255, green: 10/255, blue: 35/255), Color(red: 10/255, green: 5/255, blue: 20/255)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            starBackground

            if !showResult {
                VStack(spacing: 0) {
                    quizHeader
                    
                    VStack(spacing: 25) {
                        Spacer(minLength: 10)
                        
                        Image(mascotImages[currentQuestionIndex % mascotImages.count])
                            .resizable()
                            .scaledToFit()
                            .frame(width: 220, height: 220)
                            .shadow(color: progressColor.opacity(0.5), radius: 20)
                        
                        Text(questions[currentQuestionIndex].question)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 35)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer(minLength: 10)
                    }
                    .frame(maxHeight: .infinity)

                    VStack(spacing: 12) {
                        ForEach(questions[currentQuestionIndex].options, id: \.text) { option in
                            Button(action: { handleAnswer(index: option.index) }) {
                                Text(option.text)
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.07)))
                                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.1), lineWidth: 1))
                            }
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.bottom, 40)
                }
            } else {
                resultView
            }
        }
    }

    var quizHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").font(.title2).foregroundColor(.white.opacity(0.3))
                }
                Spacer()
                Text("Emotional Power").font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(.white.opacity(0.5))
                Spacer()
                Text("\(currentQuestionIndex + 1)/10").font(.system(size: 14, weight: .bold, design: .monospaced)).foregroundColor(progressColor)
            }
            .padding(.horizontal, 25).padding(.top, 20)
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.08)).frame(height: 6)
                GeometryReader { geo in
                    let width = geo.size.width * CGFloat(currentQuestionIndex + 1) / 10.0
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(colors: [progressColor, progressColor.opacity(0.6)], startPoint: .leading, endPoint: .trailing))
                        .frame(width: width, height: 6)
                }.frame(height: 6)
            }.padding(.horizontal, 25)
        }
    }

    var resultView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle().fill(progressColor.opacity(0.2)).frame(width: 260, height: 260).blur(radius: 50)
                Image(associatedImage)
                    .resizable().scaledToFit().frame(width: 240, height: 240)
                    .shadow(color: progressColor.opacity(0.4), radius: 25)
            }
            
            VStack(spacing: 8) {
                Text("Power Unlocked!")
                    .font(.system(size: 18, weight: .bold, design: .rounded)).foregroundColor(progressColor)
                Text(finalResult.rawValue)
                    .font(.system(size: 30, weight: .black, design: .rounded)).foregroundColor(.white).multilineTextAlignment(.center)
            }
            
            Text(resultDescription)
                .font(.system(size: 17, weight: .medium, design: .rounded)).foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center).padding(.horizontal, 40)
            
            Spacer()
            
            VStack(spacing: 16) {
                // MARK: - Paylaşım Butonu Güncellemesi
                ShareLink(item: Image(associatedShareImage), message: Text("My emotional power: \(finalResult.rawValue)! What's yours? Solve this quiz on NoxuApp to find out!"), preview: SharePreview("My Power", image: Image(associatedShareImage))) {
                    Text("Share My Power")
                        .font(.system(size: 17, weight: .bold, design: .rounded)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).frame(height: 60)
                        .background(progressColor).cornerRadius(20)
                }
                Button("Done") { dismiss() }.foregroundColor(.white.opacity(0.3))
            }.padding(.horizontal, 30).padding(.bottom, 30)
        }
    }

    var progressColor: Color {
        let colors: [Color] = [.green, .blue, .purple, .pink]
        let index = Int(CGFloat(currentQuestionIndex) / 10.0 * CGFloat(colors.count - 1))
        return colors[min(index, colors.count - 1)]
    }

    var associatedImage: String {
        switch finalResult {
        case .empathy: return "p22"; case .resilience: return "p11"; case .intuition: return "p33"
        case .optimism: return "p44"; case .wisdom: return "p22"; case .serenity: return "p33"
        }
    }

    var associatedShareImage: String {
        switch finalResult {
        case .empathy: return "share1"
        case .resilience: return "share2"
        case .intuition: return "share3"
        case .serenity: return "share4"
        case .optimism: return "share5"
        case .wisdom: return "share6"
        }
    }

    func handleAnswer(index: Int) {
        counts[index, default: 0] += 1
        if currentQuestionIndex < 9 {
            withAnimation(.spring()) { currentQuestionIndex += 1 }
        } else {
            calculateResult()
        }
    }

    func calculateResult() {
        let c1 = counts[1] ?? 0; let c2 = counts[2] ?? 0
        let c3 = counts[3] ?? 0; let c4 = counts[4] ?? 0
        let maxVal = max(c1, c2, c3, c4)
        if c1 == maxVal { finalResult = .empathy }
        else if c2 == maxVal { finalResult = .resilience }
        else if c3 == maxVal { finalResult = .intuition }
        else { finalResult = .serenity }
        withAnimation { showResult = true }
    }

    var resultDescription: String {
        switch finalResult {
        case .empathy: return "You have a rare ability to feel what others feel. Your heart is a sanctuary."
        case .resilience: return "Like a diamond under pressure, you only get stronger when life gets tough."
        case .intuition: return "You see through masks and hear what is unsaid. Trust your inner voice."
        case .optimism: return "You are a light-bringer. You find hope even in the darkest times."
        case .wisdom: return "You possess a deep understanding of life's complex and beautiful patterns."
        case .serenity: return "You are the eye of the storm. Your calm energy grounds everyone."
        }
    }

    var starBackground: some View {
        ZStack {
            ForEach(0..<15) { _ in
                Circle().fill(Color.white.opacity(0.2)).frame(width: 2)
                    .position(x: .random(in: 0...400), y: .random(in: 0...800))
            }
        }
    }
}
struct EmotionalPowerQuizView_Previews: PreviewProvider {
    static var previews: some View {
        EmotionalPowerQuizView().ignoresSafeArea()
    }
}
