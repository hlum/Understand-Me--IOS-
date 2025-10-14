//
//  ProjectRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/14.
//

import Foundation

protocol ProjectRepository {
    func uploadProject(project: Project) async throws
}
