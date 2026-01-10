//
//  HomeworkListViewModel.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/14.
//

import Foundation
import Combine
import SwiftUI
import OSLog

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
    // MARK: Dependencies
    private var homeworkUseCase: HomeworkUseCase
    private var authenticationUseCase: AuthenticationUseCase
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnderstandMe", category: "Presentation")
    
    // MARK: Published State
    @Published var allHomeworks: [HomeworkWithStatus] = []
    @Published var filteredHomeworks: [HomeworkWithStatus] = []
    @Published var searchText = ""
    @Published var selectedFilter: HomeworkFilterOption = .all
    @Published var errorMessage: String = ""
    @Published var showErrorAlert: Bool = false
    @Published var isLoading: Bool = false
    @Published var isFiltering: Bool = false
    
    private var cancellables: Set<AnyCancellable> = []
    
    
    
    init(
        homeworkUseCase: HomeworkUseCase,
        authenticationUseCase: AuthenticationUseCase
    ) {
        self.homeworkUseCase = homeworkUseCase
        self.authenticationUseCase = authenticationUseCase
        self.observeSearchTextChange()
    }
    
    
    
    func observeSearchTextChange() {
        $searchText
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main) // ⏱ wait 300ms after last keystroke
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { @MainActor in
                    await self?.filterAndSearch()
                }
            }
            .store(in: &cancellables)
    }
    
    
    
    // MARK: Data Loading
    @MainActor
    func loadHomeworks() async {
        isLoading = true
        defer { isLoading = false }
        
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            logger.error("HomeworkListViewModel.loadHomeworks: ログインしているユーザーがいません。")
            return
        }
        
        do {
            
            self.allHomeworks = try await homeworkUseCase
                .fetchHomeworks(studentID: authDataResult.id)

        } catch let error as LollipopError {
            showAlert(message: error.errorDescription ?? "宿題一覧の取得に失敗しました。")
            logger.error("HomeworkListViewModel.loadHomeworks: \(error.debugDescription)")
        } catch {
            showAlert(message: "宿題一覧の取得に失敗しました。")
            logger.error("HomeworkListViewModel.loadHomeworks: \(error.localizedDescription)")
        }
    }
    
 
    
}

// MARK: Filtering Logic
extension HomeworkListViewModel {
    
    @MainActor
    func filterAndSearch() async {
        isFiltering = true
        defer { isFiltering = false }
        
        let homeworks = allHomeworks
        let filter = selectedFilter
        let search = searchText
        
        let result = await performFilterAndSearch(homeworks: homeworks, filter: filter, searchText: search)
        filteredHomeworks = result
    }
    
    @concurrent
    private func performFilterAndSearch(
        homeworks: [HomeworkWithStatus],
        filter: HomeworkFilterOption,
        searchText: String
    ) async -> [HomeworkWithStatus] {
        var result = await filterHomeworks(homeworks: homeworks, filter: filter)
        result = await searchHomeworks(homeworks: result, searchText: searchText)
        return result
    }
    
    @concurrent
    private func filterHomeworks(homeworks: [HomeworkWithStatus], filter: HomeworkFilterOption) async -> [HomeworkWithStatus] {
        var filteredHomeworks: [HomeworkWithStatus] = []
        
        switch filter {
        case .all:
            filteredHomeworks = homeworks.sorted { $0.createdAt > $1.createdAt }
        case .state(let homeworkState):
                if homeworkState == .notAssigned {
                    filteredHomeworks = homeworks
                        .filter { $0.submissionState == homeworkState }
                        .sorted {
                            switch ($0.dueDate, $1.dueDate) {
                                case let (d1?, d2?):  return d1 < d2     // 両方 non-nil → 直接比較
                                case (nil, nil):      return false       // 両方 nil → 順番変えない
                                case (nil, _):        return false       // 左が nil → 後ろへ
                                case (_, nil):        return true        // 右が nil → 左を前へ
                            }
                        }
                } else {
                    filteredHomeworks = homeworks
                        .filter { $0.submissionState == homeworkState }
                }
                
        }
        
        return filteredHomeworks
    }
    
    @concurrent
    private func searchHomeworks(homeworks: [HomeworkWithStatus], searchText: String) async -> [HomeworkWithStatus] {
        guard !searchText.isEmpty else { return homeworks }
        
        // 半角、全角、スペース、! を無視する
        func normalize(_ text: String) -> String {
            text
                .folding(options: [.diacriticInsensitive, .widthInsensitive, .caseInsensitive], locale: .current)
                .replacingOccurrences(of: "\\p{P}|\\s", with: "", options: .regularExpression)
        }
        
        let normalizedSearchText = normalize(searchText)
        
        return homeworks.filter {
            let normalizedTitle = normalize($0.title)
            let normalizedDescription = normalize($0.description ?? "")
            
            return normalizedTitle.contains(normalizedSearchText) ||
            normalizedDescription.contains(normalizedSearchText)
        }
    }
    
    @MainActor
    private func showAlert(message: String) {
        errorMessage = message
        showErrorAlert = true
    }
    
}
