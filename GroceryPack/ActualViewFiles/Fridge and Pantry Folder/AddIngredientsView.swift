//
//  AddIngredientsView.swift
//  GroceryPack
//
//  Created by Luciano Huapaya on 11/6/23.
//

import SwiftUI

struct Ingredient: Codable {
    let ingredientName_Original: String
    let ingredientId: Int
    let FridgeorPantry: String
    let ingredientName_Combined: String
    let Ingredient_Category: String
    let Avg_Expiration_Date: Double
}

struct AddIngredientsView: View {
    @State private var searchText = ""
    @ObservedObject var viewModel = AddIngredientViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading) {
                    SearchbarIngredientsView(searchText: $searchText, viewModel: viewModel)

                    Text("Usually people search for \nthe following products")
                        .font(
                            Font.custom("Jost", size: 18)
                                .weight(.medium)
                        )
                        .foregroundColor(Color(red: 0.06, green: 0.06, blue: 0.06))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 21)

                    Spacer() // Add spacer to push content to the top

                    IngredientListView101(searchText: searchText, viewModel: viewModel)
                }
            }
            .background(BackgroundColor)
        }
    }
}

struct IngredientListView101: View {
    var searchText: String
    @ObservedObject var viewModel: AddIngredientViewModel
    let boxSize: CGFloat = 110 // Fixed size for each box

    var filteredAllIngredients: [Ingredient] {
        if searchText.isEmpty {
            return viewModel.ingredients
        } else {
            return viewModel.ingredients.filter {
                $0.ingredientName_Original.lowercased().contains(searchText.lowercased())
            }
        }
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.fixed(boxSize), spacing: 10),
                GridItem(.fixed(boxSize), spacing: 10),
                GridItem(.fixed(boxSize), spacing: 10)
            ], spacing: 10) {
                ForEach(filteredAllIngredients, id: \.ingredientId) { ingredient in
                    ZStack {
                        Button(action: {
                            viewModel.addIngredientToUserPantry(for: ingredient)
                            viewModel.load_UserPantryDataList()
                        }) {
                            ZStack {
                                Color(red: 0.97, green: 1, blue: 0.77) // Background color
                                Text(ingredient.ingredientName_Original)
                                    .frame(width: boxSize, height: boxSize) // Fixed size for each box
                                    .cornerRadius(10)
                                    .foregroundColor(.black) // Set text color to white
                            }
                        }

                        // Checkmark view
                        if viewModel.isIngredientSelected(ingredient) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green) // Set checkmark color
                                .bold()
                                .padding(8)
                                .position(x: boxSize - 15, y: 15) // Adjust position to top-right
                        }
                    }
                }
            }
            .background(BackgroundColor)
            .padding()
        }
    }
}



struct SearchbarIngredientsView101: View {
    @Binding var searchText: String
    @ObservedObject var viewModel: AddIngredientViewModel
    
    var body: some View {
        HStack {
            ZStack(alignment: .trailing) {
                TextField("Search Ingredients", text: $searchText)
                    .padding(.horizontal, 23)
                    .padding(.vertical, 13)
                    .background(Color.white)
                    .cornerRadius(9)
                    .overlay(
                        RoundedRectangle(cornerRadius: 9)
                            .inset(by: 0.5)
                            .stroke(Color(red: 0.72, green: 0.77, blue: 0.44), lineWidth: 1)
                    )
                
                HStack {
                    Spacer()
                    Image(systemName: "magnifyingglass")
                        .padding(.horizontal, 23)
                        .padding(.vertical, 13)
                        .frame(width: 50, height: 50, alignment: .center)
                        .cornerRadius(9)
                    
                }
                
            }
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 10)
            }
        }
        .padding(.leading, 21)
        .padding(.vertical, 8)
        .padding(.trailing, 8)
        .foregroundColor(.black)
        .frame(width: 350, height: 50, alignment: .leading)
        .cornerRadius(9)

    }
}


#Preview {
    AddIngredientsView()
}
