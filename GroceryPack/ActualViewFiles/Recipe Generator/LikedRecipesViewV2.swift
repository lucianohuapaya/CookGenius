//
//  LikedRecipesViewV2.swift
//  GroceryPack
//
//  Created by Luciano Huapaya on 11/8/23.
//

import SwiftUI
import Kingfisher

struct LikedRecipesViewV2: View {
    @StateObject var likedRecipes = LikedRecipes()

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                    ForEach(likedRecipes.likedRecipeData, id: \.id) { likedrecipe in
                        NavigationLink(destination: LikedRecipeDetailView(likedrecipe: likedrecipe)) {
                            VStack(alignment: .center) {
                                if let imageURL = URL(string: likedrecipe.image ?? "") {
                                    KFImage(imageURL)
                                        .resizable()
                                        .frame(width: 150, height: 100)
                                        .scaledToFit()
                                        .cornerRadius(10)
                                }
                                
                                Text(likedrecipe.title)
                                    .font(.system(size: 14))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(red: 0.11, green: 0.28, blue: 0.01))
                                    .frame(width: 150, height: 40)
                                   .lineLimit(2)
                            }
                            .padding(7)
                            .background(Color(red: 0.8, green: 0.88, blue: 0.8))
                            .cornerRadius(10)
                        }
                        .background(BackgroundColor)
                    }
                }
                .background(BackgroundColor)
            }
            .background(BackgroundColor)
            .padding()
        }
        .background(BackgroundColor)
    }
}


struct LikedRecipeDetailView: View {
    let likedrecipe: LikedRecipesJSON
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // Display the recipe image using Kingfisher
                if let imageURL = URL(string: likedrecipe.image ?? "") {
                    KFImage(imageURL)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(30)
                        .padding(.bottom, 20) // Increase the bottom padding to create more space
                        .padding(.horizontal, 20) // Add horizontal padding to center the image
                        .onAppear {
                            // Preload image into cache
                            ImageCache.default.retrieveImage(forKey: imageURL.absoluteString) { result in
                                if case .failure = result {
                                    ImagePrefetcher(urls: [imageURL]).start()
                                }
                            }
                        }
                }
                
                //Title of Recipe
                Text("\(likedrecipe.title)")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.11, green: 0.28, blue: 0.01))
                    .padding(.horizontal)
                
                HStack {
                    // Display Total cook time
                    HStack {
                        Image(systemName: "alarm")
                            .resizable()
                            .frame(width: 25, height: 25)

                        if let readyInMinutes = likedrecipe.readyInMinutes {
                            Text("\(readyInMinutes) min")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                    }
                    .frame(width: 130, height: 50)
                    .foregroundColor(Color(red: 0.55, green: 0.57, blue: 0.05))
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(red: 0.55, green: 0.57, blue: 0.05), lineWidth: 3) // Adjust the lineWidth as needed
                            .background(Color(red: 0.72, green: 0.77, blue: 0.44).opacity(0.18))
                    )
                    .cornerRadius(10)

                    
                    // Display Total cook time
                    HStack {
                        Image(systemName: "person")
                            .resizable()  // Make the image resizable
                            .frame(width: 25, height: 25)  // Set the desired size (adjust as needed)

                        if let serves = likedrecipe.servings {
                            Text("Serves \(serves)")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                    }
                    .frame(width: 130, height: 50)
                    .foregroundColor(Color(red: 0.95, green: 0.5, blue: 0.01)) // Adjust the opacity as needed
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(red: 0.95, green: 0.5, blue: 0.01), lineWidth: 3) // Adjust the lineWidth as needed
                            .background(Color(red: 0.98, green: 0.76, blue: 0.01).opacity(0.18))
                    )
                    .cornerRadius(10)
                }
                .padding(.horizontal)

                
                //Display Ingredients required
                Text("Ingredients:")
                    .font(.system(size: 20))
                    .fontWeight(.medium)
                    .padding(.horizontal, 20) // Add horizontal padding to center the text
                    .padding(.top, 10)
                
                if let usedIngredients = likedrecipe.usedIngredients {
                    ForEach(usedIngredients, id: \.id) { ingredient in
                        HStack {
                            //Displays Ingredient Image
                            if let imageURL = URL(string: ingredient.image ?? "") {
                                KFImage(imageURL)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit) // Maintain aspect ratio
                                    .frame(width: 40, height: 40) // Fixed size for the ingredient image
                                    .cornerRadius(20)
                                    .padding(.trailing, 10)
                                    .onAppear {
                                        // Preload image into cache
                                        ImageCache.default.retrieveImage(forKey: imageURL.absoluteString) { result in
                                            if case .failure = result {
                                                ImagePrefetcher(urls: [imageURL]).start()
                                            }
                                        }
                                    }
                                //Displays Ingredient Name
                                Text("\(ingredient.originalName ?? "")")
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading) // Fill remaining space and align leading
                            }
                        }
                        .padding(.horizontal, 20) // Add horizontal padding to align the ingredients
                    }
                }
                
                if let missedIngredients = likedrecipe.missedIngredients {
                    ForEach(missedIngredients, id: \.id) { ingredient in
                        HStack {
                            //Displays Ingredient Image
                            if let imageURL = URL(string: ingredient.image ?? "") {
                                KFImage(imageURL)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit) // Maintain aspect ratio
                                    .frame(width: 40, height: 40) // Fixed size for the ingredient image
                                    .cornerRadius(20)
                                    .padding(.trailing, 10)
                                    .onAppear {
                                        // Preload image into cache
                                        ImageCache.default.retrieveImage(forKey: imageURL.absoluteString) { result in
                                            if case .failure = result {
                                                ImagePrefetcher(urls: [imageURL]).start()
                                            }
                                        }
                                    }
                                
                                //Displays Ingredient Name
                                Text("\(ingredient.originalName ?? "")")
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading) // Fill remaining space and align leading
                            }
                        }
                        .padding(.horizontal, 20) // Add horizontal padding to align the ingredients
                    }
                }
            }
        }
        .background(BackgroundColor)
    }
    
}

struct QuickRecipeInfo_HStack: View {
    var body: some View {
        HStack {
            
        }
    }
}

class LikedRecipes: ObservableObject {
    @Published var likedRecipeData = [LikedRecipesJSON]()
    
    init() {
        loadLikedRecipes()
        
        if let fileURL = Bundle.main.url(forResource: "likedRecipes_JSON", withExtension: "json") {
                do {
                    let data = try Data(contentsOf: fileURL)
                    let decoder = JSONDecoder()
                    likedRecipeData = try decoder.decode([LikedRecipesJSON].self, from: data)
                } catch {
                    print("Error reading JSON file: \(error.localizedDescription)")
                }
            }
    }
    
    //gathers data from other JSON files and puts them here.
    func saveRecipeDetails(_ recipe: Recipe, recipeInfo: RecipeInformation) {
        
        let parsedInstructions = createParsedInstructions(from: recipeInfo.analyzedInstructions)
        
        let missingIngredients = createMissedIngredients(from: recipe.missedIngredients)
        
        let usedIngredients = createUsedIngredients(from: recipe.usedIngredients)
        
        let extendedIngredients = createExtendedIngredients(from: recipeInfo.extendedIngredients)
        
        let winePairing = createLikedWinePairing(from: recipeInfo.winePairing)
        
        let likedRecipe = createLikedRecipe(
            from: recipe,
            recipeInfo: recipeInfo,
            parsedInstructions: parsedInstructions,
            missingIngredients: missingIngredients,
            usedIngredients: usedIngredients,
            extendedIngredients: extendedIngredients,
            winePairing: winePairing
        )
        
        if isRecipeLiked(recipe) {
            likedRecipeData.removeAll { $0.id == recipe.id }
        } else {
            likedRecipeData.append(likedRecipe)
        }
        
        saveLikedRecipes()
    }
    
    func createLikedRecipe(from recipe: Recipe,
                           recipeInfo: RecipeInformation,
                           parsedInstructions: [LikedRecipesJSON.ParsedInstructions]?,
                           missingIngredients: [LikedRecipesJSON.MissedIngredient]?,
                           usedIngredients: [LikedRecipesJSON.UsedIngredient]?,
                           extendedIngredients: [LikedRecipesJSON.ExtendedIngredient]?,
                           winePairing: LikedRecipesJSON.WinePairing?) -> LikedRecipesJSON {
        
        let winePairing = createLikedWinePairing(from: recipeInfo.winePairing)
        
        return LikedRecipesJSON(
            id: recipe.id,
            image: recipe.image,
            title: recipe.title,
            servings: recipeInfo.servings ?? 0,
            pricePerServing: recipeInfo.pricePerServing,
            instructions: recipeInfo.instructions,
            timestamp: Date(),
            cheap: recipeInfo.cheap,
            dairyFree: recipeInfo.dairyFree,
            glutenFree: recipeInfo.glutenFree,
            sustainable: recipeInfo.sustainable,
            vegan: recipeInfo.vegan,
            vegetarian: recipeInfo.vegetarian,
            veryHealthy: recipeInfo.veryHealthy,
            veryPopular: recipeInfo.veryPopular,
            lowFodmap: recipeInfo.lowFodmap,
            weightWatcherSmartPoints: recipeInfo.weightWatcherSmartPoints,
            preparationMinutes: recipeInfo.preparationMinutes,
            cookingMinutes: recipeInfo.cookingMinutes,
            readyInMinutes: recipeInfo.readyInMinutes,
            healthScore: recipeInfo.healthScore,
            dishTypes: recipeInfo.dishTypes,
            creditsText: recipeInfo.creditsText,
            sourceName: recipeInfo.sourceName,
            sourceUrl: recipeInfo.sourceUrl,
            spoonacularSourceUrl: recipeInfo.spoonacularSourceUrl,
            cuisines: [],
            diets: [],
            analyzedInstructions: parsedInstructions,
            missedIngredients: missingIngredients,
            usedIngredients: usedIngredients,
            extendedIngredients: extendedIngredients,
            winePairing: winePairing // Add the timestamp here
        )
    }

    
    func createParsedInstructions(from instructions: [RecipeInformation.ParsedInstructions]?) -> [LikedRecipesJSON.ParsedInstructions]? {
        return instructions?.map { recipeInstructions in
            let steps = recipeInstructions.steps?.map { recipeStep in
                let ingredients = recipeStep.ingredients?.map { recipeIngredient in
                    return LikedRecipesJSON.ParsedInstructions.Step.Ingredient(
                        id: recipeIngredient.id,
                        name: recipeIngredient.name ?? "",
                        localizedName: recipeIngredient.localizedName ?? "",
                        image: recipeIngredient.image ?? ""
                    )
                }
                
                return LikedRecipesJSON.ParsedInstructions.Step(
                    number: recipeStep.number ?? 0,
                    step: recipeStep.step ?? "",
                    ingredients: ingredients
                )
            }
            
            return LikedRecipesJSON.ParsedInstructions(
                name: recipeInstructions.name ?? "",
                steps: steps
            )
        }
    }
    
    func createMissedIngredients(from ingredients: [Recipe.MissedIngredient]?) -> [LikedRecipesJSON.MissedIngredient]? {
        return ingredients?.map { ingredient in
            return LikedRecipesJSON.MissedIngredient(
                id: ingredient.id,
                aisle: ingredient.aisle,
                image: ingredient.image ?? "",
                name: ingredient.name ?? "",
                amount: ingredient.amount ?? 0.0,
                unit: ingredient.unit ?? "",
                originalName: ingredient.originalName ?? "",
                unitShort: ingredient.unitShort ?? ""
            )
        }
    }

    func createUsedIngredients(from ingredients: [Recipe.UsedIngredient]?) -> [LikedRecipesJSON.UsedIngredient]? {
        return ingredients?.map { ingredient in
            return LikedRecipesJSON.UsedIngredient(
                id: ingredient.id,
                aisle: ingredient.aisle,
                image: ingredient.image ?? "",
                name: ingredient.name ?? "",
                amount: ingredient.amount ?? 0.0,
                unit: ingredient.unit ?? "",
                originalName: ingredient.originalName ?? "",
                unitShort: ingredient.unitShort ?? ""
            )
        }
    }

    func createExtendedIngredients(from ingredients: [RecipeInformation.ExtendedIngredient]?) -> [LikedRecipesJSON.ExtendedIngredient]? {
        return ingredients?.map { ingredient in
            let measures = ingredient.measures.map { measures in
                LikedRecipesJSON.ExtendedIngredient.Measures(
                    metric: measures.metric.map { metric in
                        LikedRecipesJSON.ExtendedIngredient.Measures.Metric(
                            amount: metric.amount ?? 0,
                            unitShort: metric.unitShort ?? "",
                            unitLong: metric.unitLong ?? ""
                        )
                    },
                    us: measures.us.map { us in
                        LikedRecipesJSON.ExtendedIngredient.Measures.Us(
                            amount: us.amount ?? 0,
                            unitShort: us.unitShort ?? "",
                            unitLong: us.unitLong ?? ""
                        )
                    }
                )
            }
            
            return LikedRecipesJSON.ExtendedIngredient(
                id: ingredient.id ?? 0,
                aisle: ingredient.aisle ?? "",
                image: ingredient.image ?? "",
                consistency: ingredient.consistency ?? "",
                name: ingredient.name ?? "",
                nameClean: ingredient.nameClean ?? "",
                original: ingredient.original ?? "",
                originalName: ingredient.originalName ?? "",
                amount: ingredient.amount ?? 0,
                unit: ingredient.unit ?? "",
                meta: ingredient.meta ?? [],
                measures: measures
            )
        }
    }
    
    func createLikedWinePairing(from winePairing: RecipeInformation.WinePairing?) -> LikedRecipesJSON.WinePairing? {
        guard let winePairing = winePairing else {
            return nil
        }
        
        let productMatches = winePairing.productMatches?.map { productMatch in
            return LikedRecipesJSON.WinePairing.ProductMatch(
                id: productMatch.id,
                title: productMatch.title,
                description: productMatch.description,
                price: productMatch.price,
                imageUrl: productMatch.imageUrl,
                averageRating: productMatch.averageRating,
                ratingCount: productMatch.ratingCount,
                score: productMatch.score,
                link: productMatch.link
            )
        }
        
        return LikedRecipesJSON.WinePairing(
            pairedWines: winePairing.pairedWines,
            pairingText: winePairing.pairingText,
            productMatches: productMatches
        )
    }
    
    //Returns a boolean operation that declares if there is any matching recipeIDs
    func isRecipeLiked(_ recipe: Recipe) -> Bool {
        return likedRecipeData.contains { $0.id == recipe.id }
    }
    
    //loads the Recipe data for display.
    private func loadLikedRecipes() {
        if let fileURL = Bundle.main.url(forResource: "likedRecipes_JSON", withExtension: "json") {
            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                likedRecipeData = try decoder.decode([LikedRecipesJSON].self, from: data)
            } catch {
                print("Error reading JSON file: \(error.localizedDescription)")
            }
        } else {
            print("JSON file not found in the app bundle.")
        }
    }
    
    //saves the data to the appropriate JSON file and makes it look pretty
    private func saveLikedRecipes() {
        if let fileURL = Bundle.main.url(forResource: "likedRecipes_JSON", withExtension: "json") {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
            
            do {
                let jsonData = try encoder.encode(likedRecipeData)
                try jsonData.write(to: fileURL)
            } catch {
                print("Failed to encode liked recipes data: \(error)")
            }
        } else {
            print("JSON file not found in the app bundle.")
        }
    }

    //saves the data to the appropriate JSON file and makes it look pretty
    private func saveLikedRecipesList() {
        if let fileURL = Bundle.main.url(forResource: "likedRecipesList_JSON", withExtension: "json") {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            do {
                let jsonData = try encoder.encode(likedRecipeData)
                try jsonData.write(to: fileURL)
            } catch {
                print("Failed to encode liked recipes data: \(error)")
            }
        } else {
            print("JSON file not found in the app bundle.")
        }
    }
}

struct LikedRecipesJSON: Codable {

    let id: Int
    let image: String?
    let title: String
    let servings: Int?
    let pricePerServing: Double?
    let instructions: String?
    var timestamp: Date?
    
    // Filtering
    let cheap: Bool?
    let dairyFree: Bool?
    let glutenFree: Bool?
    let sustainable: Bool?
    let vegan: Bool?
    let vegetarian: Bool?
    let veryHealthy: Bool?
    let veryPopular: Bool?
    let lowFodmap: Bool?
    
    //other stuff
    let weightWatcherSmartPoints: Int?
    let preparationMinutes: Int?
    let cookingMinutes: Int?
    let readyInMinutes: Int?
    let healthScore: Int?
    let dishTypes: [String]?
    
    //credits
    let creditsText: String?
    let sourceName: String?
    let sourceUrl: String?
    let spoonacularSourceUrl: String?
    
    //other filters
    let cuisines: [String]?
    let diets: [String]?
    
    let analyzedInstructions: [ParsedInstructions]?
    let missedIngredients: [MissedIngredient]?
    let usedIngredients: [UsedIngredient]?
    let extendedIngredients: [ExtendedIngredient]?
    let winePairing: WinePairing?

    struct ParsedInstructions: Codable {
        let name: String?
        let steps: [Step]?
        
        struct Step: Codable {
            let number: Int?
            let step: String?
            let ingredients: [Ingredient]?
            
            struct Ingredient: Codable {
                let id: Int
                let name: String?
                let localizedName: String?
                let image: String?
            }
        }
    }
    
    struct MissedIngredient: Codable {
        let id: Int
        let aisle: String?
        let image: String?
        let name: String?
        let amount: Double?
        let unit: String?
        let originalName: String?
        let unitShort: String?
    }
    
    struct UsedIngredient: Codable {
        let id: Int
        let aisle: String?
        let image: String?
        let name: String?
        let amount: Double?
        let unit: String?
        let originalName: String?
        let unitShort: String?
    }
    

    struct ExtendedIngredient: Codable {
        let id: Int?
        let aisle: String?
        let image: String?
        let consistency: String?
        let name: String?
        let nameClean: String?
        let original: String?
        let originalName: String?
        let amount: Double?
        let unit: String?
        let meta: [String]?
        let measures: Measures?


        struct Measures: Codable {
            let metric: Metric?
            let us: Us?
            
            struct Metric: Codable {
                let amount: Double?
                let unitShort: String?
                let unitLong: String?
            }

            struct Us: Codable {
                let amount: Double?
                let unitShort: String?
                let unitLong: String?
            }
        }
    }
    
    //Wine Pairing
    struct WinePairing: Codable {
        let pairedWines: [String]?
        let pairingText: String?
        let productMatches: [ProductMatch]?

        struct ProductMatch: Codable {
            let id: Int?
            let title: String?
            let description: String?
            let price: String?
            let imageUrl: String?
            let averageRating: Double?
            let ratingCount: Double?
            let score: Double?
            let link: String?
        }
    }
    
}


#Preview {
    LikedRecipesViewV2()
}
