//
//  SkeletonViews.swift
//  Understand Me
//
//  Created by cmStudent on 2026/01/10.
//

import SwiftUI

// MARK: - Homework Item Skeleton
struct HomeworkItemSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("プレースホルダータイトル")
                .font(.headline)
            
            HStack {
                Image(systemName: "calendar")
                Text("2024/01/01まで")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
            
            Text("未提出")
                .font(.caption.bold())
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(Color.gray.opacity(0.15))
                .foregroundColor(.gray)
                .cornerRadius(12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.background)
                .shadow(color: .primary.opacity(0.7), radius: 1)
        )
        .padding(.horizontal)
        .redacted(reason: .placeholder)
    }
}

// MARK: - Class Item Skeleton
struct ClassItemSkeleton: View {
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 60, height: 60)
                .foregroundStyle(.gray)
            
            VStack(alignment: .leading) {
                Text("科目名プレースホルダー")
                    .font(.system(size: 20, weight: .bold))
                    .padding(.bottom, 4)
                    .lineLimit(1)
                
                Text("先生の名前")
                    .foregroundStyle(.secondary)
            }
            .padding(.leading, 20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.background)
        .cornerRadius(20)
        .shadow(color: .primary.opacity(0.2), radius: 2)
        .padding(.horizontal)
        .redacted(reason: .placeholder)
    }
}

// MARK: - Class Card Skeleton (for HomeView horizontal scroll)
struct ClassCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("科目名")
                .font(.headline)
            
            Text("先生の名前")
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
        .redacted(reason: .placeholder)
    }
}

// MARK: - Home Header Skeleton
struct HomeHeaderSkeleton: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("こんにちは")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text("ユーザー名")
                    .font(.title3.bold())
            }
            
            Spacer()
            
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 55, height: 55)
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 20)
        .background(
            LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                .opacity(0.3)
        )
        .redacted(reason: .placeholder)
    }
}

// MARK: - Skeleton List Views
struct HomeworkListSkeleton: View {
    var count: Int = 5
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(0..<count, id: \.self) { _ in
                    HomeworkItemSkeleton()
                }
            }
            .padding()
        }
    }
}

struct ClassListSkeleton: View {
    var count: Int = 5
    
    var body: some View {
        ScrollView {
            ForEach(0..<count, id: \.self) { _ in
                ClassItemSkeleton()
            }
        }
    }
}

// MARK: - Home View Skeleton
struct HomeViewSkeleton: View {
    var body: some View {
        VStack {
            HomeHeaderSkeleton()
            
            // My Classes Section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("科目")
                        .font(.title2.bold())
                        .padding(.horizontal)
                    
                    Image(systemName: "arrow.forward")
                        .bold()
                        .foregroundStyle(.accent.opacity(0.3))
                    
                    Spacer()
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(0..<3, id: \.self) { _ in
                            ClassCardSkeleton()
                        }
                    }
                    .padding()
                }
            }
            .frame(maxHeight: 150)
            
            Spacer()
            
            // Upcoming Homework Section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("提出期限が近い課題")
                        .font(.title2.bold())
                        .padding(.horizontal)
                    
                    Image(systemName: "arrow.forward")
                        .bold()
                        .foregroundStyle(.accent.opacity(0.3))
                    
                    Spacer()
                }
                
                ScrollView(showsIndicators: false) {
                    LazyVStack {
                        ForEach(0..<3, id: \.self) { _ in
                            HomeworkItemSkeleton()
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .foregroundStyle(.primary)
    }
}

#Preview("Homework Skeleton") {
    HomeworkItemSkeleton()
}

#Preview("Class Skeleton") {
    ClassItemSkeleton()
}

#Preview("Home Skeleton") {
    HomeViewSkeleton()
}

// MARK: - Homework Detail Skeleton
struct HomeworkDetailSkeleton: View {
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("課題のタイトルプレースホルダー")
                        .font(.title.bold())
                        .padding(.bottom, 7)
                    
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "graduationcap")
                    Text("科目名")
                }
                
                HStack {
                    Image(systemName: "calendar")
                    Text("締切：2024/01/01")
                }
                .padding(.bottom, 12)
                
                Text("課題の説明がここに表示されます。この課題では様々なことを学びます。")
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .cornerRadius(20)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 16) {
                Text("提出リンク (GitHub または Google Drive)")
                    .font(.headline)
                
                RoundedRectangle(cornerRadius: 200)
                    .fill(Color(.secondarySystemBackground))
                    .frame(height: 55)
                
                RoundedRectangle(cornerRadius: 70)
                    .fill(Color.gray.opacity(0.4))
                    .frame(height: 55)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .redacted(reason: .placeholder)
    }
}

// MARK: - Question Item Skeleton
struct QuestionItemSkeleton: View {
    var mode: QuestionViewMode = .answering
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("残り時間: 20秒")
                .foregroundStyle(.red)
            
            Text("ここに質問のテキストが表示されます。質問は複数行にわたる場合があります。")
                .font(.title3.bold())
                .foregroundStyle(.primary)
            
            VStack(spacing: 12) {
                ForEach(0..<4, id: \.self) { _ in
                    HStack {
                        Text("選択肢のテキストがここに表示されます")
                            .font(.body)
                        
                        Spacer()
                        
                        Image(systemName: "circle.fill")
                            .opacity(0.3)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                    )
                }
            }
            
            if mode == .answering {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.blue)
                    .frame(height: 55)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
        )
        .padding()
        .redacted(reason: .placeholder)
    }
}

// MARK: - Questions View Skeleton
struct QuestionsViewSkeleton: View {
    var body: some View {
        VStack {
            QuestionItemSkeleton()
            Spacer()
        }
    }
}

// MARK: - Profile View Skeleton
struct ProfileViewSkeleton: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                // Profile Image
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 150, height: 150)
                
                Text("ユーザー名")
                    .font(.title.bold())
                
                Text("user@example.com")
                    .foregroundStyle(.gray)
                
                // Graph Section
                Text("学業進捗")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                
                RoundedRectangle(cornerRadius: 20)
                    .stroke(lineWidth: 2)
                    .foregroundStyle(.gray.opacity(0.2))
                    .frame(height: 260)
                    .overlay {
                        VStack {
                            HStack(alignment: .bottom, spacing: 20) {
                                ForEach(0..<6, id: \.self) { i in
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 30, height: CGFloat(40 + i * 20))
                                }
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
                
                // Status Info
                HStack {
                    VStack(spacing: 10) {
                        Image(systemName: "checkmark.circle")
                            .font(.title2)
                            .foregroundStyle(.secAccent)
                        
                        Text("10")
                            .font(.headline)
                        
                        Text("完了した課題")
                            .fontWeight(.thin)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    
                    RoundedRectangle(cornerRadius: 0)
                        .frame(width: 1)
                        .padding(.vertical)
                        .foregroundStyle(.gray.opacity(0.5))
                    
                    VStack(spacing: 10) {
                        Image(systemName: "star.hexagon")
                            .font(.title2)
                            .foregroundStyle(.accent)
                        
                        Text("85点")
                            .font(.headline)
                        
                        Text("平均スコア")
                            .fontWeight(.thin)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(lineWidth: 2)
                        .foregroundStyle(.gray.opacity(0.2))
                )
                
                // Logout Button
                RoundedRectangle(cornerRadius: 30)
                    .stroke(lineWidth: 2)
                    .foregroundStyle(.gray.opacity(0.2))
                    .frame(height: 55)
                    .padding(.top, 50)
            }
            .padding(.horizontal)
        }
        .redacted(reason: .placeholder)
    }
}

#Preview("Homework Detail Skeleton") {
    HomeworkDetailSkeleton()
}

#Preview("Question Skeleton") {
    QuestionItemSkeleton()
}

#Preview("Profile Skeleton") {
    ProfileViewSkeleton()
}
