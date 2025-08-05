import Foundation
import SwiftUI
import WidgetKit
import UserNotifications

// Widget transaction structure for sharing data
struct WidgetTransaction: Codable {
    let amount: Double
    let type: String
    let date: Date
}

class MainViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var reminders: [Reminder] = []
    @Published var totalIncome: Double = 0.0
    @Published var totalExpense: Double = 0.0
    @Published var balance: Double = 0.0
    @Published var categoryTotals: [CategoryTotal] = []
    @Published var monthlyBudget: MonthlyBudget?
    
    private let userDefaults = UserDefaults.standard
    private let transactionsKey = "transactions"
    private let remindersKey = "reminders"
    private let budgetKey = "monthlyBudget"
    private let notificationManager = NotificationManager.shared
    
    init() {
        setupNotifications()
        loadData()
    }
    
    func loadData() {
        loadTransactions()
        loadReminders()
        loadBudget()
        calculateTotals()
        setupNotificationObservers()
    }
    
    private func loadTransactions() {
        do {
            if let data = userDefaults.data(forKey: transactionsKey) {
                let decodedTransactions = try JSONDecoder().decode([Transaction].self, from: data)
                transactions = decodedTransactions
            }
        } catch {
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
            reminders = []
        }
    }
    
    private func saveTransactions() {
        do {
            let encoded = try JSONEncoder().encode(transactions)
            userDefaults.set(encoded, forKey: transactionsKey)
            
                        // Save to shared UserDefaults for widget
            let sharedDefaults = UserDefaults(suiteName: "group.com.walletlens.widget") ?? UserDefaults.standard
                // Convert transactions to widget format
                let widgetTransactions = transactions.map { transaction in
                    WidgetTransaction(
                        amount: transaction.amount,
                        type: transaction.type.rawValue,
                        date: transaction.date
                    )
                }
                
                let widgetEncoded = try JSONEncoder().encode(widgetTransactions)
                sharedDefaults.set(widgetEncoded, forKey: "widget_transactions")
                sharedDefaults.synchronize() // Force immediate save
                
                // Refresh the widget immediately
                WidgetCenter.shared.reloadAllTimelines()
                
                // Also refresh after a short delay to ensure data is written
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    WidgetCenter.shared.reloadAllTimelines()
                }
                
                // Additional refresh after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    WidgetCenter.shared.reloadAllTimelines()
                }
        } catch {
            // Handle error silently
        }
    }
    
    private func saveReminders() {
        do {
            let encoded = try JSONEncoder().encode(reminders)
            userDefaults.set(encoded, forKey: remindersKey)
        } catch {
            // Handle error silently
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
        // Schedule notification for the reminder
        notificationManager.scheduleBillReminder(for: reminder)
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        transactions.removeAll { $0.id == transaction.id }
        saveTransactions()
        calculateTotals()
        checkBudgetWarnings()
    }
    
    func deleteReminder(_ reminder: Reminder) {
        reminders.removeAll { $0.id == reminder.id }
        saveReminders()
        // Cancel notification for the reminder
        notificationManager.cancelBillReminder(for: reminder)
    }
    
    func updateReminder(_ reminder: Reminder) {
        print("updateReminder called for: \(reminder.title), isCompleted: \(reminder.isCompleted)")
        print("Current reminders count: \(reminders.count)")
        
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            print("Found reminder at index: \(index)")
            print("Old isCompleted: \(reminders[index].isCompleted)")
            reminders[index] = reminder
            print("New isCompleted: \(reminders[index].isCompleted)")
            saveReminders()
            // Reschedule notification
            notificationManager.cancelBillReminder(for: reminder)
            if !reminder.isCompleted {
                notificationManager.scheduleBillReminder(for: reminder)
            }
            
            // Force UI update by triggering objectWillChange
            objectWillChange.send()
            print("Reminder updated successfully")
        } else {
            print("Could not find reminder to update: \(reminder.title)")
            print("Available reminder IDs: \(reminders.map { $0.id })")
            print("Looking for ID: \(reminder.id)")
        }
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
        updateBudgetSpending()
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
    
    // MARK: - Budget Management
    func setMonthlyBudget(_ amount: Double) {
        let calendar = Calendar.current
        let currentMonth = calendar.dateInterval(of: .month, for: Date())?.start ?? Date()
        
        monthlyBudget = MonthlyBudget(
            totalLimit: amount,
            month: currentMonth,
            spent: totalExpense,
            categoryBudgets: []
        )
        saveBudget()
    }
    
    func updateBudgetSpending() {
        guard var budget = monthlyBudget else { return }
        budget.spent = totalExpense
        monthlyBudget = budget
        saveBudget()
        checkBudgetWarnings()
    }
    
    private func loadBudget() {
        do {
            if let data = userDefaults.data(forKey: budgetKey) {
                let decodedBudget = try JSONDecoder().decode(MonthlyBudget.self, from: data)
                monthlyBudget = decodedBudget
            }
        } catch {
            monthlyBudget = nil
        }
    }
    
    private func saveBudget() {
        guard let budget = monthlyBudget else { return }
        do {
            let encoded = try JSONEncoder().encode(budget)
            userDefaults.set(encoded, forKey: budgetKey)
        } catch {
            // Handle error silently
        }
    }
    
    // MARK: - Notification Management
    private func setupNotifications() {
        notificationManager.requestNotificationPermission()
        notificationManager.setupNotificationCategories()
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleReminderCompleted),
            name: .reminderCompleted,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleShowBudgetDetails),
            name: .showBudgetDetails,
            object: nil
        )
    }
    
    @objc private func handleReminderCompleted(_ notification: Notification) {
        guard let reminder = notification.object as? Reminder else { return }
        updateReminder(Reminder(
            title: reminder.title,
            amount: reminder.amount,
            dueDate: reminder.dueDate,
            isCompleted: true,
            notes: reminder.notes
        ))
    }
    
    @objc private func handleShowBudgetDetails(_ notification: Notification) {
        // This will be handled by the view to navigate to budget details
        // For now, we'll just print a message
        print("Show budget details requested")
    }
    
    private func checkBudgetWarnings() {
        guard let budget = monthlyBudget else { return }
        notificationManager.checkBudgetWarnings(
            currentExpense: totalExpense,
            monthlyBudget: budget.totalLimit
        )
    }
}
