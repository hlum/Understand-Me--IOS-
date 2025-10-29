//
//  AppDelegate.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/29.
//

import SwiftUI
import Firebase
import FirebaseMessaging
import UserNotifications
import OSLog

class AppDelegate: NSObject, UIApplicationDelegate {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnderstandMe", category: "Presentation")
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // Firebase Cloud Messagingのデリゲートを設定
        Messaging.messaging().delegate = self
        
        // 通知の許可をリクエスト
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { [weak self] granted, error in
                if let error = error {
                    self?.logger.error("通知許可の取得に失敗しました: \(error.localizedDescription)")
                } else if granted {
                    self?.logger.info("通知許可が付与されました")
                }
            }
        )
        
        // Apple Push Notificationサービスに登録
        application.registerForRemoteNotifications()
        
        return true
    }
    
    // Apple Push Notificationサービスへの登録が成功した場合に呼ばれる
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
    // FCMトークンが更新されたときに呼ばれる
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else {
            logger.error("FCMトークンがnilです")
            return
        }
        
        logger.info("FCMトークンを受信しました: \(fcmToken)")
        
        // FCM トークンが更新されたことを通知(アプリ内通知)
        NotificationCenter.default.post(
            name: .fcmTokenRefreshed,
            object: nil,
            userInfo: ["token": fcmToken]
        )
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([[.banner, .sound]])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response.notification.request.content.userInfo["homeworkId"])
        completionHandler()
    }
}
