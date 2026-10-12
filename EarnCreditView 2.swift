import SwiftUI

struct EarnCreditView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("userCredits") var userCredits = 0
    @State private var showWalletDetails = false
    @State private var showAdRewards = false
    var body: some View {
        ZStack {
            Color(red: 13/255, green: 8/255, blue: 26/255).ignoresSafeArea()
            starsBackground
            
            VStack(spacing: 25) {
                headerSection
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        NavigationLink(destination: DailyRewardView()) {
                            creditActionCardDesign(
                                title: "Daily Rewards",
                                subtitle: "Your Daily Rewards :)",
                                icon: "calendar.badge.clock",
                                accentColor: Color(hex: "##5787d4"),
                                badge: "COLLECT"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        NavigationLink(destination: SpecialView()) {
                            creditActionCardDesign(
                                title: "What's For Me?",
                                subtitle: "See if your custom Pufi sent you gifts!",
                                icon: "questionmark.circle",
                                accentColor: Color(hex: "#aa57d4"),
                                badge: "NEW"
                            )
                        }
                        
                   
                            
                        
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            .blur(radius: showWalletDetails ? 10 : 0)
            .animation(.spring(), value: showWalletDetails)
            if showWalletDetails {
                Color.black.opacity(0.6).ignoresSafeArea()
                    .onTapGesture { showWalletDetails = false }
                
                centerPopupView
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    var centerPopupView: some View {
        VStack(spacing: 20) {
            Text("Your Balance")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
            VStack(spacing: 12) {
                Image("100")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .shadow(color: .purple.opacity(0.5), radius: 15)
                
                Text("\(userCredits)")
                    .font(.system(size: 42, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                
                Text("PUFI CREDITS")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.blue.opacity(0.8))
                    .tracking(2)
            }
            .padding(.vertical, 10)
            Button(action: { showWalletDetails = false }) {
                Text("Got it!")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(15)
                    .shadow(color: .purple.opacity(0.4), radius: 10)
            }
        }
        .padding(30)
        .frame(width: 300)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color(red: 25/255, green: 20/255, blue: 45/255))
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(LinearGradient(colors: [.purple.opacity(0.5), .blue.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                )
        )
    }
    var headerSection: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.title2.bold())
                    .foregroundColor(.white.opacity(0.6))
            }
            Spacer()
            Button(action: { withAnimation { showWalletDetails = true } }) {
                HStack(spacing: 8) {
                    Image("100").resizable().frame(width: 22, height: 22)
                    Text("\(userCredits)").font(.system(size: 16, weight: .bold, design: .monospaced)).foregroundColor(.white)
                }
                .padding(.vertical, 8).padding(.horizontal, 14)
                .background(Capsule().fill(Color.white.opacity(0.08)))
                .overlay(Capsule().stroke(Color.purple.opacity(0.4), lineWidth: 1))
            }
        }
        .padding(.horizontal, 20).padding(.top, 10)
    }

    // MARK: - Kart Tasarımı
    func creditActionCardDesign(title: String, subtitle: String, icon: String, accentColor: Color, badge: String) -> some View {
        HStack(spacing: 15) {
            ZStack {
                RoundedRectangle(cornerRadius: 15).fill(accentColor.opacity(0.1)).frame(width: 55, height: 55)
                Image(systemName: icon).font(.title2).foregroundColor(accentColor)
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title).font(.system(size: 17, weight: .bold, design: .rounded)).foregroundColor(.white)
                    Spacer()
                    Text(badge).font(.system(size: 10, weight: .black)).padding(.vertical, 4).padding(.horizontal, 8).background(accentColor.opacity(0.6)).cornerRadius(8).foregroundColor(.white)
                }
                Text(subtitle).font(.system(size: 13)).foregroundColor(.gray)
            }
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 22).fill(Color.white.opacity(0.03)))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }

    var starsBackground: some View {
        ZStack {
            ForEach(0..<20) { _ in
                Circle().fill(Color.white.opacity(.random(in: 0.1...0.3)))
                    .frame(width: 2, height: 2)
                    .position(x: .random(in: 0...400), y: .random(in: 0...800))
            }
        }
    }
}
// Preview için
struct EarnCreditView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EarnCreditView()
        }
    }
}
