//
//  LollipopAPIUtilityClass.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/13.
//

import Foundation
import OSLog

class LollipopAPIUtility {
    private let secretLoader = SecretLoader.shared
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnderstandMe", category: "API")

    func makeURL(_ path: String) throws -> URL {
        let base = secretLoader.fetchSecret(from: "Secrets", forKey: "endpoint")
        guard let baseURL = URL(string: base)?.appendingPathComponent(path) else {
            throw LollipopError.InvalidURL
        }
        return baseURL
    }
    
    
    
    func makeRequest(url: URL, method: String, body: Data? = nil) throws -> URLRequest {
        let apiKey = secretLoader.fetchSecret(from: "Secrets", forKey: "APIKEY")
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        request.httpBody = body
        return request
    }
    
    
    
    func decodeAPIResponse(from data: Data) throws -> APIResponse {
        try JSONDecoder().decode(APIResponse.self, from: data)
    }
    
    /// APIレスポンスのエラーチェックを行い、エラーがある場合は適切な例外を投げる
    /// - Parameter response: デコードされたAPIレスポンス
    /// - Throws: エラータイプに応じたLollipopError
    func checkResponseForErrors(_ response: APIResponse) throws {
        guard response.status == "success" else {
            // エラーの詳細をログに記録
            logger.error("❌ API エラー発生 - status: \(response.status), error_type: \(response.error_type ?? "不明"), message: \(response.message)")
            
            switch response.error_type {
            case "validation_error":
                logger.warning("バリデーションエラー: \(response.message)")
                throw LollipopError.validation(response.message)
            case "auth_error":
                logger.error("認証エラー: 認証情報が無効または期限切れです")
                throw LollipopError.auth
            case "forbidden":
                logger.error("アクセス拒否エラー: リソースへのアクセス権限がありません")
                throw LollipopError.forbidden
            case "not_found":
                logger.warning("リソース未検出エラー: 要求されたリソースが見つかりません")
                throw LollipopError.notFound
            case "server_error":
                logger.error("サーバーエラー: サーバー側で問題が発生しました - \(response.message)")
                throw LollipopError.server
            default:
                logger.error("不明なエラー: error_type=\(response.error_type ?? "null"), message=\(response.message)")
                throw LollipopError.invalidResponse
            }
        }
    }
    
}
