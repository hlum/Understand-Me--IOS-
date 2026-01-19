//
//  ContentView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/07.
//

import SwiftUI
import AlertToast

struct HomeView: View {
    @Binding var selectedTab: Int

    @StateObject private var viewModel: HomeViewModel
    @State private var refreshTrigger = UUID()
    
    // MARK: Init
    init(
        selectedTab: Binding<Int>,
        authenticationRepo: AuthenticationRepository = FirebaseAuthenticationRepository(),
        userDataRepo: UserDataRepository = LollipopUserDataRepository(),
        homeworkRepo: HomeworkRepository = LollipopHomeworkRepository(),
        classRepo: ClassRepository = LollipopClassRepository(),
        fcmTokenRepo: FCMTokenRepository = LollipopFCMTokenRepository()
    ) {
        self._selectedTab = selectedTab
        
        self._viewModel = .init(
            wrappedValue: .init(
                authenticationUseCase: AuthenticationUseCase(authenticationRepository: authenticationRepo),
                userDataUseCase: UserDataUseCase(userDataRepository: userDataRepo, fcmTokenRepository: fcmTokenRepo),
                homeworkUseCase: HomeworkUseCase(homeworkRepository: homeworkRepo),
                classUseCase: ClassUseCase(classRepository: classRepo)
            )
        )
    }
    
    var body: some View {
        
        Group {
            if viewModel.isLoading {
                HomeViewSkeleton()
            } else {
                VStack {
                    
                    header
                    
              
                    
                    // MARK: - My Classes
                    VStack(alignment: .leading, spacing: 12) {
                        Button {
                            selectedTab = 1
                        } label: {
                            HStack {
                                Text("科目")
                                    .font(.title2.bold())
                                    .padding(.horizontal)
                                
                                Image(systemName: "arrow.forward")
                                    .bold()
                                    .foregroundStyle(.accent.opacity(0.3))
                                
                                Spacer()
                            }
                        }
                        .foregroundStyle(.primary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack {
                                ForEach(viewModel.classes) { classItem in
                                    classCell(
                                        classID: classItem.id,
                                        className: classItem.name,
                                        teacherName: classItem.teacherName
                                    )
                                }
                            }
                            .padding()
                        }
                    }
                    .frame(maxHeight: 150)

                    
                    Spacer()
                    
                    
                    // MARK: - Upcoming Homework
                    VStack(alignment: .leading, spacing: 12) {
                        Button {
                            selectedTab = 2
                        } label: {
                            HStack {
                                Text("提出期限が近い課題")
                                    .font(.title2.bold())
                                    .padding(.horizontal)
                                
                                Image(systemName: "arrow.forward")
                                    .bold()
                                    .foregroundStyle(.accent.opacity(0.3))
                                
                                Spacer()
                            }
                        }
                        
                        Group {
                            if !viewModel.homeworks.isEmpty {
                                
                                ScrollView(showsIndicators: false ) {
                                    LazyVStack {
                                        ForEach(viewModel.homeworks) { homework in
                                            HomeworkListItemView(
                                                id: homework.id,
                                                title: homework.title,
                                                dueDate: homework.dueDate ?? Date(),
                                                state: homework.submissionState,
                                                onTestCompleted: {
                                                    Task {
                                                        guard !Task.isCancelled else { return }
                                                        await viewModel.loadHomeworks()
                                                    }
                                                }
                                            )
                                        }
                                    }
                                    .padding(.vertical)
                                }
                            } else {
                                ContentUnavailableView("提出期限が近い課題はありません。", systemImage: "book.closed")
                                    .foregroundStyle(.secondary.opacity(0.7))
                            }
                        }
                    }
                }
                .foregroundStyle(.primary)
            }
        }
        .task(id: refreshTrigger) {
            guard !Task.isCancelled else { return }
            viewModel.isLoading = true

            guard !Task.isCancelled else { return }
            await viewModel.loadUserData()

            guard !Task.isCancelled else { return }
            await viewModel.loadHomeworks()

            guard !Task.isCancelled else { return }
            await viewModel.loadClasses()

            guard !Task.isCancelled else { return }
            viewModel.isLoading = false
        }
        .onAppear {
            // Refresh when navigating back
            refreshTrigger = UUID()
        }
        .refreshable {
            guard !Task.isCancelled else { return }
            await viewModel.loadUserData()

            guard !Task.isCancelled else { return }
            await viewModel.loadHomeworks()

            guard !Task.isCancelled else { return }
            await viewModel.loadClasses()
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
    
    // MARK: - Header
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("こんにちは")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text(viewModel.userData?.displayName ?? "ゲスト")
                    .font(.title3.bold())
            }
            
            Spacer()
            
            AsyncImage(url: URL(string: viewModel.userData?.photoURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(.profilePic)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            .frame(width: 55, height: 55)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.primary.opacity(0.3), lineWidth: 1))
        }
        .padding(.horizontal,10)
        .padding(.bottom, 20)
        .background(
            LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                .opacity(0.3)
        )
    }
    
    // MARK: - Class Card
    private func classCell(classID: String, className: String, teacherName: String) -> some View {
        NavigationLink(destination: {
            ClassHomeworkView(classID: classID)
        }, label: {
            VStack(alignment: .leading, spacing: 6) {
                Text(className)
                    .font(.headline)
                
                Text(teacherName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .lineLimit(1)
            .padding()
            .frame(minWidth: 200, maxWidth: 200, minHeight: 100, alignment: .leading)
            .background(.background)
            .cornerRadius(20)
            .shadow(color: .primary.opacity(0.2), radius: 2)
        })
    }
}


#Preview {
    NavigationStack {
        HomeView(
            selectedTab: .constant(1),
            authenticationRepo: TestAuthenticationRepository(),
            userDataRepo: TestUserRepository(),
            homeworkRepo: TestHomeworkRepository(),
            classRepo: TestClassRepository(),
            fcmTokenRepo: TestFCMTokenRepository()
        )
    }
}
