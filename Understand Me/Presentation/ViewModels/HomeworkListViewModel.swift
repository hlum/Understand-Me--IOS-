//
//  HomeworkListViewModel.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/14.
//

import Foundation
import Combine


enum HomeworkFilterOption: Hashable, CaseIterable {
    case all
    case state(HomeworkState)
    
    var displayName: String {
        switch self {
        case .all:
            return "すべて"
        case .state(let homeworkState):
            return homeworkState.stateDescription
        }
    }
    
    static var allCases: [HomeworkFilterOption] {
        return [.all] + HomeworkState.allCases.map { .state($0) }
    }
}


class HomeworkListViewModel: ObservableObject {
    @Published var homeworks: [HomeworkWithStatus] = []
    
    @Published var selectedFilter: HomeworkFilterOption = .all
    
    private var homeworkUseCase: HomeworkUseCase
    private var authenticationUseCase: AuthenticationUseCase
    
    init(
        homeworkUseCase: HomeworkUseCase,
        authenticationUseCase: AuthenticationUseCase
    ) {
        self.homeworkUseCase = homeworkUseCase
        self.authenticationUseCase = authenticationUseCase
    }
    
    @MainActor
    func loadHomeworks() async {
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            print("HomeworkListViewModel.loadHomeworks: ログインしているユーザーがいません。")
            return
        }
        
        do {
            self.homeworks = try await homeworkUseCase.fetchHomeworks(studentID: authDataResult.id)
        } catch {
            print("HomeworkListViewModel.loadHomeworks: 宿題の取得に失敗しました。\(error.localizedDescription)")
        }
    }
}
