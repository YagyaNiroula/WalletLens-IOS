import Foundation

struct Budget: Identifiable, Codable {
    let id = UUID()
    var monthlyLimit: Double
    var category: String
    var month: Date
    var spent: Double
    
    init(monthlyLimit: Double, category: String, month: Date = Date(), spent: Double = 0.0) {
        self.monthlyLimit = max(0, monthlyLimit)
        self.category = category.trimmingCharacters(in: .whitespacesAndNewlines)
        self.month = month
        self.spent = max(0, spent)
    }
    
    var remaining: Double {
        return max(0, monthlyLimit - spent)
    }
    
    var percentageUsed: Double {
        guard monthlyLimit > 0 else { return 0 }
        return (spent / monthlyLimit) * 100
    }
    
    var isOverBudget: Bool {
        return spent > monthlyLimit
    }
    
    var isNearLimit: Bool {
        return percentageUsed >= 80
    }
}

struct MonthlyBudget: Identifiable, Codable {
    let id = UUID()
    var totalLimit: Double
    var month: Date
    var spent: Double
    var categoryBudgets: [Budget]
    
    init(totalLimit: Double, month: Date = Date(), spent: Double = 0.0, categoryBudgets: [Budget] = []) {
        self.totalLimit = max(0, totalLimit)
        self.month = month
        self.spent = max(0, spent)
        self.categoryBudgets = categoryBudgets
    }
    
    var remaining: Double {
        return max(0, totalLimit - spent)
    }
    
    var percentageUsed: Double {
        guard totalLimit > 0 else { return 0 }
        return (spent / totalLimit) * 100
    }
    
    var isOverBudget: Bool {
        return spent > totalLimit
    }
    
    var isNearLimit: Bool {
        return percentageUsed >= 80
    }
} 