//i

/*
import Foundation
import SwiftUI
import URLImage
import Kingfisher

struct FridgePantryJSON: View {
    @StateObject var spoonacularAPI1 = SpoonacularAPI()

    var body: some View {
        VStack{
            List(spoonacularAPI1.SpoonacularAPIdata, id: \.id) { recipe in


                        Text(recipe.title)
                            .font(.headline)
                            .fontWeight(.bold)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                

        
    }
}


class SpoonacularAPI1: ObservableObject {
    
    @Published var SpoonacularAPIdata = [Recipe1]()
    @Published var recipeInformation = [RecipeInformation1]()
    
    init() {
        if let path = Bundle.main.path(forResource: "RecipesList_JSON", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let decoder = JSONDecoder()
                let recipes = try decoder.decode([Recipe1].self, from: data)
                self.SpoonacularAPIdata = recipes
            } catch {
                print("Error reading JSON file: \(error.localizedDescription)")
            }
        }
        
        if let path = Bundle.main.path(forResource: "RecipesInformation_JSON", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let decoder = JSONDecoder()
                let recipesInfo = try decoder.decode([RecipeInformation1].self, from: data)
                self.recipeInformation = recipesInfo
            } catch {
                print("Error reading JSON file: \(error.localizedDescription)")
            }
        }
    }
}


////
///

struct Recipe1: Codable {
    let title: String
    let id: Int
    let image: String
    let imageType: String
}


struct RecipeInformation1: Codable {
    let id: Int
    let title: String

}



struct FridgePantryJSON_Previews: PreviewProvider {
    static var previews: some View {
        FridgePantryJSON()
    }
}
*/


// Extended Ingredients
/*
let extendedIngredients: [ExtendedIngredient]?
struct ExtendedIngredient: Codable {
    let id: Int
    let aisle: String?
    let image: String?
    let consistency: String?
    let name: String?
    let nameClean: String?
    let original: String?
    let originalName: String?
    let amount: Double?
    let unit: String?
    let measures: [Measures]?

    struct Measures: Codable {
        let us: [us]?
        let metric: [metric]?

        struct us: Codable {
            let amount: Double?
            let unitShort: String?
            let unitLong: String?
        }
        
        struct metric: Codable {
            let amount: Double?
            let unitShort: String?
            let unitLong: String?
        }
    }
}
 */
