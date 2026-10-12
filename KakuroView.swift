import SwiftUI
import UIKit

struct KakuroCell: Identifiable {
    let id = UUID()
    var value: Int = 0
    var targetSumRow: Int? = nil
    var targetSumCol: Int? = nil
    var isWhiteCell: Bool = false
    var solution: Int = 0
}

class KakuroManager: ObservableObject {
    @Published var grid: [KakuroCell] = []
    @Published var isGameFinished = false
    @Published var showWrongAnswerAlert = false
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
        let lastDate = UserDefaults.standard.string(forKey: "lastRewardDateString") ?? ""
        let currentCount = UserDefaults.standard.integer(forKey: "dailyRewardCount")
        
        if lastDate != todayDateString {
            UserDefaults.standard.set(todayDateString, forKey: "lastRewardDateString")
            UserDefaults.standard.set(0, forKey: "dailyRewardCount")
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
            UserDefaults.standard.set(dailyRewardCount, forKey: "dailyRewardCount")
        }
    }
    
    func setupLevel(difficulty: Difficulty) {
        currentDifficulty = difficulty
        isGameFinished = false
        showWrongAnswerAlert = false
        
        let whiteIndices: [Int]
        switch difficulty {
        case .hard: whiteIndices = [6,7,8,11,12,13,16,17,18,21,22,23]
        case .medium: whiteIndices = [6,7,11,12,16,17,21,22]
        case .easy: whiteIndices = [6,7,11,12]
        }
        
        var solutions = [Int: Int]()
        var success = false
        
        while !success {
            solutions.removeAll()
            success = fillValidSolutions(indexPos: 0, whiteIndices: whiteIndices, solutions: &solutions)
        }
        
        var newGrid: [KakuroCell] = []
        for i in 0..<25 {
            if whiteIndices.contains(i) {
                newGrid.append(KakuroCell(value: 0, isWhiteCell: true, solution: solutions[i] ?? 1))
            } else {
                newGrid.append(KakuroCell(isWhiteCell: false))
            }
        }
        
        for i in 0..<25 {
            if !newGrid[i].isWhiteCell {
                if i % 5 < 4 && newGrid[i+1].isWhiteCell {
                    var sum = 0
                    var next = i + 1
                    while next % 5 != 0 && newGrid[next].isWhiteCell {
                        sum += newGrid[next].solution
                        next += 1
                    }
                    newGrid[i].targetSumRow = sum
                }
                if i < 20 && newGrid[i+5].isWhiteCell {
                    var sum = 0
                    var next = i + 5
                    while next < 25 && newGrid[next].isWhiteCell {
                        sum += newGrid[next].solution
                        next += 5
                    }
                    newGrid[i].targetSumCol = sum
                }
            }
        }
        
        grid = newGrid
    }
    
    private func fillValidSolutions(indexPos: Int, whiteIndices: [Int], solutions: inout [Int: Int]) -> Bool {
        if indexPos == whiteIndices.count { return true }
        let gridIndex = whiteIndices[indexPos]
        
        var availableNumbers = Set(1...9)
        
        for prevPos in 0..<indexPos {
            let prevIndex = whiteIndices[prevPos]
            if prevIndex / 5 == gridIndex / 5 {
                if let val = solutions[prevIndex] { availableNumbers.remove(val) }
            }
            if prevIndex % 5 == gridIndex % 5 {
                if let val = solutions[prevIndex] { availableNumbers.remove(val) }
            }
        }
        
        for num in availableNumbers.shuffled() {
            solutions[gridIndex] = num
            if fillValidSolutions(indexPos: indexPos + 1, whiteIndices: whiteIndices, solutions: &solutions) {
                return true
            }
        }
        return false
    }
    
    func updateCellValue(at index: Int, value: Int) {
        guard grid.indices.contains(index) else { return }
        grid[index].value = value
        showWrongAnswerAlert = false
    }
    
    func verifyUserAnswers() {
        let whiteCells = grid.filter { $0.isWhiteCell }
        if whiteCells.contains(where: { $0.value == 0 }) {
            triggerFailure()
            return
        }
        
        for i in 0..<25 {
            if let targetRow = grid[i].targetSumRow {
                var numbers: [Int] = []
                var currentSum = 0
                var next = i + 1
                while next % 5 != 0 && grid[next].isWhiteCell {
                    let val = grid[next].value
                    numbers.append(val)
                    currentSum += val
                    next += 1
                }
                if currentSum != targetRow || Set(numbers).count != numbers.count {
                    triggerFailure()
                    return
                }
            }
            
            if let targetCol = grid[i].targetSumCol {
                var numbers: [Int] = []
                var currentSum = 0
                var next = i + 5
                while next < 25 && grid[next].isWhiteCell {
                    let val = grid[next].value
                    numbers.append(val)
                    currentSum += val
                    next += 5
                }
                if currentSum != targetCol || Set(numbers).count != numbers.count {
                    triggerFailure()
                    return
                }
            }
        }
        
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        isGameFinished = true
    }
    
    private func triggerFailure() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        withAnimation {
            showWrongAnswerAlert = true
        }
    }
}

struct KakuroView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("userCredits") private var userCredits = 100
    @AppStorage("hasSeenKakuroTutorial") private var hasSeenTutorial = false
    
    @StateObject private var game = KakuroManager()
    @State private var selectedIndex: Int? = nil
    @State private var showTutorial = false
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 5)
    
    var body: some View {
        ZStack {
            Color(red: 13/255, green: 8/255, blue: 26/255).ignoresSafeArea()
            
            VStack(spacing: 20) {
                header
                difficultySelector
                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(0..<game.grid.count, id: \.self) { i in
                        KakuroCellItem(cell: game.grid[i], isSelected: selectedIndex == i)
                            .onTapGesture {
                                if !game.isGameFinished && game.grid[i].isWhiteCell {
                                    selectedIndex = i
                                }
                            }
                    }
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 15).fill(Color.white.opacity(0.02)))
                .overlay(RoundedRectangle(cornerRadius: 15).stroke(ThemeColors.blue.opacity(0.2), lineWidth: 1))
                .padding(.horizontal)
                
                if game.showWrongAnswerAlert {
                    Text("Try again... ❌ Sums are incorrect or numbers repeat!")
                        .font(.subheadline.bold())
                        .foregroundColor(.red)
                        .padding(.vertical, 4)
                        .transition(.opacity)
                }
                
                Spacer()
                numberPad.padding(.bottom, 20)
            }
            .padding(.top)
            .blur(radius: (showTutorial || game.isGameFinished) ? 5 : 0)
            .disabled(showTutorial || game.isGameFinished)
            
            if showTutorial {
                tutorialPopup
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(10)
            }
            
            if game.isGameFinished {
                winPopup
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(20)
            }
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
            Button(action: { dismiss() }) { Image(systemName: "chevron.left").bold().foregroundColor(.white.opacity(0.6)) }
            Spacer()
            VStack(spacing: 2) {
                Text("Kakuro✨").font(.system(size: 22, weight: .medium, design: .serif)).foregroundColor(.white)
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
                Button(action: {
                    selectedIndex = nil
                    game.setupLevel(difficulty: game.currentDifficulty)
                }) {
                    Image(systemName: "arrow.counterclockwise").foregroundColor(ThemeColors.purple)
                }
            }
        }.padding(.horizontal)
    }

    private var difficultySelector: some View {
        HStack(spacing: 12) {
            ForEach(KakuroManager.Difficulty.allCases, id: \.self) { level in
                Button(level.rawValue) {
                    selectedIndex = nil
                    game.setupLevel(difficulty: level)
                }
                .font(.caption.bold())
                .padding(.vertical, 8).padding(.horizontal, 15)
                .background(game.currentDifficulty == level ? ThemeColors.blue : Color.white.opacity(0.1))
                .foregroundColor(game.currentDifficulty == level ? .black : .white)
                .cornerRadius(10)
            }
        }
    }

    private var numberPad: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { n in padButton(n) }
            }
            HStack(spacing: 8) {
                ForEach(6...9, id: \.self) { n in padButton(n) }
                
                Button(action: { if let idx = selectedIndex { game.updateCellValue(at: idx, value: 0) } }) {
                    Image(systemName: "eraser.fill").frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.white.opacity(0.1)).cornerRadius(12).foregroundColor(.white)
                }
            }
            
            Button(action: { game.verifyUserAnswers() }) {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                    Text("Check Puzzle")
                }
                .font(.headline.bold())
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(ThemeColors.green)
                .foregroundColor(.black)
                .cornerRadius(14)
                .shadow(color: ThemeColors.green.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.top, 5)
            
        }.padding(.horizontal, 25)
    }

    private func padButton(_ n: Int) -> some View {
        Button(action: {
            if let idx = selectedIndex {
                game.updateCellValue(at: idx, value: n)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }) {
            Text("\(n)").font(.title2.bold()).frame(maxWidth: .infinity, minHeight: 50)
                .background(ThemeColors.blue.opacity(0.2)).cornerRadius(12).foregroundColor(ThemeColors.blue)
        }
    }

    private var winPopup: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            VStack(spacing: 25) {
                Text("✨ PERFECT! ✨").font(.system(size: 28, weight: .bold, design: .serif)).foregroundColor(ThemeColors.yellow)
                
                VStack(spacing: 8) {
                    Text("Puzzle Solved!").foregroundColor(.white.opacity(0.7))
                    if game.dailyRewardCount < game.maxDailyRewards {
                        Text("+\(game.currentDifficulty.reward) Credits").font(.title2.bold()).foregroundColor(ThemeColors.blue)
                    } else {
                        Text("Daily reward limit reached (5/5).\nNo credits awarded.")
                            .font(.subheadline.bold())
                            .foregroundColor(.orange)
                            .multilineTextAlignment(.center)
                    }
                }
                
                Button(game.dailyRewardCount < game.maxDailyRewards ? "Collect & New Game" : "Play New Game") {
                    if game.isGameFinished {
                        if game.canEarnReward {
                            userCredits += game.currentDifficulty.reward
                            game.incrementDailyReward()
                        }
                        
                        selectedIndex = nil
                        game.isGameFinished = false
                        game.setupLevel(difficulty: game.currentDifficulty)
                    }
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
                VStack(spacing: 10) {
                    Image(systemName: "sparkles").font(.system(size: 40)).foregroundColor(ThemeColors.yellow)
                    Text("How to Play Kakuro").font(.system(size: 24, weight: .light, design: .serif)).foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 18) {
                    tutorialRow(icon: "plus.circle", text: "Fill white cells so their sum equals the number in the dark triangle.")
                    tutorialRow(icon: "number.square", text: "Blue numbers indicate column sums, Green indicates row sums.")
                    tutorialRow(icon: "exclamationmark.triangle", text: "Numbers 1-9 only. You cannot repeat a number in the same sum block.")
                }
                Button("Got it!") {
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
}
struct KakuroCellItem: View {
    let cell: KakuroCell
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(cell.isWhiteCell ? (isSelected ? ThemeColors.purple.opacity(0.3) : Color.white.opacity(0.05)) : Color.black.opacity(0.4))
                .aspectRatio(1, contentMode: .fit)
            
            if cell.isWhiteCell {
                if cell.value != 0 {
                    Text("\(cell.value)").font(.system(.title3, design: .rounded).bold()).foregroundColor(ThemeColors.yellow)
                }
            } else {
                GeometryReader { geo in
                    Path { path in
                        path.move(to: .zero)
                        path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height))
                    }.stroke(Color.white.opacity(0.1), lineWidth: 1)
                    
                    if let r = cell.targetSumRow {
                        Text("\(r)").font(.system(size: 10, weight: .bold)).foregroundColor(ThemeColors.green)
                            .position(x: geo.size.width * 0.75, y: geo.size.height * 0.25)
                    }
                    if let c = cell.targetSumCol {
                        Text("\(c)").font(.system(size: 10, weight: .bold)).foregroundColor(ThemeColors.blue)
                            .position(x: geo.size.width * 0.25, y: geo.size.height * 0.75)
                    }
                }
            }
        }
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(isSelected ? ThemeColors.blue : Color.clear, lineWidth: 2))
    }
}
