//
//  SessionCompleteView.swift
//  FlowState
//
//  Created by Dương Đinh Đông Khoa on 14/2/26.
//

import SwiftUI

struct SessionCompleteView: View {
    @Environment(ViewModel.self) var viewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            IconActionButton(icon: "xmark") { dismiss() }
                .frame(maxWidth: .infinity, alignment: .leading)
            
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
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
    }
}
