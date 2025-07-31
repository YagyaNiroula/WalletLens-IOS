import SwiftUI

struct ReceiptView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var selectedMonth = Date()
    
    var monthlyTransactions: [Transaction] {
        let calendar = Calendar.current
        return viewModel.transactions.filter { transaction in
            calendar.isDate(transaction.date, equalTo: selectedMonth, toGranularity: .month)
        }.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Month Selector
                MonthSelector(selectedMonth: $selectedMonth)
                    .padding(.horizontal, 20)
                
                if monthlyTransactions.isEmpty {
                    // Empty state
                    VStack(spacing: 20) {
                        Image(systemName: "doc.text.viewfinder")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Transactions This Month")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Add your first transaction to get started")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        

                    }
                    .padding(32)
                } else {
                    // Transaction list
                    List {
                        ForEach(monthlyTransactions) { transaction in
                            ReceiptRow(transaction: transaction)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Monthly Transactions")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Month Selector
struct MonthSelector: View {
    @Binding var selectedMonth: Date
    
    var body: some View {
        HStack {
            Button(action: {
                withAnimation {
                    selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            Text(monthYearString(from: selectedMonth))
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Receipt Row
struct ReceiptRow: View {
    let transaction: Transaction
    @State private var showingTransactionDetail = false
    
    var body: some View {
        Button(action: {
            showingTransactionDetail = true
        }) {
            HStack(spacing: 16) {
                // Transaction icon
                Image(systemName: iconForCategory(transaction.category))
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        LinearGradient(
                            colors: transaction.type == .income ?
                                [Color.green.opacity(0.8), Color.green] :
                                [Color.red.opacity(0.8), Color.red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.description.isEmpty ? transaction.category : transaction.description)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(transaction.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(transaction.date, style: .date)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(String(format: "%.2f", transaction.amount))")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(transaction.type == .income ? .green : .red)
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingTransactionDetail) {
            TransactionDetailView(transaction: transaction)
        }
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

// MARK: - Transaction Detail View
struct TransactionDetailView: View {
    let transaction: Transaction
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Transaction icon
                    VStack(spacing: 12) {
                        Image(systemName: iconForCategory(transaction.category))
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                            .frame(width: 100, height: 100)
                            .background(
                                LinearGradient(
                                    colors: transaction.type == .income ?
                                        [Color.green.opacity(0.8), Color.green] :
                                        [Color.red.opacity(0.8), Color.red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                        
                        Text(transaction.type == .income ? "Income" : "Expense")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Transaction details
                    VStack(spacing: 16) {
                        DetailRow(title: "Amount", value: "$\(String(format: "%.2f", transaction.amount))", color: transaction.type == .income ? .green : .red)
                        DetailRow(title: "Category", value: transaction.category, color: .primary)
                        DetailRow(title: "Description", value: transaction.description.isEmpty ? "No description" : transaction.description, color: .primary)
                        DetailRow(title: "Type", value: transaction.type == .income ? "Income" : "Expense", color: transaction.type == .income ? .green : .red)
                        DetailRow(title: "Date", value: transaction.date.formatted(date: .long, time: .shortened), color: .primary)
                        if transaction.imagePath != nil {
                            DetailRow(title: "Receipt", value: "Available", color: .blue)
                        }
                    }
                    .padding(20)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(20)
            }
            .navigationTitle("Transaction Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
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

// MARK: - Detail Row
struct DetailRow: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

#Preview {
    ReceiptView(viewModel: MainViewModel())
} 