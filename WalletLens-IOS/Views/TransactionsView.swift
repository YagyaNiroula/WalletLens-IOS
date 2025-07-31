import SwiftUI

struct TransactionsView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var amount = ""
    @State private var description = ""
    @State private var category = "Food & Dining"
    @State private var transactionType: TransactionType = .expense
    @State private var date = Date()
    
    private let expenseCategories = [
        "Food & Dining", "Transportation", "Shopping", "Entertainment",
        "Utilities", "Healthcare", "Education", "Insurance", "Other"
    ]
    
    private let incomeCategories = [
        "Salary", "Freelance", "Investment", "Business", "Gift", "Refund", "Other Income"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Transaction Type Toggle
                VStack(spacing: 12) {
                    Text("Transaction Type")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 0) {
                        Button(action: { 
                            transactionType = .expense
                            // Update category when switching to expense
                            if !expenseCategories.contains(category) {
                                category = expenseCategories[0]
                            }
                        }) {
                            Text("Expense")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(transactionType == .expense ? .white : .primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(transactionType == .expense ? Color.red : Color(.systemGray5))
                        }
                        
                        Button(action: { 
                            transactionType = .income
                            // Update category when switching to income
                            if !incomeCategories.contains(category) {
                                category = incomeCategories[0]
                            }
                        }) {
                            Text("Income")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(transactionType == .income ? .white : .primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(transactionType == .income ? Color.green : Color(.systemGray5))
                        }
                    }
                    .cornerRadius(8)
                }
                
                // Amount Field
                VStack(spacing: 8) {
                    Text("Amount")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField("Enter amount", text: $amount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.title2)
                }
                
                // Description Field
                VStack(spacing: 8) {
                    Text("Description (Optional)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField("Enter description", text: $description)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Category Field
                VStack(spacing: 8) {
                    Text("Category")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Picker("Category", selection: $category) {
                        ForEach(transactionType == .expense ? expenseCategories : incomeCategories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                // Date Field
                VStack(spacing: 8) {
                    HStack {
                        Text("Date")
                            .font(.headline)
                        
                        Spacer()
                        
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .labelsHidden()
                    }
                }
                
                Spacer()
                
                // Add Button
                Button(action: addTransaction) {
                    Text("Add Transaction")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.8), Color.blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .disabled(amount.isEmpty)
                .opacity(amount.isEmpty ? 0.6 : 1.0)
            }
            .padding(20)
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func addTransaction() {
        guard let amountValue = Double(amount.trimmingCharacters(in: .whitespacesAndNewlines)),
              amountValue > 0 else {
            return
        }
        
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let transaction = Transaction(
            amount: amountValue,
            description: trimmedDescription,
            category: trimmedCategory,
            type: transactionType,
            date: date
        )
        
        viewModel.addTransaction(transaction)
        
        // Reset form
        amount = ""
        description = ""
        category = transactionType == .expense ? "Food & Dining" : "Salary"
        date = Date()
    }
}

#Preview {
    TransactionsView(viewModel: MainViewModel())
}
