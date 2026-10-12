import SwiftUI

struct QuizSelectionView: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("userCredits") private var userCredits = 100
    @AppStorage("personalityQuizPlayed") var personalityQuizPlayed: Bool = false
    @AppStorage("pufiQuizPlayed") var pufiQuizPlayed: Bool = false
    @AppStorage("emotionQuizPlayed") var emotionQuizPlayed: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 13/255, green: 8/255, blue: 26/255).ignoresSafeArea()
                starsBackground
                
                VStack(spacing: 0) {
                    headerBar

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            Text("Explore your inner world.")
                                .font(.title3)
                                .foregroundColor(.gray)
                                .padding(.top, 20)

                            QuizCardComponent(
                                title: "Personality Quiz",
                                subtitle: "Deep dive into your character's mysteries.",
                                icon: "person",
                                color: Color(red: 135/255, green: 147/255, blue: 245/255),
                                destination: AnyView(PersonalityQuizView()), // Kendi View'ını buraya koy
                                isPlayed: $personalityQuizPlayed
                            )

                            QuizCardComponent(
                                title: "Which Pufi Are You?",
                                subtitle: "Find your Noxu mascot match.",
                                icon: "face.dashed",
                                color: Color(red: 255/255, green: 150/255, blue: 200/255),
                                destination: AnyView(PufiQuizView()),
                                isPlayed: $pufiQuizPlayed
                            )

                            QuizCardComponent(
                                title: "Emotion Superpower",
                                subtitle: "What is your hidden emotional strength?",
                                icon: "bolt.heart",
                                color: Color(red: 255/255, green: 200/255, blue: 100/255),
                                destination: AnyView(EmotionalPowerQuizView()),
                                isPlayed: $emotionQuizPlayed
                            )
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    var headerBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                }
                .font(.headline).foregroundColor(.white.opacity(0.7))
            }
            Spacer()
            Text("Quizzes")
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundColor(.white)
            Spacer()
            HStack(spacing: 10) {
                Text("\(userCredits)").fontWeight(.bold)
                Image("100").resizable().scaledToFit().frame(width: 18, height: 18)
            }
            .foregroundColor(.white).padding(.horizontal, 12).padding(.vertical, 6)
            .background(Capsule().fill(Color.white.opacity(0.1)))
        }
        .padding()
    }

    var starsBackground: some View {
        ZStack {
            ForEach(0..<25) { _ in
                Circle()
                    .fill(Color.white.opacity(.random(in: 0.1...0.4)))
                    .frame(width: 2, height: 2)
                    .position(x: .random(in: 0...400), y: .random(in: 0...800))
            }
        }
    }
}
struct QuizCardComponent: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let destination: AnyView
    @Binding var isPlayed: Bool

    @AppStorage("userCredits") private var userCredits = 100
    @AppStorage("cardBalance") private var cardBalance = 0
    @AppStorage("useCardForGames") private var useCardForGames = false
    
    @State private var showPopup = false
    @State private var isSheetPresented = false

    var baseCost: Int { isPlayed ? 10 : 5 }
    var finalCost: Int {
        useCardForGames ? Int(Double(baseCost) * 0.8) : baseCost
    }
    var activeBalance: Int {
        useCardForGames ? cardBalance : userCredits
    }

    var body: some View {
        ZStack {
            Button(action: { withAnimation { showPopup = true } }) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: icon).font(.title).foregroundColor(color)
                        Spacer()
                        HStack(spacing: 4) {
                            if useCardForGames {
                                Text("\(baseCost)").strikethrough().font(.caption2).foregroundColor(.white.opacity(0.3))
                            }
                            Text("\(finalCost)")
                            Image("100").resizable().frame(width: 14, height: 14)
                        }
                        .font(.caption.bold())
                        .foregroundColor(useCardForGames ? Color(hex: "#ABDEE6") : .white.opacity(0.7))
                        .padding(8).background(Color.white.opacity(0.1)).cornerRadius(8)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title).font(.headline).foregroundColor(.white)
                        Text(subtitle).font(.caption).foregroundColor(.gray).multilineTextAlignment(.leading)
                    }
                }
                .padding(20).background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.05)))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(useCardForGames ? Color(hex: "#ABDEE6").opacity(0.5) : color.opacity(0.3), lineWidth: 1))
            }
            .buttonStyle(PlainButtonStyle())
            .sheet(isPresented: $isSheetPresented) { destination }

            if showPopup {
                popupView
            }
        }
    }

    private var popupView: some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()
                .onTapGesture { withAnimation { showPopup = false } }
            
            VStack(spacing: 25) {
                Image(systemName: useCardForGames ? "creditcard.fill" : icon)
                    .font(.system(size: 50)).foregroundColor(useCardForGames ? Color(hex: "#ABDEE6") : color)
                
                VStack(spacing: 10) {
                    Text(activeBalance >= finalCost ? "Start Quiz" : "Low Credits")
                        .font(.title3.bold()).foregroundColor(.white)
                    
                    if useCardForGames {
                        Text("CARD DISCOUNT ACTIVE (-%20)")
                            .font(.caption2.bold()).padding(4).background(Color(hex: "#ABDEE6")).foregroundColor(.black).cornerRadius(4)
                    }
                    
                    Text("Price: \(finalCost) credits. (Balance: \(activeBalance))")
                        .font(.subheadline).foregroundColor(.white.opacity(0.6))
                }
                
                HStack(spacing: 15) {
                    Button("Cancel") { withAnimation { showPopup = false } }
                        .foregroundColor(.gray)
                    
                    if activeBalance >= finalCost {
                        Button("Confirm") {
                            if useCardForGames { cardBalance -= finalCost } else { userCredits -= finalCost }
                            isPlayed = true
                            withAnimation { showPopup = false; isSheetPresented = true }
                        }
                        .padding().frame(maxWidth: .infinity).background(useCardForGames ? Color(hex: "#ABDEE6") : color).foregroundColor(.black).cornerRadius(12)
                    }
                }
            }
            .padding(30).background(Color(red: 25/255, green: 20/255, blue: 45/255)).cornerRadius(25).padding(30)
        }
    }
}

