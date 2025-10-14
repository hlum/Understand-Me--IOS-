//
//  LollipopProjectRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/14.
//

import Foundation

class LollipopProjectRepository: ProjectRepository {
    private let lollipopAPIUtility = LollipopAPIUtility()
    
    
    
    func uploadProject(userID: String, homeworkID: String, githubURLString: String) async throws {
        let url = try lollipopAPIUtility.makeURL("project/add_project.php")
        let body = try JSONEncoder().encode([
            "user_id": userID,
            "homework_id": homeworkID,
            "github_file_link": githubURLString
        ])
        
        let request = try lollipopAPIUtility.makeRequest(url: url, method: "PATCH", body: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        
        print("レスポンスデータ: " + String(data: data, encoding: .utf8)!)
        let response = try lollipopAPIUtility.decodeAPIResponse(from: data)
        
        guard response.status == "success" else {
            print("ResponseのStatusがsuccessではありません。エラー詳細:" + response.message)
            throw UserDataRepositoryError.InvalidResponseStatus
        }
    }
    
    
}
