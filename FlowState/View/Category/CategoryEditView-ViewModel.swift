//
//  CategoryEditViewModel.swift
//  FlowState
//
//  Created by Dương Đinh Đông Khoa on 27/1/25.
//

import SwiftUI

struct Category: Identifiable, Hashable {
    var id = UUID()
    var emoji: String
    var title: String
    var color: Color
    var isSelected: Bool = false
}

@Observable
class CategoryEditViewModel: ObservableObject {
    let initialCategories = [
        Category(emoji: "📚", title: "Studying", color: .blue, isSelected: true),
        Category(emoji: "🧠", title: "Deep Work", color: .purple),
        Category(emoji: "🎨", title: "Creative Work", color: .mint),
        Category(emoji: "🧑🏻‍💻", title: "Coding Session", color: .orange),
        Category(emoji: "🎯", title: "Working", color: .yellow)
    ]
    
    var categories: [Category] = []
    var selectedCategory: Category
    
    init() {
        self.categories = initialCategories
        self.selectedCategory = initialCategories.first!
    }
    
    func applyTemplate(_ category: Category) {
        // Update the isSelected property for correct UI update
        for index in categories.indices {
            categories[index].isSelected = (categories[index].id == category.id)
        }
        
        selectedCategory = category
    }
}
