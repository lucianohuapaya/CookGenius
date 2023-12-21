import Foundation
import Combine

struct UserIngredient: Codable {
    let ingredientName_Original: String
    let ingredientId: Int
    let FridgeorPantry: String
    let ingredientName_Combined: String
    let Ingredient_Category: String
    let Avg_Expiration_Date: Double
}

class AddIngredientViewModel: ObservableObject {
    
    @Published var ingredients: [Ingredient] = []
    
    @Published var userIngredients: [UserIngredient] = []
    
    @Published var isDeleteButtonClicked = false

    init() {
        load_FridgePantryDataList()
        load_UserPantryDataList()
    }

    
    func load_FridgePantryDataList() {
        if let url = Bundle.main.url(forResource: "FridgePantryList_JSON", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decodedData = try JSONDecoder().decode([Ingredient].self, from: data)
                
                DispatchQueue.main.async {
                    self.ingredients = decodedData
                }
                
            } catch {
                print("Error loading or decoding JSON (load_FridgePantryDataList): \(error)")
            }
        } else {
            print("FridgePantryList_JSON file not found in the app bundle.")
        }

        do {
            self.userIngredients = try loadUserPantryData()
        } catch {
            print("Error loading UserPantry_JSON data: \(error)")
        }
    }

    func load_UserPantryDataList() {
        if let url = Bundle.main.url(forResource: "UserPantry_JSON", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decodedData = try JSONDecoder().decode([UserIngredient].self, from: data)
                
                DispatchQueue.main.async {
                    self.userIngredients = decodedData
                }
            } catch {
                print("Error loading or decoding JSON (load_UserPantryDataList): \(error)")
            }
        } else {
            print("FridgePantryList_JSON file not found in the app bundle.")
        }

        do {
            self.userIngredients = try loadUserPantryData()
        } catch {
            print("Error loading UserPantry_JSON data: \(error)")
        }
    }


    func addIngredientToUserPantry(for ingredient: Ingredient) {
        do {
            // Load existing user pantry data
            var userPantryIngredients = try loadUserPantryData()

            // Check if the ingredient is already present in userPantryIngredients
            if !userPantryIngredients.contains(where: { $0.ingredientId == ingredient.ingredientId }) {
                let userIngredient = UserIngredient(
                    ingredientName_Original: ingredient.ingredientName_Original,
                    ingredientId: ingredient.ingredientId,
                    FridgeorPantry: ingredient.FridgeorPantry,
                    ingredientName_Combined: ingredient.ingredientName_Combined,
                    Ingredient_Category: ingredient.Ingredient_Category,
                    Avg_Expiration_Date: ingredient.Avg_Expiration_Date
                )
                userPantryIngredients.append(userIngredient)

                // Save the updated data
                try saveUserPantryData(userPantryIngredients)

            } else {
                print("Ingredient already exists in UserPantry_JSON.")
            }
        } catch {
            print("Error encoding, saving, or loading data: \(error)")
        }
    }

    
    func deleteIngredientFromUserPantry(_ ingredient: UserIngredient) {
        do {
            var userPantryIngredients = try loadUserPantryData()

            // Find the index of the ingredient to be deleted
            if let index = userPantryIngredients.firstIndex(where: { $0.ingredientId == ingredient.ingredientId }) {
                userPantryIngredients.remove(at: index)

                // Save the updated data
                try saveUserPantryData(userPantryIngredients)

            } else {
                print("Ingredient not found in UserPantry_JSON.")
            }
        } catch {
            print("Error deleting ingredient: \(error)")
        }
    }

    
    func isIngredientSelected(_ ingredient: Ingredient) -> Bool {
        let isInFridgePantryList = ingredients.contains { $0.ingredientId == ingredient.ingredientId }
        let isInUserPantryList = userIngredients.contains { $0.ingredientId == ingredient.ingredientId }

        return isInFridgePantryList && isInUserPantryList
    }

    // Function to check if userIngredients has any data in the JSON
    func isUserIngredientsEmpty() -> Bool {
        return userIngredients.isEmpty
    }
    
    // Function to handle delete button click
    func handleDeleteButtonClick() {
        isDeleteButtonClicked.toggle() // Toggle between true and false

    }
    
    func fetchAllUserIngredients() -> String {
        // Assuming you want to use the userIngredients property defined within the class
        let ingredientNames = userIngredients.map { $0.ingredientName_Combined }
        let allUserIngredients = ingredientNames.joined(separator: ",")
        
        print(allUserIngredients)
        return allUserIngredients
    }

    func loadUserPantryData() throws -> [UserIngredient] {
        let userPantryURL = try userPantryDataURL()

        do {
            let data = try Data(contentsOf: userPantryURL)
            print(String(data: data, encoding: .utf8) ?? "Invalid UTF-8 data")
            
            
            return try JSONDecoder().decode([UserIngredient].self, from: data)
        } catch {
            print("Error loading UserPantry_JSON data: \(error)")
            return []
        }
    }


    func saveUserPantryData(_ data: [UserIngredient]) throws {
        let userPantryURL = try userPantryDataURL()

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]

        do {
            let jsonData = try encoder.encode(data)
            try jsonData.write(to: userPantryURL)
            print("Data saved to UserPantry_JSON.json successfully.")
            
        } catch {
            print("Error saving UserPantry_JSON data: \(error)")
        }
    }

    func userPantryDataURL() throws -> URL {
        // Get the document directory URL
        let documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

        // Append the desired file path
        let filePath = documentsDirectory.appendingPathComponent("UserPantry_JSON.json")
        
        return filePath
    }

}
