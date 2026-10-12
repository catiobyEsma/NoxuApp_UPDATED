import SwiftUI
import UserNotifications

struct PufiCreatorView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("hasCustomPufi") var hasCustomPufi: Bool = false
    @AppStorage("selectedAsset") var savedAsset: String = ""
    @AppStorage("pufiName") var savedName: String = ""
    @AppStorage("selectedTrait") var savedTrait: String = ""
    @AppStorage("userCredits") private var userCredits = 100 // Kredi takibi
    @State private var step: Int = 0
    @State private var showResetAlert = false
    @State private var showFinalPufi = false
    @State private var showPermissionPopup = false
    @State private var currentAsset: String = ""
    @State private var currentName: String = ""
    @State private var currentTrait: String = ""
    
    let assets = ["pink_custom", "purple_custom", "green_custom", "orange_custom", "blue_custom", "dark_custom"]
    let traits = ["Calm", "Energic", "Sleepy", "Curious"]
    
    var body: some View {
        ZStack {
            Color(hex: "#061836").ignoresSafeArea()
            StarFieldView1(starCount: 100)
            
            VStack(spacing: 30) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title).foregroundColor(.white.opacity(0.5))
                    }
                    Spacer()
                }
                
                Spacer()
                
                switch step {
                case 0: welcomeView
                case 1: assetSelectionView
                case 2: nameInputView
                case 3: traitSelectionView
                case 4: finalPufiView
                default: EmptyView()
                }
                
                Spacer()
            }
            .padding()
            .blur(radius: showPermissionPopup ? 15 : 0)
            
            if showPermissionPopup {
                permissionPopupView
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear { checkInitialNotificationStatus() }
        .alert("Existing Pufi Found", isPresented: $showResetAlert) {
            Button("Confirm (10 Credits)", role: .destructive) {
                userCredits -= 10
                resetPufiData()
                withAnimation { step = 1 }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            let balanceAfter = userCredits - 10
            if userCredits >= 10 {
                Text("Deleting your existing pufi costs 10 credits. Your balance will be \(balanceAfter).")
            } else {
                Text("Your balance is not enough. If you continue anyway, your balance will drop to \(balanceAfter).")
            }
        }
    }
    
    private func resetPufiData() {
        savedAsset = ""
        savedName = ""
        savedTrait = ""
    }
    
    private func completeCreation() {
        savedAsset = currentAsset
        savedName = currentName
        savedTrait = currentTrait
        hasCustomPufi = true
        withAnimation { step = 4 }
    }
    private var welcomeView: some View {
        VStack(spacing: 25) {
            Text("Hi! Here, you can adopt a pufi and give it a unique personality.")
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundColor(.white).multilineTextAlignment(.center)
            
            Button(action: {
                if hasCustomPufi {
                    showResetAlert = true
                } else {
                    withAnimation { step = 1 }
                }
            }) {
                Text("Let's Start!")
                    .font(.headline).foregroundColor(.white)
                    .frame(width: 200, height: 55)
                    .background(Color(hex: "#4232a8")).cornerRadius(15)
            }
        }
    }
    private var assetSelectionView: some View {
        VStack(spacing: 20) {
            Text("Choose your Pufi").font(.title2.bold()).foregroundColor(.white)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(assets, id: \.self) { asset in
                    Button(action: {
                        currentAsset = asset
                        withAnimation { step = 2 }
                    }) {
                        Image(asset).resizable().scaledToFit().frame(height: 80).padding()
                            .background(Color.white.opacity(0.05)).cornerRadius(20)
                    }
                }
            }
        }
    }

    private var nameInputView: some View {
        VStack(spacing: 25) {
            Text("Give a name to your Pufi!").font(.title2.bold()).foregroundColor(.white)
            TextField("Pufi's name...", text: $currentName)
                .padding().background(Color.white.opacity(0.1)).cornerRadius(15)
                .foregroundColor(.white).multilineTextAlignment(.center).padding(.horizontal, 40)
            
            if !currentName.isEmpty {
                Button(action: { withAnimation { step = 3 } }) {
                    Image(systemName: "arrow.right").font(.system(size: 60)).foregroundColor(Color(hex: "#8793f5"))
                }
            }
        }
    }

    private var traitSelectionView: some View {
        VStack(spacing: 20) {
            Text("Choose its character").font(.title2.bold()).foregroundColor(.white)
            ForEach(traits, id: \.self) { trait in
                Button(action: {
                    currentTrait = trait
                    completeCreation()
                }) {
                    Text(trait).font(.headline).foregroundColor(.white)
                        .frame(maxWidth: .infinity).frame(height: 55)
                        .background(Color.white.opacity(0.1)).cornerRadius(15)
                }
            }
            .padding(.horizontal, 40)
        }
    }

    private var finalPufiView: some View {
        VStack(spacing: 30) {
            if !savedAsset.isEmpty {
                Image(savedAsset).resizable().scaledToFit().frame(width: 200, height: 200)
                    .scaleEffect(showFinalPufi ? 1.05 : 0.95)
            }
            
            Text("Hi! I'm \(savedName), Nice to Meet You!")
                .font(.system(size: 24, weight: .bold)).foregroundColor(.white).multilineTextAlignment(.center)
            
            Button("Let's Go!") { dismiss() }
                .font(.headline).foregroundColor(.white).frame(width: 200, height: 60)
                .background(Color(hex: "#4232a8")).cornerRadius(20)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                showFinalPufi = true
            }
        }
    }

    // Bildirim ve Popup kodları (Orijinal haliyle kalıyor)
    private func checkInitialNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus != .authorized {
                    withAnimation(.spring()) { showPermissionPopup = true }
                }
            }
        }
    }

    private func requestNotificationPermissionFromPopup() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .denied {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } else {
                    center.requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
                        DispatchQueue.main.async { withAnimation { showPermissionPopup = false } }
                    }
                }
            }
        }
    }

    private var permissionPopupView: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            VStack(spacing: 25) {
                Image(systemName: "bell.badge.fill").font(.system(size: 60)).foregroundColor(Color(hex: "#8793f5"))
                Text("Keep in Touch!").font(.system(size: 24, weight: .bold, design: .rounded)).foregroundColor(.white)
                Text("This feature requires notification permission. Your Pufi wants to talk to you!").font(.body).multilineTextAlignment(.center).foregroundColor(.white.opacity(0.8)).padding(.horizontal)
                VStack(spacing: 15) {
                    Button(action: { requestNotificationPermissionFromPopup() }) {
                        Text("Enable Notifications").font(.headline).foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 55).background(Color(hex: "#4232a8")).cornerRadius(15)
                    }
                    Button(action: { withAnimation { showPermissionPopup = false } }) {
                        Text("Continue Without Notifications").font(.subheadline).foregroundColor(.white.opacity(0.5))
                    }
                }.padding(.horizontal, 20)
            }
            .padding(30).background(RoundedRectangle(cornerRadius: 30).fill(Color(hex: "#061836")).overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.white.opacity(0.1), lineWidth: 1))).padding(.horizontal, 30)
        }
    }
}
