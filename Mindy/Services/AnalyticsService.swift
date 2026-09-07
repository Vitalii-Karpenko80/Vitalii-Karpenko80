//
//  AnalyticsService.swift
//  Mindy
//
//  Сервис для аналитики и статистики задач
//

import Foundation

@MainActor
class AnalyticsService: ObservableObject {
    
    // MARK: - Analytics Data Models
    
    struct TaskStats {
        let totalTasks: Int
        let completedTasks: Int
        let pendingTasks: Int
        let highPriorityTasks: Int
        let mediumPriorityTasks: Int
        let lowPriorityTasks: Int
        
        var completionRate: Double {
            guard totalTasks > 0 else { return 0 }
            return Double(completedTasks) / Double(totalTasks) * 100
        }
    }
    
    struct CategoryStats {
        let calls: Int
        let meetings: Int
        let purchases: Int
        let reminders: Int
        let notes: Int
        let tasks: Int
        
        var total: Int {
            calls + meetings + purchases + reminders + notes + tasks
        }
        
        var mostCommon: (type: String, count: Int) {
            let categories = [
                ("call", calls),
                ("meeting", meetings),
                ("purchase", purchases),
                ("reminder", reminders),
                ("note", notes),
                ("task", tasks)
            ]
            return categories.max(by: { $0.1 < $1.1 }) ?? ("task", 0)
        }
    }
    
    struct TimeStats {
        let todayTasks: Int
        let tomorrowTasks: Int
        let thisWeekTasks: Int
        let thisMonthTasks: Int
        let noDueDateTasks: Int
        let overdueTasks: Int
    }
    
    struct ProductivityInsight {
        let title: String
        let description: String
        let icon: String
        let color: String
    }
    
    // MARK: - Analytics Methods
    
    func calculateStats(for thoughts: [Thought]) -> TaskStats {
        let completed = thoughts.filter { $0.isProcessed }.count
        let pending = thoughts.count - completed
        
        let high = thoughts.filter { $0.priority == "high" }.count
        let medium = thoughts.filter { $0.priority == "medium" }.count
        let low = thoughts.filter { $0.priority == "low" }.count
        
        return TaskStats(
            totalTasks: thoughts.count,
            completedTasks: completed,
            pendingTasks: pending,
            highPriorityTasks: high,
            mediumPriorityTasks: medium,
            lowPriorityTasks: low
        )
    }
    
    func calculateCategoryStats(for thoughts: [Thought]) -> CategoryStats {
        var calls = 0
        var meetings = 0
        var purchases = 0
        var reminders = 0
        var notes = 0
        var tasks = 0
        
        for thought in thoughts {
            switch thought.taskType {
            case "call": calls += 1
            case "meeting": meetings += 1
            case "purchase": purchases += 1
            case "reminder": reminders += 1
            case "note": notes += 1
            default: tasks += 1
            }
        }
        
        return CategoryStats(
            calls: calls,
            meetings: meetings,
            purchases: purchases,
            reminders: reminders,
            notes: notes,
            tasks: tasks
        )
    }
    
    func calculateTimeStats(for thoughts: [Thought]) -> TimeStats {
        let now = Date()
        let calendar = Calendar.current
        
        let today = calendar.startOfDay(for: now)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: today)!
        let monthEnd = calendar.date(byAdding: .month, value: 1, to: today)!
        
        var todayCount = 0
        var tomorrowCount = 0
        var weekCount = 0
        var monthCount = 0
        var noDueDate = 0
        var overdue = 0
        
        for thought in thoughts {
            guard let when = thought.when else {
                noDueDate += 1
                continue
            }
            
            if when < now && !thought.isProcessed {
                overdue += 1
            }
            
            if calendar.isDate(when, inSameDayAs: today) {
                todayCount += 1
            } else if when >= tomorrow && when < calendar.date(byAdding: .day, value: 1, to: tomorrow)! {
                tomorrowCount += 1
            } else if when >= today && when < weekEnd {
                weekCount += 1
            } else if when >= today && when < monthEnd {
                monthCount += 1
            }
        }
        
        return TimeStats(
            todayTasks: todayCount,
            tomorrowTasks: tomorrowCount,
            thisWeekTasks: weekCount,
            thisMonthTasks: monthCount,
            noDueDateTasks: noDueDate,
            overdueTasks: overdue
        )
    }
    
    func generateInsights(
        taskStats: TaskStats,
        categoryStats: CategoryStats,
        timeStats: TimeStats
    ) -> [ProductivityInsight] {
        var insights: [ProductivityInsight] = []
        
        // Completion rate insight
        if taskStats.completionRate >= 80 {
            insights.append(ProductivityInsight(
                title: "Отличная продуктивность! 🎉",
                description: "Вы выполнили \(Int(taskStats.completionRate))% задач",
                icon: "chart.line.uptrend.xyaxis",
                color: "green"
            ))
        } else if taskStats.completionRate >= 50 {
            insights.append(ProductivityInsight(
                title: "Хороший прогресс",
                description: "Выполнено \(Int(taskStats.completionRate))% задач. Так держать!",
                icon: "chart.bar.fill",
                color: "yellow"
            ))
        } else if taskStats.totalTasks > 0 {
            insights.append(ProductivityInsight(
                title: "Есть куда расти",
                description: "Выполнено только \(Int(taskStats.completionRate))% задач",
                icon: "chart.bar.xaxis",
                color: "red"
            ))
        }
        
        // Overdue tasks warning
        if timeStats.overdueTasks > 0 {
            insights.append(ProductivityInsight(
                title: "Просроченные задачи",
                description: "У вас \(timeStats.overdueTasks) просроченных задач",
                icon: "exclamationmark.triangle.fill",
                color: "red"
            ))
        }
        
        // High priority tasks
        if taskStats.highPriorityTasks > 0 {
            insights.append(ProductivityInsight(
                title: "Важные задачи",
                description: "\(taskStats.highPriorityTasks) задач высокого приоритета требуют внимания",
                icon: "flag.fill",
                color: "red"
            ))
        }
        
        // Most common task type
        let mostCommon = categoryStats.mostCommon
        if mostCommon.count > 0 {
            let typeNames: [String: String] = [
                "call": "звонков",
                "meeting": "встреч",
                "purchase": "покупок",
                "reminder": "напоминаний",
                "note": "заметок",
                "task": "задач"
            ]
            
            insights.append(ProductivityInsight(
                title: "Ваш фокус",
                description: "Больше всего \(typeNames[mostCommon.type] ?? "задач"): \(mostCommon.count)",
                icon: "target",
                color: "blue"
            ))
        }
        
        // Today's workload
        if timeStats.todayTasks > 5 {
            insights.append(ProductivityInsight(
                title: "Загруженный день",
                description: "Сегодня у вас \(timeStats.todayTasks) задач. Расставьте приоритеты!",
                icon: "calendar.badge.exclamationmark",
                color: "orange"
            ))
        } else if timeStats.todayTasks > 0 {
            insights.append(ProductivityInsight(
                title: "Спокойный день",
                description: "Всего \(timeStats.todayTasks) задач на сегодня",
                icon: "calendar",
                color: "green"
            ))
        }
        
        return insights
    }
    
    func getTasksForPeriod(_ period: String, from thoughts: [Thought]) -> [Thought] {
        let now = Date()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        
        switch period {
        case "today":
            return thoughts.filter { thought in
                guard let when = thought.when else { return false }
                return calendar.isDate(when, inSameDayAs: today)
            }
            
        case "tomorrow":
            guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) else {
                return []
            }
            return thoughts.filter { thought in
                guard let when = thought.when else { return false }
                return calendar.isDate(when, inSameDayAs: tomorrow)
            }
            
        case "week":
            guard let weekEnd = calendar.date(byAdding: .day, value: 7, to: today) else {
                return []
            }
            return thoughts.filter { thought in
                guard let when = thought.when else { return false }
                return when >= today && when < weekEnd
            }
            
        case "overdue":
            return thoughts.filter { thought in
                guard let when = thought.when else { return false }
                return when < now && !thought.isProcessed
            }
            
        default:
            return thoughts
        }
    }
}
