import SwiftUI

struct SetView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage = "en"
    @Environment(\.dismiss) var dismiss
    @AppStorage("userCredits") private var userCredits = 100
    @AppStorage("moodHistoryData") private var moodHistoryData: Data = Data()
    @AppStorage("ownedCardAsset") private var ownedCardAsset: String = ""
    @AppStorage("cardBalance") private var cardBalance: Int = 0
    @AppStorage("useCardForGames") private var useCardForGames: Bool = false
    @State private var showDeleteAlert = false
    
    var body: some View {
        ZStack {
            Color(hex: "#061836").ignoresSafeArea()
            StaticBackgroundStarsView()
            
            VStack(spacing: 25) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2.bold())
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Text("Settings")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Customization")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.leading, 5)
                            
                            SettingsButton(title: "Set app icon to default", icon: "app.badge", color: "#8793f5") {
                                changeAppIcon(to: nil)
                            }
                        }
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Puficonomy")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.leading, 5)
                            
                            NavigationLink(destination: PufiCardSystemView()) {
                                HStack(spacing: 15) {
                                    ZStack {
                                        Circle().fill(Color(hex: "#9dcee3").opacity(0.2))
                                        Image(systemName: "creditcard")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color(hex: "#9dcee3"))
                                    }
                                    .frame(width: 36, height: 36)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Pufi Card System")
                                            .foregroundColor(.white)
                                            .font(.system(size: 16, weight: .medium))
                                        
                                        if !ownedCardAsset.isEmpty {
                                            Text("Active Card: \(ownedCardAsset.uppercased())")
                                                .font(.system(size: 11))
                                                .foregroundColor(.white.opacity(0.4))
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    if ownedCardAsset.isEmpty {
                                        Text("GET CARD")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.black)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Capsule().fill(Color(hex: "#9dcee3")))
                                    } else {
                                        HStack(spacing: 4) {
                                            Text("\(cardBalance)").bold().foregroundColor(.white)
                                            Image("100").resizable().frame(width: 14, height: 14)
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Capsule().fill(Color.white.opacity(0.1)))
                                    }
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white.opacity(0.3))
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Statistics")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.leading, 5)
                            
                            HStack {
                                Image(systemName: "star").foregroundColor(Color(hex: "#FFEFBA"))
                                Text("Main Wallet Credits").foregroundColor(.white.opacity(0.8))
                                Spacer()
                                Text("\(userCredits)").fontWeight(.bold).foregroundColor(.white)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
                        }
                        
                        Spacer().frame(height: 30)
                        Button(action: { showDeleteAlert = true }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete my account")
                                Spacer()
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.red)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color.red.opacity(0.1)))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.red.opacity(0.3), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("Are you sure?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) { deleteAccountData() }
        } message: {
            Text("If you continue, all your saved in-game data, credits, and Pufi Cards will be deleted PERMANENTLY.")
        }
    }
    func changeAppIcon(to iconName: String?) {
        if UIApplication.shared.supportsAlternateIcons {
            UIApplication.shared.setAlternateIconName(iconName) { error in
                if let error = error {
                    print("Hata: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func deleteAccountData() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
        }
        userCredits = 100
        cardBalance = 0
        ownedCardAsset = ""
        useCardForGames = false
        moodHistoryData = Data()
        selectedLanguage = "en"
        dismiss()
    }
}
struct SettingsButton: View {
    let title: String
    let icon: String
    let color: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        }) {
            HStack(spacing: 15) {
                ZStack {
                    Circle().fill(Color(hex: color).opacity(0.2)).frame(width: 36, height: 36)
                    Image(systemName: icon).font(.system(size: 14)).foregroundColor(Color(hex: color))
                }
                Text(title).foregroundColor(.white).font(.system(size: 16, weight: .medium))
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 12, weight: .bold)).foregroundColor(.white.opacity(0.3))
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
        }
    }
}

struct SetView_Previews: PreviewProvider {
    static var previews: some View {
        let _ = UserDefaults.standard.set(100, forKey: "userCredits")
        SetView()
            .preferredColorScheme(.dark)
    }
}
