import SwiftUI
import AVFoundation

struct CameraView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var showingImagePicker = false
    @State private var showingAddTransaction = false
    @State private var capturedImage: UIImage?
    @State private var extractedAmount: Double = 0.0
    @State private var isProcessing = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Enhanced Header
                VStack(spacing: 12) {
                    Text("Receipt Scanner")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Select receipt photos to add transactions automatically")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .background(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Enhanced Camera Preview Area
                        VStack(spacing: 20) {
                ZStack {
                                RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemGray6))
                        .frame(height: 300)
                        .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(.systemGray4), lineWidth: 2)
                        )
                                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    
                    VStack(spacing: 20) {
                        if let image = capturedImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 200)
                                            .cornerRadius(16)
                                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        } else {
                            VStack(spacing: 16) {
                                Image(systemName: "camera.fill")
                                                .font(.system(size: 80))
                                    .foregroundColor(.secondary)
                                                .opacity(0.6)
                                
                                                                Text("Tap to select receipt photo")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }
                        }
                        
                        if isProcessing {
                                        HStack(spacing: 12) {
                                ProgressView()
                                                .scaleEffect(1.2)
                                Text("Processing receipt...")
                                    .font(.subheadline)
                                                .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                            }
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .onTapGesture {
                    if capturedImage == nil {
                        showingImagePicker = true
                    }
                }
                        }
                        .padding(.horizontal)

                        // Enhanced Instructions
                        VStack(spacing: 20) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .font(.title2)
                                .foregroundColor(.blue)
                                Text("How it works:")
                                .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            Spacer()
                        }
                        
                            VStack(spacing: 16) {
                                InstructionStep(
                                    number: "1",
                                    title: "Take a photo of your receipt",
                                    icon: "camera.fill"
                                )

                                InstructionStep(
                                    number: "2",
                                    title: "We'll extract the amount automatically",
                                    icon: "doc.text.magnifyingglass"
                                )

                                InstructionStep(
                                    number: "3",
                                    title: "Review and save the transaction",
                                    icon: "checkmark.circle.fill"
                                )
                            }
                        }
                        .padding(24)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.blue.opacity(0.1), lineWidth: 1)
                        )
                        .padding(.horizontal)
                
                        Spacer(minLength: 100)
                    }
                    .padding(.vertical)
                }
                
                // Enhanced Action Buttons
                if capturedImage != nil {
                    HStack(spacing: 16) {
                        Button("Retake") {
                            capturedImage = nil
                            extractedAmount = 0.0
                            isProcessing = false
                        }
                        .foregroundColor(.red)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        Button("Process") {
                            processImage()
                        }
                        .foregroundColor(.white)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.8), Color.blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: -2)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $capturedImage, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionFromReceiptView(viewModel: viewModel, amount: extractedAmount, image: capturedImage) {
                // Reset camera view after transaction is saved
                resetCameraView()
            }
        }
    }
    
    private func processImage() {
        guard let image = capturedImage else { return }
        
        isProcessing = true
        
        // Simulate OCR processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // For demo purposes, extract a random amount
            let randomAmount = Double.random(in: 10.0...100.0)
            extractedAmount = round(randomAmount * 100) / 100
            isProcessing = false
            showingAddTransaction = true
        }
    }
    
    private func resetCameraView() {
        capturedImage = nil
        extractedAmount = 0.0
        isProcessing = false
        showingAddTransaction = false
    }
}

// Enhanced Instruction Step
struct InstructionStep: View {
    let number: String
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 32, height: 32)

                Text(number)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }

            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)

            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)

            Spacer()
        }
    }
}

struct AddTransactionFromReceiptView: View {
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss
    
    let amount: Double
    let image: UIImage?
    let onTransactionSaved: () -> Void
    
    @State private var description = "Receipt"
    @State private var category = "Food & Dining"  // Initialize with valid default
    
    private let categories = [
        "Food & Dining", "Transportation", "Shopping", "Entertainment",
        "Utilities", "Healthcare", "Education", "Insurance", "Other"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                }
                
                VStack(spacing: 20) {
                    // Enhanced Amount Display
                    VStack(spacing: 8) {
                        Text("Extracted Amount")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Text("$\(String(format: "%.2f", amount))")
                            .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Enhanced Form Fields
                    VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        Text("Description")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        TextField("Description", text: $description)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    VStack(spacing: 8) {
                        Text("Category")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Picker("Category", selection: $category) {
                            ForEach(categories, id: \.self) { cat in
                                Text(cat).tag(cat)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Add Receipt Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                    .fontWeight(.semibold)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTransaction()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                }
            }
        }
    }
    
    private func saveTransaction() {
        guard amount > 0 else {
            return
        }

        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedCategory.isEmpty else {
            return
        }

        let transaction = Transaction(
            amount: amount,
            description: trimmedDescription,
            category: trimmedCategory,
            type: .expense,
            date: Date()
        )
        
        viewModel.addTransaction(transaction)
        onTransactionSaved() // Call the callback to reset camera view
        dismiss()
    }
}

#Preview {
    CameraView(viewModel: MainViewModel())
}
