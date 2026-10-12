import SwiftUI

struct CalmSwiftView: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("userCredits") private var userCredits = 100
    @AppStorage("cardBalance") private var cardBalance = 0
    @AppStorage("useCardForGames") private var useCardForGames = false
    
    @AppStorage("hasCustomPufi") var hasCustomPufi: Bool = false
    @AppStorage("isPufi2Unlocked") var isPufi2Unlocked: Bool = false
    @AppStorage("hasCustomPufi2") var hasCustomPufi2: Bool = false
    @AppStorage("pufiName") var savedName: String = ""
    @AppStorage("pufiName2") var savedName2: String = ""
    
    @State private var showManageSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 13/255, green: 8/255, blue: 26/255).ignoresSafeArea()
                starsBackground
                
                VStack(spacing: 0) {
                    headerBar
                    
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 25) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Calm Activities")
                                    .font(.system(size: 32, weight: .bold, design: .serif))
                                    .foregroundColor(.white)
                                Text("Nurture your inner peace.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 20)
                            .padding(.horizontal)
                            
                            VStack(spacing: 18) {
                                CalmActivityCard(
                                    title: "Call It A Day",
                                    subtitle: "Tomorrow's goals and reflections.",
                                    icon: "checkmark",
                                    color: Color(red: 135/255, green: 147/255, blue: 245/255),
                                    cost: 5,
                                    destination: AnyView(CloudShaperView())
                                )
                                CalmActivityCard(
                                    title: "Life Journal",
                                    subtitle: "Midnight thoughts and dreams.",
                                    icon: "square.and.pencil",
                                    color: Color(red: 168/255, green: 85/255, blue: 247/255),
                                    cost: 5,
                                    destination: AnyView(MidnightJournalView())
                                )

                                if !hasCustomPufi {
                                    NavigationLink(destination: PufiCreatorView()) {
                                        HStack {
                                            Image(systemName: "face.smiling").foregroundColor(.cyan)
                                            VStack(alignment: .leading) {
                                                Text("Create your own Pufi!").foregroundColor(.white).bold()
                                                Text("Design your companion.").font(.caption).foregroundColor(.gray)
                                            }
                                            Spacer()
                                            Image(systemName: "chevron.right").foregroundColor(.gray)
                                        }
                                        .padding().background(Color.white.opacity(0.05)).cornerRadius(20)
                                    }
                                }

                                if hasCustomPufi && !isPufi2Unlocked {
                                    UnlockActivityCard(
                                        title: "Unlock Second Pufi",
                                        subtitle: "Double the peace, double the joy.",
                                        icon: "star",
                                        color: .cyan,
                                        cost: 45
                                    )
                                }
                                if isPufi2Unlocked && !hasCustomPufi2 {
                                    NavigationLink(destination: CustomPufi2View()) {
                                        HStack {
                                            Image(systemName: "plus.circle").foregroundColor(.cyan)
                                            Text("Create Custom Pufi 2").foregroundColor(.white).bold()
                                            Spacer()
                                            Image(systemName: "chevron.right").foregroundColor(.gray)
                                        }
                                        .padding().background(Color.white.opacity(0.05)).cornerRadius(20)
                                    }
                                }

                                if hasCustomPufi || hasCustomPufi2 {
                                    NavigationLink(destination: PufiSettingsView()) {
                                        CalmActionCardSimple(
                                            title: "Pufi Settings",
                                            sub: "Personalize your companions.",
                                            icon: "gearshape",
                                            color: "A855F7"
                                        )
                                    }

                                    Button(action: { showManageSheet = true }) {
                                        HStack {
                                            Image(systemName: "trash").foregroundColor(.red.opacity(0.8))
                                            Text("Manage Pufis").foregroundColor(.white.opacity(0.9)).font(.subheadline).bold()
                                            Spacer()
                                            Text("Edit or Delete").font(.caption2).foregroundColor(.gray)
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .background(Capsule().stroke(Color.red.opacity(0.3), lineWidth: 1))
                                    }
                                    .padding(.top, 10)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 50)
                    }
                }
            }
            .sheet(isPresented: $showManageSheet) {
                ManagePufisView()
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    var headerBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.title2.bold())
                    .foregroundColor(.white.opacity(0.6))
            }
            Spacer()
            HStack(spacing: 6) {
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
            ForEach(0..<25, id: \.self) { _ in
                Circle().fill(Color.white.opacity(.random(in: 0.1...0.4)))
                    .frame(width: 2, height: 2)
                    .position(x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                              y: CGFloat.random(in: 0...UIScreen.main.bounds.height))
            }
        }
    }
}

struct CalmActivityCard: View {
    let title, subtitle, icon: String
    let color: Color
    let cost: Int
    let destination: AnyView
    
    @AppStorage("userCredits") private var userCredits = 100
    @AppStorage("cardBalance") private var cardBalance = 0
    @AppStorage("useCardForGames") private var useCardForGames = false
    
    @State private var showPopup = false
    @State private var isSheetPresented = false

    var finalCost: Int {
        useCardForGames ? Int(Double(cost) * 0.8) : cost
    }
    var activeBalance: Int {
        useCardForGames ? cardBalance : userCredits
    }
    
    var body: some View {
        ZStack {
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { showPopup = true }
            }) {
                HStack(spacing: 15) {
                    Image(systemName: icon).font(.title2).foregroundColor(color)
                        .frame(width: 50, height: 50).background(color.opacity(0.1)).cornerRadius(15)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title).font(.headline).foregroundColor(.white)
                        Text(subtitle).font(.caption).foregroundColor(.gray)
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        if useCardForGames {
                            Text("\(cost)").strikethrough().font(.caption2).opacity(0.4)
                        }
                        Text("\(finalCost)")
                        Image("100").resizable().scaledToFit().frame(width: 14, height: 14)
                    }
                    .font(.caption.bold())
                    .foregroundColor(useCardForGames ? Color(hex: "#ABDEE6") : .white.opacity(0.6))
                    .padding(6).background(Color.white.opacity(0.05)).cornerRadius(8)
                }
                .padding().background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.05)))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(useCardForGames ? Color(hex: "#ABDEE6").opacity(0.3) : color.opacity(0.2), lineWidth: 1))
            }
            .buttonStyle(PlainButtonStyle())
            .fullScreenCover(isPresented: $isSheetPresented) {
                destination
                    .ignoresSafeArea()
            
            }
            
            if showPopup {
                popupOverlay
            }
        }
    }
    
    private var popupOverlay: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
                .onTapGesture { withAnimation { showPopup = false } }
            
            VStack(spacing: 25) {
                Image(systemName: icon).font(.system(size: 50)).foregroundColor(color)
                VStack(spacing: 10) {
                    Text(activeBalance >= finalCost ? "Start \(title)" : "Not Enough Credits")
                        .font(.title3.bold()).foregroundColor(.white)
                    if useCardForGames {
                        Text("-%20 PUFI CARD DISCOUNT APPLIED")
                            .font(.system(size: 10, weight: .bold))
                            .padding(4).background(Color(hex: "#ABDEE6")).foregroundColor(.black).cornerRadius(4)
                    }
                    
                    Text(activeBalance >= finalCost ? "This activity will cost \(finalCost) credits." : "You need \(finalCost) credits to start this.")
                        .font(.subheadline).foregroundColor(.white.opacity(0.6)).multilineTextAlignment(.center)
                }
                HStack(spacing: 20) {
                    Button("Cancel") { withAnimation { showPopup = false } }
                        .foregroundColor(.white.opacity(0.4))
                    
                    if activeBalance >= finalCost {
                        Button("Confirm") {
                            if useCardForGames { cardBalance -= finalCost } else { userCredits -= finalCost }
                            withAnimation {
                                showPopup = false
                                isSheetPresented = true
                            }
                        }
                        .bold().padding(.horizontal, 30).padding(.vertical, 12)
                        .background(useCardForGames ? Color(hex: "#ABDEE6") : color).cornerRadius(15).foregroundColor(.black)
                    }
                }
            }
            .padding(35).background(Color(red: 20/255, green: 15/255, blue: 40/255)).cornerRadius(30).padding(30)
        }
        .transition(.scale.combined(with: .opacity)).zIndex(10)
    }
}

struct UnlockActivityCard: View {
    let title, subtitle, icon: String
    let color: Color
    let cost: Int
    
    @AppStorage("userCredits") private var userCredits = 100
    @AppStorage("cardBalance") private var cardBalance = 0
    @AppStorage("useCardForGames") private var useCardForGames = false
    @AppStorage("isPufi2Unlocked") var isPufi2Unlocked: Bool = false
    
    @State private var showPopup = false
    
    var finalCost: Int {
        useCardForGames ? Int(Double(cost) * 0.8) : cost
    }
    var activeBalance: Int {
        useCardForGames ? cardBalance : userCredits
    }
    
    var body: some View {
        ZStack {
            Button(action: { withAnimation(.spring()) { showPopup = true } }) {
                HStack {
                    Image(systemName: icon).foregroundColor(useCardForGames ? Color(hex: "#ABDEE6") : color)
                    Text(title).foregroundColor(.white).bold()
                    Spacer()
                    if useCardForGames {
                        Text("\(cost)").strikethrough().font(.caption2).opacity(0.4)
                    }
                    Text("\(finalCost)").font(.caption.bold())
                    Image("100").resizable().frame(width: 14, height: 14)
                }
                .padding().background(RoundedRectangle(cornerRadius: 20).stroke(style: StrokeStyle(lineWidth: 1, dash: [5])).foregroundColor(useCardForGames ? Color(hex: "#ABDEE6").opacity(0.5) : .gray))
            }
            
            if showPopup {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                        .onTapGesture { withAnimation { showPopup = false } }
                    
                    VStack(spacing: 25) {
                        Image(systemName: icon).font(.system(size: 50)).foregroundColor(useCardForGames ? Color(hex: "#ABDEE6") : color)
                        
                        VStack(spacing: 10) {
                            Text(activeBalance >= finalCost ? title : "Not Enough Credits")
                                .font(.title3.bold()).foregroundColor(.white)
                            
                            if useCardForGames {
                                Text("CARD DISCOUNT ACTIVE")
                                    .font(.caption2.bold()).padding(4).background(Color(hex: "#ABDEE6")).foregroundColor(.black).cornerRadius(4)
                            }
                            
                            Text(activeBalance >= finalCost ? "Unlock this for \(finalCost) credits?" : "You don't have enough credits in your \(useCardForGames ? "card" : "wallet").")
                                .font(.caption).foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        
                        HStack(spacing: 20) {
                            Button("Cancel") { withAnimation { showPopup = false } }.foregroundColor(.white.opacity(0.4))
                            
                            if activeBalance >= finalCost {
                                Button("Unlock") {
                                    if useCardForGames { cardBalance -= finalCost } else { userCredits -= finalCost }
                                    isPufi2Unlocked = true
                                    withAnimation { showPopup = false }
                                }.bold().padding(.horizontal, 30).padding(.vertical, 12)
                                .background(useCardForGames ? Color(hex: "#ABDEE6") : color).cornerRadius(15).foregroundColor(.black)
                            }
                        }
                    }
                    .padding(35).background(Color(red: 20/255, green: 15/255, blue: 40/255)).cornerRadius(30).padding(30)
                }
                .transition(.scale.combined(with: .opacity)).zIndex(10)
            }
        }
    }
}

struct CalmActionCardSimple: View {
    let title, sub, icon, color: String
    var body: some View {
        HStack(spacing: 18) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color(hex: color))
                .frame(width: 50, height: 50)
                .background(Color(hex: color).opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title).foregroundColor(.white).font(.headline)
                Text(sub).font(.caption).foregroundColor(.white.opacity(0.5))
            }
            Spacer()
            Image(systemName: "chevron.right").font(.caption).foregroundColor(.white.opacity(0.3))
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 26).fill(Color.white.opacity(0.06)))
    }
}

struct ManagePufisView: View {
    @AppStorage("hasCustomPufi") var hasCustomPufi: Bool = false
    @AppStorage("hasCustomPufi2") var hasCustomPufi2: Bool = false
    @AppStorage("pufiName") var pufiName: String = ""
    @AppStorage("pufiName2") var pufiName2: String = ""
    @AppStorage("isPufi2Unlocked") var isPufi2Unlocked: Bool = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(red: 20/255, green: 15/255, blue: 40/255).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Your Companions").font(.title2.bold()).foregroundColor(.white).padding(.top)
                
                if hasCustomPufi {
                    manageRow(name: pufiName.isEmpty ? "Pufi 1" : pufiName) { hasCustomPufi = false }
                }
                
                if hasCustomPufi2 {
                    manageRow(name: pufiName2.isEmpty ? "Pufi 2" : pufiName2) {
                        hasCustomPufi2 = false
                        isPufi2Unlocked = false
                    }
                }
                
                if !hasCustomPufi && !hasCustomPufi2 {
                    Text("No Pufis found.").foregroundColor(.gray).padding()
                }
                
                Spacer()
                Button("Done") { dismiss() }.foregroundColor(.cyan).bold()
            }
            .padding()
        }
    }
    
    func manageRow(name: String, onDelete: @escaping () -> Void) -> some View {
        HStack {
            Text(name).foregroundColor(.white)
            Spacer()
            Button(action: onDelete) {
                Image(systemName: "trash").foregroundColor(.red)
            }
        }
        .padding().background(Color.white.opacity(0.05)).cornerRadius(12)
    }
}

// MARK: - Previews
struct CalmSwiftView_Previews: PreviewProvider {
    static var previews: some View {
        CalmSwiftView()
    }
}
