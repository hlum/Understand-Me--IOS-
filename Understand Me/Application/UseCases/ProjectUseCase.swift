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
    
    
    func uploadProject(project: Project) async throws {
        try await projectRepository.uploadProject(project: project)
    }
}
