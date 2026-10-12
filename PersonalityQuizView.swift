import SwiftUI

struct QuizQuestion {
    let question: String
    let options: [QuizOption]
}

struct QuizOption {
    let text: String
    let trait: PersonalityTrait
}

enum PersonalityTrait: String, CaseIterable {
    case ambitious = "Ambitious"
    case introvert = "Introvert"
    case social = "Social"
    case softHearted = "Soft-Hearted"
}

struct PersonalityQuizView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentQuestionIndex = 0
    @State private var selectedScores: [PersonalityTrait: Int] = [.ambitious: 0, .introvert: 0, .social: 0, .softHearted: 0]
    @State private var showResult = false
    @State private var resultTrait: PersonalityTrait = .ambitious
    
    let pufiImages = ["pp1", "pp2", "pp3", "pp4", "pp5"]
    let questions: [QuizQuestion] = [
        QuizQuestion(question: "You find a mysterious door. What do you do?", options: [
            QuizOption(text: "Open it to conquer the unknown.", trait: .ambitious),
            QuizOption(text: "Watch it quietly from a distance.", trait: .introvert),
            QuizOption(text: "Call your friends to explore it.", trait: .social),
            QuizOption(text: "Wait for a peaceful sign.", trait: .softHearted)
        ]),
        QuizQuestion(question: "In a team, which role is yours?", options: [
            QuizOption(text: "The leader setting the goals.", trait: .ambitious),
            QuizOption(text: "The one handling deep details.", trait: .introvert),
            QuizOption(text: "The soul of the communication.", trait: .social),
            QuizOption(text: "The one who cares for everyone.", trait: .softHearted)
        ]),
        QuizQuestion(question: "How do you recharge your energy?", options: [
            QuizOption(text: "Building something grand.", trait: .ambitious),
            QuizOption(text: "Exploring my own thoughts.", trait: .introvert),
            QuizOption(text: "Creating memories with others.", trait: .social),
            QuizOption(text: "Helping others find peace.", trait: .softHearted)
        ]),
        QuizQuestion(question: "A sudden challenge appears. Move?", options: [
            QuizOption(text: "I take it head-on to win.", trait: .ambitious),
            QuizOption(text: "I analyze it deeply in silence.", trait: .introvert),
            QuizOption(text: "I talk it out with my circle.", trait: .social),
            QuizOption(text: "I find a kind way to resolve it.", trait: .softHearted)
        ]),
        QuizQuestion(question: "Which atmosphere feels like 'home'?", options: [
            QuizOption(text: "A busy office with big goals.", trait: .ambitious),
            QuizOption(text: "A quiet room with soft light.", trait: .introvert),
            QuizOption(text: "A vibrant park full of people.", trait: .social),
            QuizOption(text: "A warm kitchen with a friend.", trait: .softHearted)
        ]),
        QuizQuestion(question: "Someone is struggling. You...", options: [
            QuizOption(text: "Give a strategic solution.", trait: .ambitious),
            QuizOption(text: "Listen and give them space.", trait: .introvert),
            QuizOption(text: "Invite them to join the group.", trait: .social),
            QuizOption(text: "Stay by their side quietly.", trait: .softHearted)
        ]),
        QuizQuestion(question: "Success is best described as...", options: [
            QuizOption(text: "Reaching the absolute top.", trait: .ambitious),
            QuizOption(text: "Knowing yourself completely.", trait: .introvert),
            QuizOption(text: "Being loved by many people.", trait: .social),
            QuizOption(text: "Making the world softer.", trait: .softHearted)
        ]),
        QuizQuestion(question: "Your favorite type of talk is...", options: [
            QuizOption(text: "Debating future possibilities.", trait: .ambitious),
            QuizOption(text: "Deep, one-on-one reflections.", trait: .introvert),
            QuizOption(text: "Laughing about shared stories.", trait: .social),
            QuizOption(text: "Sharing feelings and support.", trait: .softHearted)
        ]),
        QuizQuestion(question: "When traveling, you prefer...", options: [
            QuizOption(text: "Exploring every single peak.", trait: .ambitious),
            QuizOption(text: "A solo trip to a quiet cabin.", trait: .introvert),
            QuizOption(text: "A group tour with lots of fun.", trait: .social),
            QuizOption(text: "Visiting a place that feels kind.", trait: .softHearted)
        ]),
        QuizQuestion(question: "Your inner 'motto' would be...", options: [
            QuizOption(text: "Always move forward.", trait: .ambitious),
            QuizOption(text: "Still waters run deep.", trait: .introvert),
            QuizOption(text: "Better together.", trait: .social),
            QuizOption(text: "Kindness is everything.", trait: .softHearted)
        ])
    ]

    var body: some View {
        ZStack {
            Color(red: 13/255, green: 8/255, blue: 26/255).ignoresSafeArea()
            starBackground

            if !showResult {
                VStack(spacing: 15) {
                    quizHeader
                    Spacer(minLength: 5)
                    
                    Image(pufiImages[currentQuestionIndex % pufiImages.count])
                        .resizable().scaledToFit().frame(width: 70, height: 70).opacity(0.8)
                    
                    Text(questions[currentQuestionIndex].question)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(.white).multilineTextAlignment(.center)
                        .padding(.horizontal, 30).frame(height: 50)
                    
                    Spacer(minLength: 5)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 8) {
                            ForEach(questions[currentQuestionIndex].options, id: \.text) { option in
                                Button(action: { handleAnswer(trait: option.trait) }) {
                                    Text(option.text)
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundColor(.white.opacity(0.9)).padding(.vertical, 14)
                                        .frame(maxWidth: .infinity).background(Color.white.opacity(0.06))
                                        .cornerRadius(12).overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 0.5))
                                }
                            }
                        }.padding(.horizontal, 25)
                    }.frame(maxHeight: 280)
                    Spacer()
                }
            } else {
                resultView
            }
        }
    }
    var starBackground: some View {
        ZStack {
            ForEach(0..<20) { _ in
                Circle()
                    .fill(Color.white.opacity(.random(in: 0.1...0.4)))
                    .frame(width: .random(in: 1...3))
                    .position(x: .random(in: 0...400), y: .random(in: 0...800))
            }
            Circle()
                .fill(progressColor.opacity(0.1))
                .frame(width: 300).blur(radius: 80).offset(x: -100, y: -200)
        }
    }
    var quizHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: { dismiss() }) { Image(systemName: "chevron.down").foregroundColor(.white.opacity(0.5)) }
                Spacer()
                Text("Noxu Persona").font(.system(size: 13, weight: .semibold)).foregroundColor(.gray)
                Spacer()
                Text("\(currentQuestionIndex + 1)/10").font(.system(size: 13, weight: .medium, design: .monospaced)).foregroundColor(.gray)
            }.padding([.horizontal, .top])
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4).fill(Color.white.opacity(0.05)).frame(height: 4)
                GeometryReader { geo in
                    let progress = CGFloat(currentQuestionIndex + 1) / 10.0
                    RoundedRectangle(cornerRadius: 4)
                        .fill(progressColor)
                        .frame(width: progress * geo.size.width, height: 4)
                        .shadow(color: progressColor.opacity(0.8), radius: 6)
                }.frame(height: 4)
            }.padding(.horizontal, 25)
        }
    }
    var resultView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(associatedPufi)
                .resizable().scaledToFit().frame(width: 120, height: 120)
                .shadow(color: progressColor.opacity(0.3), radius: 20)
            
            Text("You are \(resultTrait.rawValue)")
                .font(.system(size: 26, weight: .bold, design: .rounded)).foregroundColor(.white)
            
            Text(resultDescription)
                .font(.system(size: 15)).multilineTextAlignment(.center)
                .foregroundColor(.gray).padding(.horizontal, 40)
            
            Spacer()
            
            HStack(spacing: 15) {
                Button("Return to Noxu") { dismiss() }
                    .font(.system(size: 16, weight: .medium)).padding()
                    .frame(maxWidth: .infinity)
                    .background(progressColor.opacity(0.8))
                    .foregroundColor(.white).cornerRadius(15)
                
                ShareLink(
                    item: Image(associatedShareImage),
                    message: Text("You can take the same quiz on NoxuApp! Download now on AppStore"),
                    preview: SharePreview(
                        "My Noxu Persona: \(resultTrait.rawValue)",
                        image: Image(associatedShareImage)
                    )
                ) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 55, height: 55)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(15)
                        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.2), lineWidth: 1))
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
    var progressColor: Color {
        let p = Double(currentQuestionIndex) / 10.0
        return Color(hue: 0.6 + (p * 0.3), saturation: 0.6, brightness: 1.0)
    }

    var associatedShareImage: String {
        switch resultTrait {
        case .ambitious: return "pufi_study"
        case .introvert: return "pufi_bed"
        case .social: return "purple_custom"
        case .softHearted: return "p2"
        }
    }

    var associatedPufi: String {
        switch resultTrait {
        case .ambitious: return "pufi_study"
        case .introvert: return "pufi_bed"
        case .social: return "purple_custom"
        case .softHearted: return "p2"
        }
    }

    func handleAnswer(trait: PersonalityTrait) {
        selectedScores[trait, default: 0] += 1
        if currentQuestionIndex < questions.count - 1 {
            withAnimation(.spring()) { currentQuestionIndex += 1 }
        } else {
            calculateResult()
        }
    }

    func calculateResult() {
        if let winner = selectedScores.max(by: { $0.value < $1.value }) { resultTrait = winner.key }
        withAnimation { showResult = true }
    }

    var resultDescription: String {
        switch resultTrait {
        case .ambitious: return "A natural leader with a grand vision. You don't just dream; you execute with purpose."
        case .introvert: return "A deep observer who finds power in silence and clarity in your own thoughts."
        case .social: return "A vibrant energy that heals and connects. You are the heartbeat of your circle."
        case .softHearted: return "A gentle soul who prioritizes empathy and makes the world a warmer place."
        }
    }
}
