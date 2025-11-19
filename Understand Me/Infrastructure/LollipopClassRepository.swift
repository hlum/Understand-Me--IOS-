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
        
        let request = try lollipopAPIUtility.makeRequest(url: url, method: "POST", body: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try lollipopAPIUtility.decodeAPIResponse(from: data)
        
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
        
        let request = try lollipopAPIUtility.makeRequest(url: finalURL, method: "GET")
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let response = try lollipopAPIUtility.decodeAPIResponse(from: data)
        
        guard response.status == "success" else {
            logger.error("ResponseのStatusがsuccessではありません。エラー詳細: \(response.message)")
            throw LollipopError.InvalidResponseStatus
        }
        
        guard let jsonString = response.dataString,
              let jsonData = jsonString.data(using: .utf8) else {
            throw ClassRepositoryError.NoDataFoundInResponse
        }

        do {
            let classes = try JSONDecoder().decode([Class].self, from: jsonData)
            return classes.first
        } catch {
            logger.error("ClassのDecodeに失敗。失敗: \(error.localizedDescription)")
            throw error
        }
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
        
        let request = try lollipopAPIUtility.makeRequest(url: finalURL, method: "GET")
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let response = try lollipopAPIUtility.decodeAPIResponse(from: data)
        
        do {
            try lollipopAPIUtility.checkResponseForErrors(response)
        } catch let error as LollipopError {
            logger.error("クラス一覧の取得に失敗: \(error.debugDescription)")
            return []
        } catch {
            logger.error("クラス一覧の取得に失敗（予期しないエラー）: \(error.localizedDescription)")
            return []
        }
        
        guard let jsonString = response.dataString,
              let jsonData = jsonString.data(using: .utf8) else {
            throw ClassRepositoryError.NoDataFoundInResponse
        }

        do {
            let classes = try JSONDecoder().decode([Class].self, from: jsonData)
            logger.info("クラス一覧の取得成功: \(classes.count)件")
            return classes
        } catch {
            logger.error("クラスのデータのDecodeに失敗: \(error.localizedDescription)")
            throw error
        }
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
        
        
        let request = try lollipopAPIUtility.makeRequest(url: finalURL, method: "GET")
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let response = try lollipopAPIUtility.decodeAPIResponse(from: data)

        try lollipopAPIUtility.checkResponseForErrors(response)
        
        guard let jsonString = response.dataString,
              let jsonData = jsonString.data(using: .utf8) else {
            throw ClassRepositoryError.NoDataFoundInResponse
        }

        do {
            let classData = try JSONDecoder().decode([Class].self, from: jsonData)
            if let firstClass = classData.first {
                logger.info("クラス情報の取得に成功: classID=\(id)")
                return firstClass
            }
            logger.error("クラスが配列に含まれていません: classID=\(id)")
            throw ClassRepositoryError.NoDataFoundInResponse
            
        } catch let error as ClassRepositoryError {
            throw error
        } catch {
            logger.error("クラスのDecodeに失敗: \(error.localizedDescription)")
            throw error
        }
    }
}
