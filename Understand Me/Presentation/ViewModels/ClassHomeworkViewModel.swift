//
//  ClassHomeworkViewModel.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/14.
//

import Foundation
import Combine

class ClassHomeworkViewModel: ObservableObject {
    @Published var homeworks: [HomeworkWithStatus] = []
    @Published var classInfo: Class? = nil
    @Published var filteredHomeworks: [HomeworkWithStatus] = []
    @Published var selectedFilterOption: HomeworkFilterOption = .all
    
    private var homeworkUseCase: HomeworkUseCase
    private var authenticationUseCase: AuthenticationUseCase
    private var classUseCase: ClassUseCase
    private var classID: String
    
    
    init(
        homeworkUseCase: HomeworkUseCase,
        authenticationUseCase: AuthenticationUseCase,
        classUseCase: ClassUseCase,
        classID: String
    ) {
        self.homeworkUseCase = homeworkUseCase
        self.authenticationUseCase = authenticationUseCase
        self.classUseCase = classUseCase
        self.classID = classID
    }
    
    @MainActor
    func loadClassInfos() async {
        do {
            self.classInfo = try await classUseCase.fetchClass(id: classID)
        } catch {
            print("ClassHomeworkViewModel.loadClassInfos: クラス情報の取得に失敗しました。\(error.localizedDescription)")
        }
    }
    
    
    
    @MainActor
    func loadHomeworks(classID: String) async {
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            print("ClassHomeworkViewModel.loadHomeworks: ログインしているユーザーがいません。")
            return
        }
        
        do {
            self.homeworks = try await homeworkUseCase.fetchHomeworks(studentID: authDataResult.id, classID: classID)
        } catch {
            print("ClassHomeworkViewModel.loadHomeworks: 宿題の取得に失敗しました。\(error.localizedDescription)")
        }
    }
    
    
    @MainActor
    func filterHomeworks() {
        switch selectedFilterOption {
        case .all:
            filteredHomeworks = homeworks
        case .state(let state):
            filteredHomeworks = homeworks.filter { $0.submissionState == state }
        }
    }
}
