import SwiftUI
import Charts

struct PieChartView: View {
    let categoryTotals: [CategoryTotal]
    let month: Date
    
    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM, yyyy"
        return formatter
    }()
    
    private let colors: [Color] = [
        .blue, .red, .green, .orange, .purple, .pink, .yellow, .gray
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            // Month Header
            Text("Month: \(monthFormatter.string(from: month))")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            if categoryTotals.isEmpty {
                // Empty State
                VStack(spacing: 12) {
                    Image(systemName: "chart.pie")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                        .opacity(0.6)
                    
                    Text("No expense data")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(height: 200)
            } else {
                // Pie Chart
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 1)
                        .frame(width: 200, height: 200)
                    
                    // Pie Chart Segments
                    ForEach(Array(categoryTotals.enumerated()), id: \.offset) { index, category in
                        PieChartSegment(
                            category: category,
                            total: categoryTotals.reduce(0) { $0 + $1.total },
                            startAngle: startAngle(for: index),
                            color: colors[index % colors.count]
                        )
                    }
                }
                .frame(width: 200, height: 200)
                
                // Legend
                VStack(spacing: 8) {
                    ForEach(Array(categoryTotals.enumerated()), id: \.offset) { index, category in
                        HStack {
                            Circle()
                                .fill(colors[index % colors.count])
                                .frame(width: 12, height: 12)
                            
                            Text(category.category)
                                .font(.caption)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("$\(String(format: "%.2f", category.total))")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.blue.opacity(0.1), lineWidth: 1)
        )
    }
    
    private func startAngle(for index: Int) -> Double {
        let total = categoryTotals.reduce(0) { $0 + $1.total }
        let previousSlices = categoryTotals.prefix(index).reduce(0) { $0 + $1.total }
        return (previousSlices / total) * 360
    }
}

struct PieChartSegment: View {
    let category: CategoryTotal
    let total: Double
    let startAngle: Double
    let color: Color
    
    private var endAngle: Double {
        startAngle + (category.total / total) * 360
    }
    
    var body: some View {
        Path { path in
            let center = CGPoint(x: 100, y: 100)
            let radius: CGFloat = 90
            
            path.move(to: center)
            path.addArc(
                center: center,
                radius: radius,
                startAngle: Angle(degrees: startAngle),
                endAngle: Angle(degrees: endAngle),
                clockwise: false
            )
            path.closeSubpath()
        }
        .fill(color)
        .overlay(
            Path { path in
                let center = CGPoint(x: 100, y: 100)
                let radius: CGFloat = 90
                
                path.move(to: center)
                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: Angle(degrees: startAngle),
                    endAngle: Angle(degrees: endAngle),
                    clockwise: false
                )
                path.closeSubpath()
            }
            .stroke(Color.white, lineWidth: 2)
        )
    }
}

#Preview {
    PieChartView(
        categoryTotals: [
            CategoryTotal(category: "Food & Dining", total: 150.0),
            CategoryTotal(category: "Transportation", total: 80.0),
            CategoryTotal(category: "Shopping", total: 120.0),
            CategoryTotal(category: "Entertainment", total: 60.0)
        ],
        month: Date()
    )
} 