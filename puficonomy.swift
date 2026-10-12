import SwiftUI

struct PuficonomyView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("userCredits") private var userCredits = 100
    @AppStorage("hasPufiCard") private var hasPufiCard = false
    @State private var backgroundAssets: [(name: String, x: CGFloat, y: CGFloat, size: CGFloat)] = []
    
    var body: some View {
        ZStack {
            Color(red: 13/255, green: 8/255, blue: 26/255).ignoresSafeArea()
            StaticBackgroundStarsView()
            starsBackground
            ForEach(0..<backgroundAssets.count, id: \.self) { i in
                Image(backgroundAssets[i].name)
                    .resizable()
                    .scaledToFit()
                    .frame(width: backgroundAssets[i].size)
                    .opacity(0.12)
                    .position(x: backgroundAssets[i].x, y: backgroundAssets[i].y)
            }
            VStack(spacing: 30) {
                headerBar
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Manage Your Balance")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                    Text("Manage your credits and special cards to spend credits to unlock games ✨")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                VStack(spacing: 20) {
                    NavigationLink(destination: EarnCreditView()) {
                        EconomyMenuButton(
                            title: "Refill Credits",
                            subtitle: "Get free credits to play games <3!",
                            icon: "checkmark.circle",
                            color: "#d3a0db",
                            imageName: "pufi_bed"
                        )
                    }
                    NavigationLink(destination: PufiCardSystemView()) {
                        EconomyMenuButton(
                            title: hasPufiCard ? "Edit My Pufi Card" : "Get Pufi Card",
                            subtitle: hasPufiCard ? "Customize your active card" : "Unlock 20% discount on games",
                            icon: hasPufiCard ? "bag" : "bag",
                            color: "#ABDEE6",
                            imageName: "pufi_bed"
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 10)
        }
        .navigationBarHidden(true)
        .onAppear {
            setupBackgroundAssets()
        }
    }
    private var starsBackground: some View {
        ZStack {
            ForEach(0..<15, id: \.self) { _ in
                Circle().fill(Color.white.opacity(0.15))
                    .frame(width: 1.5, height: 1.5)
                    .position(x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                              y: CGFloat.random(in: 0...UIScreen.main.bounds.height))
            }
        }
    }

    private func setupBackgroundAssets() {
        if backgroundAssets.isEmpty {
            backgroundAssets = [
                (name: "c2", x: 300, y: 520, size: 200),
                (name: "100", x: 120, y: 650, size: 200)
            ]
        }
    }
    
    var headerBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.title2.bold())
                    .foregroundColor(.white.opacity(0.6))
            }
            Spacer()
            HStack(spacing: 8) {
                Text("\(userCredits)").fontWeight(.bold)
                Image("100").resizable().frame(width: 20, height: 20)
            }
            .padding(.horizontal, 15).padding(.vertical, 8)
            .background(Capsule().fill(Color.white.opacity(0.1)))
            .foregroundColor(.white)
        }
        .padding(.horizontal)
    }
}
struct EconomyMenuButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: String
    let imageName: String
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(hex: color).opacity(0.15))
                    .frame(width: 55, height: 55)
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(Color(hex: color))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.2))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}
struct PuficonomyView_Previews: PreviewProvider {
    static var previews: some View {
        let _ = UserDefaults.standard.set(100, forKey: "userCredits")
        
        PuficonomyView()
            .preferredColorScheme(.dark)
    }
}

