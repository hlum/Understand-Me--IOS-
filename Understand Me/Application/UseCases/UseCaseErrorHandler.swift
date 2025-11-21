//
//  UseCaseErrorHandler.swift
//  Understand Me
//
//  Created by cmStudent on 2025/11/20.
//

import Foundation



final class UseCaseErrorHandler {
    static let shared = UseCaseErrorHandler()
    
    
    private init() {}
    
    func map(error: Error) -> UseCaseErrors {
        if let lollipopError = error as? LollipopError {
            switch lollipopError {
                case .UnsupportedRepoURL:
                    return .invalidInput("サポートされていないリポジトリURLです。")
                case .UnsupportedFileTypeException:
                    return .invalidInput("サポートされていないファイルタイプです。Zipファイルか確認してください！")
                default:
                    return .unknown
                    
            }
        }
        
        return .unknown
    }
}
