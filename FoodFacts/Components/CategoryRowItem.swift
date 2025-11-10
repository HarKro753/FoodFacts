//
//  CategoryRowItem.swift
//  FoodFacts
//
//  Created by Harro Krog on 10.11.25.
//

import SwiftUI


struct CategoryRowItem: View {
    let category: Category

    var body: some View {
        HStack {
            Image(systemName: category.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(category.color)
            Text(category.name)
        }
    }
}
