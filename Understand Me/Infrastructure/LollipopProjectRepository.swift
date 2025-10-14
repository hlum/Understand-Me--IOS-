//
//  LollipopProjectRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/14.
//

import Foundation

class LollipopProjectRepository: ProjectRepository {
    private let lollipopAPIUtility = LollipopAPIUtility()
    
    
    
    func uploadProject(project: Project) async throws {
        let url = try lollipopAPIUtility.makeURL("project/add_project.php")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        components?.queryItems = [
            URLQueryItem(name: "user_id", value: project.userID),
            URLQueryItem(name: "homework_id", value: project.homeworkID),
            URLQueryItem(name: "github_file_link", value: project.githubURL),
            ]
        
        guard let finalURL = components?.url else {
            throw URLError(.badURL)
        }
        
        let request = try lollipopAPIUtility.makeRequest(url: finalURL, method: "POST")
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let response = try lollipopAPIUtility.decodeAPIResponse(from: data)
        
        guard response.status == "success" else {
            print("ResponseのStatusがsuccessではありません。エラー詳細:" + response.message)
            throw UserDataRepositoryError.InvalidResponseStatus
        }
    }
    
    
}
