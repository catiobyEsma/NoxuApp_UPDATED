import SwiftUI

class CreditManager: ObservableObject {
    @AppStorage("userCredits") var userCredits = 100
    
    func canAfford(_ amount: Int) -> Bool {
        return userCredits >= amount
    }
    
    func spend(_ amount: Int) {
        if canAfford(amount) {
            objectWillChange.send()
            userCredits -= amount
        }
    }
}
struct SleepGamesView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var creditManager = CreditManager()
    @AppStorage("useCardForGames") private var useCardForGames = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#0D081A").ignoresSafeArea()
                StaticBackgroundStarsView()
                
                VStack(spacing: 20) {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.title2.bold())
                                .foregroundColor(.white.opacity(0.6))
                        }
                        Spacer()
                        HStack(spacing: 8) {
                            Image("100")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text("\(useCardForGames ? UserDefaults.standard.integer(forKey: "cardBalance") : creditManager.userCredits)")
                                .font(.system(.subheadline, design: .rounded).bold())
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color.white.opacity(0.1)))
                    }
                    .padding(.horizontal)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Quiet Your Mind")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                        Text("Choose a gentle activity to drift off.")
                            .foregroundColor(.white.opacity(0.6))
                        
                        if useCardForGames {
                            Text("20% Pufi Card Discount Active")
                                .font(.caption2.bold())
                                .foregroundColor(Color(hex: "#ABDEE6"))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(hex: "#ABDEE6").opacity(0.1))
                                .cornerRadius(5)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            GameCard(icon: "brain.head.profile", title: "Cognitive Shuffle", desc: "Visualize random objects.", color: Color(hex: "#8E86D7"), destination: AnyView(CognitiveShuffleView()))
                            
                            GameCard(icon: "pawprint", title: "Sheep Counter", desc: "Slow and steady.", color: Color(hex: "#6bb09d"), destination: AnyView(SheepCounterView()))
                        }
                        .padding()
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .environmentObject(creditManager)
    }
}
struct GameCard: View {
    let icon: String; let title: String; let desc: String; let color: Color; let destination: AnyView
    
    @EnvironmentObject var creditManager: CreditManager
    @AppStorage("useCardForGames") private var useCardForGames = false
    @AppStorage("cardBalance") private var cardBalance = 0
    
    @State private var showPopup = false
    @State private var isActive = false
    private let baseCost = 5
    var finalCost: Int {
        useCardForGames ? Int(Double(baseCost) * 0.8) : baseCost
    }
    var activeBalance: Int {
        useCardForGames ? cardBalance : creditManager.userCredits
    }
    
    var body: some View {
        ZStack {
            Button(action: {
                withAnimation(.spring()) { showPopup = true }
            }) {
                HStack(spacing: 15) {
                    Image(systemName: icon).font(.title).foregroundColor(color)
                        .frame(width: 60, height: 60).background(color.opacity(0.1)).cornerRadius(15)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title).font(.headline).foregroundColor(.white)
                        Text(desc).font(.caption).foregroundColor(.white.opacity(0.5)).multilineTextAlignment(.leading)
                    }
                    Spacer()
                    Image(systemName: "play.circle").font(.title2).foregroundColor(color.opacity(0.7))
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(20)
            }
            .buttonStyle(PlainButtonStyle())
            if showPopup {
                ZStack {
                    Color.black.opacity(0.8).ignoresSafeArea()
                        .onTapGesture { showPopup = false }
                    
                    VStack(spacing: 25) {
                        Image(systemName: icon).font(.system(size: 50)).foregroundColor(color)
                        
                        VStack(spacing: 10) {
                            Text(activeBalance >= finalCost ? "Ready to Relax?" : "Not Enough Credits")
                                .font(.title2.bold()).foregroundColor(.white)
                            
                            if useCardForGames && activeBalance >= finalCost {
                                Text("20% Pufi Card Discount Applied!")
                                    .font(.caption2.bold())
                                    .foregroundColor(Color(hex: "#ABDEE6"))
                            }
                            
                            Text(activeBalance >= finalCost ? "This activity will use \(finalCost) credits." : "You need \(finalCost) credits. Current: \(activeBalance)")
                                .font(.subheadline).foregroundColor(.white.opacity(0.6)).multilineTextAlignment(.center)
                        }
                        
                        HStack(spacing: 20) {
                            Button("Cancel") {
                                withAnimation { showPopup = false }
                            }
                            .foregroundColor(.white.opacity(0.4))
                            
                            if activeBalance >= finalCost {
                                Button(action: {
                                    if useCardForGames {
                                        cardBalance -= finalCost
                                    } else {
                                        creditManager.spend(finalCost)
                                    }
                                    
                                    withAnimation {
                                        showPopup = false
                                        isActive = true
                                    }
                                }) {
                                    Text("Let's Go")
                                        .bold().padding(.horizontal, 30).padding(.vertical, 12)
                                        .background(color).cornerRadius(15).foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .padding(35)
                    .background(Color(hex: "#1A152E"))
                    .cornerRadius(30)
                    .shadow(color: .black.opacity(0.5), radius: 20)
                    .padding(30)
                }
                .zIndex(10)
            }
        }
        .navigationDestination(isPresented: $isActive) {
            destination
        }
    }
}
struct CognitiveShuffleView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentWord = "Carpet"
    @State private var timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    
    let words = [
        "Carpet", "Lampshade", "Teapot", "Silver Spoon", "Keychain", "Velvet Pillow",
        "Glass Pitcher", "Copper Pot", "Door Handle", "Blanket", "Bookmark", "Piggy Bank",
        "Wooden Chair", "Porcelain Cup", "Gas Lamp", "Radio", "Picture Frame", "Alarm Clock",
        "Ironing Board", "Shutter", "Pebble", "Pinecone", "Raindrop", "Palm Leaf", "Waterfall",
        "Water Lily", "Snowflake", "Cave", "Starfish", "Bamboo", "Wren", "Sunflower", "Volcanic Rock",
        "Rainbow", "Fence", "Path", "Moss", "White Cloud", "Grain of Sand", "Grass", "Red Apple",
        "Fresh Bread", "Cinnamon", "Watermelon Slice", "Green Olive", "Pumpkin", "Corn", "Hazelnut",
        "Vanilla Stick", "Orange Peel", "Wheat", "Walnut", "Lemon", "Eggplant", "Strawberry", "Honey Jar",
        "Grape", "Kite", "Sailboat", "Paper Plane", "Bicycle", "Backpack", "Telescope", "Compass",
        "Old Key", "Paintbrush", "Chessboard", "Violin", "Harmonica", "Racket", "Lighthouse", "Anchor",
        "Balloon", "Train Track", "Posta Box", "Umbrella", "Turtle", "Peacock", "Butterfly", "Giraffe",
        "Snail", "Penguin", "Dragonfly", "Elephant", "Dolphin", "Bee", "Flamingo", "Deer", "Ladybug",
        "Squirrel", "Swan", "Hedgehog", "Horse", "Koala", "Panda"
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "#0D081A").ignoresSafeArea()
            StaticBackgroundStarsView()
            
            VStack(spacing: 40) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title).foregroundColor(.white.opacity(0.2))
                    }
                    Spacer()
                }.padding()
                
                Spacer()
                
                VStack(spacing: 20) {
                    Text("Visualize this:")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.4))
                    
                    Text(currentWord)
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#8E86D7"))
                        .id(currentWord)
                        .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.9)), removal: .opacity))
                }
                
                Spacer()
                
                Text("Close your eyes and imagine the object in detail...")
                    .font(.subheadline)
                    .italic()
                    .foregroundColor(.white.opacity(0.3))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 50)
                    .padding(.bottom, 50)
            }
        }
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 1.5)) {
                currentWord = words.randomElement() ?? "Peace"
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

