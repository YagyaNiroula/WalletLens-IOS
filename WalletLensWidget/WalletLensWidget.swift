//
//  WalletLensWidget.swift
//  WalletLensWidget
//
//  Created by Yagya Niroula on 2025-07-31.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> QuickBalanceEntry {
        QuickBalanceEntry(date: Date(), balance: 1250.0, income: 3000.0, expense: 1750.0, percentageChange: 5.2)
    }

    func getSnapshot(in context: Context, completion: @escaping (QuickBalanceEntry) -> ()) {
        let entry = QuickBalanceEntry(date: Date(), balance: 1250.0, income: 3000.0, expense: 1750.0, percentageChange: 5.2)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // Get data from UserDefaults (shared with main app)
        let userDefaults = UserDefaults(suiteName: "group.com.walletlens.widget") ?? UserDefaults.standard
        
        let currentDate = Date()
        let calendar = Calendar.current
        
        // Get current month's data
        let currentMonthStart = calendar.dateInterval(of: .month, for: currentDate)?.start ?? currentDate
        let currentMonthTransactions = loadTransactions(for: currentMonthStart, userDefaults: userDefaults)
        
        let currentIncome = currentMonthTransactions.filter { $0.type == "INCOME" }.reduce(0) { $0 + $1.amount }
        let currentExpense = currentMonthTransactions.filter { $0.type == "EXPENSE" }.reduce(0) { $0 + $1.amount }
        let currentBalance = currentIncome - currentExpense
        
        // Get previous month's data for percentage calculation
        let previousMonthStart = calendar.date(byAdding: .month, value: -1, to: currentMonthStart) ?? currentDate
        let previousMonthTransactions = loadTransactions(for: previousMonthStart, userDefaults: userDefaults)
        
        let previousIncome = previousMonthTransactions.filter { $0.type == "INCOME" }.reduce(0) { $0 + $1.amount }
        let previousExpense = previousMonthTransactions.filter { $0.type == "EXPENSE" }.reduce(0) { $0 + $1.amount }
        let previousBalance = previousIncome - previousExpense
        
        // Calculate percentage change
        let percentageChange: Double
        if previousBalance != 0 {
            percentageChange = ((currentBalance - previousBalance) / abs(previousBalance)) * 100
        } else {
            percentageChange = 0
        }
        
        let entry = QuickBalanceEntry(
            date: currentDate,
            balance: currentBalance,
            income: currentIncome,
            expense: currentExpense,
            percentageChange: percentageChange
        )
        
        // Update every 2 minutes for more responsive widget
        let nextUpdate = calendar.date(byAdding: .minute, value: 2, to: currentDate) ?? currentDate
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func loadTransactions(for monthStart: Date, userDefaults: UserDefaults?) -> [WidgetTransaction] {
        guard let userDefaults = userDefaults else {
            return []
        }
        
        guard let data = userDefaults.data(forKey: "widget_transactions") else {
            return []
        }
        
        do {
            let transactions = try JSONDecoder().decode([WidgetTransaction].self, from: data)
            let calendar = Calendar.current
            
            return transactions.filter { transaction in
                calendar.isDate(transaction.date, equalTo: monthStart, toGranularity: .month)
            }
        } catch {
            return []
        }
    }
}

struct QuickBalanceEntry: TimelineEntry {
    let date: Date
    let balance: Double
    let income: Double
    let expense: Double
    let percentageChange: Double
}

struct WidgetTransaction: Codable {
    let amount: Double
    let type: String
    let date: Date
}

struct WalletLensWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallBalanceView(entry: entry)
        case .systemMedium:
            MediumBalanceView(entry: entry)
        default:
            SmallBalanceView(entry: entry)
        }
    }
}

struct SmallBalanceView: View {
    let entry: QuickBalanceEntry
    
    var body: some View {
        VStack(spacing: 8) {
            // Balance
            VStack(spacing: 4) {
                Text("BALANCE")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .tracking(0.5)
                
                Text("$\(String(format: "%.0f", entry.balance))")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            
            Spacer()
            
            // Percentage change
            HStack(spacing: 4) {
                Image(systemName: entry.percentageChange >= 0 ? "arrow.up" : "arrow.down")
                    .font(.caption2)
                    .foregroundColor(.white)
                
                Text("\(String(format: "%.1f", abs(entry.percentageChange)))%")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: entry.balance >= 0 ? 
                    [Color.green.opacity(0.8), Color.green] : 
                    [Color.red.opacity(0.8), Color.red],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .widgetURL(URL(string: "walletlens://home"))
    }
}

struct MediumBalanceView: View {
    let entry: QuickBalanceEntry
    
    var body: some View {
        HStack(spacing: 16) {
            // Balance section
            VStack(spacing: 8) {
                Text("BALANCE")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .tracking(0.5)
                
                Text("$\(String(format: "%.0f", entry.balance))")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                HStack(spacing: 4) {
                    Image(systemName: entry.percentageChange >= 0 ? "arrow.up" : "arrow.down")
                        .font(.caption2)
                        .foregroundColor(.white)
                    
                    Text("\(String(format: "%.1f", abs(entry.percentageChange)))%")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            
            // Income and Expense
            VStack(spacing: 12) {
                // Income
                VStack(spacing: 4) {
                    Text("INCOME")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("$\(String(format: "%.0f", entry.income))")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                // Expense
                VStack(spacing: 4) {
                    Text("EXPENSE")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("$\(String(format: "%.0f", entry.expense))")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: entry.balance >= 0 ? 
                    [Color.green.opacity(0.8), Color.green] : 
                    [Color.red.opacity(0.8), Color.red],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .widgetURL(URL(string: "walletlens://home"))
    }
}

struct WalletLensWidget: Widget {
    let kind: String = "WalletLensWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WalletLensWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Quick Balance")
        .description("View your current month's balance, income, and expenses.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    WalletLensWidget()
} timeline: {
    QuickBalanceEntry(date: Date(), balance: 1250.0, income: 3000.0, expense: 1750.0, percentageChange: 5.2)
    QuickBalanceEntry(date: Date(), balance: -500.0, income: 2000.0, expense: 2500.0, percentageChange: -15.8)
}

#Preview(as: .systemMedium) {
    WalletLensWidget()
} timeline: {
    QuickBalanceEntry(date: Date(), balance: 1250.0, income: 3000.0, expense: 1750.0, percentageChange: 5.2)
    QuickBalanceEntry(date: Date(), balance: -500.0, income: 2000.0, expense: 2500.0, percentageChange: -15.8)
}
