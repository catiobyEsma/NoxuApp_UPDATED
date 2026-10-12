import SwiftUI

struct SpecialView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("hasCustomPufi") var hasCustomPufi: Bool = false
    @AppStorage("selectedAsset") var savedAsset: String = ""
    @AppStorage("pufiName") var savedName: String = ""
    @AppStorage("userCredits") private var userCredits = 100
    @AppStorage("lastClaimDateSpecial") var lastClaimDate: String = ""
    
    @State private var showPopup = false
    @State private var earnedAmount = 0
    @State private var popupMessage = ""
    
    var body: some View {
        ZStack {
            Color(hex: "#061836").ignoresSafeArea()
            StarFieldView1(starCount: 80)
            
            VStack(spacing: 30) {
                headerView
                
                Spacer()
                
                if hasCustomPufi {
                    VStack(spacing: 20) {
                        Image(savedAsset)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 180, height: 180)
                            .shadow(color: Color(hex: "#8793f5").opacity(0.3), radius: 20)
                        
                        Text("Your best friend \(savedName) is here!")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Button(action: { checkPufiGift() }) {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("From \(savedName)")
                                    .fontWeight(.bold)
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 240, height: 60)
                            .background(
                                LinearGradient(colors: [Color(hex: "#4232a8"), Color(hex: "#8793f5")], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(20)
                            .shadow(color: Color(hex: "#4232a8").opacity(0.5), radius: 10)
                        }
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "paws.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white.opacity(0.1))
                        
                        Text("You must have a custom Pufi to use this feature!")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        NavigationLink(destination: PufiCreatorView()) {
                                HStack {
                                    Text("Create My Pufi")
                                        .fontWeight(.bold)
                                    Image(systemName: "plus.circle.fill")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 220, height: 55)
                                .background(
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(Color(hex: "#4232a8"))
                                        
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    }
                                )
                                .shadow(color: Color(hex: "#4232a8").opacity(0.4), radius: 15, x: 0, y: 8)
                            }
                            .padding(.top, 10)
                        
                    }
                }
                
                Spacer()
            }
            .blur(radius: showPopup ? 10 : 0)
            if showPopup {
                Color.black.opacity(0.6).ignoresSafeArea()
                rewardPopup
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    func checkPufiGift() {
        let today = ISO8601DateFormatter().string(from: Date()).prefix(10)
        if String(today) == lastClaimDate {
            earnedAmount = 0
            popupMessage = "\(savedName) is resting right now. Come back tomorrow!"
            showPopup = true
            return
        }
        let chance = Int.random(in: 1...100)
        if chance <= 60 {
            let multiplier = Int.random(in: 1...5)
            earnedAmount = multiplier * 10
            userCredits += earnedAmount
            lastClaimDate = String(today)
            popupMessage = "\(savedName) left you a secret gift!"
        } else {
            earnedAmount = 0
            lastClaimDate = String(today)
            popupMessage = "\(savedName) just wanted to say hi today. No credits this time!"
        }
        
        withAnimation { showPopup = true }
    }
    var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.title2.bold())
                    .foregroundColor(.white.opacity(0.6))
            }
            Spacer()
            Text("What's For Me?")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
            Spacer()
            Circle().fill(Color.clear).frame(width: 44)
        }
        .padding(.horizontal)
    }
    
    var rewardPopup: some View {
        VStack(spacing: 25) {
            Image("100")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            
            if earnedAmount > 0 {
                Text("+\(earnedAmount)")
                    .font(.system(size: 45, weight: .black, design: .monospaced))
                    .foregroundColor(Color(hex: "#00D1FF"))
            }
            
            Text(popupMessage)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("OK, Thanks \(savedName)!") {
                withAnimation { showPopup = false }
            }
            .font(.headline)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(hex:"#5861a3"))
            .cornerRadius(15)
        }
        .padding(30)
        .background(Color(hex: "#061836"))
        .cornerRadius(30)
        .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.white.opacity(0.1), lineWidth: 1))
        .padding(40)
    }
}
