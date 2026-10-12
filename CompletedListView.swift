import SwiftUI
import EventKit

struct CompletedListView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("userCredits") private var userCredits = 100 // Bakiye sistemi
    private let eventStore = EKEventStore()
    
    @State private var todaysEvents: [EKEvent] = []
    @State private var completedEventIDs: Set<String> = []
    @State private var isLoading = true
    
    private var completionRatio: Double {
        guard !todaysEvents.isEmpty else { return 0 }
        return Double(completedEventIDs.count) / Double(todaysEvents.count)
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#0D081A").ignoresSafeArea()
            StaticBackgroundStarsView()
            
            VStack(spacing: 0) {
                headerArea
                
                VStack(spacing: 25) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Today's Progress")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("Review your completed goals")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.5))
                        }
                        Spacer()
                        Image(systemName: "checklist")
                            .font(.title)
                            .foregroundColor(Color(hex: "#6bb09d"))
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    if isLoading {
                        VStack {
                            ProgressView().tint(.white)
                            Text("Connecting to dreams...").font(.caption).foregroundColor(.white.opacity(0.5)).padding(.top)
                        }
                        .frame(maxHeight: .infinity)
                    } else if todaysEvents.isEmpty {
                        emptyStateView
                    } else {
                        VStack(spacing: 15) {
                            ScrollView(showsIndicators: false) {
                                VStack(spacing: 12) {
                                    ForEach(todaysEvents, id: \.eventIdentifier) { event in
                                        taskRow(event: event)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            motivationPanel
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            fetchEvents()
        }
    }

    var headerArea: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.title2.bold())
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            HStack(spacing: 5) {
                Text("\(userCredits)").fontWeight(.bold)
                Image("100").resizable().scaledToFit().frame(width: 20, height: 20)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(Capsule().fill(Color.white.opacity(0.1)))
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }

    private func taskRow(event: EKEvent) -> some View {
        let isDone = completedEventIDs.contains(event.eventIdentifier)
        
        return HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(isDone ? .white.opacity(0.4) : .white)
                    .strikethrough(isDone)
                
                if let start = event.startDate {
                    Text(event.isAllDay ? "All Day" : start.formatted(date: .omitted, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.3))
                }
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring()) {
                    if isDone {
                        completedEventIDs.remove(event.eventIdentifier)
                    } else {
                        completedEventIDs.insert(event.eventIdentifier)
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }
                }
            }) {
                Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isDone ? Color(hex: "#6bb09d") : .white.opacity(0.2))
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.05)))
    }
    private var motivationPanel: some View {
        VStack(spacing: 12) {
            Text("\(completedEventIDs.count) / \(todaysEvents.count) completed!")
                .font(.system(.subheadline, design: .rounded).bold())
                .foregroundColor(.white)
            
            Text(motivationMessage)
                .font(.system(.footnote, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 30)
                .frame(height: 60)
            
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.1)).frame(height: 8)
                Capsule()
                    .fill(LinearGradient(colors: [Color(hex: "#6bb09d"), Color(hex: "#8E86D7")], startPoint: .leading, endPoint: .trailing))
                    .frame(width: max(0, CGFloat(completionRatio) * (UIScreen.main.bounds.width - 80)), height: 8)
                    .animation(.spring(), value: completionRatio)
            }
            .padding(.horizontal, 40)
        }
        .padding(.vertical, 25)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.white.opacity(0.08))
                .padding(.horizontal)
        )
        .padding(.bottom, 20)
    }

    private var motivationMessage: String {
        let x = completionRatio
        let total = todaysEvents.count
        if total == 0 { return "No tasks found for today." }
        if x == 1.0 { return "Great Job! Take a good sleep!" }
        else if x > 0.5 { return "You finished most of your responsibilities!" }
        else if x > 0 { return "You're doing great, almost there!" }
        else { return "Complete your tasks to clear your mind." }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 15) {
            Image(systemName: "moon.stars").font(.system(size: 50)).foregroundColor(.white.opacity(0.2))
            Text("No goals found for today.").font(.caption).foregroundColor(.white.opacity(0.4))
        }
        .frame(maxHeight: .infinity)
    }

    private func fetchEvents() {
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents { granted, _ in
                if granted { self.loadEventsAfterPermission() }
                else { DispatchQueue.main.async { self.isLoading = false } }
            }
        } else {
            eventStore.requestAccess(to: .event) { granted, _ in
                if granted { self.loadEventsAfterPermission() }
                else { DispatchQueue.main.async { self.isLoading = false } }
            }
        }
    }
    
    private func loadEventsAfterPermission() {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        let calendars = eventStore.calendars(for: .event)
        let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: calendars)
        let allEvents = eventStore.events(matching: predicate)
        
        DispatchQueue.main.async {
            self.todaysEvents = allEvents.filter { event in
                return event.notes?.contains("CloudShaper_Task") ?? false
            }.sorted(by: { $0.startDate < $1.startDate })
            self.isLoading = false
        }
    }
}
