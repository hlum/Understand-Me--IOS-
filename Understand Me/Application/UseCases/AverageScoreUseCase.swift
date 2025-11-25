//
//  AverageScoreUseCase.swift
//  Understand Me
//
//  Created by cmStudent on 2025/11/25.
//

import Foundation
import OSLog

class AverageScoreUseCase {
    private let repository: AverageScoreRepository
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnderstandMe", category: "UseCase")
    
    init(repository: AverageScoreRepository) {
        self.repository = repository
    }
    
    func fetch(userID: String) async throws -> [AverageScorePerClass] {
        do {
            return try await repository.fetch(userID: userID)
        } catch {
            logger.error("学科ごとの平均スコアの取得に失敗：\(error.localizedDescription)")
            throw UseCaseErrorHandler.shared.map(error: error)
        }
    }
}
