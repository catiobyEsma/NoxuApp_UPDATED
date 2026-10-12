import SwiftUI

struct PufiMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

struct AppBackgroundView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("Background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                
                Color.black.opacity(0.55).ignoresSafeArea()
            }
        }
        .ignoresSafeArea()
    }
}

struct GainPerspectiveView: View {
    @Environment(\.dismiss) var dismiss
    @State private var singleWorry: String = ""
    @State private var showChat = false
    
    private let accentPurple = Color(safeHex: "#A855F7")
    private let accentIndigo = Color(safeHex: "#6366F1")
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            VStack(spacing: 25) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2.bold())
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Text("Gain Perspective")
                        .font(.system(.title3, design: .serif))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.leading, 10)
                    Spacer()
                }
                .padding(.top, 10)
                .padding(.horizontal, 20)
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("What's weighing on your mind?")
                                .font(.system(size: 24, weight: .bold, design: .serif))
                                .foregroundColor(.white)
                            Text("Write your worry as a single clear sentence. Pufi will help you clear your mind and look at it from a fresh angle.")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(BlurView(style: .systemThinMaterialDark))
                        .cornerRadius(20)
                        
                        TextField("", text: $singleWorry, prompt: Text("Type your thought here...").foregroundColor(.white.opacity(0.5)))
                            .padding(20)
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(20)
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.3), lineWidth: 1))
                    }
                    .padding(.horizontal, 20)
                }
                
                if !singleWorry.trimmingCharacters(in: .whitespaces).isEmpty {
                    Button(action: { showChat = true }) {
                        Text("That's all")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(LinearGradient(colors: [accentPurple, accentIndigo], startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(28)
                            .padding(.horizontal, 30)
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(isPresented: $showChat) {
            PerspectiveChatView(userWorry: singleWorry)
        }
    }
}

struct PerspectiveChatView: View {
    let userWorry: String
    @Environment(\.dismiss) var dismiss
    
    @State private var messages: [PufiMessage] = []
    @State private var currentOptions: [String] = []
    @State private var isConversationStarted = false
    @State private var navToSleep = false
    @State private var navToStars = false
    @State private var navToTomorrow = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                
                VStack(spacing: 0) {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                        Text("Chat with Pufi")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.leading, 8)
                        Spacer()
                    }
                    .padding()
                    
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 18) {
                                ForEach(messages) { msg in
                                    PufiBubble(message: msg,
                                               onSleep: { navToSleep = true },
                                               onStars: { navToStars = true },
                                               onTomorrow: { navToTomorrow = true })
                                }
                                
                                if !currentOptions.isEmpty {
                                    VStack(spacing: 12) {
                                        ForEach(currentOptions, id: \.self) { option in
                                            Button(action: { handleSelection(option) }) {
                                                Text(option)
                                                    .font(.subheadline)
                                                    .padding()
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .background(Color.black.opacity(0.3))
                                                    .foregroundColor(.white)
                                                    .cornerRadius(15)
                                                    .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.2)))
                                            }
                                        }
                                    }
                                    .padding(.top, 10)
                                }
                                Color.clear.frame(height: 1).id("bottom")
                            }
                            .padding()
                        }
                        .onChange(of: messages.count) { oldValue, newValue in
                            withAnimation {
                                proxy.scrollTo("bottom", anchor: .bottom)
                            }
                        }
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $navToSleep) { SleepAssistantView() }
            .navigationDestination(isPresented: $navToStars) { WorriedPage() }
            .navigationDestination(isPresented: $navToTomorrow) { CloudShaperView() }
            .onAppear {
                if !isConversationStarted {
                    startConversation()
                    isConversationStarted = true
                }
            }
        }
    }
    private func startConversation() {
        addBotMessage("Hi! I'm Pufi. I'm here to help you unload and unpack your thoughts. How is your mind feeling right now? 😊")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            currentOptions = ["Just looking for some quiet time", "A bit cluttered with thoughts", "Ready to release some weight"]
        }
    }
    
    private func handleSelection(_ option: String) {
        addUserMessage(option)
        currentOptions = []
        let delay = 1.0
        
        switch option {
        case "Just looking for some quiet time":
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                addBotMessage("Quiet time is a gift you give to yourself. Let's create a spacious, empty room in your mind for \"\(userWorry)\" to dissolve into. ✨")
                currentOptions = ["Help me clear the noise", "I just want a peaceful moment", "Let's wind down"]
            }
        case "A bit cluttered with thoughts", "Ready to release some weight":
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                addBotMessage("A crowded mind just needs a little organizing and gentle release. We can sort through \"\(userWorry)\" together and find your calm space. ⚓")
                currentOptions = ["I want to slow things down", "I feel a bit tired", "Organize for tomorrow"]
            }
        case "Help me clear the noise", "I want to slow things down":
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                addBotMessage("When we turn down the volume of the outside world, everything feels lighter. Let's let go of the gravity of \"\(userWorry)\" and make it soft like a cloud. 🎈")
                currentOptions = ["How do I step back?", "I need a cozy distraction", "I want to rest my eyes"]
            }
        case "I just want a peaceful moment", "I feel a bit tired", "Let's wind down":
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                addBotMessage("Every thought deserves a soft landing place. Let's make sure your mind is ready to transition into complete relaxation. ☁️")
                currentOptions = ["Clear my head space", "Organize for tomorrow", "Just pure stillness"]
            }
        case "I need a cozy distraction":
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                addBotMessage("Shifting focus gently is a wonderful way to rest your focus. Which calming path feels right for your mind tonight? 🕊️")
                currentOptions = ["I want to watch the stars", "I want to rest my eyes"]
            }
        case "How do I step back?", "Clear my head space", "I want to watch the stars", "Just pure stillness":
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                addBotMessage("To clear your head, creating a little distance is perfect. Let's take \"\(userWorry)\" and let it drift away into the vast night sky. Try the stars tool to release it. 🌟")
            }
        case "I want to rest my eyes":
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                addBotMessage("Your mind is ready for sanctuary. Let's set \"\(userWorry)\" aside for the night so you can float into a deep, comforting rest. Tap sleep below. 🌙")
            }
        case "Organize for tomorrow":
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                addBotMessage("Putting things in order always clears the mental slate. Let's write down a tiny plan for \"\(userWorry)\" so you can leave it here. Tap tomorrow below to start. 🗓️")
            }
        default:
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                addBotMessage("I am right here with you. Let's take a peaceful little step forward together. ❤️")
                currentOptions = ["I want to watch the stars", "I want to rest my eyes"]
            }
        }
    }
    
    private func addBotMessage(_ text: String) {
        withAnimation { messages.append(PufiMessage(text: text, isUser: false)) }
    }
    
    private func addUserMessage(_ text: String) {
        withAnimation { messages.append(PufiMessage(text: text, isUser: true)) }
    }
}

struct PufiBubble: View {
    let message: PufiMessage
    var onSleep: (() -> Void)? = nil
    var onStars: (() -> Void)? = nil
    var onTomorrow: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            VStack(alignment: .leading, spacing: 12) {
                Text(message.text)
                    .font(.system(size: 16))
                
                if !message.isUser {
                    let text = message.text.lowercased()
                    if text.contains("sleep") || text.contains("tomorrow") || text.contains("star") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                if text.contains("tomorrow") { actionButton(title: "Tomorrow", icon: "calendar", action: onTomorrow) }
                                if text.contains("star") { actionButton(title: "Stars", icon: "star", action: onStars) }
                                if text.contains("sleep") { actionButton(title: "Sleep", icon: "moon.zzz", action: onSleep) }
                            }
                        }
                    }
                }
            }
            .padding()
            .background(message.isUser ? Color.purple.opacity(0.8) : Color.white.opacity(0.15))
            .background(BlurView(style: .systemUltraThinMaterialDark))
            .foregroundColor(.white)
            .cornerRadius(18)
            .frame(maxWidth: 280, alignment: message.isUser ? .trailing : .leading)
            
            if !message.isUser { Spacer() }
        }
    }
    
    func actionButton(title: String, icon: String, action: (() -> Void)?) -> some View {
        Button(action: { action?() }) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.caption)
                Text(title).font(.caption.bold())
            }
            .padding(8)
            .background(Color.white.opacity(0.2))
            .cornerRadius(10)
        }
    }
}
struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView { UIVisualEffectView(effect: UIBlurEffect(style: style)) }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

extension Color {
    init(safeHex: String) {
        let hex = safeHex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 3: (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default: (r, g, b) = (255, 255, 255)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: 1)
    }
}
