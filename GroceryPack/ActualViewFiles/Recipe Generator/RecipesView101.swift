//
//  RecipesView101.swift
//  GroceryPack
//
//  Created by Luciano Huapaya on 4/4/23.
//

import SwiftUI
import Firebase
import Foundation
import Kingfisher
import StoreKit
import SafariServices
import UIKit
import Combine

/*
struct fetchUserIngredientView1: View {
    @ObservedObject var addIngredientViewModel = AddIngredientViewModel()
    
    var body: some View {
        
        
        Button(action: {
            let allUserIngredients = addIngredientViewModel.fetchAllUserIngredients()
            
            // Now you can use allUserIngredients as needed
            print("All User Ingredients: \(allUserIngredients)")
        }) {
            Image(systemName: "arrow.clockwise.circle")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(.blue) // #f6f5c4
                .background(Color(red: 0.965, green: 0.961, blue: 0.769))
        }
    }
}
*/

struct TopNavBar: View {
    @ObservedObject var recipeByIngredientFetch: RecipeByIngredientFetch
    @ObservedObject var recipeInfoBulkFetch: RecipeInfoBulkFetch

    var body: some View {
        HStack {
            Button(action: {
                //Fetch recipes based on ingredients
                recipeByIngredientFetch.recipeByIngredient()
                
                //Fetch Detailed list of Recipes
                recipeInfoBulkFetch.fetchRecipeInfoBulk()
                recipeByIngredientFetch.load_RecipesList()
                recipeByIngredientFetch.load_UserIngredientsRecalledList()
            }) {
                Text("Fetch Recipes by Ingredient & Recipe Information in Bluk")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            Spacer()
        }
        .background(BackgroundColor)
    }
}

struct RecipesView101: View {
    @StateObject var likedRecipes = LikedRecipes()
    @StateObject var recipeByIngredientFetch = RecipeByIngredientFetch()
    @StateObject var recipeInfoBulkFetch = RecipeInfoBulkFetch()
    //@StateObject var imageLoader = ImageLoader() // Add ImageLoader
    
    var body: some View {
        NavigationView {
            VStack {
                TopNavBar(recipeByIngredientFetch: recipeByIngredientFetch, recipeInfoBulkFetch: recipeInfoBulkFetch)
                
                //fetchUserIngredientView1()
                
                ListOfRecipes101(recipeByIngredientFetch: recipeByIngredientFetch, recipeInfoBulkFetch: recipeInfoBulkFetch, likedRecipes: likedRecipes)
                .padding()
            }
            .background(BackgroundColor)
        }
        .background(BackgroundColor)

    }
}

struct ListOfRecipes101: View {
    @ObservedObject var recipeByIngredientFetch: RecipeByIngredientFetch
    @ObservedObject var recipeInfoBulkFetch: RecipeInfoBulkFetch
    @ObservedObject var likedRecipes: LikedRecipes
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6)], spacing: 6) {
                    ForEach(recipeByIngredientFetch.SpoonacularAPIdata, id: \.id) { recipe in
                        if let recipeInfo = recipeInfoBulkFetch.recipeInformation.first(where: { $0.id == recipe.id }) {
                            NavigationLink(destination: RecipeDetailsView101(recipe: recipe, recipeInfo: recipeInfo)){
                                VStack(alignment: .leading, spacing: 10) {
                                    ZStack(alignment: .topTrailing) {
                                        if let imageURL = URL(string: recipe.image ?? "") {
                                            KFImage(imageURL)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 150, height: 100) 
                                                .padding(.horizontal, 2)
                                        }
                                        
                                        Button(action: {
                                            likedRecipes.saveRecipeDetails(recipe, recipeInfo: recipeInfo)
                                        }) {
                                            ZStack {
                                                Circle()
                                                    .foregroundColor(Color.gray)
                                                    .frame(width: 40, height: 40)
                                                Image(systemName: likedRecipes.isRecipeLiked(recipe) ? "heart.fill" : "heart")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(.red)
                                            }
                                        }
                                        .padding(5)
                                    }
                                    
                                    Text(recipe.title)
                                        .frame(height: 60, alignment: .leading)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .lineLimit(2)
                                        .padding(.bottom, -10)
                                }
                                .frame(maxWidth: .infinity) // Make sure the VStack takes the full width
                                .padding(8) // Add padding to the VStack
                            }

                        }
                        
                    }

                }
            }

        }
        .background(BackgroundColor)

    }
}

struct RecipeDetailsView101: View {
    let recipe: Recipe
    let recipeInfo: RecipeInformation // Separate property
    
    @ObservedObject var recipeInfoBulkFetch = RecipeInfoBulkFetch()
    
    @State private var timestampCheckCount = 0 // Initialize the counter
    
    @State private var isShowingSafariView = false
    @State private var isTimestampValid = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                /*
                if isTimestampValid {
                 */
                    // Display the recipe image
                    RecipeImageView(imageURL: recipeInfo.image)
                    
                    // Display Total cook time
                    CookTimeView(readyInMinutes: recipeInfo.readyInMinutes)
                    
                    // Display Ingredients
                    Text("Ingredients:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 20) // Add horizontal padding to center the text
                    
                    if let usedIngredients = recipe.usedIngredients {
                        UsedIngredientsListView101(ingredients: usedIngredients, checkmarkImageName: "checkmark")
                    }
                    
                    if let missedIngredients = recipe.missedIngredients {
                        MissedIngredientsListView101(ingredients: missedIngredients, checkmarkImageName: "xmark")
                    }
                    
                    if let instructions = recipeInfo.analyzedInstructions?.first?.steps {
                        InstructionsListView(steps: instructions)
                    }

                SourcewithLinkView(isShowingSafariView: $isShowingSafariView, sourceURL: recipeInfo.sourceUrl)
            }
            .padding()
            
        }
        
        .navigationBarTitle(recipe.title, displayMode: .inline)
        .background(BackgroundColor)
    }
    
}

struct RecipeImageView: View {
    let imageURL: String?
    
    var body: some View {
        if let imageURL = URL(string: imageURL ?? "") {
            KFImage(imageURL)
                .resizable()
                .scaledToFit()
                .aspectRatio(contentMode: .fit) // Set the aspect ratio to fit
                .cornerRadius(30)
                .padding(.bottom, 20)
                .padding(.horizontal, 20)
        }
    }
}


struct InstructionsListView: View {
    let steps: [RecipeInformation.ParsedInstructions.Step]
    
    var body: some View {
        Text("Recipe Steps:")
            .font(.subheadline)
            .fontWeight(.medium)
            .padding(.horizontal, 20)
        
        ForEach(steps, id: \.number) { step in
            VStack(alignment: .leading, spacing: 8) {
                Text("Step \(step.number ?? 0):")
                    .font(.headline)
                
                Text(step.step ?? "")
                    .font(.body)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 20)
        }
    }
}

struct CookTimeView: View {
    let readyInMinutes: Int?
    
    var body: some View {
        if let readyInMinutes = readyInMinutes {
            Text("Total Cook Time: \(readyInMinutes) mins")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 10)
                .padding(.horizontal, 20)
        }
    }
}

struct UsedIngredientsListView101: View {
    let ingredients: [Recipe.UsedIngredient]
    let checkmarkImageName: String
    
    var body: some View {
        ForEach(ingredients, id: \.id) { ingredient in
            HStack {
                if let imageURL = URL(string: ingredient.image ?? "") {
                    Image(systemName: checkmarkImageName)
                        .frame(width: 20)
                    
                    KFImage(imageURL)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .cornerRadius(20)
                        .padding(.trailing, 10)
                        .onAppear {
                            ImageCache.default.retrieveImage(forKey: imageURL.absoluteString) { result in
                                if case .failure = result {
                                    ImagePrefetcher(urls: [imageURL]).start()
                                }
                            }
                        }
                    
                    Text("\(ingredient.originalName ?? "")")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct MissedIngredientsListView101: View {
    let ingredients: [Recipe.MissedIngredient]
    let checkmarkImageName: String
    
    var body: some View {
        ForEach(ingredients, id: \.id) { ingredient in
            HStack {
                if let imageURL = URL(string: ingredient.image ?? "") {
                    Image(systemName: checkmarkImageName)
                        .frame(width: 20)
                    
                    KFImage(imageURL)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .cornerRadius(20)
                        .padding(.trailing, 10)
                        .onAppear {
                            ImageCache.default.retrieveImage(forKey: imageURL.absoluteString) { result in
                                if case .failure = result {
                                    ImagePrefetcher(urls: [imageURL]).start()
                                }
                            }
                        }
                    
                    Text("\(ingredient.originalName ?? "")")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, 20)
        }
        .background(BackgroundColor)
    }
}





struct RecipesView101_Previews: PreviewProvider {
    static var previews: some View {
        RecipesView101()
    }
}

