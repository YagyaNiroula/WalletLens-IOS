import SwiftUI

struct EditReminderView: View {
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss
    
    let reminder: Reminder
    
    @State private var title: String
    @State private var amount: String
    @State private var dueDate: Date
    @State private var notes: String
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init(reminder: Reminder, viewModel: MainViewModel) {
        self.reminder = reminder
        self.viewModel = viewModel
        self._title = State(initialValue: reminder.title)
        self._amount = State(initialValue: String(format: "%.2f", reminder.amount))
        self._dueDate = State(initialValue: reminder.dueDate)
        self._notes = State(initialValue: reminder.notes ?? "")
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 12) {
                    Text("Edit Bill Reminder")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Update your bill reminder details")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                // Form Fields
                VStack(spacing: 16) {
                    // Title Field
                    VStack(spacing: 8) {
                        Text("Bill Title")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        TextField("Enter bill title", text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Amount Field
                    VStack(spacing: 8) {
                        Text("Amount")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        TextField("Enter amount", text: $amount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Due Date Field
                    VStack(spacing: 8) {
                        Text("Due Date")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())
                            .padding(.horizontal)
                    }
                    
                    // Notes Field
                    VStack(spacing: 8) {
                        Text("Notes (Optional)")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        TextField("Add notes", text: $notes, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                    }
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: saveChanges) {
                        Text("Save Changes")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(title.isEmpty || amount.isEmpty)
                    
                    Button(action: deleteReminder) {
                        Text("Delete Bill")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding()
            .navigationBarHidden(true)
        }
        .alert("Edit Reminder", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func saveChanges() {
        guard !title.isEmpty else {
            alertMessage = "Please enter a bill title"
            showingAlert = true
            return
        }
        
        guard let amountValue = Double(amount) else {
            alertMessage = "Please enter a valid amount"
            showingAlert = true
            return
        }
        
        let updatedReminder = Reminder(
            title: title,
            amount: amountValue,
            dueDate: dueDate,
            isCompleted: reminder.isCompleted,
            notes: notes.isEmpty ? nil : notes
        )
        
        viewModel.updateReminder(updatedReminder)
        alertMessage = "Bill reminder updated successfully!"
        showingAlert = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            dismiss()
        }
    }
    
    private func deleteReminder() {
        viewModel.deleteReminder(reminder)
        alertMessage = "Bill reminder deleted successfully!"
        showingAlert = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            dismiss()
        }
    }
}

#Preview {
    EditReminderView(
        reminder: Reminder(
            title: "Electric Bill",
            amount: 75.50,
            dueDate: Date().addingTimeInterval(86400 * 7),
            notes: "Monthly electricity bill"
        ),
        viewModel: MainViewModel()
    )
} 