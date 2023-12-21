//
//  SwiftUIView.swift
//  GroceryPack
//
//  Created by Luciano Huapaya on 3/6/23.
//

//Code & Tutorial for Firestore Database
/// 1. getting data
/// 2. adding data
/// 3. deleting data
///
/// Cloud Firestore Get Data (and other operations) with SwiftUI by CodeWithChris
/// https://www.youtube.com/watch?v=xkxGoNfpLXs

import SwiftUI
import Firebase
import SwiftSoup
import Foundation


import SwiftUI

struct Recipes1: Codable, Identifiable {
    var id: Int {recipeID}
    var recipeID: Int
    var recipeName: String
    var website: String
    var averageCookTime: Int
    var servingSize: Int
    var caloriesPerServing: Int
    var totalFat: Double
    var sodium: Double
    var protein: Double
    var regionOfOrigin: String
    var category: String
    
    private enum CodingKeys: String, CodingKey {
        case recipeID = "recipe_id"
        case recipeName = "recipe_name"
        case website
        case averageCookTime = "average_cook_time"
        case servingSize = "serving_size"
        case caloriesPerServing = "calories_per_serving"
        case totalFat = "total_fat"
        case sodium
        case protein
        case regionOfOrigin = "region_of_origin"
        case category
    }
}

struct RecipeIngredient1: Codable, Identifiable {
    var id: Int {recipeID}
    
    var recipeID: Int
    var itemID: Int
    var ingredient: String
    var quantity: Double

    enum CodingKeys: String, CodingKey {
        case recipeID = "recipe_id"
        case itemID = "item_id"
        case ingredient = "ingredients"
        case quantity
    }
}



struct ContentView: View {
    let recipes = [
        Recipes1(recipeID: 1, recipeName: "Spaghetti Bolognese", website: "www.foodnetwork.com", averageCookTime: 45, servingSize: 4, caloriesPerServing: 400, totalFat: 10.0, sodium: 500.0, protein: 25.0, regionOfOrigin: "Italy", category: "Pasta"),
        Recipes1(recipeID: 2, recipeName: "Chicken Parmesan", website: "www.allrecipes.com", averageCookTime: 60, servingSize: 4, caloriesPerServing: 550, totalFat: 20.0, sodium: 900.0, protein: 35.0, regionOfOrigin: "Italy", category: "Chicken"),
        Recipes1(recipeID: 3, recipeName: "Beef Stir-Fry", website: "www.food.com", averageCookTime: 30, servingSize: 3, caloriesPerServing: 350, totalFat: 15.0, sodium: 600.0, protein: 30.0, regionOfOrigin: "China", category: "Beef")
    ]
    
    let ingredients = [
        RecipeIngredient1(recipeID: 1, itemID: 1, ingredient: "spaghetti", quantity: 1.0),
        RecipeIngredient1(recipeID: 1, itemID: 2, ingredient: "ground beef", quantity: 1.0),
        RecipeIngredient1(recipeID: 1, itemID: 3, ingredient: "tomato sauce", quantity: 1.5),
        RecipeIngredient1(recipeID: 1, itemID: 4, ingredient: "onion", quantity: 1.0),
        RecipeIngredient1(recipeID: 2, itemID: 5, ingredient: "chicken breast", quantity: 4.0),
        RecipeIngredient1(recipeID: 2, itemID: 6, ingredient: "bread crumbs", quantity: 0.5),
        RecipeIngredient1(recipeID: 2, itemID: 7, ingredient: "marinara sauce", quantity: 2.0),
        RecipeIngredient1(recipeID: 2, itemID: 8, ingredient: "mozzarella cheese", quantity: 1.0),
        RecipeIngredient1(recipeID: 3, itemID: 9, ingredient: "beef sirloin", quantity: 1.0),
        RecipeIngredient1(recipeID: 3, itemID: 10, ingredient: "soy sauce", quantity: 0.5),
        RecipeIngredient1(recipeID: 3, itemID: 11, ingredient: "garlic", quantity: 3.0),
        RecipeIngredient1(recipeID: 3, itemID: 12, ingredient: "ginger", quantity: 1.0),
    ]
    
    // Define the URL of the webpage you want to scrape
    let url = "https://www.allrecipes.com/recipe/268091/easy-korean-ground-beef-bowl/"
    
    
    @State var preparationSteps = [String]()
    @State var steps = [String]()
    
    var body: some View {
        VStack {
            NavigationView {
                List(recipes) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe, ingredients: ingredients.filter { $0.recipeID == recipe.recipeID })) {
                        VStack(alignment: .leading) {
                            Text(recipe.recipeName)
                                .font(.headline)
                            Text("\(recipe.servingSize) servings, \(recipe.caloriesPerServing) calories per serving")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            List(ingredients.filter { $0.recipeID == recipe.recipeID }) { ingredient in
                                HStack {
                                    Text(ingredient.ingredient)
                                        .font(.subheadline)
                                    Spacer()
                                    if Bool.random() { // generates a random check mark
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationBarTitle(Text("Recipes"))
            }

            

            


        }

        

    }
    

}

struct RecipeDetailView: View {
    let recipe: Recipes1
    let ingredients: [RecipeIngredient1]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(recipe.recipeName)
                .font(.largeTitle)
                .padding(.bottom)
            
            Text("Ingredients")
                .font(.headline)
            
            List() {
                ForEach(groupedIngredients, id: \.self) { group in
                    HStack {
                        Text("\(group.quantity) ")
                        Text(group.ingredient)
                        Spacer()
                    }
                }

            }
            
            Text("Instructions")
                .font(.headline)
            
            Text("Insert instructions here...")
                .font(.body)
        }
        .padding()
    }
    
    private var groupedIngredients: [GroupedIngredient] {
        var groups: [GroupedIngredient] = []
        var ingredientDict: [String: Double] = [:]
        
        for ingredient in ingredients {
            if let quantity = ingredientDict[ingredient.ingredient] {
                ingredientDict[ingredient.ingredient] = quantity + ingredient.quantity
            } else {
                ingredientDict[ingredient.ingredient] = ingredient.quantity
            }
        }
        
        for (ingredient, quantity) in ingredientDict {
            groups.append(GroupedIngredient(ingredient: ingredient, quantity: quantity))
        }
        
        return groups
    }
    
    private struct GroupedIngredient: Hashable {
        let ingredient: String
        let quantity: Double
    }
}



struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

