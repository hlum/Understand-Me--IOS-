//
//  ProfileView.swift
//  Understand Me
//
//  Created by cmStudent on 2025/10/09.
//

import SwiftUI
import Charts
import AlertToast


struct ProfileView: View {
    // ユーザがドラッグて選択した日付
    @State private var rawSelectedDate: Date? = nil
    
    @State private var showAccDeleteAlert: Bool = false
    
    // 選択された月の平均結果
    var selectedAverageResult: AverageResultPerMonth? {
        // ドラッグで選択されたに付けがなければ、resultも空
        guard let rawSelectedDate else { return nil }
        
        let calendar = Calendar.current
        
        // 平均結果配列から、選択された月と同じ月の日付を持つデータを返す
        return viewModel.averageResultsPerMonth.first { calendar.isDate($0.month, equalTo: rawSelectedDate, toGranularity: .month)}
    }
    
    var onSignOut: () -> ()
    
    @StateObject private var viewModel: ProfileViewModel
    
    
    init(
        authenticationUseCase: AuthenticationUseCase = AuthenticationUseCase(authenticationRepository:FirebaseAuthenticationRepository()),
        userDataUseCase: UserDataUseCase = UserDataUseCase(userDataRepository: LollipopUserDataRepository(), fcmTokenRepository: LollipopFCMTokenRepository()),
        resultUseCase: ResultUseCase = ResultUseCase(resultRepo: LollipopResultRepository()),
        onSignOut: @escaping () -> ()
    ) {
        self.onSignOut = onSignOut
        self._viewModel = StateObject(
            wrappedValue: ProfileViewModel(
                authenticationUseCase: authenticationUseCase,
                userDataUseCase: userDataUseCase,
                resultUseCase: resultUseCase
            )
        )
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProfileViewSkeleton()
            } else {
                ScrollView(showsIndicators: false) {
                    VStack {
                        profileBasicInfo
                        
                        graphInfo
                        
                        statusInfo
                        
                        logoutBtn
                            .padding(.bottom, 50)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .alert(isPresented: $showAccDeleteAlert) {
            Alert(
                title: Text("アカウントを削除しますか？"),
                message: Text("この操作は取り消せません。すべてのデータが完全に削除されます。"),
                primaryButton: .destructive(Text("削除")) {
                    Task {
                        await viewModel.deleteAcc()
                        onSignOut()
                    }
                },
                secondaryButton: .cancel(Text("キャンセル"))
            )
        }
        .navigationTitle("プロフィール")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Menu {
                Button("アカウントを削除", role: .destructive){
                    showAccDeleteAlert.toggle()
                }
            } label: {
                Image(systemName: "gear")
            }
        }
        .task {
            await viewModel.loadUserData()
            await viewModel.loadResults()
            viewModel.loadAverageResultsPerMonth()
            viewModel.loadAverageScoreOfAllResults()
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
    
    
    @ViewBuilder
    private var profileBasicInfo: some View {
        AsyncImage(url: URL(string: viewModel.userData?.photoURL ?? "")) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 150)
                .cornerRadius(300)
        } placeholder: {
            Image(.profilePic)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 150)
                .cornerRadius(300)
        }
        
        
        Text(viewModel.userData?.displayName ?? "")
            .font(.title.bold())
        
        Text(verbatim: viewModel.userData?.email ?? "")
            .foregroundStyle(.gray)
    }
    
    
    @ViewBuilder
    private var graphInfo: some View {
        
        Text("学業進捗")
            .font(.title2.bold())
            .frame(maxWidth: .infinity, alignment: .leading)
        
        
        
        
        Chart {
            // 選択された月の平均スコアを示すルールマーク
            if let selectedAverageResult {
                RuleMark(x: .value("選択された月", selectedAverageResult.month, unit: .month))
                    .foregroundStyle(.secAccent)
                    .annotation(position: .top, overflowResolution:.init(x: .fit(to: .chart), y: .disabled)){
                        
                        VStack {
                            Text("\(Int(selectedAverageResult.averageScore))点")
                                .font(.system(size: 20).bold())
                            //                            Text(selectedAverageResult.month, format: .dateTime.month(.twoDigits).year())
                            //                                .font(.system(size: 14))
                        }
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(.accent)
                        .cornerRadius(10)
                    }
            }
            
            
            ForEach(viewModel.averageResultsPerMonth) { dataPoint in
                // ユーザがグラフをドラッグして選択しているかどうか
                let userDraggingGraph = selectedAverageResult != nil
                let isSelectedBar = selectedAverageResult?.month == dataPoint.month
                
                
                BarMark(
                    x: .value("月", dataPoint.month, unit: .month),
                    y: .value("スコア", dataPoint.averageScore)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [.secAccent, .accent, .accent],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .cornerRadius(5)
                // 選択されているバーのみ不透明にする
                .opacity(!userDraggingGraph || isSelectedBar ? 1 : 0.3)
            }
        }
        .chartYScale(domain: 0...120)
        .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
        //                    .chartScrollableAxes(.horizontal)
        .chartXScale(range: .plotDimension(padding: 10))
        //        .chartXVisibleDomain(length: 12 * 30 * 24 * 60 * 60)
        //        .chartXAxis {
        //            AxisMarks(values: averageResultsPerMonth.map { $0.month }) { date in
        //                AxisValueLabel(format: .dateTime.month(.defaultDigits))
        //            }
        //        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { value in  // Changed to use .stride
                AxisValueLabel(format: .dateTime.month(.defaultDigits), centered: true)
            }
        }
        
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [5]))
                AxisValueLabel()
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(lineWidth: 2)
                .foregroundStyle(.gray.opacity(0.2))
        )
        .frame(height: 260)
        .overlay {
            if viewModel.averageResultsPerMonth.isEmpty {
                ContentUnavailableView("平均スコアのデータはありません。", systemImage: "info.circle")
                    .foregroundStyle(.secondary.opacity(0.7))
            }
        }
        .overlay(alignment: .top) {
            HStack {
                Button {
                    Task {
                        withAnimation(.bouncy) {
                            viewModel.currentYearForGraph -= 1
                        }
                        await viewModel.loadAverageResultsPerMonth()
                        
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .padding(5)
                        .foregroundStyle(.primary)
                        .frame(width: 60, height: 40)
                }
                
                Spacer()
                Text("\(viewModel.currentYearForGraph)年")
                    .font(.headline)
                    .padding(.top, 5)
                    .foregroundStyle(.foreground)
                
                Spacer()
                
                Button {
                    Task {
                        withAnimation(.bouncy) {
                            viewModel.currentYearForGraph += 1
                        }
                            await viewModel.loadAverageResultsPerMonth()
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .padding(5)
                        .foregroundStyle(.primary)
                        .frame(width: 60, height: 40)
                }
            }
        }
  
        
        
        HStack {
            Circle()
                .fill(.accent)
                .frame(width: 10, height: 10)
            Text("平均スコア")
                .font(.caption)
        }
        .padding(.bottom, 10)
    }
    
    
    @ViewBuilder
    private var statusInfo: some View {
        HStack {
            
            NavigationLink {
                DetailAverageScoreView()
            } label: {
                HStack {
                    VStack(spacing: 10) {
                        Image(systemName: "checkmark.circle")
                            .font(.title2)
                            .foregroundStyle(.secAccent)
                        
                        Text("\(viewModel.results.count)")
                            .font(.headline)
                        
                        Text("完了した課題")
                            .fontWeight(.thin)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    
                    RoundedRectangle(cornerRadius: 0)
                        .frame(width: 1)
                        .padding(.vertical)
                        .foregroundStyle(.gray.opacity(0.5))
                    
                    VStack(spacing: 10) {
                        Image(systemName: "star.hexagon")
                            .font(.title2)
                            .foregroundStyle(.accent)
                        
                        Text("\(viewModel.averageScoreOfAllResults)点")
                            .font(.headline)
                        
                        Text("平均スコア")
                            .fontWeight(.thin)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    
                    
                }
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(lineWidth: 2)
                        .foregroundStyle(.gray.opacity(0.2))
                )
                
                
                

            }
            .foregroundStyle(.foreground)

        }
    }
    
    
    @ViewBuilder
    private var deleteAccBtn: some View {
        Button {
            Task {
                await viewModel.signOut()
                onSignOut()
            }
        } label: {
                Text("アカウント削除する")
                    .foregroundStyle(.red)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 55)
    }
    
    
    @ViewBuilder
    private var logoutBtn: some View {
        Button {
            Task {
                await viewModel.signOut()
                onSignOut()
            }
        } label: {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                
                Text("ログアウト")
                
            }
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(lineWidth: 2)
                    .foregroundStyle(.gray.opacity(0.2))
            )
        }
        .padding(.top, 50)
    }
}

#Preview {
    NavigationStack {
        ProfileView(
            
            authenticationUseCase:
                AuthenticationUseCase(authenticationRepository: TestAuthenticationRepository()),
            
            userDataUseCase:
                UserDataUseCase(
                userDataRepository: TestUserRepository(),
                fcmTokenRepository: TestFCMTokenRepository()
            ),
            
            resultUseCase:
                ResultUseCase(resultRepo: TestResultRepository())
            ,
            
            onSignOut: {
            }
        )
    }
}
