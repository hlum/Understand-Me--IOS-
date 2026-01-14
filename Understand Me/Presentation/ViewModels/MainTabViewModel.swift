//
//  MainTabViewModel.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/11.
//

import Foundation
import Combine
import OSLog

class MainTabViewModel: ObservableObject {
    @Published var userData: UserData? = nil
    private let userDataUseCase: UserDataUseCase
    private let authenticationUseCase: AuthenticationUseCase
    private let resultUseCase: ResultUseCase
    private let homeworkUseCase: HomeworkUseCase
    
    private var fcmTokenObserver: NSObjectProtocol?
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnderstandMe", category: "Presentation")
    
    init(
        userDataUseCase: UserDataUseCase,
        authenticationUseCase: AuthenticationUseCase,
        resultUseCase: ResultUseCase,
        homeworkUseCase: HomeworkUseCase
    ) {
        self.userDataUseCase = userDataUseCase
        self.authenticationUseCase = authenticationUseCase
        self.resultUseCase = resultUseCase
        self.homeworkUseCase = homeworkUseCase
        setupFCMTokenObserver()
        self.updateWidgetData()
    }
    
    deinit {
        if let observer = fcmTokenObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // App DelegateでFCMトークンが更新されたときに呼ばれる通知を監視する
    private func setupFCMTokenObserver() {
        fcmTokenObserver = NotificationCenter.default.addObserver(
            forName: .fcmTokenRefreshed,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let userID = self.userData?.id else { return }
            
            Task {
                await FCMTokenManager.shared.updateFCMTokenToServer(
                    userID: userID,
                    userDataUseCase: self.userDataUseCase
                )
            }
        }
    }
    
    
    
    func saveUserDataIfNotExist(authDataResult: AuthDataResultModel) async {
        do {
            guard let email = authDataResult.email else {
                logger.error("Emailが取得できません")
                return
            }
            
            guard let info = extractStudentInfo(from: email) else {
                logger.error("メール形式が正しくありません。")
                return
            }
            
            // nameはAuthDataResultModelから取得、なければemailを使用
            let name = authDataResult.name ?? email
            
            let userData = UserData(
                id: authDataResult.id,
                email: email,
                name: name,
                fcmToken: nil,
                studentCode: info.studentCode,
                majorCode: info.className,
                admissionYear: info.admissionYear,
                photoURL: authDataResult.photoURL?.absoluteString
            )
            
            try await userDataUseCase.saveUserDataIfNotExist(userData: userData)
        } catch {
            logger.error("UserDataの保存に失敗しました。\(error.localizedDescription)")
        }
    }
    
    
    
    @MainActor
    func loadUserData(userID: String) async {
        do {
            self.userData = try await userDataUseCase.fetchUserData(userID: userID)
            
            // FCMトークンをサーバーに送信
            await FCMTokenManager.shared.updateFCMTokenToServer(
                userID: userID,
                userDataUseCase: userDataUseCase
            )
        } catch {
            // TODO: Userにエラーを知らせる
            logger.error("MainTabViewModel.loadUseData: UserDataの取得に失敗しました。\(error.localizedDescription)")
        }
    }
    
    
    // メールから学年と学科コードを取得する、もしメールが学校のメールじゃない場合ダミーを返す
    func extractStudentInfo(from email: String) -> (studentCode: String, className: String, admissionYear: Int)? {
        // Example valid format: "24cm0138@jec.ac.jp"
        guard let atIndex = email.firstIndex(of: "@") else {
            return ("99zz", "zz", 99)
        }
        
        // Get part before "@"
        let localPart = String(email[..<atIndex]) // e.g., "24cm0138"
        
        // Must have at least 4 characters to include year + class
        guard localPart.count >= 4 else {
            return ("99zz", "zz", 99)
        }
        
        // admissionYear = first 2 chars
        let yearPart = String(localPart.prefix(2)) // "24"
        guard let admissionYear = Int(yearPart) else {
            return ("99zz", "zz", 99)
        }
        
        // Extract class name: next 2 letters after the year
        let startIndex = localPart.index(localPart.startIndex, offsetBy: 2)
        let classPart = localPart[startIndex...]
        let letters = classPart.prefix(while: { $0.isLetter })
        let className = String(letters)
        
        // Class name must be exactly 2 letters (e.g., "cm")
        guard className.count == 2 else {
            return ("99zz", "zz", 99)
        }
        
        // studentCode is the full before "@"
        let studentCode = localPart
        
        return (studentCode, className, admissionYear)
    }
    
    func fetchCurrentLoginUser() async -> AuthDataResultModel? {
        return await authenticationUseCase.fetchCurrentUser()
    }

}


// MARK: - Widget Data Update
extension MainTabViewModel {

    /// Fetches data needed by the widget and stores it in UserDefaults
    func updateWidgetData() {
        Task {
            guard let authUser = await authenticationUseCase.fetchCurrentUser() else {
                logger.warning("認証ユーザーが存在しません。")
                return
            }
            
            do {
                let results = try await resultUseCase.fetchResults(userID: authUser.id)
                
                updateAverageScore(results: results)
                try await updateHomeworkProgress(results: results, userID: authUser.id)
                
            } catch {
                logger.error("ウィジェット用データの更新に失敗しました: \(error.localizedDescription)")
            }
        }
    }
}


// MARK: - Widget Calculations
private extension MainTabViewModel {

    func updateAverageScore(results: [ResultData]) {
        let averageScore = calculateAverageScore(from: results)
        saveToUserDefaults(key: .AVERAGESCORE, value: averageScore)
    }

    func updateHomeworkProgress(results: [ResultData], userID: String) async throws {
        let progress = try await calculateHomeworkProgress(
            results: results,
            userID: userID
        )
        saveToUserDefaults(key: .HOMEWORK_PROGRESS, value: progress)
    }
}


// MARK: - Calculation Logic
private extension MainTabViewModel {

    func calculateAverageScore(from results: [ResultData]) -> Int {
        guard !results.isEmpty else { return 0 }

        let totalScore = results.reduce(0) { $0 + $1.score }
        return totalScore / results.count
    }

    func calculateHomeworkProgress(
        results: [ResultData],
        userID: String
    ) async throws -> Int {

        let homeworks = try await homeworkUseCase.fetchHomeworks(studentID: userID)
        guard !homeworks.isEmpty else { return 0 }

        let progress = (Double(results.count) / Double(homeworks.count)) * 100
        return min(Int(progress), 100)
    }
}


// MARK: - Persistence
private extension MainTabViewModel {

    func saveToUserDefaults(key: WidgetDataKeys, value: Int) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
}
