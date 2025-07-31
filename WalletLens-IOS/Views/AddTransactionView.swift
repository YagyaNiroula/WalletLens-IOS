import SwiftUI

struct AddTransactionView: View {
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount = ""
    @State private var description = ""
    @State private var category = "Food & Dining"  // Initialize with valid default
    @State private var transactionType: TransactionType
    @State private var date = Date()
    
    // Initialize with optional initial transaction type
    init(viewModel: MainViewModel, initialType: TransactionType = .expense) {
        self.viewModel = viewModel
        self._transactionType = State(initialValue: initialType)
        
        // Set appropriate default category based on initial type
        if initialType == .income {
            self._category = State(initialValue: "Salary")
        } else {
            self._category = State(initialValue: "Food & Dining")
        }
    }
    
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
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                // Date Field
                VStack(spacing: 8) {
                    Text("Date")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    DatePicker("", selection: $date, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .labelsHidden()
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        saveTransaction()
                    }
                    .fontWeight(.semibold)
                    .disabled(amount.isEmpty || category.isEmpty)
                }
            }
            .onAppear {
                // Ensure category is valid for current transaction type
                let validCategories = transactionType == .expense ? expenseCategories : incomeCategories
                if !validCategories.contains(category) {
                    category = validCategories[0]
                }
            }
        }
    }
    
    private func saveTransaction() {
        guard let amountValue = Double(amount), amountValue > 0 else { 
            print("Invalid amount: \(amount)")
            return 
        }
        
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedCategory.isEmpty else {
            print("Category cannot be empty")
            return
        }
        
        let transaction = Transaction(
            amount: amountValue,
            description: trimmedDescription,
            category: trimmedCategory,
            type: transactionType,
            date: date
        )
        
        viewModel.addTransaction(transaction)
        dismiss()
    }
}

#Preview {
    AddTransactionView(viewModel: MainViewModel())
}
