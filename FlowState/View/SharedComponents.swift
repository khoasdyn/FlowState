//
//  SharedComponents.swift
//  FlowState
//
//  Created by Dương Đinh Đông Khoa on 14/2/26.
//

import SwiftUI

// MARK: - Icon action button

struct IconActionButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .fixedSize(horizontal: true, vertical: true)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .foregroundStyle(.grayWarm950)
                .background(.grayWarm200)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Delete button

struct DeleteButton: View {
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "multiply.circle.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.grayWarm950)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.3 : 1)
    }
}

// MARK: - Page background modifier

struct PageBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.top, 36)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.white)
    }
}

extension View {
    func pageBackground() -> some View {
        modifier(PageBackground())
    }
}

// MARK: - List item row modifier

struct ListItemRow: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(.grayWarm200)
            .clipShape(RoundedRectangle(cornerRadius: .infinity))
    }
}

extension View {
    func listItemRow() -> some View {
        modifier(ListItemRow())
    }
}

// MARK: - Pill chip modifier

struct PillChip: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
    }
}

extension View {
    func pillChip() -> some View {
        modifier(PillChip())
            .clipShape(RoundedRectangle(cornerRadius: .infinity))
    }
}
