import SwiftUI

struct AddReminderView: View {
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var amount = ""
    @State private var dueDate = Date()
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Subtitle
                Text("Set reminders for your upcoming bills")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
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
                        
                        DatePicker("", selection: $dueDate, displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())
                            .labelsHidden()
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
                .padding()
                
                Spacer()
            }
            .navigationTitle("Add Bill Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveReminder()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .disabled(title.isEmpty || amount.isEmpty)
                }
            }
        }
    }
    
    private func saveReminder() {
        guard let amountValue = Double(amount), amountValue > 0 else { 
            print("Invalid amount: \(amount)")
            return 
        }
        
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            print("Title cannot be empty")
            return
        }
        
        let reminder = Reminder(
            title: trimmedTitle,
            amount: amountValue,
            dueDate: dueDate,
            notes: notes.isEmpty ? nil : notes
        )
        
        viewModel.addReminder(reminder)
        dismiss()
    }
}

#Preview {
    AddReminderView(viewModel: MainViewModel())
}
