import SwiftUI

struct WordCell: Identifiable {
    let id = UUID()
    var char: String
    var isSelected: Bool = false
    var foundInWordCount: Int = 0
    
    var isFound: Bool {
        foundInWordCount > 0
    }
}

struct TargetWord: Identifiable {
    let id = UUID()
    let text: String
    var isFound: Bool = false
}

class FindWordManager: ObservableObject {
    @Published var grid: [WordCell] = []
    @Published var targetWords: [TargetWord] = []
    @Published var isGameFinished = false
    @Published var currentDifficulty: Difficulty = .easy
    @Published var selectedIndices: [Int] = []
    @Published var gridSize = 6

    @Published var dailyRewardCount: Int = 0
    let maxDailyRewards = 5
    
    private let wordPool = ["PINK", "PUFI", "SWIFT", "GAME", "STAR", "HAPPY", "GLOW", "WORD", "NIGHT", "BLUE", "PAPER", "COOL", "APP", "PLAY", "ARCADE", "LOVE", "HUG", "MOOD", "EMOTION", "LOGIC", "POSITIVE", "SLEEPY"]

    enum Difficulty: String, CaseIterable {
        case easy = "Easy", medium = "Medium", hard = "Hard"
        
        var reward: Int {
            switch self { case .easy: return 5; case .medium: return 10; case .hard: return 20 }
        }
        var wordCount: Int {
            switch self { case .easy: return 3; case .medium: return 4; case .hard: return 6 }
        }
        var gridSize: Int {
            switch self { case .easy: return 10; case .medium: return 10; case .hard: return 12 }
        }
        var allowedDirections: [PlacementDirection] {
            switch self {
            case .easy: return [.horizontal]
            case .medium: return [.horizontal, .vertical]
            case .hard: return [.horizontal, .vertical, .diagonal, .reverseHorizontal, .reverseVertical]
            }
        }
    }

    enum PlacementDirection: CaseIterable {
        case horizontal, vertical, diagonal, reverseHorizontal, reverseVertical
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
        let lastDate = UserDefaults.standard.string(forKey: "lastWordRewardDateString") ?? ""
        let currentCount = UserDefaults.standard.integer(forKey: "dailyWordRewardCount")
        
        if lastDate != todayDateString {
            UserDefaults.standard.set(todayDateString, forKey: "lastWordRewardDateString")
            UserDefaults.standard.set(0, forKey: "dailyWordRewardCount")
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
            UserDefaults.standard.set(dailyRewardCount, forKey: "dailyWordRewardCount")
        }
    }
    
    func setupLevel(difficulty: Difficulty) {
        currentDifficulty = difficulty
        gridSize = difficulty.gridSize
        isGameFinished = false
        selectedIndices = []
        
        let shuffledWords = wordPool.shuffled().prefix(difficulty.wordCount)
        targetWords = shuffledWords.map { TargetWord(text: String($0)) }
        
        var newGrid = (0..<(gridSize * gridSize)).map { _ in WordCell(char: "") }
        
        for target in targetWords {
            var placed = false
            var attempts = 0
            while !placed && attempts < 150 {
                let direction = difficulty.allowedDirections.randomElement()!
                let row = Int.random(in: 0..<gridSize)
                let col = Int.random(in: 0..<gridSize)
                
                if canPlace(word: target.text, row: row, col: col, dir: direction, in: newGrid) {
                    place(word: target.text, row: row, col: col, dir: direction, in: &newGrid)
                    placed = true
                }
                attempts += 1
            }
        }
        
        for i in 0..<newGrid.count {
            if newGrid[i].char.isEmpty {
                newGrid[i].char = String("ABCDEFGHIJKLMNOPQRSTUVWXYZ".randomElement()!)
            }
        }
        grid = newGrid
    }

    private func canPlace(word: String, row: Int, col: Int, dir: PlacementDirection, in currentGrid: [WordCell]) -> Bool {
        for (index, char) in word.enumerated() {
            var r = row
            var c = col
            switch dir {
            case .horizontal: c += index
            case .vertical: r += index
            case .diagonal: r += index; c += index
            case .reverseHorizontal: c -= index
            case .reverseVertical: r -= index
            }
            if r >= gridSize || c >= gridSize || r < 0 || c < 0 { return false }
            let cellChar = currentGrid[r * gridSize + c].char
            if !cellChar.isEmpty && cellChar != String(char) { return false }
        }
        return true
    }

    private func place(word: String, row: Int, col: Int, dir: PlacementDirection, in currentGrid: inout [WordCell]) {
        for (index, char) in word.enumerated() {
            var r = row
            var c = col
            switch dir {
            case .horizontal: c += index
            case .vertical: r += index
            case .diagonal: r += index; c += index
            case .reverseHorizontal: c -= index
            case .reverseVertical: r -= index
            }
            currentGrid[r * gridSize + c].char = String(char)
        }
    }
    
    func selectCell(at index: Int) {
        if selectedIndices.contains(index) {
            if selectedIndices.last == index { selectedIndices.removeLast() }
        } else {
            selectedIndices.append(index)
            checkSelection()
        }
    }
    
    private func checkSelection() {
        let currentString = selectedIndices.map { grid[$0].char }.joined()
        let reversedString = String(currentString.reversed())
        
        if let wordIndex = targetWords.firstIndex(where: { ($0.text == currentString || $0.text == reversedString) && !$0.isFound }) {
            targetWords[wordIndex].isFound = true
            for idx in selectedIndices {
                grid[idx].foundInWordCount += 1
            }
            selectedIndices = []
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            
            if targetWords.allSatisfy({ $0.isFound }) {
                withAnimation(.spring()) { isGameFinished = true }
            }
        } else {
            let maxWordLen = targetWords.map { $0.text.count }.max() ?? 0
            if currentString.count >= maxWordLen {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.selectedIndices = []
                }
            }
        }
    }
}
struct FindWordView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("userCredits") private var userCredits = 100
    @AppStorage("hasSeenWordTutorial") private var hasSeenTutorial = false
    
    @StateObject private var game = FindWordManager()
    @State private var showTutorial = false
    
    var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 6), count: game.gridSize)
    }
    
    var body: some View {
        ZStack {
            Color(red: 13/255, green: 8/255, blue: 26/255).ignoresSafeArea()
            
            VStack(spacing: 20) {
                header
                difficultySelector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(game.targetWords) { word in
                            Text(word.text)
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .strikethrough(word.isFound)
                                .foregroundColor(word.isFound ? .white.opacity(0.3) : ThemeColors.yellow)
                                .padding(.horizontal, 10).padding(.vertical, 6)
                                .background(RoundedRectangle(cornerRadius: 8).fill(word.isFound ? Color.clear : ThemeColors.yellow.opacity(0.1)))
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 40)
                LazyVGrid(columns: columns, spacing: 6) {
                    ForEach(0..<game.grid.count, id: \.self) { i in
                        WordCellItem(
                            cell: game.grid[i],
                            isSelecting: game.selectedIndices.contains(i),
                            gridSize: game.gridSize
                        )
                        .onTapGesture { game.selectCell(at: i) }
                    }
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.02)))
                .padding(.horizontal)
                
                Button(action: { game.selectedIndices = [] }) {
                    Label("Reset Selection", systemImage: "arrow.uturn.backward")
                        .font(.caption.bold())
                        .foregroundColor(ThemeColors.purple)
                }
                
                Spacer()
            }
            .padding(.top)
            .blur(radius: (showTutorial || game.isGameFinished) ? 5 : 0)
            .disabled(showTutorial || game.isGameFinished)
            
            if showTutorial { tutorialPopup.zIndex(10) }
            if game.isGameFinished { winPopup.zIndex(20) }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            game.updateDailyLimitState()
            if !hasSeenTutorial {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.spring()) { showTutorial = true }
                }
            }
        }
    }
    
    // MARK: - SUB VIEWS
    private var header: some View {
        HStack {
            Button(action: { dismiss() }) { Image(systemName: "chevron.left").bold().foregroundColor(.white.opacity(0.6)) }
            Spacer()
            VStack(spacing: 2) {
                Text("Word Find ✨").font(.system(size: 22, weight: .medium, design: .serif)).foregroundColor(.white)
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
            ForEach(FindWordManager.Difficulty.allCases, id: \.self) { level in
                Button(level.rawValue) {
                    withAnimation { game.setupLevel(difficulty: level) }
                }
                .font(.caption.bold())
                .padding(.vertical, 8).padding(.horizontal, 15)
                .background(game.currentDifficulty == level ? ThemeColors.blue : Color.white.opacity(0.1))
                .foregroundColor(game.currentDifficulty == level ? .black : .white)
                .cornerRadius(10)
            }
        }
    }

    private var winPopup: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            VStack(spacing: 25) {
                Text("✨ GENIUS! ✨").font(.system(size: 28, weight: .bold, design: .serif)).foregroundColor(ThemeColors.yellow)
                
                VStack(spacing: 8) {
                    Text("All Words Found!").foregroundColor(.white.opacity(0.7))
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

    private var tutorialPopup: some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()
            VStack(spacing: 25) {
                Text("Word Find Guide").font(.title2.bold()).foregroundColor(.white)
                VStack(alignment: .leading, spacing: 15) {
                    tutorialRow(icon: "arrow.right", text: "You must click letters in order.")
                    tutorialRow(icon: "checkmark.circle", text: "Found letters can be reused for other words!")
                    tutorialRow(icon: "arrow.left", text: "In Hard mode, words can be backwards.")
                    tutorialRow(icon: "grid", text: "Easy mode now has 3 words to find.")
                }
                Button("Got it!") {
                    hasSeenTutorial = true
                    withAnimation { showTutorial = false }
                }
                .padding().frame(maxWidth: .infinity).background(ThemeColors.blue).cornerRadius(10).foregroundColor(.black)
            }
            .padding(30).background(Color(red: 30/255, green: 25/255, blue: 55/255)).cornerRadius(25).padding()
        }
    }
    
    private func tutorialRow(icon: String, text: String) -> some View {
        HStack {
            Image(systemName: icon).foregroundColor(ThemeColors.yellow).frame(width: 30)
            Text(text).font(.subheadline).foregroundColor(.white.opacity(0.8))
        }
    }
}
struct WordCellItem: View {
    let cell: WordCell
    let isSelecting: Bool
    let gridSize: Int
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: gridSize == 8 ? 6 : 10)
                .fill(isSelecting ? ThemeColors.purple.opacity(0.4) : (cell.isFound ? ThemeColors.blue.opacity(0.2) : Color.white.opacity(0.05)))
                .aspectRatio(1, contentMode: .fit)
            
            Text(cell.char)
                .font(.system(gridSize == 8 ? .body : .title3, design: .monospaced).bold())
                .foregroundColor(isSelecting ? ThemeColors.purple : (cell.isFound ? ThemeColors.blue : .white))
        }
        .overlay(
            RoundedRectangle(cornerRadius: gridSize == 8 ? 6 : 10)
                .stroke(isSelecting ? ThemeColors.purple : (cell.isFound ? ThemeColors.blue.opacity(0.5) : Color.clear), lineWidth: 2)
        )
    }
}

struct FindWordView_Previews: PreviewProvider {
    static var previews: some View {
        FindWordView()
    }
}
