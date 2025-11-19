//
//  LollipopProjectRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/14.
//

import Foundation
import OSLog

class LollipopProjectRepository: ProjectRepository {
    private let lollipopAPIUtility = LollipopAPIUtility()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnderstandMe", category: "Domain")
    
    
    
    func uploadProject(userID: String, homeworkID: String, githubURLString: String) async throws {
        let url = try lollipopAPIUtility.makeURL("project/add_project.php")
        let body = try JSONEncoder().encode([
            "user_id": userID,
            "homework_id": homeworkID,
            "github_file_link": githubURLString
        ])
        
        let request = try lollipopAPIUtility.makeRequest(url: url, method: "PATCH", body: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        
        let response = try lollipopAPIUtility.decodeAPIResponse(from: data)
        
        try lollipopAPIUtility.checkResponseForErrors(response)
    }
    
    
}
