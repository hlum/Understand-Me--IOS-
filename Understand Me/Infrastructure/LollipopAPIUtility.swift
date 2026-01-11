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
    private let remoteConfigManager = RemoteConfigManager.shared
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnderstandMe", category: "API")
    
    func makeURL(_ path: String) throws -> URL {
        let base = remoteConfigManager.apiEndpoint
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
    
    
    
    func decodeAPIResponse<T: Codable>(from data: Data) throws -> APIResponse<T> {
        try JSONDecoder().decode(APIResponse<T>.self, from: data)
    }
    
    /// APIレスポンスのエラーチェックを行い、エラーがある場合は適切な例外を投げる
    /// - Parameter response: デコードされたAPIレスポンス
    /// - Throws: エラータイプに応じたLollipopError
    func checkResponseForErrors<T>(_ response: APIResponse<T>) throws {
        guard response.status == "success" else {
            logger.error("❌ API エラー発生 - status: \(response.status), error_type: \(response.error_type?.rawValue ?? "null"), message: \(response.message)")
            
            if let errorType = response.error_type {
                switch errorType {
                case .validation_error:
                    logger.warning("バリデーションエラー: \(response.message)")
                    throw LollipopError.validation(response.message)
                case .auth_error:
                    logger.error("認証エラー: 認証情報が無効または期限切れです")
                    throw LollipopError.auth
                case .forbidden_error:
                    logger.error("アクセス拒否エラー: リソースへのアクセス権限がありません")
                    throw LollipopError.forbidden
                case .not_found_error:
                    logger.warning("リソース未検出エラー: 要求されたリソースが見つかりません")
                    throw LollipopError.notFound
                case .server_error:
                    logger.error("サーバーエラー: サーバー側で問題が発生しました - \(response.message)")
                    throw LollipopError.server
                case .unsupported_repo_url:
                    logger.error("サポートされていないリポジトリURL: \(response.message)")
                    throw LollipopError.UnsupportedRepoURL
                case .unsupported_file_type:
                    logger.error("サポートされていないファイルタイプ: \(response.message)")
                    throw LollipopError.UnsupportedFileTypeException
                }
            } else {
                // Optional error_type is nil
                logger.error("不明なエラー: message=\(response.message)")
                throw LollipopError.UnsupportedFileTypeException // or a generic error
            }
        }
    }

}
