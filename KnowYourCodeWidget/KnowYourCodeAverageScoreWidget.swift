//
//  KnowYourCodeWidget.swift
//  KnowYourCodeWidget
//
//  Created by アウン on 2026/01/13.
//

import WidgetKit
import SwiftUI
import AppIntents


struct HomeworkProgressEntryProvider: AppIntentTimelineProvider {
    let defaultsGroup: UserDefaults? = UserDefaults(suiteName: "group.jp.ac.jec.24cm0138.understandme")

    
    func placeholder(in context: Context) -> AverageScoreEntry {
        // Just provide a generic example entry
        AverageScoreEntry(
            date: Date(),
            data: .finishedPercentage(56),
            configuration: AverageScoreConfigurationAppIntent()
        )
    }

    func snapshot(for configuration: FinishedHomeworkProgressConfigurationAppIntent, in context: Context) async -> AverageScoreEntry {
        
        let metricData: WidgetMetricData
        switch configuration.widgetType {
            case .finishedHomework:
                let percentage = fetchHomeworkProgress()
                metricData = .finishedPercentage(percentage)
            case .averageScore:
                let score = fetchAverageScore()
                metricData = .averageScore(score)
        }
        
        let entry = AverageScoreEntry(date: Date(), data: metricData,
                                configuration: configuration)
        
        return entry

    }
    
    func timeline(for configuration: FinishedHomeworkProgressConfigurationAppIntent, in context: Context) async -> Timeline<AverageScoreEntry> {
        
        let metricData: WidgetMetricData
        switch configuration.widgetType {
            case .finishedHomework:
                let percentage = fetchHomeworkProgress()
                metricData = .finishedPercentage(percentage)
            case .averageScore:
                let score = fetchAverageScore()
                metricData = .averageScore(score)
        }
        
        let entry = AverageScoreEntry(date: Date(), data: metricData,
                                configuration: configuration)
        let timeline = Timeline(entries: [entry], policy: .never)
        return timeline
        
    }
    
    
    
    private func fetchAverageScore() -> Int {
        return defaultsGroup?.integer(forKey: WidgetDataKeys.AVERAGESCORE.rawValue) ?? 0
    }
    
    
    private func fetchHomeworkProgress() -> Int {
        return defaultsGroup?.integer(forKey: WidgetDataKeys.HOMEWORK_PROGRESS.rawValue) ?? 0
    }
    
//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}



struct AverageScoreEntryProvider: AppIntentTimelineProvider {
    let defaultsGroup: UserDefaults? = UserDefaults(suiteName: "group.jp.ac.jec.24cm0138.understandme")

    
    func placeholder(in context: Context) -> AverageScoreEntry {
        // Just provide a generic example entry
        AverageScoreEntry(
            date: Date(),
            data: .averageScore(56),
            configuration: AverageScoreConfigurationAppIntent()
        )
    }

    func snapshot(for configuration: AverageScoreConfigurationAppIntent, in context: Context) async -> AverageScoreEntry {
        
        let metricData: WidgetMetricData
        switch configuration.widgetType {
            case .finishedHomework:
                let percentage = fetchHomeworkProgress()
                metricData = .finishedPercentage(percentage)
            case .averageScore:
                let score = fetchAverageScore()
                metricData = .averageScore(score)
        }
        
        let entry = AverageScoreEntry(date: Date(), data: metricData,
                                configuration: configuration)
        
        return entry

    }
    
    func timeline(for configuration: AverageScoreConfigurationAppIntent, in context: Context) async -> Timeline<AverageScoreEntry> {
        
        let metricData: WidgetMetricData
        switch configuration.widgetType {
            case .finishedHomework:
                let percentage = fetchHomeworkProgress()
                metricData = .finishedPercentage(percentage)
            case .averageScore:
                let score = fetchAverageScore()
                metricData = .averageScore(score)
        }
        
        let entry = AverageScoreEntry(date: Date(), data: metricData,
                                configuration: configuration)
        let timeline = Timeline(entries: [entry], policy: .never)
        return timeline
        
    }
    
    
    
    private func fetchAverageScore() -> Int {
        return defaultsGroup?.integer(forKey: WidgetDataKeys.AVERAGESCORE.rawValue) ?? 0
    }
    
    
    private func fetchHomeworkProgress() -> Int {
        return defaultsGroup?.integer(forKey: WidgetDataKeys.HOMEWORK_PROGRESS.rawValue) ?? 0
    }
    
//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}


enum WidgetMetricData {
    case finishedPercentage(Int)
    case averageScore(Int)
}


struct AverageScoreEntry: TimelineEntry {
    var date: Date
    let data: WidgetMetricData
    let configuration: any WidgetConfigurationIntent
}

struct KnowYourCodeWidgetEntryView: View {
    var entry: AverageScoreEntryProvider.Entry

    var body: some View {
        
        ZStack {    
            switch entry.data {
                case .finishedPercentage(let percentage):
                    WidgetViewForFinishedHomework(finishedHomeworkPercentage: percentage)
                case .averageScore(let averageScore):
                    WidgetViewForAverageScore(averageScore: averageScore)
            }
        }
        .padding()
        .containerBackground(.black, for: .widget)
        .containerRelativeFrame(.horizontal, alignment: .leading)
    }
}



struct WidgetViewForAverageScore: View {
    var averageScore: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
           ProgressCircle(progress: Double(averageScore) / 100)
            
            Spacer()
            
            Text("平均スコア")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
            
            
            HStack(alignment: .bottom, spacing: 0) {
                Text("\(averageScore)")
                    .font(.system(size: 50, weight: .heavy, design: .rounded))
                    .foregroundStyle(.orange.gradient)
                
                Text("点")
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundStyle(.gray.gradient.opacity(0.5))
                    .padding(.bottom, 10)
            }
        }
    }
}


struct WidgetViewForFinishedHomework: View {
    var finishedHomeworkPercentage: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            
            ProgressCircle(progress: Double(finishedHomeworkPercentage)/100)
            
            Spacer()

            Text("課題完成度")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
             
            HStack(alignment: .bottom, spacing: 0) {
                Text("\(finishedHomeworkPercentage)")
                    .font(.system(size: 50, weight: .heavy, design: .rounded))
                    .foregroundStyle(.main)
                
                Text("%")
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundStyle(.gray.gradient.opacity(0.5))
                    .padding(.bottom, 10)
            }
            
        }
    }
}



struct ProgressCircle: View {
    var progress: Double
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 7)
                .frame(height: 40)
                .foregroundColor(.gray.opacity(0.3))

            Circle()
                .trim(from: 0, to: progress)
                .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .frame(height: 40)
                .rotationEffect(.degrees(-90))
                .foregroundStyle(.secAccent)
        }
    }
}

struct KnowYourCodeAverageScoreWidget: Widget {
    let kind: String = "KnowYourCodeWidgetAverageScore"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: AverageScoreConfigurationAppIntent.self, provider: AverageScoreEntryProvider()) { entry in
            KnowYourCodeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("平均スコア")
        .description("自分の今までの平均スコアを表示します。")
        .supportedFamilies([
            .systemSmall
        ])
    }
}


struct KnowYourCodeHomeworkProgressWidget: Widget {
    let kind: String = "KnowYourCodeWidgetHomeworkProgress"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: FinishedHomeworkProgressConfigurationAppIntent.self, provider: HomeworkProgressEntryProvider()) { entry in
            KnowYourCodeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("課題の完成度")
        .description("課題進捗を表示します。")
        .supportedFamilies([
            .systemSmall
        ])
    }
}


class ConfigProvider {
    fileprivate static var averageScore: AverageScoreConfigurationAppIntent {
        let intent = AverageScoreConfigurationAppIntent()
        intent.widgetType = .averageScore
        return intent
    }
    
    fileprivate static var finishedHomework: FinishedHomeworkProgressConfigurationAppIntent {
        let intent = FinishedHomeworkProgressConfigurationAppIntent()
        intent.widgetType = .finishedHomework
        return intent
    }
}

#Preview(as: .systemSmall) {
    KnowYourCodeAverageScoreWidget()
} timeline: {
    
    AverageScoreEntry(date: .now, data: .averageScore(100), configuration: ConfigProvider.averageScore)
    AverageScoreEntry(date: .now, data: .finishedPercentage(100), configuration: ConfigProvider.finishedHomework)
}
