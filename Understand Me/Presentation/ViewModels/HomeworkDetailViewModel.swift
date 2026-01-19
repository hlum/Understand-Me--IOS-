//
//  HomeworkDetailViewModel.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/14.
//

import Foundation
import Combine
import OSLog


// Graph に表示する月ごとの平均点数
struct AverageResultPerMonth: Identifiable {
    let id: String = UUID().uuidString
    let month: Date
    let averageScore: Double
    
    init(month: Date, averageScore: Double) {
        self.month = month
        self.averageScore = averageScore
    }
    
    
    init(resultsOfOneMonth: [ResultData]) {
        self.month = resultsOfOneMonth.first?.evaluatedAt ?? Date()
        let totalScore = resultsOfOneMonth.reduce(0.0) { partialResult, result in
            partialResult + Double(result.score)
        }
        self.averageScore = totalScore / Double(resultsOfOneMonth.count)
    }
    
    
    static func getDummy() -> [AverageResultPerMonth] {
        let now = Date()
        let calendar = Calendar.current
        var dummyData: [AverageResultPerMonth] = []
        for i in 0..<12 {
            if let monthDate = calendar.date(byAdding: .month, value: -i, to: now) {
                let averageScore = Double.random(in: 60...100)
                let averageResult = AverageResultPerMonth(
                    month: monthDate,
                    averageScore: averageScore
                )
                dummyData.append(averageResult)
            }
        }
        
        return dummyData
        
    }
}

class HomeworkDetailViewModel: ObservableObject {
    @Published var homework: HomeworkWithStatus?
    @Published var classDetail: Class?
    @Published var homeworkLinkTxt: String = ""
    @Published var result: ResultData? = nil
    @Published var errorMessage: String = ""
    @Published var showErrorAlert: Bool = false
    @Published var showInputError: Bool = false
    @Published var inputErrorMessage: String = ""
    
    private let homeworkUseCase: HomeworkUseCase
    private let classUseCase: ClassUseCase
    private let projectUseCase: ProjectUseCase
    private let authenticationUseCase: AuthenticationUseCase
    private let resultUseCase: ResultUseCase
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnderstandMe", category: "Presentation")
    
    init(
        homeworkUseCase: HomeworkUseCase,
        classUseCase: ClassUseCase,
        projectUseCase: ProjectUseCase,
        authenticationUseCase: AuthenticationUseCase,
        resultUseCase: ResultUseCase
    ) {
        self.homeworkUseCase = homeworkUseCase
        self.classUseCase = classUseCase
        self.projectUseCase = projectUseCase
        self.authenticationUseCase = authenticationUseCase
        self.resultUseCase = resultUseCase
    }
    
    
    
    @MainActor
    func loadInfoOfHomework(homeworkID: String) async {
        await loadHomework(id: homeworkID)
        if let homework = self.homework {
            await loadClassDetail(classID: homework.classID)
        }
    }
    
    
    
    func uploadProject() async {
        inputErrorMessage = ""
        showInputError = false

        // Validate URL format
        guard let url = URL(string: homeworkLinkTxt) else {
            await showInputError(message: "URLの形式が不正です。正しいURLを入力してください。")
            logger.error("HomeworkDetailViewModel.uploadProject: URLの形式が不正です。")
            return
        }

        // Validate URL type (GitHub or Google Drive)
        let validationResult = validateRepositoryURL(url)
        if let errorMessage = validationResult {
            await showInputError(message: errorMessage)
            logger.error("HomeworkDetailViewModel.uploadProject: \(errorMessage)")
            return
        }

        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            await showInputError(message: "予期せぬエラーが発生しました。もう一度やり直してください。")
            logger.error("HomeworkDetailViewModel.uploadProject: ログインしているユーザーがいません。")
            return
        }

        guard let homework = homework else {
            await showInputError(message: "宿題の情報が見つかりません。")
            logger.error("HomeworkDetailViewModel.uploadProject: 宿題の情報がありません。")
            return
        }

        do {
            try await projectUseCase.uploadProject(
                userID: authDataResult.id,
                homeworkID: homework.id,
                githubURLString: homeworkLinkTxt
            )
        } catch let error as UseCaseErrors {
            await showInputError(message: error.localizedDescription)
        } catch {
            // unexpected errors
            await showInputError(message: "予期せぬエラーが発生しました。もう一度やり直してください。")
            logger.error("HomeworkDetailViewModel.uploadProject: \(error.localizedDescription)")
        }
    }
    
    
    
    func retryQuestionGeneration(homeworkID: String) async  {
        
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            await showAlert(message: "ログイン情報を取得できませんでした。")
            logger.error("HomeworkDetailViewModel.retryQuestionGeneration: ログインしているユーザーがいません。")
            return
        }
        
        do {
            try await homeworkUseCase.retryQuestionGeneration(homeworkID: homeworkID, studentID: authDataResult.id)
        } catch let error as LollipopError {
            await showAlert(message: error.errorDescription ?? "問題生成の再試行に失敗しました。")
            logger.error("HomeworkDetailViewModel.retryQuestionGeneration: \(error.debugDescription)")
        } catch {
            await showAlert(message: "問題生成の再試行に失敗しました。")
            logger.error("HomeworkDetailViewModel.retryQuestionGeneration: \(error.localizedDescription)")
        }
    }
    
    
    
    func cancelHomeworkSubmission(homeworkID: String) async {
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            await showAlert(message: "ログイン情報を取得できませんでした。")
            logger.error("HomeworkDetailViewModel.cancelHomeworkSubmission: ログインしているユーザーがいません。")
            return
        }
        
        do {
            try await homeworkUseCase.cancelHomeworkSubmission(homeworkID: homeworkID, studentID: authDataResult.id)
        } catch let error as LollipopError {
            await showAlert(message: error.errorDescription ?? "宿題提出の取り消しに失敗しました。")
            logger.error("HomeworkDetailViewModel.cancelHomeworkSubmission: \(error.debugDescription)")
        } catch {
            await showAlert(message: "宿題提出の取り消しに失敗しました。")
            logger.error("HomeworkDetailViewModel.cancelHomeworkSubmission: \(error.localizedDescription)")
        }
    }
    
    
    
    
    @MainActor
    private func loadHomework(id: String) async {
        do {
            
            guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
                showAlert(message: "ログイン情報を取得できませんでした。")
                logger.error("HomeworkDetailViewModel.loadHomework: ログインしているユーザーがいません。")
                return
            }
            
            homework = try await homeworkUseCase.fetchHomework(id: id, studentID: authDataResult.id)
        } catch let error as LollipopError {
            showAlert(message: error.errorDescription ?? "宿題の取得に失敗しました。")
            logger.error("HomeworkDetailViewModel.loadHomework: \(error.debugDescription)")
        } catch {
            showAlert(message: "宿題の取得に失敗しました。")
            logger.error("HomeworkDetailViewModel.loadHomework: \(error.localizedDescription)")
        }
    }
    
    
    
    @MainActor
    private func loadClassDetail(classID: String) async {
        do {
            self.classDetail = try await classUseCase.fetchClass(id: classID)
        } catch let error as LollipopError {
            showAlert(message: error.errorDescription ?? "クラス情報の取得に失敗しました。")
            logger.error("HomeworkDetailViewModel.loadClassDetail: \(error.debugDescription)")
        } catch let urlError as URLError where urlError.code == .cancelled {
            logger.debug("HomeworkDetailViewModel.loadClassDetail: network request cancelled")
        } catch {
            showAlert(message: "クラス情報の取得に失敗しました。")
            logger.error("HomeworkDetailViewModel.loadClassDetail: \(error.localizedDescription)")
        }
    }
    
    // TODO: Result should be nullable
    @MainActor
    func loadResult(homeworkID: String) async {
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            showAlert(message: "ログイン情報を取得できませんでした。")
            logger.error("QuestionsViewModel.loadAnswersForReview: ログイン中のUserがありません。")
            return
        }

        do {
            self.result = try await resultUseCase.fetchResult(userID: authDataResult.id, homeworkID: homeworkID)
        } catch let error as LollipopError {
            showAlert(message: error.errorDescription ?? "結果の取得に失敗しました。")
            logger.error("QuestionsViewModel.loadResult: \(error.debugDescription)")
        } catch {
            showAlert(message: "結果の取得に失敗しました。")
            logger.error("QuestionsViewModel.loadResult: \(error.localizedDescription)")
        }
    }

    @MainActor
    private func showAlert(message: String) {
        errorMessage = message
        showErrorAlert = true
    }
    
    @MainActor
    private func showInputError(message: String) {
        inputErrorMessage = message
        showInputError = true
    }

    /// Validates if the URL is a valid GitHub repository or Google Drive link
    /// - Parameter url: The URL to validate
    /// - Returns: Error message if invalid, nil if valid
    private func validateRepositoryURL(_ url: URL) -> String? {
        guard let host = url.host?.lowercased() else {
            return "無効なURLです。"
        }

        // Check if it's GitHub
        if host == "github.com" || host == "www.github.com" {
            return validateGitHubURL(url)
        }

        // Check if it's Google Drive
        if host == "drive.google.com" || host.hasSuffix(".google.com") {
            return validateGoogleDriveURL(url)
        }

        // Not a supported platform
        return "GitHubまたはGoogle Driveのリンクのみ対応しています。"
    }

    /// Validates GitHub repository URL
    /// Valid formats:
    /// - https://github.com/username/repository
    /// - https://github.com/username/repository/
    private func validateGitHubURL(_ url: URL) -> String? {
        let pathComponents = url.pathComponents.filter { $0 != "/" }

        // Must have at least username and repository name
        guard pathComponents.count >= 2 else {
            return "GitHubのリポジトリURLが無効です。\n正しい形式: https://github.com/ユーザー名/リポジトリ名"
        }

        let username = pathComponents[0]
        let repository = pathComponents[1]

        // Username validation: alphanumeric, hyphens, max 39 characters
        let usernamePattern = "^[a-zA-Z0-9]([a-zA-Z0-9-]{0,37}[a-zA-Z0-9])?$"
        guard username.range(of: usernamePattern, options: .regularExpression) != nil else {
            return "GitHubのユーザー名が無効です。"
        }

        // Repository name validation: alphanumeric, hyphens, underscores, dots
        let repoPattern = "^[a-zA-Z0-9._-]+$"
        guard repository.range(of: repoPattern, options: .regularExpression) != nil else {
            return "GitHubのリポジトリ名が無効です。"
        }

        // Check for disallowed repository names
        if repository == ".git" || repository == ".." {
            return "GitHubのリポジトリ名が無効です。"
        }

        // If there are more path components, it might be a specific file/folder
        // We'll allow it, but it should be the base repository URL
        if pathComponents.count > 2 {
            // Allow /tree/, /blob/, etc. for specific branches or files
            // But warn if it's not a standard pattern
            let thirdComponent = pathComponents[2]
            let allowedPaths = ["tree", "blob", "releases", "issues", "pull", "wiki", "commits", "branches", "tags"]
            if !allowedPaths.contains(thirdComponent) && thirdComponent != "" {
                return "リポジトリのメインページのURLを入力してください。\n正しい形式: https://github.com/ユーザー名/リポジトリ名"
            }
        }

        return nil // Valid
    }

    /// Validates Google Drive URL
    /// Valid formats:
    /// - https://drive.google.com/file/d/[ID]/view
    /// - https://drive.google.com/drive/folders/[ID]
    /// - https://drive.google.com/open?id=[ID]
    private func validateGoogleDriveURL(_ url: URL) -> String? {
        let pathComponents = url.pathComponents.filter { $0 != "/" }

        // Check for file sharing links
        if pathComponents.contains("file") {
            // Should have format: /file/d/[ID]/...
            guard let dIndex = pathComponents.firstIndex(of: "d"),
                  dIndex + 1 < pathComponents.count else {
                return "Google DriveのリンクのIDが見つかりません。\n共有リンクを正しくコピーしてください。"
            }

            let fileId = pathComponents[dIndex + 1]
            guard !fileId.isEmpty && fileId.count > 10 else {
                return "Google DriveのファイルIDが無効です。"
            }

            return nil // Valid file link
        }

        // Check for folder sharing links
        if pathComponents.contains("folders") {
            guard let foldersIndex = pathComponents.firstIndex(of: "folders"),
                  foldersIndex + 1 < pathComponents.count else {
                return "Google DriveのフォルダIDが見つかりません。"
            }

            let folderId = pathComponents[foldersIndex + 1]
            guard !folderId.isEmpty && folderId.count > 10 else {
                return "Google DriveのフォルダIDが無効です。"
            }

            return nil // Valid folder link
        }

        // Check for old-style open links with query parameter
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems,
           let idItem = queryItems.first(where: { $0.name == "id" }),
           let id = idItem.value, !id.isEmpty, id.count > 10 {
            return nil // Valid old-style link
        }

        // If we got here, it might be a valid Google Drive link but in an unexpected format
        // Let's allow it if it's from drive.google.com
        if url.host?.contains("drive.google.com") == true {
            return "Google Driveのリンクを確認してください。\n「リンクを知っている全員がアクセス可能」に設定されているか確認してください。"
        }

        return "無効なGoogle Driveリンクです。ファイルまたはフォルダの共有リンクを使用してください。"
    }

}

