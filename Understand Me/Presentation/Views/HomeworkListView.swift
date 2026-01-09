//
//  HomeworkListView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/09.
//

import SwiftUI

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
            
            
            if !viewModel.filteredHomeworks.isEmpty{
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.filteredHomeworks) { homework in
                            HomeworkListItemView(id: homework.id, title: homework.title, dueDate: homework.dueDate, state: homework.submissionState)
                        }
                    }
                    .padding()
            }
            } else {
                ContentUnavailableView("該当する課題はありません。", systemImage: "book.closed")
                    .foregroundStyle(.secondary.opacity(0.7))
            }
        }
        .navigationTitle("全ての課題")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "課題を検索")
        .task {
            await viewModel.loadHomeworks()
            viewModel.filterAndSearch()
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
