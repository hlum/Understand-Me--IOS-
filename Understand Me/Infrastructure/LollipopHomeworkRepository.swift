//
//  LollipopHomeworkRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/14.
//

import Foundation
import OSLog


class LollipopHomeworkRepository: HomeworkRepository {
    private let lollipopAPIUtility = LollipopAPIUtility()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnderstandMe", category: "Domain")
    
    
    
    func fetchHomeworks(studentID: String) async throws -> [HomeworkWithStatus] {
        let queryItems = [URLQueryItem(name: "student_id", value: studentID)]
        return try await fetchHomeworks(with: queryItems)
    }
    
    
    
    func fetchHomeworksFromClass(classID: String, studentID: String) async throws -> [HomeworkWithStatus] {
        let queryItems = [
            URLQueryItem(name: "class_id", value: classID),
            URLQueryItem(name: "student_id", value: studentID)
        ]
        return try await fetchHomeworks(with: queryItems)
    }
    
    
    func fetchHomework(id: String, studentID: String) async throws -> HomeworkWithStatus {
        let queryItems = [
            URLQueryItem(name: "id", value: id),
            URLQueryItem(name: "student_id", value: studentID)
        ]
        
        if let homework = try await fetchHomeworks(with: queryItems).first {
            return homework
        }
        throw URLError(.badServerResponse)
    }
    
    
    
    private func fetchHomeworks(with queryItems: [URLQueryItem]) async throws -> [HomeworkWithStatus] {
        let url = try lollipopAPIUtility.makeURL("homework/get_homework_with_status.php")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems
        
        guard let finalURL = components?.url else {
            throw URLError(.badURL)
        }
        
        let request = try lollipopAPIUtility.makeRequest(url: finalURL, method: "GET")
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let response: APIResponse<HomeworkWithStatus> = try lollipopAPIUtility.decodeAPIResponse(from: data)
        
        
        guard let result = response.dataString else {
            throw URLError(.badServerResponse)
        }

       return result
    }
    
    
    func retryQuestionGeneration(homeworkID: String, studentID: String) async throws {
        let url = try lollipopAPIUtility.makeURL("job/retry_job.php")
        
        let body = try JSONEncoder().encode([
            "homework_id": homeworkID,
            "user_id": studentID
        ])
        
        let request = try lollipopAPIUtility.makeRequest(url: url, method: "PATCH", body: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let response: APIResponse<EmptyResponse> = try lollipopAPIUtility.decodeAPIResponse(from: data)
        
        try lollipopAPIUtility.checkResponseForErrors(response)
        logger.info("問題生成の再試行に成功: homeworkID=\(homeworkID)")
    }
    
    
    func cancelHomeworkSubmission(homeworkID: String, studentID: String) async throws {
        let url = try lollipopAPIUtility.makeURL("homework/delete_submitted_homework.php")
        let body = try JSONEncoder().encode([
            "user_id": studentID,
            "homework_id": homeworkID
        ])
        
        let request = try lollipopAPIUtility.makeRequest(url: url, method: "DELETE", body: body)
        let (data, _) = try await URLSession.shared.data(for: request)
        let response: APIResponse<EmptyResponse> = try lollipopAPIUtility.decodeAPIResponse(from: data)
        
        try lollipopAPIUtility.checkResponseForErrors(response)
        logger.info("宿題提出のキャンセルに成功: homeworkID=\(homeworkID)")

    }
    
    
}
