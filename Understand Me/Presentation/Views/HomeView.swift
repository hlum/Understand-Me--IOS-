//
//  ContentView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/07.
//

import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    private let userDataUseCase: UserDataUseCase
    private let authenticationUseCase: AuthenticationUseCase
    private let homeworkUseCase: HomeworkUseCase
    
    @Published var userData: UserData? = nil
    @Published var homeworks: [HomeworkWithStatus] = []
    
    
    init(
        authenticationUseCase: AuthenticationUseCase,
        userDataUseCase: UserDataUseCase,
        homeworkUseCase: HomeworkUseCase
    ) {
        self.userDataUseCase = userDataUseCase
        self.authenticationUseCase = authenticationUseCase
        self.homeworkUseCase = homeworkUseCase
    }
    
    
    
    @MainActor
    func loadUserData() async {
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            print("AuthDataResultを取得できません。")
            return
        }
        
        do {
            self.userData = try await userDataUseCase.fetchUserData(userID: authDataResult.id)
        } catch {
            // TODO: UserにAlertで知らせる
            print("HomeViewModel.loadUserData(): UserDataの取得に失敗しました。")
        }
    }
    
    
    
    func loadHomeworks() async {
        guard let authDataResult = await authenticationUseCase.fetchCurrentUser() else {
            print("AuthDataResultを取得できません。")
            return
        }
        do {
            self.homeworks = try await homeworkUseCase.fetchHomeworks(studentID: authDataResult.id)
            self.homeworks.sort { $0.dueDate ?? Date() < $1.dueDate ?? Date()}
        } catch {
            print("HomeViewModel.loadHomeworks(): 宿題の取得に失敗しました。")
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
                    )
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
                        }
                    }
                    
                    ScrollView(showsIndicators: false ) {
                        VStack {
                            ForEach(viewModel.homeworks) { homework in
                                HomeworkListItemView(id: homework.id, title: homework.title, dueDate: homework.dueDate ?? Date(), state: homework.submissionState)
                            }
                        }
                        .padding(.vertical)
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
                        }
                    }
                    .foregroundStyle(.primary)
                    
                    LazyVGrid(columns: adaptiveColumn, spacing: 16) {
                        classCell(
                            className: "iOS プログラミング",
                            teacherName: "山田太郎先生",
                            homeworksCount: 3
                        )
                        classCell(
                            className: "Android プログラミング",
                            teacherName: "山田太郎先生",
                            homeworksCount: 10
                        )
                        classCell(
                            className: "Web プログラミング",
                            teacherName: "山田太郎先生"
                        )
                        classCell(
                            className: "コンテンツ制作",
                            teacherName: "山田太郎先生",
                            homeworksCount: 100
                        )
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
        }
    }
    
    // MARK: - Header
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("こんにちは")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text(viewModel.userData?.studentCode ?? "ゲスト")
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
    private func classCell(className: String, teacherName: String, homeworksCount: Int = 0) -> some View {
        NavigationLink(destination: {
            ClassHomeworkView(classID: className)
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
            .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
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
