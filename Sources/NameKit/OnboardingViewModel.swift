//
//  OnboardingViewModel.swift
//  NameKit
//
//  Created by Ye Park on 5/6/26.
//


import SwiftUI
import Observation

// MARK: - ViewModel
@Observable
@MainActor
public final class OnboardingViewModel {
    var userName: String = ""
    var isNameExtracted: Bool = false
    var isFocused: Bool = false
    
    private let nameExtractor: any NameExtracting
    
    public init(nameExtractor: any NameExtracting) {
        self.nameExtractor = nameExtractor
    }
    
    func onAppear() {
        if let extracted = nameExtractor.extract() {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                self.userName = extracted
                self.isNameExtracted = true
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        } else {
            self.isFocused = true
        }
    }
}

// MARK: - View
public struct ZeroFrictionOnboardingView: View {
    // 💡 Swift 6: @StateObject가 아닌 @Bindable로 뷰모델의 상태를 양방향 바인딩합니다.
    @Bindable var viewModel: OnboardingViewModel
    @FocusState private var isTextFieldFocused: Bool
    
    public init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer().frame(height: 60)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("볼래에 오신 것을 환영해요.")
                    .font(.title2)
                    .foregroundStyle(.secondary) // Swift 6 권장 (foregroundColor 대체)
                
                if viewModel.isNameExtracted {
                    Text("기기 정보를 바탕으로\n**'\(viewModel.userName)'** 님으로 설정해 보았어요.")
                        .font(.title.bold())
                        .transition(.opacity.combined(with: .slide))
                } else {
                    Text("투표에 사용할\n**이름을 알려주세요.**")
                        .font(.title.bold())
                }
            }
            
            HStack {
                TextField("이름 입력", text: $viewModel.userName)
                    .focused($isTextFieldFocused)
                    .font(.title3.weight(.semibold))
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(uiColor: .secondarySystemBackground))
                    )
                
                if viewModel.isNameExtracted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.title2)
                        .transition(.scale)
                }
            }
            
            Spacer()
            
            Button(action: {
                // Passkey Action
            }) {
                Text("이 이름으로 시작하기")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(viewModel.userName.isEmpty ? Color.gray : Color.primary)
                    )
            }
            .disabled(viewModel.userName.isEmpty)
        }
        .padding(24)
        // 💡 Observation 프레임워크에서는 상태 변화에 따른 사이드 이펙트 처리가 더 간결해집니다.
        .onChange(of: viewModel.isFocused) { _, newValue in
            isTextFieldFocused = newValue
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}

// MARK: - Previews
#Preview("Success Case") {
    ZeroFrictionOnboardingView(
        viewModel: OnboardingViewModel(
            nameExtractor: MockNameExtractor(stubbedName: "예강")
        )
    )
}

#Preview("Fallback Case") {
    ZeroFrictionOnboardingView(
        viewModel: OnboardingViewModel(
            nameExtractor: MockNameExtractor(stubbedName: nil)
        )
    )
}
