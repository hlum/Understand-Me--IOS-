//
//  HomeworkListViewModel.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/14.
//

import Foundation
import Combine
import SwiftUI

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
    @Published var allHomeworks: [HomeworkWithStatus] = []
    @Published var filteredHomeworks: [HomeworkWithStatus] = []
    
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
            self.allHomeworks = try await homeworkUseCase.fetchHomeworks(studentID: authDataResult.id).sorted(by: { $0.dueDate! < $1.dueDate! })
        } catch {
            print("HomeworkListViewModel.loadHomeworks: 宿題の取得に失敗しました。\(error.localizedDescription)")
        }
    }
    
    
    @MainActor
    func filterHomeworks() {
        withAnimation(.easeInOut) {
            switch selectedFilter {
            case .all:
                filteredHomeworks = allHomeworks
            case .state(let homeworkState):
                filteredHomeworks = allHomeworks.filter { $0.submissionState == homeworkState }
            }
        }
    }
    
}
