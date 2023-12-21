//
//  RecipeModel.swift
//  GroceryPack
//
//  Created by Luciano Huapaya on 4/8/23.
//


import SwiftUI
/*

struct Recipes: Codable, Identifiable {
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

struct RecipeIngredient: Codable {
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


class RecipeList: ObservableObject {
    @Published var recipes: [Recipes] = []
    @Published var recipeIngredients: [RecipeIngredient] = []
    @Published var selectedIngredients: [String] = []
    
    init() {
        loadRecipes()
        loadRecipeIngredients()
    }
    
    func loadRecipes() {
        if let url = Bundle.main.url(forResource: "RecipesList_JSON", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                recipes = try decoder.decode([Recipes].self, from: data)
            } catch {
                print("Error loading recipes: \(error)")
            }
        } else {
            print("Could not find RecipesJSON")
        }
    }
    
    func loadRecipeIngredients() {
        if let url = Bundle.main.url(forResource: "RecipeIngredients_JSON", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                recipeIngredients = try decoder.decode([RecipeIngredient].self, from: data)
            } catch {
                print("Error loading recipe ingredients: \(error)")
            }
        } else {
            print("Could not find RecipeIngredients_JSON")
        }
    }
}

*/
