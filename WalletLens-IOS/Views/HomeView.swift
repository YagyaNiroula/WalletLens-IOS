import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var showingAddTransaction = false
    @State private var showingAddReminder = false
    @State private var showingBudgetSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                VStack(spacing: 8) {
                    Text("WalletLens")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                        Text("Your Personal Finance Tracker")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                    .padding(.top, 10)
                
                    // Summary Cards Row (Income, Expense, Balance)
                HStack(spacing: 12) {
                        // Income Card
                    SummaryCard(
                            title: "INCOME",
                        amount: viewModel.totalIncome,
                            gradient: LinearGradient(
                                colors: [Color.green.opacity(0.8), Color.green],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            icon: "arrow.up.circle.fill",
                            iconColor: .white
                    ) {
                        showingAddTransaction = true
                    }
                    
                        // Expense Card
                    SummaryCard(
                            title: "EXPENSE",
                        amount: viewModel.totalExpense,
                            gradient: LinearGradient(
                                colors: [Color.red.opacity(0.8), Color.red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            icon: "arrow.down.circle.fill",
                            iconColor: .white
                    ) {
                        showingAddTransaction = true
                    }
                    
                        // Balance Card
                    SummaryCard(
                            title: "BALANCE",
                        amount: viewModel.balance,
                            gradient: LinearGradient(
                                colors: [Color.blue.opacity(0.8), Color.blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            icon: "dollarsign.circle.fill",
                            iconColor: .white
                        ) {
                            showingAddTransaction = true
                                    }
                                }
                    .padding(.horizontal, 20)
                    
                    // Budget Section
                    BudgetSection(
                        budget: viewModel.monthlyBudget,
                        totalExpense: viewModel.totalExpense,
                        onTap: { showingBudgetSettings = true }
                    )
                    
                    // Upcoming Bills Section
                    UpcomingBillsSection(
                        reminders: viewModel.reminders,
                        onAddReminder: { showingAddReminder = true },
                        viewModel: viewModel
                    )
                    
                    // Expense Breakdown Section
                    ExpenseBreakdownSection(
                        categoryTotals: viewModel.categoryTotals,
                        month: Date()
                    )
                    
                    // Recent Transactions Section
                    RecentTransactionsSection(
                        transactions: viewModel.transactions
                    )
                    
                    // Test Notifications Button (for development)
                    Button("Test Notifications") {
                        testNotifications()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.top, 20)
                    
                    Spacer(minLength: 100) // Space for bottom navigation
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingAddReminder) {
            AddReminderView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingBudgetSettings) {
            BudgetSettingsView(viewModel: viewModel)
        }
    }
    
    private func testNotifications() {
        // Test bill reminder
        let testReminder = Reminder(
            title: "Test Bill",
            amount: 50.0,
            dueDate: Date().addingTimeInterval(5), // 5 seconds from now
            notes: "Test notification"
        )
        NotificationManager.shared.scheduleBillReminder(for: testReminder)
        
        // Test budget warning
        NotificationManager.shared.checkBudgetWarnings(currentExpense: 1000.0, monthlyBudget: 800.0)
    }
}

// MARK: - Budget Section
struct BudgetSection: View {
    let budget: MonthlyBudget?
    let totalExpense: Double
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.title3)
                    .foregroundColor(.purple)
                
                Text("Monthly Budget")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: onTap) {
                    HStack(spacing: 4) {
                        Image(systemName: "gear")
                            .font(.caption)
                            .fontWeight(.bold)
                        Text("Settings")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.purple)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            
            if let budget = budget {
                VStack(spacing: 12) {
                    // Progress Bar
                    VStack(spacing: 8) {
                        HStack {
                            Text("Spent: $\(String(format: "%.2f", totalExpense))")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("Budget: $\(String(format: "%.2f", budget.totalLimit))")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        
                        ProgressView(value: min(totalExpense / budget.totalLimit, 1.0))
                            .progressViewStyle(LinearProgressViewStyle(tint: budget.isOverBudget ? .red : .green))
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                    }
                    
                    // Budget Status
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Remaining")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("$\(String(format: "%.2f", budget.remaining))")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(budget.remaining > 0 ? .green : .red)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Used")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(String(format: "%.1f", budget.percentageUsed))%")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(budget.isOverBudget ? .red : .primary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar")
                        .font(.title)
                        .foregroundColor(.gray)
                    
                    Text("No budget set")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button("Set Budget") {
                        onTap()
                    }
                    .font(.caption)
                    .foregroundColor(.purple)
                }
                .padding(.vertical, 20)
            }
        }
        .padding(20)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
    }
}

// MARK: - Summary Card
struct SummaryCard: View {
    let title: String
    let amount: Double
    let gradient: LinearGradient
    let icon: String
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(iconColor)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .tracking(0.5)
                
                Text("$\(String(format: "%.0f", amount))")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(gradient)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Upcoming Bills Section
struct UpcomingBillsSection: View {
    let reminders: [Reminder]
    let onAddReminder: () -> Void
    let viewModel: MainViewModel
    @State private var showingAllReminders = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "bell.fill")
                    .font(.title3)
                    .foregroundColor(.orange)
                
                Text("Upcoming Bills")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: onAddReminder) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.caption)
                            .fontWeight(.bold)
                        Text("Add")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            
            if reminders.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "bell.slash")
                        .font(.title)
                        .foregroundColor(.gray)
                    
                    Text("No upcoming bills")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button("Add Bill Reminder") {
                        onAddReminder()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                .padding(.vertical, 20)
            } else {
                ForEach(reminders.prefix(3)) { reminder in
                    ReminderRow(reminder: reminder, viewModel: viewModel)
                }
                
                // Add "View All" button if there are more than 3 reminders
                if reminders.count > 3 {
                    Button(action: {
                        showingAllReminders = true
                    }) {
                        HStack {
                            Text("View All Bills")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
        .sheet(isPresented: $showingAllReminders) {
            AllRemindersView(reminders: reminders, viewModel: viewModel)
        }
    }
}

// MARK: - All Reminders View
struct AllRemindersView: View {
    let reminders: [Reminder]
    let viewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddReminder = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(reminders) { reminder in
                    ReminderRow(reminder: reminder, viewModel: viewModel)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("All Bills")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddReminder = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddReminder) {
            AddReminderView(viewModel: viewModel)
        }
    }
}

// MARK: - Reminder Row
struct ReminderRow: View {
    let reminder: Reminder
    let viewModel: MainViewModel
    @State private var isCompleted: Bool
    @State private var showingEditSheet = false
    
    init(reminder: Reminder, viewModel: MainViewModel) {
        self.reminder = reminder
        self.viewModel = viewModel
        self._isCompleted = State(initialValue: reminder.isCompleted)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("$\(String(format: "%.2f", reminder.amount))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(reminder.dueDate, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                // Edit Button
                Button(action: {
                    showingEditSheet = true
                }) {
                    Image(systemName: "pencil")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
                
                // Complete/Incomplete Button
                Button(action: {
                    // Mark as completed
                    isCompleted.toggle()
                    let updatedReminder = Reminder(
                        title: reminder.title,
                        amount: reminder.amount,
                        dueDate: reminder.dueDate,
                        isCompleted: isCompleted,
                        notes: reminder.notes
                    )
                    viewModel.updateReminder(updatedReminder)
                }) {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(isCompleted ? .green : .gray)
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .opacity(isCompleted ? 0.6 : 1.0)
        .sheet(isPresented: $showingEditSheet) {
            EditReminderView(reminder: reminder, viewModel: viewModel)
        }
    }
}

// MARK: - Expense Breakdown Section
struct ExpenseBreakdownSection: View {
    let categoryTotals: [CategoryTotal]
    let month: Date
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Month: \(month, formatter: monthFormatter)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            if categoryTotals.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.pie")
                        .font(.title)
                        .foregroundColor(.gray)
                    
                    Text("No expenses this month")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 20)
            } else {
                PieChartView(
                    categoryTotals: categoryTotals,
                    month: month
                )
            }
        }
        .padding(20)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
    }
    
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM, yyyy"
        return formatter
    }
}

// MARK: - Recent Transactions Section
struct RecentTransactionsSection: View {
    let transactions: [Transaction]
    
    var recentTransactions: [Transaction] {
        Array(transactions.sorted { $0.date > $1.date }.prefix(4))
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Recent Transactions")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            if recentTransactions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "list.bullet")
                        .font(.title)
                        .foregroundColor(.gray)
                    
                    Text("No recent transactions")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 20)
            } else {
                VStack(spacing: 12) {
                    ForEach(recentTransactions) { transaction in
                        RecentTransactionRow(transaction: transaction)
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
    }
}

// MARK: - Recent Transaction Row
struct RecentTransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 12) {
            // Transaction icon
            Image(systemName: iconForCategory(transaction.category))
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    LinearGradient(
                        colors: transaction.type == .income ?
                            [Color.green.opacity(0.8), Color.green] :
                            [Color.red.opacity(0.8), Color.red],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description.isEmpty ? transaction.category : transaction.description)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(transaction.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(String(format: "%.2f", transaction.amount))")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(transaction.type == .income ? .green : .red)
                
                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func iconForCategory(_ category: String) -> String {
        switch category.lowercased() {
        case "food & dining": return "fork.knife"
        case "transportation": return "car.fill"
        case "shopping": return "bag.fill"
        case "entertainment": return "tv.fill"
        case "utilities": return "bolt.fill"
        case "healthcare": return "cross.fill"
        case "education": return "book.fill"
        case "insurance": return "shield.fill"
        case "salary": return "dollarsign.circle.fill"
        case "freelance": return "laptopcomputer"
        case "investment": return "chart.line.uptrend.xyaxis"
        case "business": return "building.2.fill"
        case "gift": return "gift.fill"
        case "refund": return "arrow.clockwise"
        default: return "circle.fill"
        }
    }
}

#Preview {
    HomeView(viewModel: MainViewModel())
}
