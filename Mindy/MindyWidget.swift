//
//  MindyWidget.swift
//  Mindy Widget Extension
//
//  Lock Screen Widget для быстрого доступа (iOS 2026)
//

import WidgetKit
import SwiftUI
import AppIntents

struct MindyWidget: Widget {
    let kind: String = "MindyWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: RecordThoughtIntent.self,
            provider: Provider()
        ) { entry in
            MindyWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Mindy")
        .description("Your AI thought companion")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }
    
    func snapshot(for configuration: RecordThoughtIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date())
    }
    
    func timeline(for configuration: RecordThoughtIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let entry = SimpleEntry(date: Date())
        return Timeline(entries: [entry], policy: .never)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct MindyWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            circularView
        case .accessoryRectangular:
            rectangularView
        case .accessoryInline:
            inlineView
        default:
            circularView
        }
    }
    
    private var circularView: some View {
        ZStack {
            AccessoryWidgetBackground()
            Image(systemName: "brain.head.profile")
                .font(.title)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.cyan, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
    
    private var rectangularView: some View {
        HStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.title2)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.cyan, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            VStack(alignment: .leading, spacing: 2) {
                Text("Mindy")
                    .font(.headline)
                Text("Capture thoughts")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
    }
    
    private var inlineView: some View {
        HStack {
            Image(systemName: "brain.head.profile")
            Text("Capture thought")
        }
    }
}

struct RecordThoughtIntent: AppIntent, WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Записать мысль"
    static var description = IntentDescription("Открыть Mindy для записи голосовой заметки")
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
