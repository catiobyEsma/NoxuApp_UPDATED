import SwiftUI

struct NonogramCell: Identifiable {
    let id = UUID()
    var isFilled: Bool = false
    var isMarkedEmpty: Bool = false
    var solution: Bool = false
}

class NonogramManager: ObservableObject {
    @Published var grid: [NonogramCell] = []
    @Published var rowHints: [[Int]] = []
    @Published var colHints: [[Int]] = []
    @Published var isGameFinished = false
    @Published var currentDifficulty: Difficulty = .easy

    @Published var dailyRewardCount: Int = 0
    let maxDailyRewards = 5
    
    enum Difficulty: String, CaseIterable {
        case easy = "Easy", medium = "Medium", hard = "Hard"
        var reward: Int {
            switch self { case .easy: return 5; case .medium: return 10; case .hard: return 15 }
        }
    }

    private var todayDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    init() {
        updateDailyLimitState()
        setupLevel(difficulty: .easy)
    }

    func updateDailyLimitState() {
        let lastDate = UserDefaults.standard.string(forKey: "lastNonogramRewardDateString") ?? ""
        let currentCount = UserDefaults.standard.integer(forKey: "dailyNonogramRewardCount")
        
        if lastDate != todayDateString {
            UserDefaults.standard.set(todayDateString, forKey: "lastNonogramRewardDateString")
            UserDefaults.standard.set(0, forKey: "dailyNonogramRewardCount")
            self.dailyRewardCount = 0
        } else {

            self.dailyRewardCount = currentCount
        }
    }

    var canEarnReward: Bool {
        updateDailyLimitState()
        return dailyRewardCount < maxDailyRewards
    }
    func incrementDailyReward() {
        updateDailyLimitState()
        if dailyRewardCount < maxDailyRewards {
            dailyRewardCount += 1
            UserDefaults.standard.set(dailyRewardCount, forKey: "dailyNonogramRewardCount")
        }
    }
    
    func setupLevel(difficulty: Difficulty) {
        currentDifficulty = difficulty
        isGameFinished = false
        var newGrid: [NonogramCell] = []
        let fillProbability = (difficulty == .hard) ? 0.6 : 0.4
        
        for _ in 0..<25 {
            let isSolutionFilled = Double.random(in: 0...1) < fillProbability
            newGrid.append(NonogramCell(solution: isSolutionFilled))
        }
        
        grid = newGrid
        calculateHints()
    }
    
    private func calculateHints() {
        rowHints = []
        colHints = []
        for r in 0..<5 {
            var hints: [Int] = []
            var count = 0
            for c in 0..<5 {
                if grid[r * 5 + c].solution {
                    count += 1
                } else if count > 0 {
                    hints.append(count)
                    count = 0
                }
            }
            if count > 0 { hints.append(count) }
            rowHints.append(hints.isEmpty ? [0] : hints)
        }
        for c in 0..<5 {
            var hints: [Int] = []
            var count = 0
            for r in 0..<5 {
                if grid[r * 5 + c].solution {
                    count += 1
                } else if count > 0 {
                    hints.append(count)
                    count = 0
                }
            }
            if count > 0 { hints.append(count) }
            colHints.append(hints.isEmpty ? [0] : hints)
        }
    }
    
    func toggleCell(at index: Int) {
        grid[index].isFilled.toggle()
        grid[index].isMarkedEmpty = false
        checkWin()
    }
    
    func markEmpty(at index: Int) {
        grid[index].isMarkedEmpty.toggle()
        grid[index].isFilled = false
        checkWin()
    }
    
    private func checkWin() {
        let isCorrect = grid.allSatisfy { cell in
            cell.isFilled == cell.solution
        }
        if isCorrect {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                isGameFinished = true
            }
        }
    }
}

struct NonogramView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("userCredits") private var userCredits = 100
    @AppStorage("hasSeenNonogramTutorial") private var hasSeenTutorial = false
    
    @StateObject private var game = NonogramManager()
    @State private var showTutorial = false
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 5)
    
    var body: some View {
        ZStack {
            Color(red: 13/255, green: 8/255, blue: 26/255).ignoresSafeArea()
            
            VStack(spacing: 20) {
                header
                difficultySelector
                
 
                VStack(spacing: 4) {
      
                    HStack(spacing: 4) {
                        Spacer().frame(width: 50)
                        ForEach(0..<5) { c in
                            VStack {
                                ForEach(game.colHints[c], id: \.self) { hint in
                                    Text("\(hint)").font(.caption2.bold()).foregroundColor(ThemeColors.blue)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    
                    ForEach(0..<5) { r in
                        HStack(spacing: 4) {
              
                            HStack {
                                Spacer()
                                ForEach(game.rowHints[r], id: \.self) { hint in
                                    Text("\(hint)").font(.caption2.bold()).foregroundColor(ThemeColors.purple)
                                }
                            }
                            .frame(width: 50)
                            
                            ForEach(0..<5) { c in
                                let index = r * 5 + c
                                NonogramCellItem(cell: game.grid[index])
                                    .onTapGesture { game.toggleCell(at: index) }
                                    .onLongPressGesture(minimumDuration: 0.2) {
                                        game.markEmpty(at: index)
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    }
                            }
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 15).fill(Color.white.opacity(0.02)))
                .padding(.horizontal)
                
                Text("Tap to fill, Long press to mark 'X'")
                    .font(.caption).foregroundColor(.white.opacity(0.4))
                
                Spacer()
            }
            .padding(.top)
            .blur(radius: (showTutorial || game.isGameFinished) ? 5 : 0)
            .disabled(showTutorial || game.isGameFinished)
            
            if showTutorial { tutorialPopup.zIndex(10) }
            if game.isGameFinished { winPopup.zIndex(20) }
        }
        .onAppear {
            game.updateDailyLimitState()
            if !hasSeenTutorial {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.spring()) { showTutorial = true }
                }
            }
        }
        .navigationBarHidden(true)
    }
    private var header: some View {
        HStack {
            Button(action: { dismiss() }) {  Image(systemName: "chevron.left")
                    .font(.title2.bold())
                    .foregroundColor(.white.opacity(0.6))
            }
            Spacer()
            VStack(spacing: 2) {
                Text("Nonogram✨").font(.system(size: 22, weight: .medium, design: .serif)).foregroundColor(.white)
                HStack(spacing: 8) {
                    Text("Credits: \(userCredits)").foregroundColor(ThemeColors.yellow)
                    Text("•")
                    Text("Daily: \(game.dailyRewardCount)/5 🏆")
                        .foregroundColor(game.dailyRewardCount >= 5 ? .red : ThemeColors.blue)
                }
                .font(.caption.bold())
            }
            Spacer()
            HStack(spacing: 15) {
                Button(action: { withAnimation(.spring()) { showTutorial = true } }) {
                    Image(systemName: "questionmark.circle").foregroundColor(ThemeColors.blue)
                }
                Button(action: { game.setupLevel(difficulty: game.currentDifficulty) }) {
                    Image(systemName: "arrow.counterclockwise").foregroundColor(ThemeColors.purple)
                }
            }
        }.padding(.horizontal)
    }
    
    private var difficultySelector: some View {
        HStack(spacing: 12) {
            ForEach(NonogramManager.Difficulty.allCases, id: \.self) { level in
                Button(level.rawValue) { game.setupLevel(difficulty: level) }
                    .font(.caption.bold())
                    .padding(.vertical, 8).padding(.horizontal, 15)
                    .background(game.currentDifficulty == level ? ThemeColors.blue : Color.white.opacity(0.1))
                    .foregroundColor(game.currentDifficulty == level ? .black : .white)
                    .cornerRadius(10)
            }
        }
    }
    
    private var tutorialPopup: some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()
            VStack(spacing: 25) {
                VStack(spacing: 10) {
                    Image(systemName: "square.grid.3x3.fill").font(.system(size: 40)).foregroundColor(ThemeColors.yellow)
                    Text("How to Play Nonogram").font(.system(size: 24, weight: .light, design: .serif)).foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 18) {
                    tutorialRow(icon: "list.number", text: "Numbers indicate how many consecutive filled squares are in that row/column.")
                    tutorialRow(icon: "hand.tap", text: "Tap a square to fill it and reveal the hidden pixel art.")
                    tutorialRow(icon: "xmark.circle", text: "Long press to mark a cell with an 'X' if you're sure it's empty.")
                    tutorialRow(icon: "gift", text: "Complete the pattern to earn: Easy (5), Medium (10), Hard (15)!")
                }
                Button("Start Painting!") {
                    hasSeenTutorial = true
                    withAnimation { showTutorial = false }
                }
                .font(.headline).foregroundColor(.black).frame(maxWidth: .infinity).padding(.vertical, 16)
                .background(Capsule().fill(ThemeColors.blue))
            }
            .padding(30).background(RoundedRectangle(cornerRadius: 30).fill(Color(red: 30/255, green: 25/255, blue: 55/255)))
            .padding(.horizontal, 25)
        }
    }
    
    private func tutorialRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon).foregroundColor(ThemeColors.purple).frame(width: 25)
            Text(text).font(.system(size: 14)).foregroundColor(.white.opacity(0.7)).lineSpacing(4)
        }
    }

    private var winPopup: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            VStack(spacing: 25) {
                Text("✨ ARTIST! ✨").font(.system(size: 28, weight: .bold, design: .serif)).foregroundColor(ThemeColors.yellow)
                VStack(spacing: 8) {
                    Text("Pattern Completed!").foregroundColor(.white.opacity(0.7))
                    
                    if game.dailyRewardCount < game.maxDailyRewards {
                        Text("+\(game.currentDifficulty.reward) Credits").font(.title2.bold()).foregroundColor(ThemeColors.blue)
                    } else {
                        Text("Daily reward limit reached (5/5).\nNo credits awarded.")
                            .font(.subheadline.bold())
                            .foregroundColor(.orange)
                            .multilineTextAlignment(.center)
                    }
                }
                
                Button(game.dailyRewardCount < game.maxDailyRewards ? "Collect & Replay" : "Play New Game") {
                    if game.canEarnReward {
                        userCredits += game.currentDifficulty.reward
                        game.incrementDailyReward()
                    }
                    game.setupLevel(difficulty: game.currentDifficulty)
                }
                .font(.headline).padding(.vertical, 14).padding(.horizontal, 30)
                .background(ThemeColors.blue).cornerRadius(15).foregroundColor(.black)
            }
            .padding(40).background(Color(red: 25/255, green: 20/255, blue: 50/255)).cornerRadius(30)
        }
    }
}

struct NonogramCellItem: View {
    let cell: NonogramCell
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(cell.isFilled ? ThemeColors.blue : Color.white.opacity(0.05))
                .aspectRatio(1, contentMode: .fit)
            
            if cell.isMarkedEmpty {
                Image(systemName: "xmark").font(.system(size: 12, weight: .bold)).foregroundColor(ThemeColors.purple.opacity(0.6))
            }
        }
        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }
}

struct NonogramView_Previews: PreviewProvider {
    static var previews: some View {
        let _ = UserDefaults.standard.set(100, forKey: "userCredits")
        NonogramView()
            .preferredColorScheme(.dark)
    }
}
