//
//  ContentView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/07.
//

import SwiftUI
import Combine
import OSLog

class HomeViewModel: ObservableObject {
    private let userDataUseCase: UserDataUseCase
    private let authenticationUseCase: AuthenticationUseCase
    private let homeworkUseCase: HomeworkUseCase
    private let classUseCase: ClassUseCase
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UnderstandMe", category: "Presentation")
    
    @Published var userData: UserData? = nil
    @Published var homeworks: [HomeworkWithStatus] = []
    @Published var classes: [Class] = []
    
    
    init(
        authenticationUseCase: AuthenticationUseCase,
        userDataUseCase: UserDataUseCase,
        homeworkUseCase: HomeworkUseCase,
        classUseCase: ClassUseCase
    ) {
        self.userDataUseCase = userDataUseCase
        self.authenticationUseCase = authenticationUseCase
        self.homeworkUseCase = homeworkUseCase
        self.classUseCase = classUseCase
    }
    
    
    
    @MainActor
    func loadUserData() async {
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            logger.error("AuthDataResultを取得できません。")
            return
        }
        
        do {
            self.userData = try await userDataUseCase.fetchUserData(userID: authDataResult.id)
        } catch {
            // TODO: UserにAlertで知らせる
            logger.error("HomeViewModel.loadUserData(): UserDataの取得に失敗しました。")
        }
    }
    
    
    
    @MainActor
    func loadHomeworks() async {
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            logger.error("AuthDataResultを取得できません。")
            return
        }
        do {
            var homeworks = try await homeworkUseCase.fetchHomeworks(studentID: authDataResult.id)
            
            // 1. Filter (.completed じゃないものだけ)
            homeworks = homeworks.filter { $0.submissionState != .completed }
        

            // 2. Sort: dueDate(昇順),
            //    submissionStateの順に並び替え(.notAssigned, .failed, .questionGenerated, .generatingQuestions)
            homeworks.sort { lhs, rhs in
                // dueDateのUnwarp
                let lhsDate = lhs.dueDate ?? .distantFuture
                let rhsDate = rhs.dueDate ?? .distantFuture
                
                
                if lhsDate != rhsDate {
                    return lhsDate < rhsDate
                } else {
                    
                    // submissionStateの優先順位を定義
                    let submissionStatePriority: [HomeworkState: Int] = [
                        .notAssigned: 0,
                        .failed: 1,
                        .questionGenerated: 2,
                        .generatingQuestions: 3,
                    ]
                    
                    
                    return (submissionStatePriority[lhs.submissionState] ?? Int.max < submissionStatePriority[rhs.submissionState] ?? Int.max)
                }
            }
            
            
            self.homeworks = homeworks
            
        } catch {
            logger.error("HomeViewModel.loadHomeworks(): 宿題の取得に失敗しました。")
        }
    }
    
    
    
    @MainActor
    func loadClasses() async {
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            logger.error("AuthDataResultを取得できません。")
            return
        }
        do {
            self.classes = try await classUseCase.fetchClassList(studentID: authDataResult.id)
        } catch {
            logger.error("HomeViewModel.loadClasses(): クラスの取得に失敗しました。")
        }
        
    }
}

struct HomeView: View {
    @Binding var selectedTab: Int
    
    private let adaptiveColumn = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]
    
    
    @StateObject private var viewModel: HomeViewModel
    
    
    init(selectedTab: Binding<Int>) {
        self._selectedTab = selectedTab
        
        self._viewModel = .init(
            wrappedValue: .init(
                authenticationUseCase: AuthenticationUseCase(authenticationRepository: FirebaseAuthenticationRepository()),
                userDataUseCase: UserDataUseCase(
                    userDataRepository: LollipopUserDataRepository()
                ),
                homeworkUseCase: HomeworkUseCase(
                    homeworkRepository: LollipopHomeworkRepository()
                ), classUseCase: ClassUseCase(classRepository: LollipopClassRepository())
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
        HomeView(selectedTab: .constant(1))
    }
}
