//
//  HomeworkDetailViewModel.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/14.
//

import Foundation
import Combine

class HomeworkDetailViewModel: ObservableObject {
    @Published var homework: HomeworkWithStatus?
    @Published var classDetail: Class?
    @Published var homeworkLinkTxt: String = ""
    
    private let homeworkUseCase: HomeworkUseCase
    private let classUseCase: ClassUseCase
    private let projectUseCase: ProjectUseCase
    private let authenticationUseCase: AuthenticationUseCase
    
    init(
        homeworkUseCase: HomeworkUseCase,
        classUseCase: ClassUseCase,
        projectUseCase: ProjectUseCase,
        authenticationUseCase: AuthenticationUseCase
    ) {
        self.homeworkUseCase = homeworkUseCase
        self.classUseCase = classUseCase
        self.projectUseCase = projectUseCase
        self.authenticationUseCase = authenticationUseCase
    }
    
    
    
    @MainActor
    func loadInfoOfHomework(homeworkID: String) async {
        await loadHomework(id: homeworkID)
        if let homework = self.homework {
            await loadClassDetail(classID: homework.classID)
        }
    }
    
    
    
    func uploadProject() async {
        guard let _ = URL(string: homeworkLinkTxt) else {
            // TODO: USER にAlertで知らせる
            print("HomeworkDetailViewModel.uploadProject: URLの形式が不正です。")
            return
        }
        
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            print("HomeworkDetailViewModel.uploadProject: ログインしているユーザーがいません。")
            return
        }
        
        guard let homework = homework else {
            print("HomeworkDetailViewModel.uploadProject: 宿題の情報がありません。")
            return
        }
        
        do {
            try await projectUseCase.uploadProject(
                userID: authDataResult.id,
                homeworkID: homework.id,
                githubURLString: homeworkLinkTxt
            )
        } catch {
            // TODO: Alert the user and impl retry methods
            print("HomeworkDetailViewModel.uploadProject: プロジェクトのアップロードに失敗しました。\(error.localizedDescription)")
        }
    }
    
    
    
    func retryQuestionGeneration(homeworkID: String) async  {
        
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            print("HomeworkDetailViewModel.retryQuestionGeneration: ログインしているユーザーがいません。")
            return
        }
        
        do {
            try await homeworkUseCase.retryQuestionGeneration(homeworkID: homeworkID, studentID: authDataResult.id)
        } catch {
            // TODO: Alert the user
            print("HomeworkDetailViewModel.retryQuestionGeneration: リトライ失敗.\(error.localizedDescription)")
        }
    }
    
    
    
    func cancelHomeworkSubmission(homeworkID: String) async {
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            print("HomeworkDetailViewModel.uploadProject: ログインしているユーザーがいません。")
            return
        }
        
        do {
            try await homeworkUseCase.cancelHomeworkSubmission(homeworkID: homeworkID, studentID: authDataResult.id)
        } catch {
            // TODO: Alert the user
            print("HomeworkDetailViewModel.cancelHomeworkSubmission: 取り消し失敗.\(error.localizedDescription)")
        } 
    }
    
    
    
    
    @MainActor
    private func loadHomework(id: String) async {
        do {
            
            guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
                print("HomeworkDetailViewModel.loadHomework: ログインしているユーザーがいません。")
                return
            }
            
            homework = try await homeworkUseCase.fetchHomework(id: id, studentID: authDataResult.id)
        } catch {
            print("HomeworkDetailViewModel.loadHomework: 宿題の取得に失敗しました。\(error.localizedDescription)")
        }
    }
    
    
    
    @MainActor
    private func loadClassDetail(classID: String) async {
        do {
            self.classDetail = try await classUseCase.fetchClass(id: classID)
        } catch {
            print("HomeworkDetailViewModel.loadClassDetail: クラス情報の取得に失敗しました。\(error.localizedDescription)")
        }
    }
    
}

