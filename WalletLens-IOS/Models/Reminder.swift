import Foundation

struct Reminder: Identifiable, Codable {
    let id = UUID()
    var title: String
    var amount: Double
    var dueDate: Date
    var isCompleted: Bool
    var notes: String?
    
    init(title: String, amount: Double, dueDate: Date, isCompleted: Bool = false, notes: String? = nil) {
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.amount = max(0, amount) // Ensure amount is non-negative
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.notes = notes?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
