//
//  HomeworkListView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/09.
//

import SwiftUI
import AlertToast

struct HomeworkListView: View {
    @StateObject private var viewModel: HomeworkListViewModel
    
    init(homeworkRepo: HomeworkRepository = LollipopHomeworkRepository(),
         authRepo: AuthenticationRepository = FirebaseAuthenticationRepository()
    ) {
        self._viewModel = .init(
            wrappedValue: .init(
                homeworkUseCase: HomeworkUseCase(homeworkRepository: homeworkRepo),
                authenticationUseCase: AuthenticationUseCase(authenticationRepository: authRepo)
            )
        )
    }
    
    @State private var taskId: UUID = .init()

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(HomeworkFilterOption.allCases, id: \.self) { option in
                        FilterButton(title: option.displayName, isSelected: viewModel.selectedFilter == option) {
                            viewModel.selectedFilter = option
                            viewModel.filterAndSearch()
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(10)
            .cornerRadius(10)
            ScrollView {
                
                if viewModel.isLoading || viewModel.isFiltering {
                    HomeworkListSkeleton()
                } else if !viewModel.filteredHomeworks.isEmpty {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.filteredHomeworks) { homework in
                            HomeworkListItemView(
                                id: homework.id,
                                title: homework.title,
                                dueDate: homework.dueDate,
                                state: homework.submissionState,
                                onTestCompleted: {
                                    // Refresh list when test is completed
                                    Task {
                                        guard !Task.isCancelled else { return }
                                        await viewModel.loadHomeworks()
                                        
                                        guard !Task.isCancelled else { return }
                                        viewModel.filterAndSearch()
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                    
                } else {
                    ContentUnavailableView("該当する課題はありません。", systemImage: "book.closed")
                        .foregroundStyle(.secondary.opacity(0.7))
                }
            }
            .refreshable {
                taskId = .init()
            }
        }
        .navigationTitle("全ての課題")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "課題を検索")
        .task(id: taskId) {
            await viewModel.loadHomeworks()
            viewModel.filterAndSearch()
        }
        .toast(isPresenting: $viewModel.showErrorAlert) {
            AlertToast(
                displayMode: .alert,
                type: .error(.red),
                title: "エラーが発生しました",
                subTitle: viewModel.errorMessage
            )
        }
    }
}

// MARK: - Filter Button
struct FilterButton: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.vertical, 6)
                .padding(.horizontal, 14)
                .background(isSelected ? Color.accentColor.opacity(0.25) : Color.gray.opacity(0.001))
                .foregroundColor(isSelected ? .accentColor : .primary)
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        HomeworkListView(homeworkRepo: TestHomeworkRepository(), authRepo: TestAuthenticationRepository())
    }
}
