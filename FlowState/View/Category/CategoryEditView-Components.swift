//
//  Cat.swift
//  FlowState
//
//  Created by Dương Đinh Đông Khoa on 29/6/25.
//
import SwiftUI

extension CategoryEditView {
    var listCategoryButton: some View {
        
        ScrollView {
            VStack(spacing: 12) {
                ForEach(viewModel.categories) { category in
                    Button(action: {
                        viewModel.applyTemplate(category)
                        dismiss()
                    }) {
                        HStack {
                            Text(category.emoji)
                                .font(.system(size: 28))
                            Text(category.title)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(category.color)
                            
                            Spacer()
                            
                            if category.isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(category.color)
                            }
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(category.color.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        //                .overlay(
                        //                    RoundedRectangle(cornerRadius: 16)
                        //                        .stroke(.gray200, lineWidth: 2)
                        //                )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .semibold))
                .fixedSize(horizontal: true, vertical: true)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .foregroundStyle(.primary)
                .background(.grayWarm200)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}
