import SwiftUI

struct BoredSwiftView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("userCredits") private var userCredits = 100
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 13/255, green: 8/255, blue: 26/255).ignoresSafeArea()
                starsBackground
                
                VStack(spacing: 0) {
                    headerArea
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            VStack(spacing: 8) {
                                Text("Bored?")
                                    .font(.system(size: 32, weight: .bold, design: .serif))
                                    .foregroundColor(.white)
                                Text("Select an activity for yourself :)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Image("p22")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 90)
                                    .padding(.vertical, 15)
                            }
                            .padding(.top, 30)
                            
                            Spacer(minLength: 40)
                            VStack(spacing: 16) {
                                NavigationLink(destination: QuizSelectionView()) {
                                    boredButtonContent(
                                        title: "Self-Awareness Quizzes",
                                        subtitle: "Mini-tests for you :)",
                                        icon: "brain.head.profile",
                                        color: Color(red: 135/255, green: 147/255, blue: 245/255)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                NavigationLink(destination: EarnCreditView()) {
                                    boredButtonContent(
                                        title: "Earn Credits",
                                        subtitle: "Did u take your daily credits..?",
                                        icon: "gift",
                                        color: .purple
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.horizontal, 25)
                            
                            Spacer()
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }

    var headerArea: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.title2.bold())
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()

            HStack(spacing: 5) {
                Text("\(userCredits)").fontWeight(.bold)
                Image("100").resizable().scaledToFit().frame(width: 20, height: 20)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(Capsule().fill(Color.white.opacity(0.1)))
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }

    func boredButtonContent(title: String, subtitle: String, icon: String, color: Color) -> some View {
        HStack(spacing: 20) {
            Group {
                if icon == "100" {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                } else {
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                }
            }
            .font(.system(size: 30))
            .foregroundColor(color)
            .frame(width: 50, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    var starsBackground: some View {
        ZStack {
            ForEach(0..<25) { _ in
                Circle().fill(Color.white.opacity(.random(in: 0.2...0.5)))
                    .frame(width: .random(in: 1...3))
                    .position(x: .random(in: 0...400), y: .random(in: 0...800))
            }
        }
    }
}

struct BoredSwiftView_Previews: PreviewProvider {
    static var previews: some View {
        BoredSwiftView()
    }
}
