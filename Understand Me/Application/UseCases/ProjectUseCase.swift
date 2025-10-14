//
//  ProjectUseCase.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/14.
//

import Foundation

class ProjectUseCase {
    private let projectRepository: ProjectRepository
    
    init(projectRepository: ProjectRepository) {
        self.projectRepository = projectRepository
    }
    
    
    func uploadProject(userID: String, homeworkID: String, githubURLString: String) async throws {
        try await projectRepository.uploadProject(
            userID: userID,
            homeworkID: homeworkID,
            githubURLString: githubURLString
        )
    }
}
