//
//  ContentView.swift
//  Demo_Crypto
//
//  Created by Bahadır Tarcan on 22.01.2025.
//

import SwiftUI

// Custom Colors
struct AppColors {
    static let background = Color.black
    static let cardBackground = Color(hex: "1C1C1E")
    static let accent = Color(hex: "5E5CE6") // Primary accent color (purple-blue)
    static let secondaryAccent = Color(hex: "30D158") // Success color (green)
    static let warningAccent = Color(hex: "FF453A") // Warning color (red)
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "8E8E93")
}

// Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct StatisticCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .foregroundColor(AppColors.textSecondary)
                .font(.system(size: 16, weight: .medium))
            Text(value)
                .foregroundColor(color)
                .font(.system(size: 24, weight: .bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
}

struct CalendarView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedTimeFrame = "Monthly"
    @State private var currentDate = Date()
    
    let timeFrames = ["Monthly", "Yearly"]
    let weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    // Simulated PNL data - In real app, this would come from your data model
    let pnlData: [Int: (Double, Bool)] = [
        1: (-123.45, false),
        3: (456.78, true),
        5: (-89.32, false),
        8: (234.56, true),
        10: (-45.67, false),
        15: (678.90, true),
        17: (-321.54, false),
        22: (432.10, true),
        25: (-234.56, false),
        28: (567.89, true),
        31: (-178.90, false)
    ]
    
    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday as first day
        return calendar
    }
    
    private var month: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate)
    }
    
    private var daysInMonth: [[Date?]] {
        let interval = calendar.dateInterval(of: .month, for: currentDate)!
        let firstDay = interval.start
        
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let offsetDays = firstWeekday - calendar.firstWeekday
        
        let daysInMonth = calendar.range(of: .day, in: .month, for: currentDate)!.count
        
        var days: [Date?] = Array(repeating: nil, count: offsetDays)
        
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days.chunked(into: 7)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Time Frame Selector
                HStack(spacing: 0) {
                    ForEach(timeFrames, id: \.self) { frame in
                        Button(action: {
                            selectedTimeFrame = frame
                        }) {
                            Text(frame)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(selectedTimeFrame == frame ? AppColors.accent : AppColors.cardBackground)
                                .foregroundColor(selectedTimeFrame == frame ? AppColors.textPrimary : AppColors.textSecondary)
                        }
                    }
                }
                .background(AppColors.cardBackground)
                .cornerRadius(16)
                .padding(.horizontal)
                
                // Month Navigation
                HStack {
                    Button(action: {
                        if let newDate = calendar.date(byAdding: .month, value: -1, to: currentDate) {
                            currentDate = newDate
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(AppColors.textPrimary)
                            .padding()
                    }
                    
                    Spacer()
                    
                    Text(month)
                        .font(.title2.bold())
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Button(action: {
                        if let newDate = calendar.date(byAdding: .month, value: 1, to: currentDate) {
                            currentDate = newDate
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(AppColors.textPrimary)
                            .padding()
                    }
                }
                .padding(.horizontal)
                
                // Week Days
                HStack(spacing: 0) {
                    ForEach(weekDays, id: \.self) { day in
                        Text(day)
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)
                
                // Calendar Grid
                VStack(spacing: 2) {
                    ForEach(daysInMonth.indices, id: \.self) { week in
                        HStack(spacing: 2) {
                            ForEach(0..<7) { day in
                                if let date = daysInMonth[week][day] {
                                    let dayNumber = calendar.component(.day, from: date)
                                    let pnlInfo = pnlData[dayNumber]
                                    
                                    Button(action: {
                                        // Handle date selection
                                    }) {
                                        VStack(spacing: 4) {
                                            Text("\(dayNumber)")
                                                .font(.system(size: 16, weight: .medium))
                                            
                                            if let (value, isPositive) = pnlInfo {
                                                Text(String(format: "%.1f", abs(value)))
                                                    .font(.system(size: 12, weight: .medium))
                                                    .foregroundColor(isPositive ? AppColors.secondaryAccent : AppColors.warningAccent)
                                                    .padding(.horizontal, 4)
                                                    .padding(.vertical, 2)
                                                    .background(
                                                        (isPositive ? AppColors.secondaryAccent : AppColors.warningAccent)
                                                            .opacity(0.2)
                                                    )
                                                    .cornerRadius(4)
                                            }
                                        }
                                        .frame(maxWidth: .infinity, minHeight: 60)
                                        .background(AppColors.cardBackground)
                                        .foregroundColor(AppColors.textPrimary)
                                    }
                                } else {
                                    Color.clear
                                        .frame(maxWidth: .infinity, minHeight: 60)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }
            .background(AppColors.background)
        }
    }
}

// Array Extension for chunking
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

struct DashboardView: View {
    @State private var showingCalendar = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Text("Default Portfolio")
                        .font(.title)
                        .bold()
                        .foregroundColor(AppColors.textPrimary)
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "line.3.horizontal.decrease")
                            .foregroundColor(AppColors.textPrimary)
                            .font(.system(size: 20))
                    }
                    Button(action: {
                        showingCalendar = true
                    }) {
                        Image(systemName: "calendar")
                            .foregroundColor(AppColors.textPrimary)
                            .font(.system(size: 20))
                    }
                }
                .padding(.horizontal)
                
                // Statistics Grid
                VStack(spacing: 20) {
                    Text("Statistics")
                        .font(.title2)
                        .bold()
                        .foregroundColor(AppColors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Text("Trade Count:")
                            .foregroundColor(AppColors.textSecondary)
                        Spacer()
                        Text("0")
                            .bold()
                            .foregroundColor(AppColors.textPrimary)
                    }
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        StatisticCard(title: "Average RR", value: "0", color: AppColors.textPrimary)
                        StatisticCard(title: "Win Rate", value: "0%", color: AppColors.textPrimary)
                        StatisticCard(title: "Expected Value", value: "0", color: AppColors.textPrimary)
                        StatisticCard(title: "Profit Factor", value: "0", color: AppColors.textPrimary)
                        StatisticCard(title: "Average Win", value: "0", color: AppColors.secondaryAccent)
                        StatisticCard(title: "Average Loss", value: "0", color: AppColors.warningAccent)
                    }
                    
                    // Average Holding Time
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Average Holding Time")
                            .foregroundColor(AppColors.textSecondary)
                            .font(.system(size: 16, weight: .medium))
                        HStack(spacing: 8) {
                            Image(systemName: "clock.fill")
                                .foregroundColor(AppColors.accent)
                            Text("0")
                                .foregroundColor(AppColors.accent)
                                .font(.system(size: 18, weight: .semibold))
                            Text("Days")
                                .foregroundColor(AppColors.textSecondary)
                            Text("5")
                                .foregroundColor(AppColors.accent)
                                .font(.system(size: 18, weight: .semibold))
                            Text("Hours")
                                .foregroundColor(AppColors.textSecondary)
                            Text("50")
                                .foregroundColor(AppColors.warningAccent)
                                .font(.system(size: 18, weight: .semibold))
                            Text("Minutes")
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                }
                .padding()
                
                // Finished Trades Section
                VStack(spacing: 20) {
                    Text("Finished Trades")
                        .font(.title2)
                        .bold()
                        .foregroundColor(AppColors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    // Total PNL Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Total PNL")
                            .font(.title3)
                            .bold()
                            .foregroundColor(AppColors.textPrimary)
                        
                        if true {
                            Text("No Finished Trades Found")
                                .foregroundColor(AppColors.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 20)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Daily PNL Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Daily PNL")
                            .font(.title3)
                            .bold()
                            .foregroundColor(AppColors.textPrimary)
                        
                        if true {
                            Text("No Finished Trades Found")
                                .foregroundColor(AppColors.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 20)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
            }
        }
        .background(AppColors.background)
        .sheet(isPresented: $showingCalendar) {
            CalendarView()
        }
    }
}

struct LiveTradesView: View {
    var body: some View {
        Text("Live Trades")
    }
}

struct AddTradeView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedPortfolio = "Default Portfolio"
    @State private var tradeType = "Buy (long)"
    @State private var symbol = ""
    @State private var fee = ""
    @State private var entry1 = ""
    @State private var isCompleted = true
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Portfolio Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Portfolio")
                            .font(.title3)
                            .foregroundColor(AppColors.textPrimary)
                        Menu {
                            Button("Default Portfolio") {
                                selectedPortfolio = "Default Portfolio"
                            }
                        } label: {
                            HStack {
                                Text(selectedPortfolio)
                                    .foregroundColor(AppColors.textPrimary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(AppColors.accent)
                            }
                            .padding()
                            .background(AppColors.cardBackground)
                            .cornerRadius(16)
                        }
                    }
                    
                    // Trade Type Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Type")
                            .font(.title3)
                            .foregroundColor(AppColors.textPrimary)
                        HStack(spacing: 12) {
                            Button(action: { tradeType = "Buy (long)" }) {
                                Text("Buy (long)")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(tradeType == "Buy (long)" ? AppColors.secondaryAccent.opacity(0.2) : AppColors.cardBackground)
                                    .foregroundColor(tradeType == "Buy (long)" ? AppColors.secondaryAccent : AppColors.textSecondary)
                                    .cornerRadius(16)
                            }
                            
                            Button(action: { tradeType = "Sell (short)" }) {
                                Text("Sell (short)")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(tradeType == "Sell (short)" ? AppColors.warningAccent.opacity(0.2) : AppColors.cardBackground)
                                    .foregroundColor(tradeType == "Sell (short)" ? AppColors.warningAccent : AppColors.textSecondary)
                                    .cornerRadius(16)
                            }
                        }
                    }
                    
                    // Symbol Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Symbol")
                            .font(.title3)
                            .foregroundColor(AppColors.textPrimary)
                        HStack {
                            TextField("", text: $symbol)
                                .padding()
                                .background(AppColors.cardBackground)
                                .cornerRadius(16)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Button(action: {}) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .foregroundColor(AppColors.accent)
                                    .font(.title2)
                            }
                        }
                    }
                    
                    // Fee Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Fee")
                            .font(.title3)
                            .foregroundColor(AppColors.textPrimary)
                        TextField("", text: $fee)
                            .padding()
                            .background(AppColors.cardBackground)
                            .cornerRadius(16)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    
                    // Entries Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Entries")
                                .font(.title3)
                                .foregroundColor(AppColors.textPrimary)
                            Spacer()
                            Button(action: {}) {
                                Text("Add More")
                                    .foregroundColor(AppColors.accent)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(AppColors.accent.opacity(0.2))
                                    .cornerRadius(20)
                            }
                        }
                        
                        TextField("Entry 1", text: $entry1)
                            .padding()
                            .background(AppColors.cardBackground)
                            .cornerRadius(16)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    
                    // Status Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Status")
                            .font(.title3)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text(isCompleted ? "Completed" : "Pending")
                            .foregroundColor(isCompleted ? AppColors.secondaryAccent : AppColors.textSecondary)
                            .font(.title3)
                        
                        HStack(spacing: 16) {
                            Button(action: { isCompleted = true }) {
                                Image(systemName: "checkmark")
                                    .padding()
                                    .background(isCompleted ? AppColors.accent : AppColors.cardBackground)
                                    .foregroundColor(isCompleted ? AppColors.textPrimary : AppColors.textSecondary)
                                    .cornerRadius(16)
                            }
                            
                            Button(action: { isCompleted = false }) {
                                Image(systemName: "clock")
                                    .padding()
                                    .background(!isCompleted ? AppColors.accent : AppColors.cardBackground)
                                    .foregroundColor(!isCompleted ? AppColors.textPrimary : AppColors.textSecondary)
                                    .cornerRadius(16)
                            }
                        }
                    }
                    
                    // Date and Time Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Date and Time")
                            .font(.title3)
                            .foregroundColor(AppColors.textPrimary)
                        
                        DatePicker("", selection: $selectedDate)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .colorInvert()
                            .colorMultiply(AppColors.accent)
                    }
                    
                    // Submit Button
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Submit")
                            .font(.title3.bold())
                            .foregroundColor(AppColors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.accent)
                            .cornerRadius(16)
                    }
                    .padding(.top)
                }
                .padding()
            }
            .background(AppColors.background)
            .navigationTitle("Add Trade")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }
        }
    }
}

struct HistoryView: View {
    var body: some View {
        Text("History")
    }
}

struct AlarmsView: View {
    var body: some View {
        Text("Alarms")
    }
}

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                DashboardView()
            }
            .tabItem {
                Image(systemName: "star.fill")
                Text("Home")
            }
            .tag(0)
            
            NavigationView {
                LiveTradesView()
            }
            .tabItem {
                Image(systemName: "chart.line.uptrend.xyaxis")
                Text("Live Trades")
            }
            .tag(1)
            
                AddTradeView()
            .tabItem {
                Image(systemName: "plus")
                Text("Add Trade")
            }
            .tag(2)
            
            NavigationView {
                HistoryView()
            }
            .tabItem {
                Image(systemName: "clock.arrow.circlepath")
                Text("History")
            }
            .tag(3)
            
            NavigationView {
                AlarmsView()
            }
            .tabItem {
                Image(systemName: "bell")
                Text("Alarms")
            }
            .tag(4)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
