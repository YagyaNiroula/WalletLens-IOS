import Foundation

enum TransactionType: String, CaseIterable, Codable {
    case income = "INCOME"
    case expense = "EXPENSE"
}

struct Transaction: Identifiable, Codable {
    let id = UUID()
    var amount: Double
    var description: String
    var category: String
    var type: TransactionType
    var date: Date
    var imagePath: String?
    
    init(amount: Double, description: String, category: String, type: TransactionType, date: Date = Date(), imagePath: String? = nil) {
        self.amount = max(0, amount) // Ensure amount is non-negative
        self.description = description.trimmingCharacters(in: .whitespacesAndNewlines)
        self.category = category.trimmingCharacters(in: .whitespacesAndNewlines)
        self.type = type
        self.date = date
        self.imagePath = imagePath
    }
}

struct CategoryTotal: Identifiable {
    let id = UUID()
    let category: String
    let total: Double
}
