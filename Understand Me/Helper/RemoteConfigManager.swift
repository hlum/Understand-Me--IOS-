//
//  RemoteConfigManager.swift
//  Understand Me
//
//  Created by cmStudent on 2025/01/11.
//

import Foundation
import FirebaseRemoteConfig
import OSLog

class RemoteConfigManager {
    static let shared = RemoteConfigManager()
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnderstandMe", category: "RemoteConfig")
    private let remoteConfig = RemoteConfig.remoteConfig()
    private let userDefaults = UserDefaults.standard
    
    private enum Keys {
        static let apiEndpoint = "cached_api_endpoint"
        static let mainTimerDuration = "cached_main_timer_duration"
        static let arcTimerDuration = "cached_arc_timer_duration"
    }

    private enum DefaultValues {
        static let mainTimerDuration = 60
        static let arcTimerDuration = 30
    }
    
    var apiEndpoint: String {
        get {
//            userDefaults.string(forKey: Keys.apiEndpoint) ?? "https://api.hlumaungphyo.site/"
            "http://localhost:8080"
        }
        set {
            userDefaults.set(newValue, forKey: Keys.apiEndpoint)
        }
    }

    var mainTimerDuration: Int {
        get {
            let value = userDefaults.integer(forKey: Keys.mainTimerDuration)
            return value > 0 ? value : DefaultValues.mainTimerDuration
        }
        set {
            userDefaults.set(newValue, forKey: Keys.mainTimerDuration)
        }
    }

    var arcTimerDuration: Int {
        get {
            let value = userDefaults.integer(forKey: Keys.arcTimerDuration)
            return value > 0 ? value : DefaultValues.arcTimerDuration
        }
        set {
            userDefaults.set(newValue, forKey: Keys.arcTimerDuration)
        }
    }
    
    private init() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
    }
    
    /// アプリ起動時にRemote Configを取得する
    func fetchRemoteConfig() async {
        do {
            let status = try await remoteConfig.fetchAndActivate()
            switch status {
            case .successFetchedFromRemote:
                logger.info("Remote Configをリモートから取得しました")
            case .successUsingPreFetchedData:
                logger.info("Remote Configのキャッシュを使用します")
            case .error:
                logger.error("Remote Configの取得に失敗しました")
                return
            @unknown default:
                logger.warning("Remote Configの不明なステータス")
            }
            
            let newEndpoint = remoteConfig.configValue(forKey: "API_ENDPOINT").stringValue
            let newMainTimerDuration = remoteConfig.configValue(forKey: "MAIN_TIMER_DURATION").numberValue.intValue
            let newArcTimerDuration = remoteConfig.configValue(forKey: "ARC_TIMER_DURATION").numberValue.intValue

            if newMainTimerDuration > 0 {
                mainTimerDuration = newMainTimerDuration
                logger.info("MainTimerDurationを更新しました: \(self.mainTimerDuration)")
            }

            if newArcTimerDuration > 0 {
                arcTimerDuration = newArcTimerDuration
                logger.info("ArcTimerDurationを更新しました: \(self.arcTimerDuration)")
            }

            if !newEndpoint.isEmpty {
                apiEndpoint = newEndpoint
                logger.info("API_ENDPOINTを更新しました: \(self.apiEndpoint)")
            }
        } catch {
            logger.error("Remote Configの取得エラー: \(error.localizedDescription)")
        }
    }
}
