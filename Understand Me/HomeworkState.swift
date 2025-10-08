//
//  HomeworkState.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/07.
//

import SwiftUI

// MARK: - Homework State
enum HomeworkState {
    case notAssigned
    case generatingQuestions
    case questionsGenerated
    case completed
    
    var color: Color {
        switch self {
        case .notAssigned: return .red
        case .generatingQuestions: return .yellow
        case .questionsGenerated: return .blue
        case .completed: return .green
        }
    }
    
    var stateDescription: String {
        switch self {
        case .notAssigned: return "未提出"
        case .generatingQuestions: return "問題生成中"
        case .questionsGenerated: return "問題生成完了"
        case .completed: return "提出完了"
        }
    }
}

