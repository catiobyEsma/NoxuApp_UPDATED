import SwiftUI
import UIKit

struct DailyRewardView: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("userCredits") private var userCredits = 0
    @AppStorage("claimedDays") private var claimedDaysData: String = "0,0,0,0,0,0,0"
    @AppStorage("lastClaimedWeek") private var lastClaimedWeek: Int = 0
    
    @State private var showPopup = false
    @State private var earnedAmount = 0
    @State private var popupMessage = ""
    
    let calendar = Calendar.current
    let todayID = Calendar.current.component(.weekday, from: Date())
    let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    private var currentWeekNumber: Int {
        calendar.component(.weekOfYear, from: Date())
    }
    
    private var claimedStatus: [Bool] {
        claimedDaysData.split(separator: ",").map { $0 == "1" }
    }
    
    var body: some View {
        ZStack {
            Color(red: 13/255, green: 8/255, blue: 26/255).ignoresSafeArea()
            
            backgroundDecorations
            
            VStack(spacing: 0) {
                headerView
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(Array(weekdays.enumerated()), id: \.offset) { index, day in
                            weekdayRow(day: day, dayID: index + 2) // Monday is ID 2
                        }
                        
                        HStack(spacing: 15) {
                            weekendCard(day: "Saturday", dayID: 7, baseReward: 60)
                            weekendCard(day: "Sunday", dayID: 1, baseReward: 100)
                        }
                        .padding(.top, 10)
                    }
                    .padding(.horizontal, 25).padding(.top, 15).padding(.bottom, 40)
                }
            }
            .blur(radius: showPopup ? 10 : 0)

            if showPopup {
                Color.black.opacity(0.5).ignoresSafeArea()
                centerRewardPopup
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            checkAndResetWeeklyRewards()
        }
    }
    private func checkAndResetWeeklyRewards() {
        if lastClaimedWeek != currentWeekNumber {
            claimedDaysData = "0,0,0,0,0,0,0"
            lastClaimedWeek = currentWeekNumber
        }
    }

    func claim(dayID: Int, base: Int) {
        checkAndResetWeeklyRewards()
        
        let idx = dayID == 1 ? 6 : dayID - 2
        var finalReward = Double(base)
        
        if dayID != todayID {
            let diff = abs(calculateDiff(from: dayID, to: todayID))
            let penaltyRate = min(0.50 + (Double(diff - 1) * 0.05), 0.75)
            finalReward = Double(base) * (1.0 - penaltyRate)
            self.popupMessage = "Late claim! Penalty applied."
        } else {
            self.popupMessage = "Perfect! Full reward added."
        }
        
        let netAmount = Int(finalReward)
        self.earnedAmount = netAmount
        self.userCredits += netAmount
        
        var statusArray = claimedStatus
        if idx >= 0 && idx < statusArray.count {
            statusArray[idx] = true
        }
        self.claimedDaysData = statusArray.map { $0 ? "1" : "0" }.joined(separator: ",")
        
        UISelectionFeedbackGenerator().selectionChanged()
        withAnimation(.spring()) {
            self.showPopup = true
        }
    }

    func calculateDiff(from: Int, to: Int) -> Int {
        let f = from == 1 ? 7 : from - 1
        let t = to == 1 ? 7 : to - 1
        return t - f
    }

    
    var backgroundDecorations: some View {
        VStack {
            HStack {
                Image("calm_pufi").resizable().scaledToFit().frame(width: 150, height: 150).opacity(0.4).offset(x: 70, y: 100)
                Spacer()
            }
            Spacer()
            HStack {
                Spacer()
                Image("p33").resizable().scaledToFit().frame(width: 130, height: 130).opacity(0.4).offset(x: 10, y: -20)
            }
            Spacer()
            HStack {
                Spacer()
                Image("p22").resizable().scaledToFit().frame(width: 130, height: 130).opacity(0.4).offset(x: -140, y: -20)
            }
        }.ignoresSafeArea()
    }

    func weekdayRow(day: String, dayID: Int) -> some View {
        let idx = dayID == 1 ? 6 : dayID - 2
        let isClaimed = claimedStatus[idx]
        let isToday = dayID == todayID
        let isPast = (dayID < todayID && dayID != 1) || (todayID == 1 && dayID != 1)

        return Button(action: { if !isClaimed && (isToday || isPast) { claim(dayID: dayID, base: 30) } }) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(day).font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(isToday && !isClaimed ? Color(hex: "#00D1FF") : .white)
                    if isToday && !isClaimed {
                        Text("HAVEN'T CLAIMED YET").font(.system(size: 10, weight: .black)).foregroundColor(Color(hex: "#00D1FF"))
                    } else if isClaimed {
                        Text("COLLECTED").font(.system(size: 10, weight: .bold)).foregroundColor(.green)
                    } else {
                        Text("Daily Gift").font(.caption).foregroundColor(.white.opacity(0.5))
                    }
                }
                Spacer()
                Image(isClaimed ? "checkmark.circle.fill" : "present1")
                    .resizable().scaledToFit().frame(width: 42, height: 42)
            }
            .padding(.horizontal, 20).padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: 18).fill(isToday ? Color.white.opacity(0.12) : Color.white.opacity(0.06)))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(isToday && !isClaimed ? Color(hex: "#00D1FF").opacity(0.5) : Color.clear, lineWidth: 1))
        }
        .disabled(isClaimed || (!isToday && !isPast))
    }

    func weekendCard(day: String, dayID: Int, baseReward: Int) -> some View {
        let idx = dayID == 1 ? 6 : 5
        let isClaimed = claimedStatus[idx]
        let isToday = dayID == todayID
        
        return Button(action: { if !isClaimed && isToday { claim(dayID: dayID, base: baseReward) } }) {
            VStack(spacing: 12) {
                Text(day).font(.system(size: 16, weight: .black, design: .rounded)).foregroundColor(.white)
                Image("present1").resizable().scaledToFit().frame(width: 70, height: 70).opacity(isClaimed ? 0.5 : 1)
                Text(isClaimed ? "COLLECTED" : "BIG REWARD").font(.system(size: 11, weight: .bold))
            }
            .frame(maxWidth: .infinity).padding(.vertical, 20)
            .background(RoundedRectangle(cornerRadius: 24).fill(isToday ? Color.white.opacity(0.12) : Color.white.opacity(0.08)))
        }
        .disabled(isClaimed || !isToday)
    }

    var centerRewardPopup: some View {
        VStack(spacing: 20) {
            Image("100").resizable().scaledToFit().frame(width: 100, height: 100)
            Text("+\(earnedAmount)").font(.system(size: 40, weight: .black, design: .monospaced)).foregroundColor(.white)
            Text(popupMessage).foregroundColor(.gray)
            Button("Awesome!") { withAnimation { showPopup = false } }
                .bold().foregroundColor(.black).padding().frame(maxWidth: .infinity).background(Color.white).cornerRadius(15)
        }
        .padding(30).background(Color(red: 25/255, green: 20/255, blue: 45/255)).cornerRadius(30).padding(40)
    }

    var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.title2.bold())
                    .foregroundColor(.white.opacity(0.6))
            }
            Spacer()
            Text("Pufi's Daily Gifts").font(.system(size: 22, weight: .heavy, design: .rounded)).foregroundColor(.white)
            Spacer()
            Image(systemName: "chevron.left").opacity(0).padding(10)
        }.padding(.horizontal, 25).padding(.top, 20)
    }
}
struct DailyRewardView_Previews: PreviewProvider {
    static var previews: some View {
        DailyRewardView()
    }
}
