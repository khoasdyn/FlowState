//
//  CategoryEditView.swift
//  FlowState
//
//  Created by Dương Đinh Đông Khoa on 27/1/25.
//

import SwiftUI


struct CategoryEditView: View {
    @Environment(\.dismiss) var dismiss
    var viewModel: CategoryEditViewModel
    
    
    var body: some View {
        VStack(spacing: 32) {
            
            HStack {
                Text("Select a Category")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppConfig.ColorTheme.primaryText)
                
                Spacer()
                
                closeButton
            }
            listCategoryButton
            
        }
        .padding(.vertical, 48)
        .padding(.horizontal, 16)
    }
}
