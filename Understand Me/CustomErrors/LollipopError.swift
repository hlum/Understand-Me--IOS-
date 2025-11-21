//
//  LollipopError.swift
//  Understand Me
//
//  Created by cmStudent on 2025/11/20.
//

import Foundation

enum LollipopError: LocalizedError {
    case validation(String)
    case auth
    case forbidden
    case notFound
    case server
    case invalidResponse
    case InvalidURL
    case NoDataFoundInResponse
    case UserNotFound
    case UnsupportedRepoURL
    case UnsupportedFileTypeException
    
    /// ユーザー向けのエラーメッセージ
    var errorDescription: String? {
        switch self {
            case .validation(let message):
                // バリデーションエラーはサーバーからのメッセージをそのまま表示
                return message
            case .auth:
                return "ログインの有効期限が切れました。再度ログインしてください。"
            case .forbidden:
                return "この操作を行う権限がありません。"
            case .notFound:
                return "お探しの情報が見つかりませんでした。"
            case .server:
                return "サーバーで問題が発生しました。しばらくしてからもう一度お試しください。"
            case .invalidResponse:
                return "予期しないエラーが発生しました。もう一度お試しください。"
            case .InvalidURL:
                return "接続先のURLが正しくありません。"
            case .NoDataFoundInResponse:
                return "データの取得に失敗しました。"
            case .UserNotFound:
                return "ユーザー情報が見つかりませんでした。"
            case .UnsupportedRepoURL:
                return "提出しているリポジトリのURLはサポートされていません。"
            case .UnsupportedFileTypeException:
                return "サポートされていないファイルタイプです。(Zipである必要があります。）"
        }
    }
    
    /// デバッグ用の詳細なエラー情報
    var debugDescription: String {
        switch self {
            case .validation(let message):
                return "バリデーションエラー: \(message)"
            case .auth:
                return "認証エラー: 認証情報が無効または期限切れ"
            case .forbidden:
                return "アクセス拒否: リソースへのアクセス権限なし"
            case .notFound:
                return "リソース未検出: 要求されたリソースが存在しない"
            case .server:
                return "サーバーエラー: サーバー側で内部エラーが発生"
            case .invalidResponse:
                return "不正なレスポンス: 予期しないレスポンス形式"
            case .InvalidURL:
                return "無効なURL: URLの構築に失敗"
            case .NoDataFoundInResponse:
                return "データ不在: レスポンスにdataフィールドが存在しない"
            case .UserNotFound:
                return "ユーザー未検出: 指定されたIDのユーザーが見つからない"
            case .UnsupportedRepoURL:
                return "提出しているリポジトリのURLはサポートされていません。"
            case .UnsupportedFileTypeException:
                return "サポートされていないファイルタイプです。(Zipである必要があります。）"
        }
    }
}
