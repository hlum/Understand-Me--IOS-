//
//  KnowYourCodeWidget.swift
//  KnowYourCodeWidget
//
//  Created by アウン on 2026/01/13.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        // Just provide a generic example entry
        SimpleEntry(
            date: Date(),
            data: .finishedPercentage(50),
            configuration: ConfigurationAppIntent()
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        switch configuration.widgetType {
            case .finishedHomework:
                return SimpleEntry(date: Date(), data: .finishedPercentage(40), configuration: ConfigurationAppIntent())
            case .averageScore:
                return SimpleEntry(date: Date(), data: .averageScore(40), configuration: ConfigurationAppIntent())
        }
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        
        let metricData: WidgetMetricData
        switch configuration.widgetType {
            case .finishedHomework:
                let percentage = 50
                metricData = .finishedPercentage(percentage)
            case .averageScore:
                let score = 20
                metricData = .averageScore(score)
        }
        
        let entry = SimpleEntry(date: Date(), data: metricData,
                                configuration: configuration)
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
        return timeline
        
    }
    
//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}


enum WidgetMetricData {
    case finishedPercentage(Int)
    case averageScore(Int)
}


struct SimpleEntry: TimelineEntry {
    var date: Date
    let data: WidgetMetricData
    let configuration: ConfigurationAppIntent
}

struct KnowYourCodeWidgetEntryView: View {
    var entry: Provider.Entry

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

struct KnowYourCodeWidget: Widget {
    let kind: String = "KnowYourCodeWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            KnowYourCodeWidgetEntryView(entry: entry)
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var averageScore: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.widgetType = .averageScore
        return intent
    }
    
    fileprivate static var finishedHomework: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.widgetType = .finishedHomework
        return intent
    }
}

#Preview(as: .systemSmall) {
    KnowYourCodeWidget()
} timeline: {
    SimpleEntry(date: .now, data: .averageScore(100), configuration: .averageScore)
    SimpleEntry(date: .now, data: .finishedPercentage(100), configuration: .finishedHomework)
}
