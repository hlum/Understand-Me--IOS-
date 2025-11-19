//
//  ClassListViewModel.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/13.
//

import Foundation
import Combine
import OSLog

class ClassListViewModel: ObservableObject {
    @Published var classes: [Class] = []
    @Published var classCode: String = ""
    @Published var classCodeErrorMessage: String = ""
    @Published var showAddOptionalClassSheet: Bool = false
    private let classUseCase: ClassUseCase
    private let authenticationUseCase: AuthenticationUseCase
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnderstandMe", category: "Presentation")
    
    
    
    init(classUseCase: ClassUseCase, authenticationUseCase: AuthenticationUseCase) {
        self.classUseCase = classUseCase
        self.authenticationUseCase = authenticationUseCase
    }
    
    
    @MainActor
    func addOptionalClass() async {
        guard !classCode.isEmpty else {
            showClassCodeError(message: "学科コードを入力してください！")
            return
        }
        
        guard let authData = await authenticationUseCase.fetchCurrentUser() else {
            showClassCodeError(message: "予期せぬエラ発生しました、もう一度やり直してください！")
            logger.error("ClassListViewModel.addOptionalClass: ログイン中のユーザのデータ取得に失敗したので、クラスの追加に失敗。")
            return
        }
        
        do {
            try await classUseCase.addOptionalClass(classCode: classCode, userID: authData.id)
            showAddOptionalClassSheet = false
            await loadClasses()
        } catch(ClassUseCaseErrors.InvalidClassCode) {
            showClassCodeError(message: "学科コードが無効です。")
        } catch(ClassUseCaseErrors.AlreadyEnrolled) {
            showClassCodeError(message: "すでにこの科目に登録されています。")
        } catch {
            showClassCodeError(message: "予期せぬエラ発生しました、もう一度やり直してください！")
        }
    }
    
    
    
    @MainActor
    func loadClasses() async {
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            logger.error("ClassListViewModel.loadClasses: ログイン中のユーザのデータ取得に失敗したので、クラスの取得ができません。")
            return
        }
        do {
            classes = try await classUseCase.fetchClassList(studentID: authDataResult.id)
        } catch {
            logger.error("ClassListViewModel.loadClasses: クラスの取得に失敗しました。詳細：\(error.localizedDescription)")
        }
    }
    
    
    @MainActor
    func showClassCodeError(message: String) {
        classCodeErrorMessage = message
    }
}
