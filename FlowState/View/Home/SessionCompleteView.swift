//
//  SessionCompleteView.swift
//  FlowState
//
//  Created by Dương Đinh Đông Khoa on 14/2/26.
//

import SwiftUI

struct SessionCompleteView: View {
    @Environment(ViewModel.self) var viewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(.lantern)
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
            
            VStack(spacing: 8) {
                Text("Session complete!")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(AppConfig.ColorTheme.primaryText)
                
                Text("Great focus. You earned this break.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppConfig.ColorTheme.secondaryText)
            }
            
            Spacer()
            
            Button(action: {
                viewModel.resetSession()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "cup.and.heat.waves.fill")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Take a Break")
                        .font(.system(size: 14, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .foregroundStyle(.grayWarm700)
                .background(.grayWarm200)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
        .interactiveDismissDisabled()
    }
}
