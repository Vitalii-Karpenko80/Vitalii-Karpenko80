//
//  AnalyticsView.swift
//  Mindy
//
//  Экран аналитики задач с дашбордом и графиками
//

import SwiftUI
import Charts

struct AnalyticsView: View {
    @EnvironmentObject var thoughtManager: ThoughtManager
    @StateObject private var analyticsService = AnalyticsService()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedGradientBackground()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Stats Cards
                        statsSection
                        
                        // Insights
                        insightsSection
                        
                        // Category Distribution
                        categorySection
                        
                        // Time Distribution
                        timeSection
                        
                        // Priority Breakdown
                        prioritySection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Аналитика")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.accentPrimary, .accentSecondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .springyButton()
                }
            }
        }
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        let stats = analyticsService.calculateStats(for: thoughtManager.thoughts)
        
        return VStack(spacing: 16) {
            Text("Общая статистика")
                .font(.title2())
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(
                    value: "\(stats.totalTasks)",
                    label: "Всего задач",
                    icon: "list.bullet",
                    color: .accentPrimary
                )
                
                StatCard(
                    value: "\(stats.completedTasks)",
                    label: "Выполнено",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatCard(
                    value: "\(stats.pendingTasks)",
                    label: "В работе",
                    icon: "clock.fill",
                    color: .orange
                )
                
                StatCard(
                    value: "\(Int(stats.completionRate))%",
                    label: "Процент выполнения",
                    icon: "chart.line.uptrend.xyaxis",
                    color: stats.completionRate >= 70 ? .green : .red
                )
            }
        }
    }
    
    // MARK: - Insights Section
    
    private var insightsSection: some View {
        let taskStats = analyticsService.calculateStats(for: thoughtManager.thoughts)
        let categoryStats = analyticsService.calculateCategoryStats(for: thoughtManager.thoughts)
        let timeStats = analyticsService.calculateTimeStats(for: thoughtManager.thoughts)
        let insights = analyticsService.generateInsights(
            taskStats: taskStats,
            categoryStats: categoryStats,
            timeStats: timeStats
        )
        
        return VStack(spacing: 16) {
            Text("Инсайты")
                .font(.title2())
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if insights.isEmpty {
                EmptyInsightCard()
            } else {
                ForEach(insights.indices, id: \.self) { index in
                    InsightCard(insight: insights[index])
                }
            }
        }
    }
    
    // MARK: - Category Section
    
    private var categorySection: some View {
        let categoryStats = analyticsService.calculateCategoryStats(for: thoughtManager.thoughts)
        
        return VStack(spacing: 16) {
            Text("Распределение по типам")
                .font(.title2())
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if categoryStats.total > 0 {
                VStack(spacing: 12) {
                    CategoryRow(label: "Звонки", count: categoryStats.calls, icon: "phone.fill", total: categoryStats.total)
                    CategoryRow(label: "Встречи", count: categoryStats.meetings, icon: "person.2.fill", total: categoryStats.total)
                    CategoryRow(label: "Покупки", count: categoryStats.purchases, icon: "cart.fill", total: categoryStats.total)
                    CategoryRow(label: "Напоминания", count: categoryStats.reminders, icon: "bell.fill", total: categoryStats.total)
                    CategoryRow(label: "Заметки", count: categoryStats.notes, icon: "note.text", total: categoryStats.total)
                    CategoryRow(label: "Задачи", count: categoryStats.tasks, icon: "checkmark.circle.fill", total: categoryStats.total)
                }
                .padding(20)
                .liquidGlassCard(tintColor: .glassTint, cornerRadius: 20)
            } else {
                EmptyStateCard(
                    icon: "square.grid.2x2",
                    message: "Нет данных по категориям"
                )
            }
        }
    }
    
    // MARK: - Time Section
    
    private var timeSection: some View {
        let timeStats = analyticsService.calculateTimeStats(for: thoughtManager.thoughts)
        
        return VStack(spacing: 16) {
            Text("Распределение по времени")
                .font(.title2())
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                TimeRow(label: "Сегодня", count: timeStats.todayTasks, icon: "calendar", color: .green)
                TimeRow(label: "Завтра", count: timeStats.tomorrowTasks, icon: "calendar.badge.plus", color: .blue)
                TimeRow(label: "На этой неделе", count: timeStats.thisWeekTasks, icon: "calendar.badge.clock", color: .purple)
                TimeRow(label: "В этом месяце", count: timeStats.thisMonthTasks, icon: "calendar.circle", color: .indigo)
                TimeRow(label: "Без даты", count: timeStats.noDueDateTasks, icon: "calendar.badge.minus", color: .gray)
                
                if timeStats.overdueTasks > 0 {
                    Divider()
                        .background(Color.glassBorder)
                    
                    TimeRow(label: "Просрочено", count: timeStats.overdueTasks, icon: "exclamationmark.triangle.fill", color: .red)
                }
            }
            .padding(20)
            .liquidGlassCard(tintColor: .glassTint, cornerRadius: 20)
        }
    }
    
    // MARK: - Priority Section
    
    private var prioritySection: some View {
        let stats = analyticsService.calculateStats(for: thoughtManager.thoughts)
        
        return VStack(spacing: 16) {
            Text("Приоритеты")
                .font(.title2())
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if stats.totalTasks > 0 {
                HStack(spacing: 12) {
                    PriorityCard(
                        emoji: "🔴",
                        label: "Высокий",
                        count: stats.highPriorityTasks,
                        color: .red
                    )
                    
                    PriorityCard(
                        emoji: "🟡",
                        label: "Средний",
                        count: stats.mediumPriorityTasks,
                        color: .yellow
                    )
                    
                    PriorityCard(
                        emoji: "🟢",
                        label: "Низкий",
                        count: stats.lowPriorityTasks,
                        color: .green
                    )
                }
            } else {
                EmptyStateCard(
                    icon: "flag",
                    message: "Нет данных о приоритетах"
                )
            }
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundStyle(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text(value)
                .font(.title())
                .foregroundColor(.textPrimary)
            
            Text(label)
                .font(.caption())
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .liquidGlassCard(tintColor: .glassTint, cornerRadius: 20)
    }
}

struct InsightCard: View {
    let insight: AnalyticsService.ProductivityInsight
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: insight.icon)
                .font(.system(size: 32))
                .foregroundStyle(
                    LinearGradient(
                        colors: [colorFromString(insight.color), colorFromString(insight.color).opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(insight.title)
                    .font(.body(16))
                    .foregroundColor(.textPrimary)
                
                Text(insight.description)
                    .font(.caption())
                    .foregroundColor(.textSecondary)
                    .lineSpacing(4)
            }
            
            Spacer()
        }
        .padding(20)
        .liquidGlassCard(tintColor: .glassTint, cornerRadius: 20)
    }
    
    private func colorFromString(_ string: String) -> Color {
        switch string {
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        case "yellow": return .yellow
        case "orange": return .orange
        case "purple": return .purple
        default: return .accentPrimary
        }
    }
}

struct EmptyInsightCard: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "lightbulb")
                .font(.system(size: 40))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.accentPrimary, .accentSecondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Создайте больше задач для персональных инсайтов")
                .font(.caption())
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .liquidGlassCard(tintColor: .glassTint, cornerRadius: 20)
    }
}

struct CategoryRow: View {
    let label: String
    let count: Int
    let icon: String
    let total: Int
    
    var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body(16))
                .foregroundColor(.accentPrimary)
                .frame(width: 24)
            
            Text(label)
                .font(.body())
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            Text("\(count)")
                .font(.body())
                .foregroundColor(.textSecondary)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.glassBorder)
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.accentPrimary, .accentSecondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * percentage, height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(width: 60, height: 6)
        }
    }
}

struct TimeRow: View {
    let label: String
    let count: Int
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body(16))
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(label)
                .font(.body())
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            Text("\(count)")
                .font(.title3)
                .foregroundColor(color)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(color.opacity(0.2))
                )
        }
    }
}

struct PriorityCard: View {
    let emoji: String
    let label: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Text(emoji)
                .font(.system(size: 40))
            
            Text("\(count)")
                .font(.title())
                .foregroundColor(.textPrimary)
            
            Text(label)
                .font(.caption())
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .liquidGlassCard(tintColor: color.opacity(0.1), cornerRadius: 16)
    }
}

struct EmptyStateCard: View {
    let icon: String
    let message: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.textTertiary)
            
            Text(message)
                .font(.caption())
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .liquidGlassCard(tintColor: .glassTint, cornerRadius: 20)
    }
}
