import SwiftUI

struct ArcadeView: View {
    @Environment(\.dismiss) var dismiss

    @AppStorage("userCredits") private var userCredits = 100
    @AppStorage("cardBalance") private var cardBalance = 0
    @AppStorage("useCardForGames") private var useCardForGames = false

    @AppStorage("rental_Sudoku") private var rentalSudoku: Double = 0
    @AppStorage("rental_Kakuro") private var rentalKakuro: Double = 0
    @AppStorage("rental_Nonogram") private var rentalNonogram: Double = 0
    @AppStorage("rental_FindWord") private var rentalFindWord: Double = 0
    
    @State private var selectedGameID: String? = nil
    
    let games = [
        ("Sudoku", "Classic Number Logic", "grid", "#F9E2AF", "Sudoku"),
        ("Kakuro", "Cross Sums Puzzle", "plus.forwardslash.minus", "#CBAACB", "Kakuro"),
        ("Nonogram", "Picture Cross", "paintpalette", "#A2C2E1", "Nonogram"),
        ("Find Word", "Word Search Journey", "text.magnifyingglass", "#FFFFFF", "FindWord")
    ]
    
    var body: some View {

        NavigationStack {
            ZStack {
                Color(red: 13/255, green: 8/255, blue: 26/255).ignoresSafeArea()
                StaticBackgroundStarsView()
                
                VStack(spacing: 0) {
                    headerView
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            VStack(spacing: 8) {
                                Text("Pufi Arcade")
                                    .font(.system(size: 32, weight: .bold, design: .serif))
                                    .foregroundColor(.white)
                                Text(useCardForGames ? "Rent with 20% Card Discount" : "Rent to play for 1 week")
                                    .font(.caption)
                                    .foregroundColor(useCardForGames ? Color(hex: "#ABDEE6") : .white.opacity(0.5))
                            }
                            .padding(.vertical, 20)
                            
                            ForEach(games, id: \.0) { title, subtitle, icon, color, id in
                                ArcadeGameCard(
                                    title: title,
                                    subtitle: subtitle,
                                    icon: icon,
                                    color: Color(hex: color),
                                    id: id,
                                    rentalTime: getBinding(for: id),
                                    onGameStart: { selectedGameID = id }
                                )
                            }
                        }
                        .padding(.horizontal, 25)
                    }
                }
            }
            .navigationDestination(item: $selectedGameID) { id in
                switch id {
                case "Sudoku": SudokuView()
                case "Kakuro": KakuroView()
                case "Nonogram": NonogramView()
                case "FindWord": FindWordView()
                default: EmptyView()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func getBinding(for id: String) -> Binding<Double> {
        switch id {
        case "Sudoku": return $rentalSudoku
        case "Kakuro": return $rentalKakuro
        case "Nonogram": return $rentalNonogram
        default: return $rentalFindWord
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    
                }
                .font(.headline).foregroundColor(.white.opacity(0.6))
            }
            Spacer()
            HStack(spacing: 6) {
                Text("\(userCredits)").fontWeight(.bold)
                Image("100").resizable().scaledToFit().frame(width: 18, height: 18)
            }
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(Capsule().fill(Color.white.opacity(0.1)))
            .foregroundColor(.white)
        }
        .padding()
    }
}

struct ArcadeGameCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let id: String
    @Binding var rentalTime: Double
    var onGameStart: () -> Void
    
    @AppStorage("userCredits") private var userCredits = 100
    @AppStorage("cardBalance") private var cardBalance = 0
    @AppStorage("useCardForGames") private var useCardForGames = false
    
    @State private var showPopup = false
    
    private let baseCost = 75
    var finalCost: Int {
        useCardForGames ? Int(Double(baseCost) * 0.8) : baseCost
    }
    var activeBalance: Int {
        useCardForGames ? cardBalance : userCredits
    }
    
    var isRentalActive: Bool {
        if rentalTime == 0 { return false }
        let date = Date(timeIntervalSince1970: rentalTime)
        return Date() < date.addingTimeInterval(7 * 24 * 60 * 60)
    }

    var body: some View {
        ZStack {
            Button(action: {
                if isRentalActive {
                    onGameStart()
                } else {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        showPopup = true
                    }
                }
            }) {
                ActivityCard2(title: title, subtitle: subtitle, icon: icon, color: color.toHex() ?? "#FFFFFF", imageName: " ")
                    .overlay(
                        !isRentalActive ?
                        Image(systemName: "lock")
                            .foregroundColor(.white.opacity(0.3))
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        : nil
                    )
            }
            .buttonStyle(QuietButtonStyle())

            if showPopup {
                popupLayer
            }
        }
    }
    
    private var popupLayer: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture { withAnimation { showPopup = false } }
            
            VStack(spacing: 25) {
                Image(systemName: "cart.badge.plus")
                    .font(.system(size: 50))
                    .foregroundColor(color)
                
                VStack(spacing: 10) {
                    Text(activeBalance >= finalCost ? "Rent \(title)" : "Not Enough Credits")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                    
                    // İNDİRİM BİLGİSİ BURAYA EKLENDİ
                    if useCardForGames && activeBalance >= finalCost {
                        Text("20% Pufi Card Discount Applied!")
                            .font(.caption2.bold())
                            .foregroundColor(Color(hex: "#ABDEE6"))
                            .padding(.bottom, 2)
                    }
                    
                    Text(activeBalance >= finalCost ? "This activity costs \(finalCost) credits per week." : "You need \(finalCost) credits. Current: \(activeBalance)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                
                HStack(spacing: 20) {
                    Button("Cancel") { withAnimation { showPopup = false } }
                        .foregroundColor(.white.opacity(0.4))
                        .font(.headline)
                    
                    if activeBalance >= finalCost {
                        Button(action: {
                            if useCardForGames {
                                cardBalance -= finalCost
                            } else {
                                userCredits -= finalCost
                            }
                            rentalTime = Date().timeIntervalSince1970
                            withAnimation { showPopup = false }
                        }) {
                            Text("Confirm")
                                .bold()
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(color)
                                .cornerRadius(15)
                                .foregroundColor(.black)
                        }
                    } else {
                        Button("Got it") { withAnimation { showPopup = false } }
                            .bold()
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(15)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(35)
            .background(Color(red: 20/255, green: 15/255, blue: 40/255))
            .cornerRadius(30)
            .padding(30)
        }
        .zIndex(100)
    }
}
