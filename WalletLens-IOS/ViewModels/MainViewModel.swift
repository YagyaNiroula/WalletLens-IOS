import Foundation
import SwiftUI

class MainViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var reminders: [Reminder] = []
    @Published var totalIncome: Double = 0.0
    @Published var totalExpense: Double = 0.0
    @Published var balance: Double = 0.0
    @Published var categoryTotals: [CategoryTotal] = []
    
    private let userDefaults = UserDefaults.standard
    private let transactionsKey = "transactions"
    private let remindersKey = "reminders"
    
    init() {
        loadData()
    }
    
    func loadData() {
        loadTransactions()
        loadReminders()
        calculateTotals()
    }
    
    private func loadTransactions() {
        do {
            if let data = userDefaults.data(forKey: transactionsKey) {
                let decodedTransactions = try JSONDecoder().decode([Transaction].self, from: data)
                transactions = decodedTransactions
            }
        } catch {
            print("Error loading transactions: \(error)")
            transactions = []
        }
    }
    
    private func loadReminders() {
        do {
            if let data = userDefaults.data(forKey: remindersKey) {
                let decodedReminders = try JSONDecoder().decode([Reminder].self, from: data)
                reminders = decodedReminders
            }
        } catch {
            print("Error loading reminders: \(error)")
            reminders = []
        }
    }
    
    private func saveTransactions() {
        do {
            let encoded = try JSONEncoder().encode(transactions)
            userDefaults.set(encoded, forKey: transactionsKey)
        } catch {
            print("Error saving transactions: \(error)")
        }
    }
    
    private func saveReminders() {
        do {
            let encoded = try JSONEncoder().encode(reminders)
            userDefaults.set(encoded, forKey: remindersKey)
        } catch {
            print("Error saving reminders: \(error)")
        }
    }
    
    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
        saveTransactions()
        calculateTotals()
    }
    
    func addReminder(_ reminder: Reminder) {
        reminders.append(reminder)
        saveReminders()
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        transactions.removeAll { $0.id == transaction.id }
        saveTransactions()
        calculateTotals()
    }
    
    func deleteReminder(_ reminder: Reminder) {
        reminders.removeAll { $0.id == reminder.id }
        saveReminders()
    }
    
    private func calculateTotals() {
        let calendar = Calendar.current
        let now = Date()
        
        // Safely get current month start
        guard let currentMonth = calendar.dateInterval(of: .month, for: now)?.start else {
            // Fallback to current date if month calculation fails
            totalIncome = 0.0
            totalExpense = 0.0
            balance = 0.0
            categoryTotals = []
            return
        }
        
        let currentMonthTransactions = transactions.filter { transaction in
            calendar.isDate(transaction.date, equalTo: currentMonth, toGranularity: .month)
        }
        
        totalIncome = currentMonthTransactions
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
        
        totalExpense = currentMonthTransactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
        
        balance = totalIncome - totalExpense
        
        calculateCategoryTotals()
    }
    
    private func calculateCategoryTotals() {
        let calendar = Calendar.current
        let now = Date()
        
        // Safely get current month start
        guard let currentMonth = calendar.dateInterval(of: .month, for: now)?.start else {
            categoryTotals = []
            return
        }
        
        let currentMonthExpenses = transactions.filter { transaction in
            transaction.type == .expense &&
            calendar.isDate(transaction.date, equalTo: currentMonth, toGranularity: .month)
        }
        
        let grouped = Dictionary(grouping: currentMonthExpenses) { $0.category }
        categoryTotals = grouped.map { category, transactions in
            CategoryTotal(category: category, total: transactions.reduce(0) { $0 + $1.amount })
        }.sorted { $0.total > $1.total }
    }
    
    func getRecentTransactions(limit: Int = 4) -> [Transaction] {
        return Array(transactions.sorted { $0.date > $1.date }.prefix(limit))
    }
    
    func getTransactionsForMonth(_ date: Date) -> [Transaction] {
        return transactions.filter { transaction in
            Calendar.current.isDate(transaction.date, equalTo: date, toGranularity: .month)
        }.sorted { $0.date > $1.date }
    }
}
