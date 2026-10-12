import SwiftUI

struct SudokuCell: Identifiable {
    let id = UUID()
    var value: Int
    var isFixed: Bool
    var isError: Bool = false
}
class SudokuManager: ObservableObject {
    @Published var grid: [SudokuCell] = []
    @Published var isGameFinished = false
    @Published var dailyRewardCount: Int = 0
    let maxDailyRewards = 5
    
    enum Difficulty: String, CaseIterable {
        case easy = "Easy", medium = "Medium", hard = "Hard"
        var emptyCells: Int {
            switch self { case .easy: return 30; case .medium: return 45; case .hard: return 60 }
        }
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
    }
    func updateDailyLimitState() {
        let lastDate = UserDefaults.standard.string(forKey: "lastSudokuRewardDateString") ?? ""
        let currentCount = UserDefaults.standard.integer(forKey: "dailySudokuRewardCount")
        
        if lastDate != todayDateString {
            UserDefaults.standard.set(todayDateString, forKey: "lastSudokuRewardDateString")
            UserDefaults.standard.set(0, forKey: "dailySudokuRewardCount")
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
            UserDefaults.standard.set(dailyRewardCount, forKey: "dailySudokuRewardCount")
        }
    }

    func startNewGame(difficulty: Difficulty) {
        var baseGrid = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        _ = fillBoard(&baseGrid)
        
        var playableGrid = baseGrid
        var count = difficulty.emptyCells
        while count > 0 {
            let r = Int.random(in: 0...8), c = Int.random(in: 0...8)
            if playableGrid[r][c] != 0 { playableGrid[r][c] = 0; count -= 1 }
        }
        
        var newGrid: [SudokuCell] = []
        for r in 0..<9 {
            for c in 0..<9 {
                let val = playableGrid[r][c]
                newGrid.append(SudokuCell(value: val, isFixed: val != 0))
            }
        }
        grid = newGrid
        isGameFinished = false
    }

    func checkErrors(onWin: @escaping () -> Void) {
        var hasEmpty = false
        for i in 0..<81 {
            if grid[i].value == 0 { grid[i].isError = false; hasEmpty = true; continue }
            let r = i / 9, c = i % 9
            let val = grid[i].value
            let hasRowErr = (0..<9).contains { col in col != c && grid[r * 9 + col].value == val }
            let hasColErr = (0..<9).contains { row in row != r && grid[row * 9 + c].value == val }
            let startR = (r / 3) * 3, startC = (c / 3) * 3
            var hasBlockErr = false
            for br in startR..<startR+3 {
                for bc in startC..<startC+3 {
                    let index = br * 9 + bc
                    if index != i && grid[index].value == val { hasBlockErr = true }
                }
            }
            grid[i].isError = hasRowErr || hasColErr || hasBlockErr
        }
        
        if !hasEmpty && grid.allSatisfy({ !$0.isError }) {
            if !isGameFinished {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    isGameFinished = true
                }
                onWin()
            }
        }
    }

    private func fillBoard(_ board: inout [[Int]]) -> Bool {
        for row in 0..<9 {
            for col in 0..<9 {
                if board[row][col] == 0 {
                    for num in (1...9).shuffled() {
                        if isValidMove(board, row, col, num) {
                            board[row][col] = num
                            if fillBoard(&board) { return true }
                            board[row][col] = 0
                        }
                    }
                    return false
                }
            }
        }
        return true
    }

    private func isValidMove(_ board: [[Int]], _ row: Int, _ col: Int, _ num: Int) -> Bool {
        for i in 0..<9 { if board[row][i] == num || board[i][col] == num { return false } }
        let sR = (row / 3) * 3, sC = (col / 3) * 3
        for i in 0..<3 { for j in 0..<3 { if board[sR+i][sC+j] == num { return false } } }
        return true
    }
}
struct SudokuView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("userCredits") private var userCredits = 100
    @AppStorage("hasSeenSudokuTutorial") private var hasSeenTutorial = false
    
    @StateObject private var game = SudokuManager()
    @State private var selectedIndex: Int? = nil
    @State private var difficulty: SudokuManager.Difficulty = .easy
    @State private var showTutorial = false

    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 9)

    var body: some View {
        ZStack {
            Color(red: 13/255, green: 8/255, blue: 26/255).ignoresSafeArea()
            
            VStack(spacing: 25) {
                header
                difficultySelector
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(0..<81, id: \.self) { i in
                        SudokuCellItem(
                            cell: game.grid.isEmpty ? SudokuCell(value: 0, isFixed: false) : game.grid[i],
                            isSelected: selectedIndex == i,
                            index: i
                        )
                        .onTapGesture { selectedIndex = i }
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                .background(Color.white.opacity(0.02))
                .border(ThemeColors.blue.opacity(0.4), width: 2)
                .padding(.horizontal)
                
                numberPad
                Spacer()
            }
            .padding(.top)
            .blur(radius: (showTutorial || game.isGameFinished) ? 5 : 0)
            .disabled(showTutorial || game.isGameFinished)
            if showTutorial {
                tutorialPopup
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .scale(scale: 1.1).combined(with: .opacity)
                    ))
                    .zIndex(10)
            }

            if game.isGameFinished {
                winPopup
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                    .zIndex(20)
            }
        }
        .onAppear {
            game.updateDailyLimitState()
            game.startNewGame(difficulty: difficulty)
            if !hasSeenTutorial {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        showTutorial = true
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.title2.bold())
                    .foregroundColor(.white.opacity(0.6))
            }
            Spacer()
            VStack(spacing: 2) {
                Text("Pufi Sudoku").font(.pufiSerif(size: 22)).foregroundColor(.white)
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
                Button(action: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        showTutorial = true
                    }
                }) {
                    Image(systemName: "questionmark.circle").foregroundColor(ThemeColors.blue)
                }
                Button(action: { game.startNewGame(difficulty: difficulty) }) {
                    Image(systemName: "arrow.counterclockwise").foregroundColor(ThemeColors.purple)
                }
            }
        }.padding(.horizontal)
    }

    private var difficultySelector: some View {
        HStack(spacing: 12) {
            ForEach(SudokuManager.Difficulty.allCases, id: \.self) { level in
                Button(level.rawValue) {
                    difficulty = level
                    game.startNewGame(difficulty: level)
                }
                .font(.caption.bold())
                .padding(.vertical, 8).padding(.horizontal, 12)
                .background(difficulty == level ? ThemeColors.blue : Color.white.opacity(0.1))
                .foregroundColor(difficulty == level ? .black : .white)
                .cornerRadius(10)
            }
        }
    }

    private var numberPad: some View {
        VStack(spacing: 10) {
            HStack {
                ForEach(1...5, id: \.self) { n in numBtn(n) }
            }
            HStack {
                ForEach(6...9, id: \.self) { n in numBtn(n) }
                Button(action: { play(0) }) {
                    Image(systemName: "eraser.fill")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12).foregroundColor(.white)
                }
            }
        }.padding(.horizontal, 25)
    }

    private func numBtn(_ n: Int) -> some View {
        Button("\(n)") { play(n) }
            .font(.title2.bold())
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(ThemeColors.blue.opacity(0.2))
            .cornerRadius(12).foregroundColor(ThemeColors.blue)
    }

    private func play(_ n: Int) {
        guard let idx = selectedIndex, !game.grid[idx].isFixed else { return }
        game.grid[idx].value = n
        
        game.checkErrors {
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    private var tutorialPopup: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showTutorial = false
                    }
                }
            
            VStack(spacing: 25) {
                VStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 40))
                        .foregroundColor(ThemeColors.yellow)
                    Text("How to Play")
                        .font(.system(size: 28, weight: .light, design: .serif))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    tutorialRow(icon: "1.circle", text: "Fill each 9x9 grid so that every row, column, and 3x3 box contains all digits from 1 to 9.")
                    tutorialRow(icon: "hand.tap", text: "Tap a cell and select a number from the bottom pad to place it.")
                    tutorialRow(icon: "paintpalette", text: "Fixed numbers are white, your entries are yellow, and errors will glow in red.")
                    tutorialRow(icon: "gift", text: "Complete the puzzle to earn credits: Easy (5), Medium (10), Hard (15)!")
                }
                .padding(.horizontal, 5)
                
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
                        hasSeenTutorial = true
                        showTutorial = false
                    }
                }) {
                    Text("Got it!")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Capsule().fill(ThemeColors.blue))
                }
            }
            .padding(35)
            .background(RoundedRectangle(cornerRadius: 30).fill(Color(red: 30/255, green: 25/255, blue: 55/255)))
            .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.white.opacity(0.1), lineWidth: 1))
            .padding(.horizontal, 25)
        }
    }

    private func tutorialRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 18) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(ThemeColors.purple.opacity(0.8))
                .frame(width: 30)
            Text(text)
                .font(.system(size: 15, weight: .regular))
                .lineSpacing(4)
                .foregroundColor(.white.opacity(0.7))
        }
    }
    private var winPopup: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            VStack(spacing: 25) {
                Text("✨ PERFECT! ✨")
                    .font(.pufiSerif(size: 32))
                    .foregroundColor(ThemeColors.yellow)
                
                VStack(spacing: 8) {
                    Text("Puzzle Solved!")
                        .foregroundColor(.white.opacity(0.7))
                    if game.dailyRewardCount < game.maxDailyRewards {
                        Text("+\(difficulty.reward) Credits").font(.title2.bold()).foregroundColor(ThemeColors.blue)
                    } else {
                        Text("Daily reward limit reached (5/5).\nNo credits awarded.")
                            .font(.subheadline.bold())
                            .foregroundColor(.orange)
                            .multilineTextAlignment(.center)
                    }
                }
                
                Button(action: {
                    if game.canEarnReward {
                        userCredits += difficulty.reward
                        game.incrementDailyReward()
                    }
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        game.startNewGame(difficulty: difficulty)
                    }
                }) {
                    Text(game.dailyRewardCount < game.maxDailyRewards ? "Collect & Replay" : "Play New Game")
                        .font(.headline)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 30)
                        .background(ThemeColors.blue)
                        .cornerRadius(15)
                        .foregroundColor(.black)
                }
            }
            .padding(40)
            .background(Color(red: 25/255, green: 20/255, blue: 50/255))
            .cornerRadius(30)
            .overlay(RoundedRectangle(cornerRadius: 30).stroke(ThemeColors.blue.opacity(0.3), lineWidth: 2))
        }
    }
}
struct SudokuCellItem: View {
    let cell: SudokuCell
    let isSelected: Bool
    let index: Int

    var body: some View {
        let r = index / 9
        let c = index % 9
        ZStack {
            Rectangle().fill(isSelected ? ThemeColors.purple.opacity(0.3) : Color.white.opacity(0.01))
            Rectangle().stroke(Color.white.opacity(0.08), lineWidth: 0.5)
            if c % 3 == 0 && c != 0 {
                HStack { Rectangle().fill(ThemeColors.blue.opacity(0.4)).frame(width: 2); Spacer() }
            }
            if r % 3 == 0 && r != 0 {
                VStack { Rectangle().fill(ThemeColors.blue.opacity(0.4)).frame(height: 2); Spacer() }
            }
            if cell.value != 0 {
                Text("\(cell.value)")
                    .font(.system(.title3, design: .rounded).bold())
                    .foregroundColor(cell.isError ? .red : (cell.isFixed ? .white : ThemeColors.yellow))
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .contentShape(Rectangle())
    }
}
extension Font {
    static func pufiSerif(size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .serif)
    }
}

struct ThemeColors {
    static let yellow = Color(red: 249/255, green: 226/255, blue: 175/255)
    static let purple = Color(red: 203/255, green: 170/255, blue: 203/255)
    static let blue = Color(red: 162/255, green: 194/255, blue: 225/255)
    static let green = Color(red: 107.0 / 255.0, green: 176.0 / 255.0, blue: 157.0 / 255.0)
}
