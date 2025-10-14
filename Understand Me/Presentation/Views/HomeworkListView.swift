//
//  HomeworkListView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/09.
//

import SwiftUI

struct HomeworkListView: View {
    @StateObject private var viewModel = HomeworkListViewModel(
        homeworkUseCase: HomeworkUseCase(homeworkRepository: LollipopHomeworkRepository()),
        authenticationUseCase: AuthenticationUseCase(authenticationRepository: FirebaseAuthenticationRepository())
    )
    @State private var searchText = ""
    @State private var selectedFilter: HomeworkState? = nil

    var body: some View {
        VStack(spacing: 0) {

                HStack(spacing: 10) {
                    FilterButton(title: "すべて", isSelected: selectedFilter == nil) {
                        selectedFilter = nil
                    }
                    FilterButton(title: "未提出", isSelected: selectedFilter == .notAssigned) {
                        selectedFilter = .notAssigned
                    }
                    FilterButton(title: "生成中", isSelected: selectedFilter == .generatingQuestions) {
                        selectedFilter = .generatingQuestions
                    }
                    FilterButton(title: "完了", isSelected: selectedFilter == .completed) {
                        selectedFilter = .completed
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .cornerRadius(10)
            

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.homeworks) { homework in
                        HomeworkListItemView(title: homework.title, dueDate: homework.dueDate ?? Date(), state: homework.submissionState)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("全ての課題")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, placement: .navigationBarDrawer, prompt: "課題を検索")
        .task {
            await viewModel.loadHomeworks()
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
        HomeworkListView()
    }
}
