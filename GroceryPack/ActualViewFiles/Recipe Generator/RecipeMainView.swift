//
//  RecipeMainView.swift
//  GroceryPack
//
//  Created by Luciano Huapaya on 6/30/23.
//

import SwiftUI

struct ViewModel {
    let title: String
    let color: Color
    let view: AnyView
    
    init<T: View>(title: String, color: Color, view: T) {
        self.title = title
        self.color = color
        self.view = AnyView(view)
    }
} 

struct RecipeMainView: View {
    @State private var selectedViewIndex = 0
    private let viewModels: [ViewModel] = [
        ViewModel(title: "Recipes Generator", color: .blue, view: AnyView(RecipesView101())),
        ViewModel(title: "Saved Recipes", color: .green, view: AnyView(LikedRecipesViewV2())),
    ]
    
    var body: some View {
        VStack {
            HStack {
                Text("insert search here")
                Spacer()
                Text("add fetch recipes button")
            }
            
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(viewModels.indices), id: \.self) { index in
                        Button(action: {
                            selectedViewIndex = index
                        }) {
                            Text(viewModels[index].title)
                                .foregroundColor(selectedViewIndex == index ? .white : .black)
                                .padding()
                                .background(selectedViewIndex == index ? Color.black : Color.clear)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                        }
                    }
                }
            }
            .padding(.horizontal, 10)


            
            viewModels[selectedViewIndex].view

        }
        .background(BackgroundColor)
    }
}



struct RecipeMainView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeMainView()
    }
}


