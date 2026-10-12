import SwiftUI

struct PufiCardSystemView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("userCredits") private var userCredits = 100
    @State private var showUnlockAlert = false
    @AppStorage("ownedCardAsset") private var ownedCardAsset: String = ""
    @AppStorage("cardBalance") private var cardBalance: Int = 0
    @AppStorage("useCardForGames") private var useCardForGames: Bool = false
    
    @State private var selectedCard: String = "c1"
    @State private var showTransferSheet = false
    @State private var isWithdrawing = false
    @State private var transferAmount: String = ""
    @State private var showDeleteAlert = false
    let pastelPurple = Color(hex: "#CBAACB")
    let pastelBlue = Color(hex: "#ABDEE6")
    let pastelPink = Color(hex: "#FFCCF9")
    let pastelYellow = Color(hex: "#FFFFB5")
    let pastelRed = Color(hex: "#FFB7B2")

    let allCards = ["c1", "c2", "c3", "c4", "c5", "c6"]

    var body: some View {
        ZStack {
            Color(red: 13/255, green: 8/255, blue: 26/255).ignoresSafeArea()
            StaticBackgroundStarsView()
            
            VStack(spacing: 25) {
                header
                
                if ownedCardAsset.isEmpty {
                    shopView
                } else {
                    VStack(spacing: 20) {
                        cardManagementView
                        VStack(spacing: 12) {
                            Button(action: {
                                isWithdrawing = true
                                showTransferSheet = true
                            }) {
                                Label("Withdraw to Wallet", systemImage: "arrow.down.left")
                                    .font(.subheadline.bold())
                                    .foregroundColor(pastelPurple)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(pastelPurple.opacity(0.1))
                                    .cornerRadius(18)
                            }
                            
                            Button(action: { showDeleteAlert = true }) {
                                HStack {
                                    Image(systemName: "trash.fill")
                                    Text("Terminate Card")
                                }
                                .font(.caption.bold())
                                .foregroundColor(pastelRed.opacity(0.8))
                                .padding(.vertical, 8)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                Spacer()
            }
            .padding(.top, 10)
        }
        .sheet(isPresented: $showTransferSheet) { transferSheetView }
        .alert("Terminate Card?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Terminate", role: .destructive) { terminateCard() }
        } message: {
            Text("You are about to delete your card. Your remaining card balance will be moved to your main wallet.")
        }
        .navigationBarHidden(true)
    }
    private var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.title2.bold())
                    .foregroundColor(.white.opacity(0.6))
            }
            Spacer()
            VStack(spacing: 4) {
                Text("PUFI BANK").font(.system(.headline, design: .serif)).foregroundColor(.white)
                Text("Premium Card Services").font(.caption2).foregroundColor(pastelPurple.opacity(0.8))
            }
            Spacer()
            HStack(spacing: 8) {
                Text("\(userCredits)").bold()
                Image("100").resizable().frame(width: 18, height: 18)
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(Capsule().fill(pastelBlue.opacity(0.15)))
            .overlay(Capsule().stroke(pastelBlue.opacity(0.3), lineWidth: 1))
            .foregroundColor(pastelBlue)
        }
        .padding(.horizontal)
    }

    private var shopView: some View {
        VStack(spacing: 25) {
            VStack(spacing: 8) {
                Text("Select Your Identity").font(.system(size: 26, weight: .light, design: .serif)).foregroundColor(.white)
                Text("Unlock exclusive benefits").font(.footnote).foregroundColor(.white.opacity(0.5))
                Text("These are only for in-game purposes!").font(.footnote).foregroundColor(.white.opacity(0.5))
            }
            
            TabView(selection: $selectedCard) {
                ForEach(allCards, id: \.self) { card in
                    Image(card)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 280)
                        .cornerRadius(25)
                        .shadow(color: pastelPurple.opacity(0.4), radius: 20)
                        .tag(card)
                }
            }
            .frame(height: 220)
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            customIndicator.padding(.top, 10)
            Button(action: {
                showUnlockAlert = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                    Text("Unlock for 500 Credits").bold()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(LinearGradient(colors: [pastelBlue, pastelPurple],
                                           startPoint: .leading,
                                           endPoint: .trailing))
                .foregroundColor(.black)
                .cornerRadius(20)
            }
            .alert("Are you sure?", isPresented: $showUnlockAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Confirm") { buyCard() }
            } message: {
                Text("You are about to unlock this card.")
            }
            .padding(.horizontal, 40)
        }
    }

    private var cardManagementView: some View {
        VStack(spacing: 30) {
            Image(ownedCardAsset)
                .resizable()
                .scaledToFit()
                .frame(width: 320)
                .cornerRadius(25)
                .shadow(color: pastelBlue.opacity(0.3), radius: 30)
                .overlay(
                    VStack {
                        HStack { Spacer(); Image(systemName: "checkmark.seal.fill").foregroundColor(pastelYellow).font(.title) }
                        Spacer()
                        HStack {
                            VStack(alignment: .leading) {
                                Text("CARD BALANCE").font(.caption2.bold()).foregroundColor(.white.opacity(0.6))
                                Text("\(cardBalance) Credits").font(.title2.bold()).foregroundColor(.white)
                            }
                            Spacer()
                            Image("100").resizable().frame(width: 30, height: 30)
                        }
                        .padding(20).background(.ultraThinMaterial).cornerRadius(20, corners: [.bottomLeft, .bottomRight])
                    }
                )
            
            VStack(spacing: 1) {
                settingsToggle(title: "Use card for games", isOn: $useCardForGames, icon: "gamecontroller", color: pastelPink)
                Divider().background(Color.white.opacity(0.1)).padding(.horizontal)
                Button(action: {
                    isWithdrawing = false
                    showTransferSheet = true
                }) {
                    HStack {
                        ZStack { Circle().fill(pastelBlue.opacity(0.2)).frame(width: 35, height: 35); Image(systemName: "plus").foregroundColor(pastelBlue) }
                        Text("Load Credits").bold().foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.right").font(.caption).foregroundColor(.white.opacity(0.3))
                    }
                    .padding()
                }
            }
            .background(RoundedRectangle(cornerRadius: 24).fill(Color.white.opacity(0.05))).padding(.horizontal)
        }
    }

    private var customIndicator: some View {
        HStack(spacing: 8) {
            ForEach(allCards, id: \.self) { card in
                Capsule()
                    .fill(selectedCard == card ? pastelBlue : Color.white.opacity(0.2))
                    .frame(width: selectedCard == card ? 20 : 8, height: 8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedCard)
            }
        }
    }

    private var transferSheetView: some View {
        ZStack {
            Color(red: 20/255, green: 15/255, blue: 40/255).ignoresSafeArea()
            VStack(spacing: 25) {
                Capsule().fill(Color.white.opacity(0.2)).frame(width: 40, height: 4).padding(.top, 10)
                Text(isWithdrawing ? "Withdraw to Wallet" : "Transfer to Card")
                    .font(.title3.bold()).foregroundColor(isWithdrawing ? pastelPurple : pastelBlue)
                
                VStack(spacing: 5) {
                    TextField("0", text: $transferAmount)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center).keyboardType(.numberPad).foregroundColor(.white)
                    Text(isWithdrawing ? "Available in Card: \(cardBalance)" : "Available in Wallet: \(userCredits)")
                        .font(.caption2).foregroundColor(.white.opacity(0.4))
                }
                .padding().background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.05)))
                
                Button("Confirm Action") {
                    executeTransfer()
                }
                .font(.headline).frame(maxWidth: .infinity).padding()
                .background(isWithdrawing ? pastelPurple : pastelBlue).foregroundColor(.black).cornerRadius(15)
            }
            .padding(30)
        }
        .presentationDetents([.height(360)])
    }
    func buyCard() {
        if userCredits >= 500 {
            userCredits -= 500
            ownedCardAsset = selectedCard
        }
    }

    func executeTransfer() {
        guard let amt = Int(transferAmount), amt > 0 else { return }
        if isWithdrawing {
            if cardBalance >= amt {
                cardBalance -= amt
                userCredits += amt
                showTransferSheet = false
            }
        } else {
            if userCredits >= amt {
                userCredits -= amt
                cardBalance += amt
                showTransferSheet = false
            }
        }
        transferAmount = ""
    }

    func terminateCard() {
        if userCredits >= 0 {
            userCredits -= 0
            userCredits += cardBalance
            ownedCardAsset = ""
            cardBalance = 0
            useCardForGames = false
        }
    }

    private func settingsToggle(title: String, isOn: Binding<Bool>, icon: String, color: Color) -> some View {
        Toggle(isOn: isOn) {
            HStack {
                ZStack { Circle().fill(color.opacity(0.2)).frame(width: 35, height: 35); Image(systemName: icon).foregroundColor(color) }
                Text(title).bold().foregroundColor(.white)
            }
        }
        .padding().tint(color)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
