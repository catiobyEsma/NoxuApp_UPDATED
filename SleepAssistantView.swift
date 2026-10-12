import SwiftUI

struct SleepAssistantView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("userCredits") private var userCredits = 100
    @AppStorage("cardBalance") private var cardBalance = 0
    @AppStorage("useCardForGames") private var useCardForGames = false

    @State private var showCreditPopup = false
    @State private var navigateToRoom = false
    let baseCost = 10
    var finalCost: Int {
        useCardForGames ? Int(Double(baseCost) * 0.8) : baseCost
    }
    var activeBalance: Int {
        useCardForGames ? cardBalance : userCredits
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#0D081A").ignoresSafeArea()
                StaticBackgroundStarsView()
                
                VStack(spacing: 20) {
                    headerView
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 25) {
                            VStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color(hex: "#6bb09d"))
                                Text("Ready for deep rest?")
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                                if useCardForGames {
                                    Text("Pufi Card: 20% Discount Active")
                                        .font(.caption2.bold())
                                        .foregroundColor(Color(hex: "#ABDEE6"))
                                        .padding(4)
                                        .background(Color(hex: "#ABDEE6").opacity(0.1))
                                        .cornerRadius(5)
                                }
                            }
                            .padding(.top, 10)
                            Button(action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    showCreditPopup = true
                                }
                            }) {
                                AssistantCard(icon: "bed.double", title: "Optimize Your Room", description: "Scientific ways to prepare your environment.", accentColor: Color(hex: "#6bb09d"))
                            }
                            
                            NavigationLink(destination: SleepGamesView()) {
                                AssistantCard(icon: "gamecontroller", title: "Sleep Games", description: "Proven methods like counting sheep to calm your mind.", accentColor: Color(hex: "#8E86D7"))
                            }
                        }
                        .padding(20)
                    }
                }
                if showCreditPopup {
                    creditApprovalPopup
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $navigateToRoom) {
                RoomOptimizationView()
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.title2.bold())
                    .foregroundColor(.white.opacity(0.6))
            }
            Spacer()
            VStack(spacing: 2) {
                Text("Sleep Assistant").font(.headline).foregroundColor(.white)
                Text("Balance: \(activeBalance) Credits").font(.caption.bold()).foregroundColor(useCardForGames ? Color(hex: "#ABDEE6") : Color(hex: "#F9E2AF"))
            }
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal)
    }
    private var creditApprovalPopup: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
                .onTapGesture { withAnimation { showCreditPopup = false } }
            
            VStack(spacing: 25) {
                Image(systemName: "cart.badge.plus")
                    .font(.system(size: 50))
                    .foregroundColor(Color(hex: "#6bb09d"))
                
                VStack(spacing: 10) {
                    Text(activeBalance >= finalCost ? "Unlock Content" : "Not Enough Credits")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                    
                    if useCardForGames && activeBalance >= finalCost {
                        Text("20% Pufi Card Discount Applied!")
                            .font(.caption2.bold())
                            .foregroundColor(Color(hex: "#ABDEE6"))
                            .padding(.bottom, 2)
                    }
                    
                    Text(activeBalance >= finalCost ? "Optimization guide costs \(finalCost) credits." : "You need \(finalCost) credits. Current: \(activeBalance)")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal)
                }
                
                HStack(spacing: 15) {
                    Button("Cancel") {
                        withAnimation(.spring()) { showCreditPopup = false }
                    }
                    .foregroundColor(.white.opacity(0.6))
                    .font(.headline)
                    
                    Button(action: {
                        if activeBalance >= finalCost {
                            if useCardForGames { cardBalance -= finalCost } else { userCredits -= finalCost }
                            withAnimation {
                                showCreditPopup = false
                                navigateToRoom = true
                            }
                        }
                    }) {
                        Text(activeBalance >= finalCost ? "Confirm" : "Got it")
                            .bold()
                            .foregroundColor(.black)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(activeBalance >= finalCost ? Color(hex: "#6bb09d") : Color.white.opacity(0.2))
                            .cornerRadius(12)
                    }
                }
            }
            .padding(35)
            .background(Color(hex: "#1D1933"))
            .cornerRadius(30)
            .padding(30)
        }
    }
}
struct RoomOptimizationView: View {
    @Environment(\.dismiss) var dismiss
    @State private var conditions = [
        SleepCondition(icon: "thermometer.low", title: "Cool Temperature", desc: "Scientific studies suggest 18.3°C (65°F) is the ideal sleep temperature.", isDone: false),
        SleepCondition(icon: "light.max", title: "Pitch Black", desc: "Darkness triggers melatonin. Even small standby lights can interfere.", isDone: false),
        SleepCondition(icon: "wind", title: "Proper Ventilation", desc: "Lower CO2 levels are linked to better sleep depth and morning alertness.", isDone: false),
        SleepCondition(icon: "speaker.zzz", title: "White Noise", desc: "Steady background sounds mask sudden noise spikes that wake you up.", isDone: false),
        SleepCondition(icon: "iphone.slash", title: "No Blue Light", desc: "Avoid screens 1 hour before sleep to keep your circadian rhythm stable.", isDone: false),
        SleepCondition(icon: "leaf", title: "Scent of Lavender", desc: "Lavender is shown to increase slow-wave sleep (deep sleep) significantly.", isDone: false)
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "#0D081A").ignoresSafeArea()
            StaticBackgroundStarsView()
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2.bold())
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Spacer()
                    Text("Room Setup").font(.headline).foregroundColor(.white)
                    Spacer()
                    Text("\(conditions.filter({$0.isDone}).count)/\(conditions.count)")
                        .font(.caption.bold()).foregroundColor(Color(hex: "#6bb09d"))
                        .padding(8).background(Color(hex: "#6bb09d").opacity(0.2)).cornerRadius(10)
                }
                .padding()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Ideal Sleep Conditions").font(.system(size: 28, weight: .bold)).foregroundColor(.white)
                        Text("Scientific environment settings for your best rest.").font(.subheadline).foregroundColor(.white.opacity(0.6))
                        
                        ForEach($conditions) { $condition in
                            OptimizationRowView(condition: $condition)
                        }
                    }
                    .padding()
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
struct SleepCondition: Identifiable {
    let id = UUID(); let icon: String; let title: String; let desc: String; var isDone: Bool
}

struct OptimizationRowView: View {
    @Binding var condition: SleepCondition
    var body: some View {
        Button(action: { withAnimation(.spring()) { condition.isDone.toggle() } }) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12).fill(condition.isDone ? Color(hex: "#6bb09d").opacity(0.2) : Color.white.opacity(0.05)).frame(width: 50, height: 50)
                    Image(systemName: condition.icon).foregroundColor(condition.isDone ? Color(hex: "#6bb09d") : .white.opacity(0.7))
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(condition.title).font(.headline).foregroundColor(condition.isDone ? Color(hex: "#6bb09d") : .white)
                    Text(condition.desc).font(.caption).foregroundColor(.white.opacity(0.5)).multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: condition.isDone ? "checkmark.circle.fill" : "circle").font(.title2).foregroundColor(condition.isDone ? Color(hex: "#6bb09d") : .white.opacity(0.2))
            }
            .padding().background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(condition.isDone ? 0.08 : 0.03)))
        }.buttonStyle(PlainButtonStyle())
    }
}

struct AssistantCard: View {
    let icon, title, description: String; let accentColor: Color
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon).font(.system(size: 30)).foregroundColor(accentColor).frame(width: 60)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline).foregroundColor(.white)
                Text(description).font(.subheadline).foregroundColor(.white.opacity(0.6)).multilineTextAlignment(.leading)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.footnote).foregroundColor(.white.opacity(0.3))
        }
        .padding(20).background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.05)))
    }
}
