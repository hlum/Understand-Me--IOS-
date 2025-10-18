//
//  LollipopHomeworkRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/14.
//

import Foundation


class LollipopHomeworkRepository: HomeworkRepository {
    private let lollipopAPIUtility = LollipopAPIUtility()
    
    
    
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
        
        guard response.status == "success" else {
            print("ResponseのStatusがsuccessではありません。エラー詳細:" + response.message)
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
            print("❌ Missing key: '\(key.stringValue)' in \(context.codingPath.map(\.stringValue).joined(separator: " → "))")
            print("   Debug Description: \(context.debugDescription)")
            print("   Coding Path: \(context.codingPath)")
        } catch let DecodingError.typeMismatch(type, context) {
            print("❌ Type mismatch for type '\(type)' at \(context.codingPath.map(\.stringValue).joined(separator: " → "))")
            print("   Debug Description: \(context.debugDescription)")
        } catch let DecodingError.valueNotFound(value, context) {
            print("❌ Value not found for type '\(value)' at \(context.codingPath.map(\.stringValue).joined(separator: " → "))")
            print("   Debug Description: \(context.debugDescription)")
        } catch let DecodingError.dataCorrupted(context) {
            print("❌ Data corrupted: \(context.debugDescription)")
        } catch {
            print("⚠️ Unknown decoding error: \(error)")
        }
        return []
    }
    
    
}
