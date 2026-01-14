//
//  HomeworkState.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/07.
//

import SwiftUI
import AppIntents

// 課題の状況
enum HomeworkState: String, Codable, CaseIterable, AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        return .init(name: "課題の状況")
    }

    static var caseDisplayRepresentations: [HomeworkState : DisplayRepresentation] {
        return [
            .notAssigned: "未提出",
            .generatingQuestions: "問題生成中",
            .questionGenerated: "問題生成完了",
            .completed: "提出",
            .failed: "生成失敗"
        ]
    }
    
    case notAssigned
    case generatingQuestions
    case questionGenerated
    case completed
    case failed
    
    var color: Color {
        switch self {
        case .notAssigned: return .gray
        case .generatingQuestions: return .yellow
        case .questionGenerated: return .blue
        case .completed: return .green
        case .failed: return .red
        }
    }
    
    var stateDescription: String {
        switch self {
        case .notAssigned: return "未提出"
        case .generatingQuestions: return "問題生成中"
        case .questionGenerated: return "問題生成完了"
        case .completed: return "提出完了"
        case .failed: return "生成失敗"
        }
    }
}

