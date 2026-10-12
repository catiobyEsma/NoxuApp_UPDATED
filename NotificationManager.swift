import Foundation
import UserNotifications
import SwiftUI
import UIKit

class NotificationManager {
    static let instance = NotificationManager()
    
    @AppStorage("pufiName") var pufiName: String = "Pufi"
    @AppStorage("selectedAsset") var selectedAsset: String = ""
    @AppStorage("userMantra") var userMantra: String = ""

    private let noonMessages = [
        "How is your day going so far?",
        "Remember to take a deep breath!",
        "Have a wonderful and productive day.",
        "Pufi is thinking of you! Have a nice day.",
        "Don't forget to hydrate today!"
    ]
    
    private let eveningMessages = [
        "How about relaxing a bit with me?",
        "The sun is setting, time to unwind.",
        "You've worked hard today. Rest a little?",
        "Evening is here. Let's find some peace.",
        "Time for a small break, don't you think?"
    ]
    
    private let nightMessages = [
        "I was about to sleep, just wanted to say good night.",
        "Sweet dreams! See you tomorrow.",
        "Soft pillows and calm minds... Good night.",
        "Stars are out! Time to rest your eyes.",
        "Sleep tight, I'll be here when you wake up."
    ]

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, _) in
            if success { self.rescheduleAllNotifications() }
        }
    }

    func rescheduleAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let name = pufiName.isEmpty ? "Pufi" : pufiName
        let imageToUse = selectedAsset.isEmpty ? "p1" : selectedAsset

        if !selectedAsset.isEmpty {
            scheduleRollingNotifications(id: "pufi_noon", title: name, pool: noonMessages, hour: 13, minute: 0, interval: 2, image: imageToUse)
            scheduleRollingNotifications(id: "pufi_evening", title: name, pool: eveningMessages, hour: 19, minute: 30, interval: 3, image: imageToUse)
            scheduleRollingNotifications(id: "pufi_night", title: name, pool: nightMessages, hour: 22, minute: 0, interval: 2, image: imageToUse)
        } else {
            scheduleRollingNotifications(id: "default_noon", title: name, pool: ["Have a nice day!"], hour: 12, minute: 0, interval: 2, image: imageToUse)
            scheduleRollingNotifications(id: "default_night", title: name, pool: nightMessages, hour: 22, minute: 30, interval: 1, image: imageToUse)
        }
    }

    private func scheduleRollingNotifications(id: String, title: String, pool: [String], hour: Int, minute: Int, interval: Int, image: String) {
        let calendar = Calendar.current
        
        for i in stride(from: 0, through: 20, by: interval) {
            guard let date = calendar.date(byAdding: .day, value: i, to: Date()) else { continue }
            
            var components = calendar.dateComponents([.year, .month, .day], from: date)
            components.hour = hour
            components.minute = minute
            
            if let targetDate = calendar.date(from: components), targetDate < Date() { continue }

            let content = UNMutableNotificationContent()
            content.title = title
            let randomBody = pool.randomElement() ?? "Hello!"
            content.body = userMantra.isEmpty ? randomBody : "\(randomBody)\n\n✨ \(userMantra)"
            content.sound = .default
            
            if let attachment = createAttachment(for: image) {
                content.attachments = [attachment]
            }

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: "\(id)_\(i)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }

    private func createAttachment(for imageName: String) -> UNNotificationAttachment? {
        guard let image = UIImage(named: imageName), let data = image.pngData() else { return nil }
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".png")
        do {
            try data.write(to: tempURL)
            return try UNNotificationAttachment(identifier: UUID().uuidString, url: tempURL, options: nil)
        } catch { return nil }
    }
}
