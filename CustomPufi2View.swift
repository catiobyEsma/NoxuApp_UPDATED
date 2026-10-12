import SwiftUI
import UserNotifications

struct CustomPufi2View: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("hasCustomPufi2") var hasCustomPufi2: Bool = false
    @AppStorage("selectedAsset2") var savedAsset2: String = ""
    @AppStorage("pufiName2") var savedName2: String = ""
    @AppStorage("selectedTrait2") var savedTrait2: String = ""
    @AppStorage("userCredits") private var userCredits = 100
    @State private var step: Int = 0
    @State private var showResetAlert = false
    @State private var showFinalPufi = false
    @State private var currentAsset: String = ""
    @State private var currentName: String = ""
    @State private var currentTrait: String = ""
    
    let assets = ["pink_custom", "purple_custom", "green_custom", "orange_custom", "blue_custom", "dark_custom"]
    let traits = ["Calm", "Energic", "Sleepy", "Curious"]
    
    var body: some View {
        ZStack {
            // Arka Plan
            Color(hex: "#061836").ignoresSafeArea()
            StarFieldView1(starCount: 120)
            
            VStack(spacing: 30) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2.bold())
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Spacer()
                    Text("Pufi #2").font(.subheadline.bold()).foregroundColor(.white.opacity(0.3))
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
        }
        .navigationBarBackButtonHidden(true)
        .alert("Existing Pufi Found", isPresented: $showResetAlert) {
            Button("Confirm (10 Credits)", role: .destructive) {
                userCredits -= 10
                resetPufi2Data()
                withAnimation { step = 1 }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            let balanceAfter = userCredits - 10
            if userCredits >= 10 {
                Text("Re-creating your 2nd pufi costs 10 credits. Your balance will be \(balanceAfter).")
            } else {
                Text("Your balance is not enough. If you continue anyway, your balance'd drop to \(balanceAfter).")
            }
        }
    }

    private func resetPufi2Data() {
        savedAsset2 = ""
        savedName2 = ""
        savedTrait2 = ""
    }
    
    private func completeCreation() {
        savedAsset2 = currentAsset
        savedName2 = currentName
        savedTrait2 = currentTrait
        hasCustomPufi2 = true
        withAnimation { step = 4 }
    }
    private var welcomeView: some View {
        VStack(spacing: 25) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 60)).foregroundColor(Color(hex: "#00D1FF"))
            
            Text("Ready for a second friend?\nLet's design your new companion.")
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundColor(.white).multilineTextAlignment(.center)
            
            Button(action: {
                if hasCustomPufi2 {
                    showResetAlert = true
                } else {
                    withAnimation { step = 1 }
                }
            }) {
                Text("Start Creation")
                    .font(.headline).foregroundColor(.white)
                    .frame(width: 220, height: 55)
                    .background(Color(hex: "#00D1FF").opacity(0.8)).cornerRadius(15)
            }
        }
    }

    private var assetSelectionView: some View {
        VStack(spacing: 20) {
            Text("Select Appearance").font(.title2.bold()).foregroundColor(.white)
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
            Text("Name your new friend").font(.title2.bold()).foregroundColor(.white)
            TextField("Pufi's name...", text: $currentName)
                .padding().background(Color.white.opacity(0.1)).cornerRadius(15)
                .foregroundColor(.white).multilineTextAlignment(.center).padding(.horizontal, 40)
            
            if !currentName.isEmpty {
                Button(action: { withAnimation { step = 3 } }) {
                    Image(systemName: "arrow.right").font(.system(size: 60)).foregroundColor(Color(hex: "#00D1FF"))
                }
            }
        }
    }

    private var traitSelectionView: some View {
        VStack(spacing: 20) {
            Text("Pick a Personality").font(.title2.bold()).foregroundColor(.white)
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
            if !savedAsset2.isEmpty {
                Image(savedAsset2).resizable().scaledToFit().frame(width: 200, height: 200)
                    .scaleEffect(showFinalPufi ? 1.05 : 0.95)
            }
            
            Text("Hi! I'm \(savedName2)!\nYour second pufi is ready.")
                .font(.system(size: 24, weight: .bold)).foregroundColor(.white).multilineTextAlignment(.center)
            
            Button("Awesome!") { dismiss() }
                .font(.headline).foregroundColor(.white).frame(width: 200, height: 60)
                .background(Color(hex: "#00D1FF")).cornerRadius(20)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                showFinalPufi = true
            }
        }
    }
}
