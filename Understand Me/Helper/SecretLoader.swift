//
//  APIKeyLoader.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/11.
//

import Foundation

// Secrets.plistからのAPIKEYや、endpoint urlを取得するためのクラス
class SecretLoader {
    static var shared = SecretLoader()
    
    private init() {}
    
    static func fetchSecret(from file: String = "Secrets", forKey key: String) -> String? {
        guard let url = Bundle.main.url(forResource: file, withExtension: "plist") else {
            fatalError("\(file).plist がありません。")
            return nil
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("\(file).plist からデータを読み込めません。")
            return nil
        }
        
        guard let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: String] else {
            fatalError("\(file).plist のデータは型変換できません。")
            return nil
        }
        
        guard let result = plist[key] else {
            fatalError("\(key)の値は設定されていません。")
        }
        
        return result
        
    }
}
