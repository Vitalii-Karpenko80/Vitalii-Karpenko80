//
//  VoicePocketWidget.swift
//  VoicePocket Widget Extension
//
//  Lock Screen Widget для быстрого доступа (iOS 2026)
//

import WidgetKit
import SwiftUI
import AppIntents

struct VoicePocketWidget: Widget {
    let kind: String = "VoicePocketWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: RecordThoughtIntent.self,
            provider: Provider()
        ) { entry in
            VoicePocketWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Voice Pocket")
        .description("Быстрая запись мыслей")
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

struct VoicePocketWidgetEntryView: View {
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
            Image(systemName: "mic.fill")
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
            Image(systemName: "waveform.circle.fill")
                .font(.title2)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.cyan, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            VStack(alignment: .leading, spacing: 2) {
                Text("Voice Pocket")
                    .font(.headline)
                Text("Записать мысль")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
    }
    
    private var inlineView: some View {
        HStack {
            Image(systemName: "mic.fill")
            Text("Записать мысль")
        }
    }
}

struct RecordThoughtIntent: AppIntent, WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Записать мысль"
    static var description = IntentDescription("Открыть Voice Pocket для записи голосовой заметки")
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
