//
//  LollipopHomeworkRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/14.
//

import Foundation


class LollipopHomeworkRepository: HomeworkRepository {
    private let lollipopAPIUtility = LollipopAPIUtility()
    
    
    
    func fetchHomeworks(studentID: String) async throws -> [Homework] {
        let queryItems = [URLQueryItem(name: "student_id", value: studentID)]
        return try await fetchHomeworks(with: queryItems)
    }
    
    
    
    func fetchHomeworksFromClass(classID: String, studentID: String) async throws -> [Homework] {
        let queryItems = [
            URLQueryItem(name: "class_id", value: classID),
            URLQueryItem(name: "student_id", value: studentID)
        ]
        return try await fetchHomeworks(with: queryItems)
    }
    
    
    
    private func fetchHomeworks(with queryItems: [URLQueryItem]) async throws -> [Homework] {
        let url = try lollipopAPIUtility.makeURL("homework/get_homework.php")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems
        
        guard let finalURL = components?.url else {
            throw URLError(.badURL)
        }
        
        let request = try lollipopAPIUtility.makeRequest(url: finalURL, method: "GET")
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let response = try lollipopAPIUtility.decodeAPIResponse(from: data)
        
        guard response.status == "success" else {
            print("ResponseのStatusがsuccessではありません。エラー詳細:" + response.message)
            return []
        }
        
        guard let jsonString = response.dataString,
              let jsonData = jsonString.data(using: .utf8) else {
            throw URLError(.badServerResponse)
        }
        
        do {
            let homeworks = try JSONDecoder().decode([Homework].self, from: jsonData)
            return homeworks
        } catch {
            print("HomeworkのDecodeに失敗。失敗: \(error.localizedDescription)")
            throw error
        }
    }
    
    
}
