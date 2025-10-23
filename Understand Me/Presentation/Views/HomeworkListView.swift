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
    
    var body: some View {
        VStack(spacing: 0) {
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(HomeworkFilterOption.allCases, id: \.self) { option in
                        FilterButton(title: option.displayName, isSelected: viewModel.selectedFilter == option) {
                            viewModel.selectedFilter = option
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(10)
            .cornerRadius(10)
            
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.homeworks) { homework in
                        HomeworkListItemView(id: homework.id, title: homework.title, dueDate: homework.dueDate ?? Date(), state: homework.submissionState)
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
