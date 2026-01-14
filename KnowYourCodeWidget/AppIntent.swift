//
//  AppIntent.swift
//  KnowYourCodeWidget
//
//  Created by アウン on 2026/01/13.
//

import WidgetKit
import AppIntents

enum WidgetType: String, AppEnum {
    case finishedHomework
    case averageScore
    
    // Displayed in widget configuration UI
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Widget 設定"
    }
    
    static var caseDisplayRepresentations: [WidgetType: DisplayRepresentation] {
        [
            .finishedHomework: "完了率",
            .averageScore: "平均点"
        ]
    }
}

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "設定" }
    static var description: IntentDescription { "このウィジェットの設定を行います。" }

    // An example configurable parameter.
    @Parameter(title: "種類", default: WidgetType.averageScore)
    var widgetType: WidgetType
}
