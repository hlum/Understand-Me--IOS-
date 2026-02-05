//
//  ClassHomeworkView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/08.
//

import SwiftUI
import AlertToast

struct ClassHomeworkView: View {

    @StateObject private var viewModel: ClassHomeworkViewModel
    @State private var refreshTrigger = UUID()

    var classID: String
    
    
    init(classID: String,
         homeworkRepo: HomeworkRepository = LollipopHomeworkRepository(),
         authenticationRepo:AuthenticationRepository = FirebaseAuthenticationRepository(),
         classRepo: ClassRepository = LollipopClassRepository()
    ) {
        self.classID = classID
        _viewModel = StateObject(wrappedValue: ClassHomeworkViewModel(
            homeworkUseCase: HomeworkUseCase(homeworkRepository: homeworkRepo),
            authenticationUseCase: AuthenticationUseCase(authenticationRepository: authenticationRepo),
            classUseCase: ClassUseCase(classRepository: classRepo),
            classID: classID
        ))
    }
    
    
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(HomeworkFilterOption.allCases, id: \.self) { option in
                        FilterButton(title: option.displayName, isSelected: viewModel.selectedFilterOption == option) {
                            viewModel.selectedFilterOption = option
                            viewModel.filterHomeworks()
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 30)
            .padding(10)
            .cornerRadius(10)
            
            ScrollView(showsIndicators: false) {
                if viewModel.isLoading || viewModel.isFiltering {
                    HomeworkListSkeleton()
                } else if !viewModel.filteredHomeworks.isEmpty {
                    LazyVStack {
                        ForEach(viewModel.filteredHomeworks) { homework in
                            HomeworkListItemView(
                                id: homework.id,
                                title: homework.title,
                                dueDate: homework.dueDate ?? Date(),
                                state: homework.submissionState,
                                onTestCompleted: {
                                    Task {
                                        await viewModel.loadHomeworks(classID: classID)
                                        viewModel.filterHomeworks()
                                    }
                                }
                            )
                        }
                    }
                    .padding(.top, 10)
                    
                } else {
                    ContentUnavailableView("該当する課題がありません。", systemImage: "book.closed")
                }
            }
            .refreshable {
                self.refreshTrigger = UUID()
            }

        }
        .navigationTitle(viewModel.classInfo?.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: refreshTrigger) {
            viewModel.isLoading = true
            
            await viewModel.loadClassInfos()
            await viewModel.loadHomeworks(classID: classID)
            viewModel.filterHomeworks()
            
            viewModel.isLoading = false
        }
        .toast(isPresenting: $viewModel.showError) {
            AlertToast(
                displayMode: .alert,
                type: .error(.red),
                title: "エラーが発生しました",
                subTitle: viewModel.errorMessage
            )
        }
    }
}

#Preview {
    NavigationStack {
        ClassHomeworkView(
            classID: "IOS プログラミング",
            homeworkRepo: TestHomeworkRepository(),
            authenticationRepo: TestAuthenticationRepository(),
            classRepo: TestClassRepository()
        )
    }
}
