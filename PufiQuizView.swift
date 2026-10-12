import SwiftUI
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
struct PufiQuestion {
    let question: String
    let options: [PufiOption]
}

struct PufiOption {
    let text: String
    let index: Int
}

enum PufiResult: String {
    case green = "Green Pufi"
    case orange = "Orange Pufi"
    case pink = "Pink Pufi"
    case purple = "Purple Pufi"
    case blue = "Blue Pufi"
    case night = "Night Pufi"
}

struct PufiQuizView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentQuestionIndex = 0
    @State private var counts: [Int: Int] = [1: 0, 2: 0, 3: 0, 4: 0]
    @State private var showResult = false
    @State private var finalResult: PufiResult = .green
    
    let pufiImages = ["p1", "p2", "p3", "p4", "p5"]
    let questions: [PufiQuestion] = [
        PufiQuestion(question: "You prefer which place?", options: [
            PufiOption(text: "Forest", index: 1), PufiOption(text: "Seaside", index: 2),
            PufiOption(text: "Shopping Mall", index: 3), PufiOption(text: "Anywhere I can sleep", index: 4)
        ]),
        PufiQuestion(question: "Choose one music genre?", options: [
            PufiOption(text: "Classic", index: 1), PufiOption(text: "Hip-Hop", index: 2),
            PufiOption(text: "Pop", index: 3), PufiOption(text: "Metal", index: 4)
        ]),
        PufiQuestion(question: "Which animal defines your 'spirit animal'?", options: [
            PufiOption(text: "Fox", index: 1), PufiOption(text: "Dog", index: 2),
            PufiOption(text: "Cat", index: 3), PufiOption(text: "Bird", index: 4)
        ]),
        PufiQuestion(question: "What is your favorite snack?", options: [
            PufiOption(text: "Fruits", index: 1), PufiOption(text: "Pizza", index: 2),
            PufiOption(text: "Candy", index: 3), PufiOption(text: "Nothing", index: 4)
        ]),
        PufiQuestion(question: "Pick a superpower!", options: [
            PufiOption(text: "Nature control", index: 1), PufiOption(text: "Super speed", index: 2),
            PufiOption(text: "Invisibility", index: 3), PufiOption(text: "Time travel", index: 4)
        ]),
        PufiQuestion(question: "Best way to spend a Sunday?", options: [
            PufiOption(text: "Hiking", index: 1), PufiOption(text: "Partying", index: 2),
            PufiOption(text: "Shopping", index: 3), PufiOption(text: "Sleeping", index: 4)
        ]),
        PufiQuestion(question: "Your favorite weather?", options: [
            PufiOption(text: "Sunny", index: 1), PufiOption(text: "Stormy", index: 2),
            PufiOption(text: "Cloudy", index: 3), PufiOption(text: "Dark Night", index: 4)
        ]),
        PufiQuestion(question: "Pick a hobby!", options: [
            PufiOption(text: "Gardening", index: 1), PufiOption(text: "Gaming", index: 2),
            PufiOption(text: "Fashion", index: 3), PufiOption(text: "Stargazing", index: 4)
        ]),
        PufiQuestion(question: "Which color do you like most?", options: [
            PufiOption(text: "Green", index: 1), PufiOption(text: "Orange", index: 2),
            PufiOption(text: "Pink", index: 3), PufiOption(text: "Purple", index: 4)
        ]),
        PufiQuestion(question: "How do you feel today?", options: [
            PufiOption(text: "Calm", index: 1), PufiOption(text: "Energetic", index: 2),
            PufiOption(text: "Happy", index: 3), PufiOption(text: "Mysterious", index: 4)
        ])
    ]

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 15/255, green: 10/255, blue: 35/255), Color(red: 10/255, green: 5/255, blue: 20/255)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            starBackground

            if !showResult {
                VStack(spacing: 20) {
                    quizHeader
                    
                    Spacer()
                    Image(pufiImages[currentQuestionIndex % pufiImages.count])
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .shadow(color: progressColor.opacity(0.6), radius: 20)
                    
                    if let currentQuestion = questions[safe: currentQuestionIndex] {
                        Text(currentQuestion.question)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .frame(height: 80)

                        Spacer()
                        VStack(spacing: 12) {
                            ForEach(currentQuestion.options, id: \.text) { option in
                                Button(action: { handleAnswer(index: option.index) }) {
                                    Text(option.text)
                                        .font(.system(size: 17, weight: .medium, design: .rounded))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.08)))
                                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(LinearGradient(colors: [.white.opacity(0.2), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
                                }
                            }
                        }
                        .padding(.horizontal, 25)
                        .padding(.bottom, 40)
                    }
                }
            } else {
                resultView
            }
        }
    }
    var quizHeader: some View {
        VStack(spacing: 15) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.3))
                }
                Spacer()
                Text("Pufi Discovery")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                Spacer()
                Text("\(currentQuestionIndex + 1)/10")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(progressColor)
            }
            .padding(.horizontal, 25)
            .padding(.top, 20)
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 8)
                
                GeometryReader { geo in
                    let width = geo.size.width * CGFloat(currentQuestionIndex + 1) / 10.0
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(colors: [progressColor, progressColor.opacity(0.7)], startPoint: .leading, endPoint: .trailing))
                        .frame(width: width, height: 8)
                        .shadow(color: progressColor.opacity(0.5), radius: 8)
                }
                .frame(height: 8)
            }
            .padding(.horizontal, 25)
        }
    }
    var resultView: some View {
        VStack(spacing: 25) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(progressColor.opacity(0.15))
                    .frame(width: 220, height: 220)
                    .blur(radius: 50)
                
                Image(associatedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .shadow(color: progressColor.opacity(0.5), radius: 30)
            }
            
            VStack(spacing: 8) {
                Text("Perfect Match!")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(progressColor)
                
                Text("You are the \(finalResult.rawValue)!")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            
            Text(resultDescription)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 45)
            
            Spacer()
            
            VStack(spacing: 16) {
                ShareLink(
                    item: Image(associatedImage),
                    message: Text("My pufi version is \(finalResult.rawValue) on NoxuApp! Which one is yours? Take the quiz on NoxuApp!"),
                    preview: SharePreview("My Pufi Persona", image: Image(associatedImage))
                ) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Share My Result")
                    }
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(LinearGradient(colors: [progressColor, progressColor.opacity(0.8)], startPoint: .top, endPoint: .bottom))
                    .cornerRadius(20)
                }
                
                Button("Done") { dismiss() }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(.horizontal, 35)
            .padding(.bottom, 30)
        }
    }

    // MARK: - HELPERS
    var progressColor: Color {
        let colors: [Color] = [
            Color(red: 0.4, green: 0.9, blue: 0.7), 
            Color(red: 0.5, green: 0.7, blue: 1.0),
            Color(red: 0.8, green: 0.6, blue: 1.0),
            Color(red: 1.0, green: 0.5, blue: 0.8)
        ]
        let idx = min(Int(Double(currentQuestionIndex) / 10.0 * Double(colors.count)), colors.count - 1)
        return colors[idx]
    }

    var associatedImage: String {
        switch finalResult {
        case .green: return "p5"; case .orange: return "p4"; case .pink: return "p2"
        case .purple: return "p6"; case .blue: return "p1"; case .night: return "p3"
        }
    }

    func handleAnswer(index: Int) {
        counts[index, default: 0] += 1
        if currentQuestionIndex < questions.count - 1 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { currentQuestionIndex += 1 }
        } else {
            calculatePufiResult()
        }
    }

    func calculatePufiResult() {
        let c1 = counts[1] ?? 0; let c2 = counts[2] ?? 0
        let c3 = counts[3] ?? 0; let c4 = counts[4] ?? 0
        
        if c1 == c3 && c1 >= c2 && c1 >= c4 { finalResult = .blue }
        else if c2 == c4 && c2 >= c1 && c2 >= c3 { finalResult = .night }
        else {
            let maxVal = max(c1, c2, c3, c4)
            if c1 == maxVal { finalResult = .green }
            else if c2 == maxVal { finalResult = .orange }
            else if c3 == maxVal { finalResult = .pink }
            else { finalResult = .purple }
        }
        withAnimation(.easeInOut) { showResult = true }
    }

    var resultDescription: String {
        switch finalResult {
        case .green: return "A nature lover who enjoys the tranquility of the forest and the wisdom of trees."
        case .orange: return "Energetic, bold, and always ready for a new adventure. You are the spark!"
        case .pink: return "Sweet, social, and full of love. You make everyone's day a little brighter."
        case .purple: return "Dreamy and creative. You find comfort in your own magical world."
        case .blue: return "A perfect balance of peace and sweetness. You are as calm as a clear sky."
        case .night: return "Mysterious and powerful. You thrive when the stars come out to play."
        }
    }

    var starBackground: some View {
        ZStack {
            ForEach(0..<25) { _ in
                Circle()
                    .fill(Color.white.opacity(.random(in: 0.1...0.4)))
                    .frame(width: .random(in: 1...3))
                    .position(x: .random(in: 0...500), y: .random(in: 0...1000))
            }
        }
    }
}

