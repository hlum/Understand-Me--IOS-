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
        
        let response = try lollipopAPIUtility.decodeAPIResponse(from: data)
        
        do {
            try lollipopAPIUtility.checkResponseForErrors(response)
        } catch let error as LollipopError {
            logger.error("宿題一覧の取得に失敗: \(error.debugDescription)")
            return []
        } catch {
            logger.error("宿題一覧の取得に失敗（予期しないエラー）: \(error.localizedDescription)")
            return []
        }
        
        guard let jsonString = response.dataString,
              let jsonData = jsonString.data(using: .utf8) else {
            throw URLError(.badServerResponse)
        }

        do {
            let decoder = JSONDecoder()
            let homeworks = try decoder.decode([HomeworkWithStatus].self, from: jsonData)
            
            return homeworks
        }catch let DecodingError.keyNotFound(key, context) {
            logger.error("❌ Missing key: '\(key.stringValue)' in \(context.codingPath.map(\.stringValue).joined(separator: " → "))")
            logger.error("   Debug Description: \(context.debugDescription)")
            logger.error("   Coding Path: \(context.codingPath)")
        } catch let DecodingError.typeMismatch(type, context) {
            logger.error("❌ Type mismatch for type '\(type)' at \(context.codingPath.map(\.stringValue).joined(separator: " → "))")
            logger.error("   Debug Description: \(context.debugDescription)")
        } catch let DecodingError.valueNotFound(value, context) {
            logger.error("❌ Value not found for type '\(value)' at \(context.codingPath.map(\.stringValue).joined(separator: " → "))")
            logger.error("   Debug Description: \(context.debugDescription)")
        } catch let DecodingError.dataCorrupted(context) {
            logger.error("❌ Data corrupted: \(context.debugDescription)")
        } catch {
            logger.warning("⚠️ Unknown decoding error: \(error)")
        }
        return []
    }
    
    
    func retryQuestionGeneration(homeworkID: String, studentID: String) async throws {
        let url = try lollipopAPIUtility.makeURL("job/retry_job.php")
        
        let body = try JSONEncoder().encode([
            "homework_id": homeworkID,
            "user_id": studentID
        ])
        
        let request = try lollipopAPIUtility.makeRequest(url: url, method: "PATCH", body: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let response = try lollipopAPIUtility.decodeAPIResponse(from: data)
        
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
        let response = try lollipopAPIUtility.decodeAPIResponse(from: data)
        
        try lollipopAPIUtility.checkResponseForErrors(response)
        logger.info("宿題提出のキャンセルに成功: homeworkID=\(homeworkID)")

    }
    
    
}
