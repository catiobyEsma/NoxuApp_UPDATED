import SwiftUI
import EventKit

// MARK: - Model
struct DailyGoal: Identifiable {
    let id = UUID()
    var task: String = ""
    var time: Date = Date()
    var isTimeEnabled: Bool = false
}

struct CloudShaperView: View {
    @Environment(\.dismiss) var dismiss
    private let eventStore = EKEventStore()
    
    @State private var goals: [DailyGoal] = [DailyGoal()]
    @State private var showInstructions = true
    @State private var calendarStatus: String = ""
    @State private var animateSway = false
    
    var body: some View {
        ZStack {
            Color(hex: "#0D081A").ignoresSafeArea()
            StaticBackgroundStarsView()
            VStack {
                HStack {
                    Image(systemName: "moon.zzz.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: "#8E86D7"))
                        .rotationEffect(.degrees(animateSway ? 10 : -10))
                        .padding(40)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: "sparkles")
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: "#6bb09d"))
                        .scaleEffect(animateSway ? 1.2 : 0.8)
                        .padding(40)
                }
            }
            
            VStack(spacing: 20) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2.bold())
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Spacer()
                    Text("Plan Your Day✨")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: { withAnimation { goals.append(DailyGoal()) }}) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color(hex: "#6bb09d"))
                    }
                }
                .padding(.horizontal)
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white.opacity(0.1))
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.white.opacity(0.2), lineWidth: 2)
                                .blur(radius: 1)
                        )
                        .overlay(
                            VStack(spacing: 40) {
                                ForEach(0..<10, id: \.self) { _ in
                                    Divider().background(Color.white.opacity(0.1))
                                }
                            }
                            .padding(.top, 60)
                        )
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "pencil.and.outline")
                                .foregroundColor(Color(hex: "#6bb09d"))
                            Text("Tomorrow's Dreams")
                                .font(.system(.subheadline, design: .rounded).bold())
                                .foregroundColor(.white.opacity(0.6))
                            Spacer()
                        }
                        .padding([.top, .leading], 25)
                        
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 5) {
                                ForEach($goals) { $goal in
                                    CloudGoalRow(goal: $goal)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        }
                    }
                }
                .frame(maxHeight: 450)
                .padding(.horizontal, 25)
                VStack(spacing: 15) {
                    if !calendarStatus.isEmpty {
                        Text(calendarStatus)
                            .font(.caption)
                            .foregroundColor(calendarStatus.contains("Başarıyla") ? Color(hex: "#6bb09d") : .red.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Button(action: { addToCalendar() }) {
                        HStack {
                            Image(systemName: "calendar.badge.plus")
                            Text("Add to Calendar")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(
                            LinearGradient(colors: [Color(hex: "#6bb09d"), Color(hex: "#4A90E2")], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(20)
                    }
                    .padding(.horizontal, 40)
                }
            }
            if showInstructions {
                instructionOverlay
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                animateSway = true
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
                .navigationBarBackButtonHidden(true)
                .navigationTitle("")
    }

    func addToCalendar() {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
        case .notDetermined:
            if #available(iOS 17.0, *) {
                eventStore.requestFullAccessToEvents { granted, _ in
                    DispatchQueue.main.async { self.handlePermission(granted: granted) }
                }
            } else {
                eventStore.requestAccess(to: .event) { granted, _ in
                    DispatchQueue.main.async { self.handlePermission(granted: granted) }
                }
            }
        case .fullAccess, .authorized:
            saveEvents()
        case .writeOnly:
            calendarStatus = "You need to give permission to access calender"
        case .denied, .restricted:
            calendarStatus = "Access denied. Check the settings."
        @unknown default:
            break
        }
    }

    func handlePermission(granted: Bool) {
        if granted {
            saveEvents()
        } else {
            calendarStatus = "Without permission, calendar will only be visible."
        }
    }

    func saveEvents() {
            let hour = Calendar.current.component(.hour, from: Date())
            let targetDate = (hour >= 0 && hour < 6) ? Date() : Calendar.current.date(byAdding: .day, value: 1, to: Date())!
            
            var successCount = 0
            
            for goal in goals where !goal.task.isEmpty {
                let event = EKEvent(eventStore: eventStore)
                event.title = goal.task
                event.notes = "CloudShaper_Task"
                
                if goal.isTimeEnabled {
                    let timeComp = Calendar.current.dateComponents([.hour, .minute], from: goal.time)
                    var dateComp = Calendar.current.dateComponents([.year, .month, .day], from: targetDate)
                    dateComp.hour = timeComp.hour
                    dateComp.minute = timeComp.minute
                    event.startDate = Calendar.current.date(from: dateComp)
                    event.endDate = event.startDate?.addingTimeInterval(3600)
                } else {
                    event.startDate = targetDate
                    event.endDate = targetDate
                    event.isAllDay = true
                }
                
                event.calendar = eventStore.defaultCalendarForNewEvents
                
                do {
                    try eventStore.save(event, span: .thisEvent)
                    successCount += 1
                } catch {
                    print("Event save error: \(error.localizedDescription)")
                }
            }
            
            DispatchQueue.main.async {
                if successCount > 0 {
                    calendarStatus = "Added to calendar! ✨"
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    goals = [DailyGoal()]
                }
            }
        }

    var instructionOverlay: some View {
        ZStack {
            Color.black.opacity(0.92).ignoresSafeArea()
            VStack(spacing: 25) {
                Text("🗓️").font(.system(size: 80))
                Text("Plan Your Day").font(.title.bold()).foregroundColor(.white)
                Text("Write down your plans for tomorrow so you can leave them behind and drift into sleep peacefully.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 40)
                
                Button(action: { withAnimation { showInstructions = false } }) {
                    HStack {
                        Text("Start Planning")
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: 250)
                    .frame(height: 60)
                    .background(
                        LinearGradient(colors: [Color(hex: "#4232a8"), Color(hex: "#c9704d")], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(20)
                    .shadow(color: Color(hex: "#4232a8").opacity(0.5), radius: 15, x: 0, y: 8)
                }
            }
        }
    }
}

struct CloudGoalRow: View {
    @Binding var goal: DailyGoal
    
    var body: some View {
        HStack {
            TextField("A dream to achieve...", text: $goal.task)
                .foregroundColor(.white)
                .font(.system(.body, design: .rounded))
            
            if goal.isTimeEnabled {
                DatePicker("", selection: $goal.time, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .colorInvert()
                    .colorMultiply(.white)
                    .scaleEffect(0.9)
            }
            
            Button(action: { withAnimation { goal.isTimeEnabled.toggle() }}) {
                Image(systemName: goal.isTimeEnabled ? "bell.fill" : "bell")
                    .foregroundColor(goal.isTimeEnabled ? Color(hex: "#6bb09d") : .white.opacity(0.3))
            }
        }
        .padding(.vertical, 12)
        .overlay(
            VStack {
                Spacer()
                Divider().background(Color.white.opacity(0.1))
            }
        )
    }
}
