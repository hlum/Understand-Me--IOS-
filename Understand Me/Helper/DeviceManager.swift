//
//  DeviceIDManager.swift
//  Understand Me
//
//  Created by cmStudent on 2025/11/01.
//

import Foundation
import UIKit

// Userが複数端末で同じUserIDを使う場合に備えて、端末固有のIDを生成・保存・取得するクラス
class DeviceManager {
    static let shared = DeviceManager()
    
    private let deviceIDUserDefaultsKey = "DeviceIDUserDefaultsKey"
    
    private init() {}
    
    
    func getDeviceID() -> String {
        let existingKey = UserDefaults.standard.string(forKey: deviceIDUserDefaultsKey)
        if let existingKey { return existingKey }
        
        return createNewDeviceID()
    }
    
    
    private func createNewDeviceID() -> String {
        let newID = UUID().uuidString
        UserDefaults.standard.set(newID, forKey: deviceIDUserDefaultsKey)
        return newID
    }
}

extension DeviceManager {

    func getDeviceType() -> String {
        let device = UIDevice.current.model // "iPhone", "iPad", etc.
        let systemName = UIDevice.current.systemName // e.g., "iOS"
        let systemVersion = UIDevice.current.systemVersion // e.g., "16.0"
        let deviceName = UIDevice.current.name // e.g., "John's iPhone"
        return device + "-" + systemName + "-" + systemVersion + "-" + deviceName
    }
}
