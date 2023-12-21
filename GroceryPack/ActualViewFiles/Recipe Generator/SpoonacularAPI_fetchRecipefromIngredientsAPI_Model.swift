//
//  SpoonacularAPI_fetchRecipefromIngredientsAPI_Model.swift
//  GroceryPack
//
//  Created by Luciano Huapaya on 6/30/23.
//

import Foundation
import Swift
import Combine

struct Recipe: Codable {
    let title: String
    let id: Int
    let image: String?
    let imageType: String?
    let missedIngredientCount: Int?
    let missedIngredients: [MissedIngredient]?
    let usedIngredients: [UsedIngredient]?
    var timestamp: Date?
    
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
    
    enum CodingKeys: String, CodingKey {
        case title
        case id
        case image
        case imageType
        case missedIngredientCount
        case missedIngredients
        case usedIngredients
        case timestamp
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(id, forKey: .id)
        try container.encode(image, forKey: .image)
        try container.encode(imageType, forKey: .imageType)
        try container.encode(missedIngredientCount, forKey: .missedIngredientCount)
        try container.encode(missedIngredients, forKey: .missedIngredients)
        try container.encode(usedIngredients, forKey: .usedIngredients)
        try container.encode(timestamp, forKey: .timestamp)
    }

    
    
}

struct RecipeInformation: Codable {
    
    let id: Int
    let image: String?
    let title: String?
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
    
    let analyzedInstructions: [ParsedInstructions]?
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
    
    let cuisines: [String]?
    let diets: [String]?
    
    
    //ingredients for this.
    let extendedIngredients: [ExtendedIngredient]?
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
    let winePairing: WinePairing?
    
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

struct UserIngredientRecalled: Codable {
    let ingredientName_Original: String
    let ingredientId: Int
    let FridgeorPantry: String
    let ingredientName_Combined: String
    let Ingredient_Category: String
    let Avg_Expiration_Date: Double
}

class RecipeByIngredientFetch: ObservableObject {
    
    @Published var SpoonacularAPIdata = [Recipe]()
    @Published var userIngredientsRecalled = [UserIngredientRecalled]()
    
    init() {
        load_RecipesList()
        load_UserIngredientsRecalledList()
    }
    
    func load_RecipesList() {
        if let url = Bundle.main.url(forResource: "RecipesList_JSON", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url, options: .mappedIfSafe)
                let decoder = JSONDecoder()
                let recipes = try decoder.decode([Recipe].self, from: data)
                self.SpoonacularAPIdata = recipes
            } catch {
                print("Error reading JSON file (load_RecipesList): \(error.localizedDescription)")
            }
        } else {
            print("RecipesList_JSON file not found in the app bundle.")
        }
    }

    func load_UserIngredientsRecalledList() {
        if let url = Bundle.main.url(forResource: "UserPantry_JSON", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let userIngredients = try decoder.decode([UserIngredientRecalled].self, from: data)
                
                self.userIngredientsRecalled = userIngredients
            } catch {
                print("Error reading JSON file (load_UserIngredientsRecalledList): \(error.localizedDescription)")
            }
        } else {
            print("UserPantry_JSON file not found in the app bundle.")
        }
    }
    
    // Function to fetch all user ingredients
    func fetchAllUserIngredients() -> String {
        do {
            let path = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("UserPantry_JSON.json")

            let data = try Data(contentsOf: path)
            let userIngredients = try JSONDecoder().decode([UserIngredientRecalled].self, from: data)
            
            let ingredientNames = userIngredients.map { $0.ingredientName_Combined }
            let allUserIngredients = ingredientNames.joined(separator: ",")
            
            print("All User Ingredients: \(allUserIngredients)")
            
            return allUserIngredients
        } catch {
            print("Error loading UserPantry_JSON data: \(error)")
            return ""
        }
    }
    
    //Main func: fetch Recipes.
    func fetchRecipesByIngredients(completion: @escaping ([Recipe]?, Date?) -> Void) {
        let apiKey = "d992fe1bc4a8452e90934e827102a1f9"
        let ingredients = fetchAllUserIngredients()
        
        if ingredients.isEmpty {
            print("Didn't receive ingredients")
            completion(nil, Date()) // Pass nil and a default timestamp
            return
        } else {
            print("Ingredients: \(ingredients)")
        }
        
        let ranking = "2"
        let amountOfRecipes = "20"
        let ignorePantry = "false"
        let urlString = "https://api.spoonacular.com/recipes/findByIngredients?apiKey=\(apiKey)&ingredients=\(ingredients)&ignorePantry=\(ignorePantry)&ranking=\(ranking)&number=\(amountOfRecipes)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion(nil, Date()) // Pass nil and a default timestamp
            return
        }
        
        let timestamp = Date()
        print("Requesting data from URL: \(url)")
        
        let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let data = data {
                let decoder = JSONDecoder()
                if var recipes = try? decoder.decode([Recipe].self, from: data) {
                    for index in 0..<recipes.count {
                        recipes[index].timestamp = timestamp // Assign the timestamp to each Recipe
                    }
                    print("Fetched Recipes Data: \(recipes)")
                    
                    DispatchQueue.main.async {
                        // Perform UI updates or other tasks on the main thread
                        completion(recipes, timestamp) // Pass recipes and the timestamp
                    }
                    
                } else {
                    print("Failed to decode JSON data.")
                    completion(nil, timestamp) // Pass nil and the timestamp
                }
            } else if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                
                DispatchQueue.main.async {
                    // Perform UI updates or other tasks on the main thread
                    completion(nil, timestamp) // Pass nil and the timestamp
                }
            }
        }
        task.resume()
    }


    func saveRecipesToJSONFile(recipes: [Recipe], timestamp: Date?) {
        if let fileURL = getRecipesJSONFileURL() {
            do {
                let jsonEncoder = JSONEncoder()
                jsonEncoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
                
                // Encode the recipes array directly
                let jsonData = try jsonEncoder.encode(recipes)
                try jsonData.write(to: fileURL)
                
                print("Recipes saved to file: \(fileURL)")
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    // Modify the recipeByIngredient function
    func recipeByIngredient() {
        fetchRecipesByIngredients { recipes, timestamp in
            if let recipes = recipes {
                //print statement.
                print("Received recipes: \(recipes)")
                
                //timestamp print statement.
                if let timestamp = timestamp {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM-dd-yyyy'T'HH:mm:ssZ"
                    let timestampString = dateFormatter.string(from: timestamp)
                    print("Received recipes with timestamp: \(timestampString)")
                } else {
                    print("Received recipes with unknown timestamp")
                }

                // Dispatch to the main thread for UI updates or other tasks
                DispatchQueue.main.async {
                    self.saveRecipesToJSONFile(recipes: recipes,
                                               timestamp: timestamp)
                }
            }
        }
        
        load_RecipesList()
        load_UserIngredientsRecalledList()
        
        
    }
    
    // Function to check if a specific recipe's timestamp is greater than 1 hour ago
    func isRecipeTimestampGreaterThanOneHourAgo(recipe: Recipe) -> Bool {
        guard let timestamp = recipe.timestamp else {
            print("Recipe \(recipe.id) does not have a timestamp.")
            return false // Recipe does not have a timestamp
        }
        
        let currentTime = Date()
        let oneHourAgo = currentTime.addingTimeInterval(-3600) // 3600 seconds = 1 hour
        
        if timestamp > oneHourAgo {
            print("Recipe \(recipe.id) was updated within the last hour.")
            // Add your logic for handling recently updated recipes here
            return true
        } else {
            print("Recipe \(recipe.id) is older than 1 hour.")
            // Add your logic for handling older recipes here
            return false
        }
    }

 
    // get Recipes JSON file.
    func getRecipesJSONFileURL() -> URL? {
        if let fileURL = Bundle.main.url(forResource: "RecipesList_JSON", withExtension: "json") {
            return fileURL
        } else {
            print("JSON file not found in the app bundle.")
            return nil
        }
    }
}

class RecipeInfoBulkFetch:ObservableObject {
    
    @Published var recipeInformation = [RecipeInformation]()
    
    init() {
        RecipesInformation()
    }
    
    func RecipesInformation() {
        if let url = Bundle.main.url(forResource: "RecipesInformation_JSON", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decodedData = try JSONDecoder().decode([RecipeInformation].self, from: data)
                
                DispatchQueue.main.async {
                    self.recipeInformation = decodedData
                }
                
            } catch {
                print("Error reading JSON file: \(error.localizedDescription)")
                //print("Data content: \(String(data: decodedData, encoding: .utf8) ?? "Invalid UTF-8 data")")
            }
        }
    }
    
    func RecipeIDstoBulkRecipeInfoFetch() -> String? {
        if let fileURL = getRecipesJSONFileURL() {
            do {
                let jsonData = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                let recipes = try decoder.decode([Recipe].self, from: jsonData)
                
                let recipeIDs = "(\(recipes.map { String($0.id) }.joined(separator: ",")))"
                
                print("Formatting IDs: \(recipeIDs)")
                
                return recipeIDs
            } catch {
                print("Error reading JSON file:", error.localizedDescription)
                return nil
            }
        }
        
        return nil
    }
    
    func fetchRecipeInfoBulk() {
        guard let recipeIDs = RecipeIDstoBulkRecipeInfoFetch() else {
            print("---------------------------------------")
            print("Failed to obtain recipe IDs.")
            print("---------------------------------------")
            return
        }

        let apiKey = "d992fe1bc4a8452e90934e827102a1f9"
        let urlString = "https://api.spoonacular.com/recipes/informationBulk?apiKey=\(apiKey)&ids=\(recipeIDs)&includeNutrition=false"
        
        print(recipeIDs)
        
        guard let url = URL(string: urlString) else {
            print("---------------------------------------")
            print("Invalid URL: \(urlString)")
            print("---------------------------------------")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("---------------------------------------")
                print("Error fetching recipe information: \(error.localizedDescription)")
                print("---------------------------------------")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("---------------------------------------")
                print("Invalid HTTP response")
                print("---------------------------------------")
                return
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                print("---------------------------------------")
                print("HTTP response error: \(httpResponse.statusCode)")
                print("---------------------------------------")
                return
            }
            
            guard let data = data else {
                print("---------------------------------------")
                print("No data received")
                print("---------------------------------------")
                return
            }
            
            print("---------------------------------------")
            print("Received data:")
            if let jsonString = String(data: data, encoding: .utf8) {
                print(jsonString)
            }
            print("---------------------------------------")
            
            self.addTimestampAndSave(data: data)
        }
        
        task.resume()
    }

    func addTimestampAndSave(data: Data) {
        var recipesInfo: [RecipeInformation] = []
        let decoder = JSONDecoder()
        
        do {
            recipesInfo = try decoder.decode([RecipeInformation].self, from: data)
        } catch {
            print("---------------------------------------")
            print("Error decoding recipe information: \(error.localizedDescription)")
            print("---------------------------------------")
            return
        }
        
        let timestamp = Date()
        for index in 0..<recipesInfo.count {
            recipesInfo[index].timestamp = timestamp
        }
        
        saveUpdatedRecipeInfoToJSONFile(data: recipesInfo)
    }

    func saveUpdatedRecipeInfoToJSONFile(data: [RecipeInformation]) {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        
        if let fileURL = getRecipesInformationJSONFileURL() {
            do {
                let jsonData = try jsonEncoder.encode(data)
                try jsonData.write(to: fileURL)
                
                print("---------------------------------------")
                print("Recipe information saved to file: \(fileURL.path)")
                print("---------------------------------------")
                
                DispatchQueue.main.async {
                    self.recipeInformation = data
                }
                
                print(data)
            } catch {
                print("---------------------------------------")
                print("Error saving recipe information: \(error.localizedDescription)")
                print("---------------------------------------")
            }
        }
    }

    func updateRefetchedRecipeToJSON(for recipeID: Int, with newData: RecipeInformation) {
        if let index = recipeInformation.firstIndex(where: { $0.id == recipeID }) {
            // Update the timestamp of the existing instance
            recipeInformation[index].timestamp = Date()
            
            // Save the updated data to the JSON file
            if let fileURL = getRecipesInformationJSONFileURL() {
                saveToJSONFile(data: recipeInformation, fileURL: fileURL)
            }
        }
    }

    func refetchRecipeInfo(for recipeID: Int) {
        // Construct the API request URL with the given recipeID
        let apiKey = "d992fe1bc4a8452e90934e827102a1f9" // Replace with your actual API key
        let urlString = "https://api.spoonacular.com/recipes/\(recipeID)/information?apiKey=\(apiKey)&includeNutrition=false"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error fetching recipe information: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid HTTP response")
                return
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                print("HTTP response error: \(httpResponse.statusCode)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            // Decode the received data into RecipeInformation
            let decoder = JSONDecoder()
            do {
                var recipeInfo = try decoder.decode(RecipeInformation.self, from: data)
                
                // Update the timestamp of the existing instance
                let currentTimestamp = Date()
                recipeInfo.timestamp = currentTimestamp

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
                let currentTimestampFormattedNicely = dateFormatter.string(from: currentTimestamp)

                
                // Update the existing recipeInformation array with the new data
                DispatchQueue.main.async {
                    if let index = self.recipeInformation.firstIndex(where: { $0.id == recipeID }) {
                        // Update the data
                        self.recipeInformation[index] = recipeInfo
                    }
                    
                    // Save the updated data to the JSON file after the update
                    if let fileURL = self.getRecipesInformationJSONFileURL() {
                        self.saveToJSONFile(data: self.recipeInformation, fileURL: fileURL)
                    }
                    
                    // Print a message when finished fetching and updating data
                    print("Finished refetching data for Recipe ID: \(recipeID)")
                    
                    print("Current Timestamp: \(currentTimestamp)")
                    print("Current Timestamp: \(currentTimestampFormattedNicely)")
                }
            } catch {
                print("Error decoding recipe information: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }

    func saveToJSONFile(data: [RecipeInformation], fileURL: URL) {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        
        do {
            let jsonData = try jsonEncoder.encode(data)
            try jsonData.write(to: fileURL)
            
            print("Recipe information saved to file: \(fileURL.path)")
            
        } catch {
            print("Error saving recipe information: \(error.localizedDescription)")
        }
    }
    
    func updateRefetchRecipeWithCurrentTimestamp(for recipeID: Int) {
        if let index = recipeInformation.firstIndex(where: { $0.id == recipeID }) {
            // Update the timestamp of the existing instance
            recipeInformation[index].timestamp = Date()
            
            // Save the updated data to the JSON file
            if let fileURL = getRecipesInformationJSONFileURL() {
                saveToJSONFile(data: recipeInformation, fileURL: fileURL)
            }
        }
    }

    func checkTimestamp(for recipeInfo: RecipeInformation) -> (isTimestampValid: Bool, recipeIDNeedsUpdate: Int) {
        if let timestamp = recipeInfo.timestamp {
            let currentTime = Date()
            let timestampPlusOneHour = Calendar.current.date(byAdding: .hour, value: 1, to: timestamp) ?? Date()

            // Compare current time with timestamp + 1 hour
            if currentTime < timestampPlusOneHour {
                // Data is still valid

                return (true, recipeInfo.id)
            } else {

                return (false, recipeInfo.id)
            }
        } else {

            return (false, recipeInfo.id)
        }
    }

    func getRecipesJSONFileURL() -> URL? {
        if let fileURL = Bundle.main.url(forResource: "RecipesList_JSON", withExtension: "json") {
            return fileURL
        } else {
            print("JSON file not found in the app bundle.")
            return nil
        }
    }

    func getRecipesInformationJSONFileURL() -> URL? {
        if let fileURL = Bundle.main.url(forResource: "RecipesInformation_JSON", withExtension: "json") {
            return fileURL
        } else {
            print("JSON file not found in the app bundle.")
            return nil
        }
    }
}
