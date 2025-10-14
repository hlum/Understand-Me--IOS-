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
    
    private let homeworkUseCase: HomeworkUseCase
    private let classUseCase: ClassUseCase
    
    init(homeworkUseCase: HomeworkUseCase, classUseCase: ClassUseCase) {
        self.homeworkUseCase = homeworkUseCase
        self.classUseCase = classUseCase
    }
    
    
    @MainActor
    func loadInfoOfHomework(homeworkID: String) async {
        await loadHomework(id: homeworkID)
        if let homework = self.homework {
            await loadClassDetail(classID: homework.classID)
        }
    }
    
    
    @MainActor
    private func loadHomework(id: String) async {
        do {
            homework = try await homeworkUseCase.fetchHomework(id: id)
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

