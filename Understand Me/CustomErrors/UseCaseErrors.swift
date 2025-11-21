//
//  UseCaseErrors.swift
//  Understand Me
//
//  Created by cmStudent on 2025/11/20.
//

import Foundation

enum UseCaseErrors: LocalizedError {
    case invalidInput(String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidInput(let message):
            return message
        case .unknown:
            return "予期せぬエラーが発生しました。"
        }
    }
}
