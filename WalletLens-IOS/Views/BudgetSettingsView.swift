import SwiftUI

struct BudgetSettingsView: View {
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var monthlyBudget = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Text("Budget Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Set your monthly spending limit")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                // Current Budget Status
                if let budget = viewModel.monthlyBudget {
                    VStack(spacing: 16) {
                        Text("Current Monthly Budget")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 8) {
                            Text("$\(String(format: "%.2f", budget.totalLimit))")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            
                            Text("Spent: $\(String(format: "%.2f", budget.spent))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Remaining: $\(String(format: "%.2f", budget.remaining))")
                                .font(.subheadline)
                                .foregroundColor(budget.remaining > 0 ? .green : .red)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                
                // Budget Input
                VStack(spacing: 16) {
                    Text("Set New Monthly Budget")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text("$")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        TextField("Enter amount", text: $monthlyBudget)
                            .keyboardType(.decimalPad)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Save Button
                Button(action: saveBudget) {
                    Text("Save Budget")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(monthlyBudget.isEmpty)
                
                // Notification Settings
                VStack(spacing: 16) {
                    Text("Notification Settings")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 12) {
                        NotificationSettingRow(
                            title: "Bill Reminders",
                            description: "Get notified when bills are due",
                            isEnabled: true
                        )
                        
                        NotificationSettingRow(
                            title: "Budget Warnings",
                            description: "Get notified at 80% and 100% of budget",
                            isEnabled: true
                        )
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
        .alert("Budget Settings", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func saveBudget() {
        guard let amount = Double(monthlyBudget) else {
            alertMessage = "Please enter a valid amount"
            showingAlert = true
            return
        }
        
        viewModel.setMonthlyBudget(amount)
        alertMessage = "Budget saved successfully!"
        showingAlert = true
        monthlyBudget = ""
    }
}

struct NotificationSettingRow: View {
    let title: String
    let description: String
    let isEnabled: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: isEnabled ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundColor(isEnabled ? .green : .gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    BudgetSettingsView(viewModel: MainViewModel())
} 