//
//  LollipopClassRepository.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/13.
//

import Foundation
import OSLog


enum ClassRepositoryError: LocalizedError {
    case InvalidURL
    case NoDataFoundInResponse
    
    var errorDescription: String? {
        switch self {
        case .InvalidURL:
            return "URL が無効です。"
        case .NoDataFoundInResponse:
            return "データが返っていません。"
        }
    }
}

class LollipopClassRepository: ClassRepository {
    
    private let lollipopAPIUtility: LollipopAPIUtility = LollipopAPIUtility()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnderstandMe", category: "Domain")

    
    
    func addOptionalClass(classCode: String, userID: String) async throws {
        let url = try lollipopAPIUtility.makeURL("class/enroll.php")
        let body = try JSONEncoder().encode([
            "student_id": userID,
            "class_code": classCode
        ])
        
        let request = try await lollipopAPIUtility.makeRequest(url: url, method: "POST", body: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response: APIResponse<EmptyResponse> = try lollipopAPIUtility.decodeAPIResponse(from: data)
        
        try lollipopAPIUtility.checkResponseForErrors(response)
        logger.info("選択科目の追加に成功: classCode=\(classCode), userID=\(userID)")
    }

    
    
    func fetch(classCode: String) async throws -> Class? {
        let url = try lollipopAPIUtility.makeURL("class/get_class.php")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "class_code", value: classCode)
        ]
        
        guard let finalURL = components?.url else {
            throw ClassRepositoryError.InvalidURL
        }
        
        let request = try await lollipopAPIUtility.makeRequest(url: finalURL, method: "GET")
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let response: APIResponse<Class> = try lollipopAPIUtility.decodeAPIResponse(from: data)
        
        try lollipopAPIUtility.checkResponseForErrors(response)
        
        return response.dataString?.first
    }
    
    
    func fetchAll(studentID: String) async throws -> [Class] {
        let url = try lollipopAPIUtility.makeURL("class/get_class.php")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "student_id", value: studentID)
        ]
        
        guard let finalURL = components?.url else {
            throw ClassRepositoryError.InvalidURL
        }
        
        let request = try await lollipopAPIUtility.makeRequest(url: finalURL, method: "GET")
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let response: APIResponse<Class> = try lollipopAPIUtility.decodeAPIResponse(from: data)
        try lollipopAPIUtility.checkResponseForErrors(response)

        
        guard let result = response.dataString else {
            throw ClassRepositoryError.NoDataFoundInResponse
        }

        return result
    }
    
    
    
    func fetch(id: String) async throws -> Class {
        let url = try lollipopAPIUtility.makeURL("class/get_class.php")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "id", value: id)
        ]
        
        guard let finalURL = components?.url else {
            throw ClassRepositoryError.InvalidURL
        }
        
        
        let request = try await lollipopAPIUtility.makeRequest(url: finalURL, method: "GET")
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let response: APIResponse<Class> = try lollipopAPIUtility.decodeAPIResponse(from: data)

        try lollipopAPIUtility.checkResponseForErrors(response)
        
        guard let results = response.dataString,
              let result = results.first else {
            throw ClassRepositoryError.NoDataFoundInResponse
        }

        return result
    }
}
