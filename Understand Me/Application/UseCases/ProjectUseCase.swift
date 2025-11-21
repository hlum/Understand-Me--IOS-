//
//  ProjectUseCase.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/14.
//

import Foundation
import OSLog

class ProjectUseCase {
    private let projectRepository: ProjectRepository
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnderstandMe", category: "UseCase")
    

    init(projectRepository: ProjectRepository) {
        self.projectRepository = projectRepository
    }
    
    
    func uploadProject(userID: String, homeworkID: String, githubURLString: String) async throws {
        do {
            try await projectRepository.uploadProject(
                userID: userID,
                homeworkID: homeworkID,
                githubURLString: githubURLString
            )
        } catch {
            logger.error("エラー：プロジェクトの提出に失敗：\(error.localizedDescription)")
            throw UseCaseErrorHandler.shared.map(error: error)
        }
    }
}
