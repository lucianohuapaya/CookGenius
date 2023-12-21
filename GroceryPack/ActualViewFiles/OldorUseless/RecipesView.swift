//
//  RecipesView.swift
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
   http://stackoverflow.com/questions/9061800/how-do-i-autocrop-a-uiimage/40780523#40780523
*/
extension UIImage {

    func trim() -> UIImage {
        let newRect = self.cropRect
        if let imageRef = self.cgImage!.cropping(to: newRect) {
            return UIImage(cgImage: imageRef)
        }
        return self
    }

    var cropRect: CGRect {
        let cgImage = self.cgImage
        let context = createARGBBitmapContextFromImage(inImage: cgImage!)
        if context == nil {
            return CGRect.zero
        }

        let height = CGFloat(cgImage!.height)
        let width = CGFloat(cgImage!.width)

        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        context?.draw(cgImage!, in: rect)

        //let data = UnsafePointer<CUnsignedChar>(CGBitmapContextGetData(context))
        guard let data = context?.data?.assumingMemoryBound(to: UInt8.self) else {
            return CGRect.zero
        }

        var lowX = width
        var lowY = height
        var highX: CGFloat = 0
        var highY: CGFloat = 0

        let heightInt = Int(height)
        let widthInt = Int(width)
        //Filter through data and look for non-transparent pixels.
        for y in (0 ..< heightInt) {
            let y = CGFloat(y)
            for x in (0 ..< widthInt) {
                let x = CGFloat(x)
                let pixelIndex = (width * y + x) * 4 /* 4 for A, R, G, B */

                if data[Int(pixelIndex)] == 0  { continue } // crop transparent

                if data[Int(pixelIndex+1)] > 0xE0 && data[Int(pixelIndex+2)] > 0xE0 && data[Int(pixelIndex+3)] > 0xE0 { continue } // crop white

                if (x < lowX) {
                    lowX = x
                }
                if (x > highX) {
                    highX = x
                }
                if (y < lowY) {
                    lowY = y
                }
                if (y > highY) {
                    highY = y
                }

            }
        }

        return CGRect(x: lowX, y: lowY, width: highX - lowX, height: highY - lowY)
    }

    func createARGBBitmapContextFromImage(inImage: CGImage) -> CGContext? {

        let width = inImage.width
        let height = inImage.height

        let bitmapBytesPerRow = width * 4
        let bitmapByteCount = bitmapBytesPerRow * height

        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let bitmapData = malloc(bitmapByteCount)
        if bitmapData == nil {
            return nil
        }

        let context = CGContext (data: bitmapData,
                                 width: width,
                                 height: height,
                                 bitsPerComponent: 8,      // bits per component
            bytesPerRow: bitmapBytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)

        return context
    }
}

class ImageLoader: ObservableObject {
    @Published var imageCache: [URL: UIImage] = [:]

    func loadImage(url: URL) {
        if imageCache[url] != nil {
            // Image already cached, no need to load it again
            return
        }

        DispatchQueue.global(qos: .background).async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data)?.trim() {
                DispatchQueue.main.async {
                    self.imageCache[url] = image
                }
            }
        }
    }
}

struct RecipesView: View {
    @StateObject var likedRecipes = LikedRecipes()
    @StateObject var recipeByIngredientFetch = RecipeByIngredientFetch()
    @StateObject var recipeInfoBulkFetch = RecipeInfoBulkFetch()
    //@StateObject var imageLoader = ImageLoader() // Add ImageLoader
    
    var body: some View {
        NavigationView {
            VStack {
                TopNavBar(recipeByIngredientFetch: recipeByIngredientFetch, recipeInfoBulkFetch: recipeInfoBulkFetch)
                ListOfRecipes(recipeByIngredientFetch: recipeByIngredientFetch, recipeInfoBulkFetch: recipeInfoBulkFetch, likedRecipes: likedRecipes)
                .padding()
            }
        }

    }
}

/*
struct TopNavBar: View {
    @ObservedObject var recipeByIngredientFetch: RecipeByIngredientFetch
    @ObservedObject var recipeInfoBulkFetch: RecipeInfoBulkFetch

    var body: some View {
        HStack {
            Button(action: {
                recipeByIngredientFetch.recipeByIngredient()
                //spoonacularAPI.formatRecipeIDs()
            }) {
                Text("Fetch Recipes by Ingredient")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            Spacer()
            Button(action: {
                recipeInfoBulkFetch.fetchRecipeInfoBulk()
                //spoonacularAPI.formatRecipeIDs()
            }) {
                Text("Fetch Recipe Information Bulk")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}
*/

struct ListOfRecipes: View {
    @ObservedObject var recipeByIngredientFetch: RecipeByIngredientFetch
    @ObservedObject var recipeInfoBulkFetch: RecipeInfoBulkFetch
    @ObservedObject var likedRecipes: LikedRecipes
    
    // Array to hold preprocessed images
    @State private var processedImages: [UIImage?] = []
    
    // State to track whether images are being processed
    @State private var isProcessingImages = true
    
    var body: some View {
        VStack {
            if isProcessingImages {
                // Display a loading indicator while images are being processed
                ProgressView("Processing Images...")
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6)], spacing: 6) {
                        ForEach(Array(zip(recipeByIngredientFetch.SpoonacularAPIdata, processedImages)), id: \.0.id) { recipe, processedImage in
                            if let recipeInfo = recipeInfoBulkFetch.recipeInformation.first(where: { $0.id == recipe.id }) {
                                NavigationLink(destination: RecipeDetailsView(recipe: recipe, recipeInfo: recipeInfo)){
                                    VStack(alignment: .leading, spacing: 10) {
                                        ZStack(alignment: .topTrailing) {
                                            if let uiImage = processedImage {
                                                Image(uiImage: uiImage) // Display the preprocessed image
                                                    .resizable()
                                                    .scaledToFit()
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
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            // Preprocess images and update the processedImages array
            DispatchQueue.global(qos: .background).async {
                var images: [UIImage?] = []
                for (_, recipe) in recipeByIngredientFetch.SpoonacularAPIdata.enumerated() {
                    if let imageURL = URL(string: recipe.image ?? ""),
                       let imageData = try? Data(contentsOf: imageURL),
                       let uiImage = UIImage(data: imageData)?.trim() {
                        images.append(uiImage)
                    } else {
                        images.append(nil)
                    }
                }
                DispatchQueue.main.async {
                    self.processedImages = images
                    self.isProcessingImages = false
                }
            }
        }

    }
}

/*
struct ListOfRecipes: View {
    @ObservedObject var recipeByIngredientFetch: RecipeByIngredientFetch
    @ObservedObject var recipeInfoBulkFetch: RecipeInfoBulkFetch
    @ObservedObject var likedRecipes: LikedRecipes

    var body: some View {
        VStack {
            if recipeByIngredientFetch.SpoonacularAPIdata.isEmpty {
                ProgressView("Loading...")
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6)], spacing: 6) {
                        ForEach(recipeByIngredientFetch.SpoonacularAPIdata, id: \.id) { recipe in
                            if let recipeInfo = recipeInfoBulkFetch.recipeInformation.first(where: { $0.id == recipe.id }) {
                                NavigationLink(destination: RecipeDetailsView(recipe: recipe, recipeInfo: recipeInfo)) {
                                    VStack(alignment: .leading, spacing: 10) {
                                        KFImage(URL(string: recipe.image ?? "")) // Use Kingfisher for image loading
                                            .resizable()
                                            .scaledToFit()
                                            .placeholder {
                                                // You can use a placeholder view here
                                                Image(systemName: "photo")
                                                    .font(.largeTitle)
                                            }
                                            .onSuccess { _ in
                                                // Image loaded successfully
                                            }
                                            .onFailure { error in
                                                // Handle image loading failure
                                                print("Image loading error: \(error)")
                                            }
                                            .padding(.horizontal, 2)
                                        
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
                                        
                                        Text(recipe.title)
                                            .frame(height: 60, alignment: .leading)
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .lineLimit(2)
                                            .padding(.bottom, -10)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            recipeByIngredientFetch.recipeByIngredient()
        }
    }
}
*/
 
struct RecipeDetailsView: View {
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
                        //UsedIngredientsListView(ingredients: usedIngredients, checkmarkImageName: "checkmark")
                    }
                    
                    if let missedIngredients = recipe.missedIngredients {
                        //MissedIngredientsListView(ingredients: missedIngredients, checkmarkImageName: "xmark")
                    }
                    
                    if let instructions = recipeInfo.analyzedInstructions?.first?.steps {
                        //InstructionsListView(steps: instructions)
                    }
                    
                    /*
                } else {
                     
                    // Show progress view or message
                    ProgressView("fetching recipe...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            */
                // Display the source view button
                SourcewithLinkView(isShowingSafariView: $isShowingSafariView, sourceURL: recipeInfo.sourceUrl)
            }
            .background(Color(red: 0.996, green: 1, blue: 0.2))
            .padding()
            /*
            .onAppear {
                let (isValid, recipeID, _) = recipeInfoBulkFetch.checkTimestamp(for: recipeInfo)
                isTimestampValid = isValid
                if !isValid {
                    print("Recipe with ID \(recipeID) needs updated data.")
                    recipeInfoBulkFetch.refetchRecipeInfo(for: recipeInfo.id)
                    let (isValid, _, _) = recipeInfoBulkFetch.checkTimestamp(for: recipeInfo)
                    isTimestampValid = isValid
                    
                }
            }
             */
        }
        .background(Color(red: 0.996, green: 1, blue: 0.2))
        .navigationBarTitle(recipe.title, displayMode: .inline)
        /*
        .onReceive(recipeInfoBulkFetch.$recipeInformation) { updatedRecipeInfo in
                    // Increment the counter each time this closure is called
                    timestampCheckCount += 1
                    

                    // This closure is called when recipeInformation is updated
                    if let updatedInfo = updatedRecipeInfo.first(where: { $0.id == recipeInfo.id }) {
                        // Update the view state based on the updated recipeInfo's timestamp
                        if let timestamp = updatedInfo.timestamp {
                            let currentTime = Date()
                            let timestampPlusOneHour = Calendar.current.date(byAdding: .hour, value: 1, to: timestamp) ?? Date()
                            print("Inside the updatedInfo timestamp: \(timestampCheckCount)")
                            isTimestampValid = currentTime < timestampPlusOneHour
                        } else {
                            print("Inside the false timestamp: \(timestampCheckCount)")
                            isTimestampValid = false
                        }
                    }
                }
         */
    }
}




