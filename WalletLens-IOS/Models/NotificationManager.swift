import Foundation
import UserNotifications
import SwiftUI

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {}
    
    // MARK: - Notification Permission
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Notification permission granted")
                } else {
                    print("Notification permission denied: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    // MARK: - Bill Reminder Notifications
    func scheduleBillReminder(for reminder: Reminder) {
        let content = UNMutableNotificationContent()
        content.title = "Bill Reminder"
        content.body = "\(reminder.title) - $\(String(format: "%.2f", reminder.amount)) is due today"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "BILL_REMINDER"
        
        // Schedule notification for the due date at 9:00 AM
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: reminder.dueDate)
        components.hour = 9
        components.minute = 0
        
        guard let triggerDate = calendar.date(from: components) else { return }
        
        // Only schedule if the date is in the future
        guard triggerDate > Date() else { return }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "bill_\(reminder.id.uuidString)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling bill reminder: \(error.localizedDescription)")
            } else {
                print("Bill reminder scheduled for \(reminder.title)")
            }
        }
    }
    
    func cancelBillReminder(for reminder: Reminder) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["bill_\(reminder.id.uuidString)"])
    }
    
    // MARK: - Budget Warning Notifications
    func checkBudgetWarnings(currentExpense: Double, monthlyBudget: Double) {
        let percentageUsed = (currentExpense / monthlyBudget) * 100
        
        // Warning at 80% of budget
        if percentageUsed >= 80 && percentageUsed < 100 {
            scheduleBudgetWarning(percentage: Int(percentageUsed), isCritical: false)
        }
        // Critical warning at 100% of budget
        else if percentageUsed >= 100 {
            scheduleBudgetWarning(percentage: Int(percentageUsed), isCritical: true)
        }
    }
    
    private func scheduleBudgetWarning(percentage: Int, isCritical: Bool) {
        let content = UNMutableNotificationContent()
        content.title = isCritical ? "Budget Exceeded!" : "Budget Warning"
        content.body = isCritical ? 
            "You've exceeded your monthly budget by \(percentage - 100)%" :
            "You've used \(percentage)% of your monthly budget"
        content.sound = isCritical ? .defaultCritical : .default
        content.badge = 1
        content.categoryIdentifier = "BUDGET_WARNING"
        
        // Schedule immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "budget_warning_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling budget warning: \(error.localizedDescription)")
            } else {
                print("Budget warning scheduled")
            }
        }
    }
    
    // MARK: - Notification Categories
    func setupNotificationCategories() {
        let billReminderCategory = UNNotificationCategory(
            identifier: "BILL_REMINDER",
            actions: [
                UNNotificationAction(
                    identifier: "MARK_PAID",
                    title: "Mark as Paid",
                    options: [.foreground]
                ),
                UNNotificationAction(
                    identifier: "REMIND_LATER",
                    title: "Remind Later",
                    options: [.foreground]
                )
            ],
            intentIdentifiers: [],
            options: []
        )
        
        let budgetWarningCategory = UNNotificationCategory(
            identifier: "BUDGET_WARNING",
            actions: [
                UNNotificationAction(
                    identifier: "VIEW_DETAILS",
                    title: "View Details",
                    options: [.foreground]
                ),
                UNNotificationAction(
                    identifier: "DISMISS",
                    title: "Dismiss",
                    options: []
                )
            ],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([billReminderCategory, budgetWarningCategory])
    }
    
    // MARK: - Notification Actions Handler
    func handleNotificationAction(_ actionIdentifier: String, for reminder: Reminder? = nil) {
        switch actionIdentifier {
        case "MARK_PAID":
            if let reminder = reminder {
                // Mark reminder as completed
                DispatchQueue.main.async {
                    // This will be handled by the view model
                    NotificationCenter.default.post(
                        name: .reminderCompleted,
                        object: reminder
                    )
                }
            }
        case "REMIND_LATER":
            if let reminder = reminder {
                // Reschedule for tomorrow
                let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
                scheduleBillReminder(for: Reminder(
                    title: reminder.title,
                    amount: reminder.amount,
                    dueDate: tomorrow,
                    notes: reminder.notes
                ))
            }
        case "VIEW_DETAILS":
            // Navigate to budget details
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .showBudgetDetails, object: nil)
            }
        case "DISMISS":
            // Just dismiss the notification
            break
        default:
            break
        }
    }
    
    // MARK: - Clear All Notifications
    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    // MARK: - Get Pending Notifications
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            completion(requests)
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let reminderCompleted = Notification.Name("reminderCompleted")
    static let showBudgetDetails = Notification.Name("showBudgetDetails")
} 