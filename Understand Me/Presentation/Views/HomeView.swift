//
//  ContentView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/07.
//

import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: Int
    
    private let adaptiveColumn = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]
    
    
    @StateObject private var viewModel: HomeViewModel
    
    
    init(
        selectedTab: Binding<Int>,
        authenticationRepo: AuthenticationRepository = FirebaseAuthenticationRepository(),
        userDataRepo: UserDataRepository = LollipopUserDataRepository(),
        homeworkRepo: HomeworkRepository = LollipopHomeworkRepository(),
        classRepo: ClassRepository = LollipopClassRepository()
    ) {
        self._selectedTab = selectedTab
        
        self._viewModel = .init(
            wrappedValue: .init(
                authenticationUseCase: AuthenticationUseCase(authenticationRepository: authenticationRepo),
                userDataUseCase: UserDataUseCase(userDataRepository: userDataRepo),
                homeworkUseCase: HomeworkUseCase(homeworkRepository: homeworkRepo),
                classUseCase: ClassUseCase(classRepository: classRepo)
            )
        )
    }
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            VStack {
                
                header
                
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
                                VStack {
                                    ForEach(viewModel.homeworks) { homework in
                                        HomeworkListItemView(id: homework.id, title: homework.title, dueDate: homework.dueDate ?? Date(), state: homework.submissionState)
                                    }
                                }
                                .padding(.vertical)
                            }
                        } else {
                            ContentUnavailableView("提出期限が近い課題はありません。", systemImage: "book.closed")
                                .foregroundStyle(.secondary.opacity(0.7))
                        }
                    }
                    .frame(height: 300)
                }
                
                
                // MARK: - My Classes
                VStack(alignment: .leading, spacing: 12) {
                    Button {
                        selectedTab = 1
                    } label: {
                        HStack {
                            Text("マイクラス")
                                .font(.title2.bold())
                                .padding(.horizontal)
                            
                            Image(systemName: "arrow.forward")
                                .bold()
                                .foregroundStyle(.accent.opacity(0.3))
                            
                            Spacer()
                        }
                    }
                    .foregroundStyle(.primary)
                    
                    Group {
                        if !viewModel.classes.isEmpty {
                            LazyVGrid(columns: adaptiveColumn, spacing: 16) {
                                ForEach(viewModel.classes) { classItem in
                                    classCell(
                                        classID: classItem.id,
                                        className: classItem.name,
                                        teacherName: classItem.teacherId
                                    )
                                }
                            }
                        } else {
                            ContentUnavailableView("所属するクラスがありません。", systemImage: "book")
                                .foregroundStyle(.secondary.opacity(0.7))
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 40)
            }
            .foregroundStyle(.primary)
        }
        .task {
            await viewModel.loadUserData()
            await viewModel.loadHomeworks()
            await viewModel.loadClasses()
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
        .padding()
        .padding(.top, 20)
        .padding(.horizontal, 10)
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
            }
            .lineLimit(1)
            .padding()
            .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
            .background(.background)
            .cornerRadius(20)
            .shadow(color: .primary.opacity(0.2), radius: 8)
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
            classRepo: TestClassRepository()
        )
    }
}
