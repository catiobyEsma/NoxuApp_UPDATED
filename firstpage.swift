import SwiftUI
import Charts
struct MoodStat: Identifiable, Codable {
    var id = UUID()
    let mood: String
    var count: Int
    let hexColor: String
    let date: Date
}

struct firstpage: View {
    @State private var startAnimation = false
    @State private var selectedMood: String? = nil
    @State private var showFeedback = false
    @State private var feedbackColor: Color = .clear
    @AppStorage("moodHistoryData") private var moodHistoryData: Data = Data()
    @AppStorage("userCredits") private var userCredits = 100 // Bakiye Sistemi
    @State private var monthlyStats: [MoodStat] = []

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#061836").ignoresSafeArea()
                StaticBackgroundStarsView()
                VStack {
                    Spacer()
                    if showFeedback {
                        feedbackColor
                            .opacity(0.3)
                            .frame(height: 300)
                            .mask(LinearGradient(gradient: Gradient(colors: [.clear, feedbackColor.opacity(0.5)]), startPoint: .top, endPoint: .bottom))
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }.ignoresSafeArea()
                pufiDecorations
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 25) {
                        
                        headerSection
                        
                        moodTrackerSection
                        VStack(spacing: 16) {
                            dynamicRoutineButton
                            NavigationLink(destination: NatureSoundsView()) {
                                ActivityCard2(title: "Night Sounds", subtitle: "Rain & Forest", icon: "speaker.wave.2", color: "#FF7AF3", imageName: "pufi_music")
                            }
                            NavigationLink(destination: ArcadeView()) {
                                ActivityCard2(
                                    title: "Pufi Arcade",
                                    subtitle: "Brain training, mini relaxing games",
                                    icon: "gamecontroller",
                                    color: "#CBAACB",
                                    imageName: "pufi_social"
                                )
                            }
                          

                            // MARK: - PUFICONOMY BUTONU
                            NavigationLink(destination: PuficonomyView()) {
                                ActivityCard2(
                                    title: "Puficonomy",
                                    subtitle: "Manage assets, cards & rewards",
                                    icon: "leaf.arrow.circlepath",
                                    color: "#ABDEE6",
                                    imageName: "pufi_study"
                                )
                            }
                        }
                        .padding(.horizontal)
                        .opacity(startAnimation ? 1 : 0)
                        .offset(y: startAnimation ? 0 : 40)
                        chartSection // Grafik Alanı
                    }
                    .padding(.bottom, 50)
                }
            }
            .onAppear {
                loadMoodHistory()
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                    startAnimation = true
                }
            }
        }
    }

    var headerSection: some View {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Good Evening,")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.6))
                    Text("Ready for peace?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 12) {

                    HStack(spacing: 5) {
                        Text("\(userCredits)").fontWeight(.bold)
                        Image("100")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.white.opacity(0.1)))

                    HStack(spacing: 12) {
                        NavigationLink(destination: SetView()) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 20))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(10)
                                .background(Circle().fill(Color.white.opacity(0.1)))
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
        }
  
    var moodTrackerSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("How do you feel right now?")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                moodButton(name: "Calm", img: "pufi_study", col: Color(hex: "#8793f5"), hex: "#8793f5")
                moodButton(name: "Sleepy", img: "pufi_bed", col: Color.purple, hex: "#A855F7")
                moodButton(name: "Bored", img: "pufi_social", col: Color(hex: "#4959cc"), hex: "#4959cc")
                moodButton(name: "Confused", img: "pufi_worried", col: Color(hex: "#4232a8"), hex: "#4232a8")
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(24)
        .padding(.horizontal)
    }
    
    func moodButton(name: String, img: String, col: Color, hex: String) -> some View {
        let isSelected = selectedMood == name
        
        return Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            logMood(name: name, color: col, hex: hex)
        }) {
            VStack(spacing: 8) {
                Image(img)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .scaleEffect(isSelected ? 1.15 : 1.0)
                
                Text(name)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(col.opacity(0.35))
                            .shadow(color: col.opacity(0.5), radius: 12, x: 0, y: 0)
                    } else {
                        Color.white.opacity(0.08)
                    }
                }
            )
            .cornerRadius(16)
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }

    func logMood(name: String, color: Color, hex: String) {
        let today = Calendar.current.startOfDay(for: Date())
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            selectedMood = name
            if let index = monthlyStats.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
                monthlyStats[index] = MoodStat(mood: name, count: 1, hexColor: hex, date: today)
            } else {
                let newStat = MoodStat(mood: name, count: 1, hexColor: hex, date: today)
                monthlyStats.append(newStat)
            }
        }
        saveMoodHistory()
        feedbackColor = color
        withAnimation(.easeOut(duration: 0.4)) { showFeedback = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeIn(duration: 0.8)) { showFeedback = false }
        }
    }

    func saveMoodHistory() {
        if let encoded = try? JSONEncoder().encode(monthlyStats) {
            moodHistoryData = encoded
        }
    }

    func loadMoodHistory() {
        if let decoded = try? JSONDecoder().decode([MoodStat].self, from: moodHistoryData) {
            monthlyStats = decoded
        }
    }
    
    func groupMoods() -> [MoodStat] {
        var counts: [String: (Int, String)] = [:]
        for stat in monthlyStats {
            counts[stat.mood, default: (0, stat.hexColor)].0 += 1
        }
        return counts.map { MoodStat(mood: $0.key, count: $0.value.0, hexColor: $0.value.1, date: Date()) }
    }
    var dynamicRoutineButton: some View {
        Group {
            if let mood = selectedMood {
                NavigationLink(destination: destinationView(for: mood)) {
                    ActivityCard2(
                        title: "Night routine if you feel \(mood.uppercased())",
                        subtitle: "Custom session for you",
                        icon: moodIcon(for: mood),
                        color: moodHex(for: mood),
                        imageName: "button_pufi"
                    )
                }
            } else {
                ActivityCard2(title: "Select how you feel", subtitle: "to get your night routine", icon: "sparkles", color: "#FFFFFF", imageName: "button_pufi").opacity(0.6)
            }
        }
    }

    @ViewBuilder
    func destinationView(for mood: String) -> some View {
        switch mood {
        case "Calm": CalmSwiftView()
        case "Sleepy": SleepySwiftView()
        case "Bored": BoredSwiftView()
        case "Confused": WorriedStartPage()
        default: Text("Page not found")
        }
    }

    func moodIcon(for mood: String) -> String {
        switch mood {
        case "Calm": return "leaf"
        case "Sleepy": return "moon.stars"
        case "Bored": return "face.smiling"
        case "Confused": return "brain.head.profile"
        default: return "star"
        }
    }

    func moodHex(for mood: String) -> String {
        switch mood {
        case "Calm": return "#8793f5"
        case "Sleepy": return "#A855F7"
        case "Bored": return "#4959cc"
        case "Confused": return "#4232a8"
        default: return "#FFFFFF"
        }
    }

    var chartSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Your Mood Trends:").font(.system(size: 18, weight: .semibold)).foregroundColor(.white)
            ZStack {
                RoundedRectangle(cornerRadius: 24).fill(Color.white.opacity(0.05)).frame(height: 200)
                if monthlyStats.isEmpty {
                    Text("No data yet. Start logging!").foregroundColor(.white.opacity(0.4))
                } else {
                    Chart {
                        ForEach(groupMoods(), id: \.mood) { data in
                            BarMark(x: .value("Mood", data.mood), y: .value("Days", data.count))
                                .foregroundStyle(Color(hex: data.hexColor).gradient)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: monthlyStats.count)
                    .chartYAxis {
                        AxisMarks(position: .leading) { _ in
                            AxisGridLine().foregroundStyle(.white.opacity(0.05))
                            AxisTick().foregroundStyle(.white.opacity(0.2))
                            AxisValueLabel().foregroundStyle(.white.opacity(0.4))
                        }
                    }
                }
            }
        }.padding(.horizontal)
    }

    var pufiDecorations: some View {
        VStack {
            HStack { Spacer(); Image("purple_pufi1").resizable().scaledToFit().frame(width: 160).opacity(0.15).offset(x: 30, y: 120) }
            Spacer()
            HStack { Image("pufi_social").resizable().scaledToFit().frame(width: 150).opacity(0.15).offset(x: -30, y: -60); Spacer() }
        }.ignoresSafeArea()
    }
}
struct StaticBackgroundStarsView: View {
    @State private var starPoints: [CGPoint] = []
    var body: some View {
        ZStack {
            ForEach(0..<starPoints.count, id: \.self) { i in
                Circle().fill(Color.white).frame(width: 1.5).position(starPoints[i]).opacity(0.4)
            }
        }
        .onAppear {
            if starPoints.isEmpty {
                for _ in 0..<60 {
                    starPoints.append(CGPoint(x: .random(in: 0...UIScreen.main.bounds.width), y: .random(in: 0...UIScreen.main.bounds.height)))
                }
            }
        }
    }
}

struct ActivityCard2: View {
    let title: String; let subtitle: String; let icon: String; let color: String; let imageName: String
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(Color(hex: color).opacity(0.15)).frame(width: 40, height: 40)
                Image(systemName: icon).font(.system(size: 14)).foregroundColor(Color(hex: color))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                Text(subtitle).font(.system(size: 12)).foregroundColor(.white.opacity(0.5))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Image(imageName).resizable().scaledToFit().frame(width: 50, height: 50).scaleEffect(1.6)
            Image(systemName: "chevron.right").foregroundColor(.white.opacity(0.3)).font(.system(size: 12, weight: .bold))
        }
        .padding().background(ZStack { Color.white.opacity(0.05); RoundedRectangle(cornerRadius: 22).stroke(Color(hex: color).opacity(0.4), lineWidth: 1.5) })
        .cornerRadius(22)
    }
}
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: //
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: //
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // 
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
