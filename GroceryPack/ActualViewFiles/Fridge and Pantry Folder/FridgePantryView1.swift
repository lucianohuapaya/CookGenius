import SwiftUI
import Kingfisher
//import UIKit

struct FridgePantry101: View {
    @State private var searchText = ""
    @ObservedObject var viewModel = AddIngredientViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading) {
                    SearchbarIngredientsView(searchText: $searchText, viewModel: viewModel)

                    
                    // Check if the fridge is empty and show the appropriate content
                    if viewModel.isUserIngredientsEmpty() {
                        // ... Your existing code ...
                    } else {
                        HStack {
                            Spacer()
                            Text("Delete items")
                                .padding(.bottom, 20)
                                .padding(.leading, 40)
                                .foregroundColor(.gray)
                            
                            Image(systemName: "arrow.right")
                                .padding(.bottom, 20)
                                .padding(.trailing, 15)
                                .foregroundColor(.gray)
                            
                            Button(action: {
                                viewModel.handleDeleteButtonClick()
                                viewModel.load_UserPantryDataList()
                            }) {
                                Image(systemName: "trash")
                                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                    .background(Color.gray)
                                    .cornerRadius(25)
                                    .foregroundColor(.white)
                            }
                            .padding(.bottom, 20)
                            .padding(.trailing, 40)
                        }
                        
                        // Conditionally display either UserPantryListView or UserDeleteView
                        if viewModel.isDeleteButtonClicked {
                            UserDeleteView(viewModel: viewModel, searchText: searchText)
                        } else {
                            UserPantryListView(viewModel: viewModel, searchText: searchText)
                        }
                    }
                    
                    Spacer() // Add spacer to push content to the top
                }
                
                VStack() {
                    Spacer()
                    HStack {
                        Text("Add ingredients by clicking \non the plus sign")
                            .padding(.bottom, 20)
                            .padding(.leading, 40)
                            .foregroundColor(.gray)
                        
                        Image(systemName: "arrow.right")
                            .padding(.bottom, 20)
                            .padding(.trailing, 15)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Button(action: {
                            // Use NavigationLink to navigate to the destination
                        }) {
                            NavigationLink(destination: AddIngredientsView()) {
                                Image(systemName: "plus")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                                    .background(Color.blue)
                                    .cornerRadius(25)
                            }
                        }
                        .padding(.bottom, 20)
                        .padding(.trailing, 40)
                    }
                }
            }
            .onAppear {
                // This closure will be called when the view appears
                viewModel.load_UserPantryDataList()
            }
        }
    }
}


struct UserPantryListView: View {
    @ObservedObject var viewModel = AddIngredientViewModel()
    let boxSize: CGFloat = 110 // Fixed size for each box
    var searchText: String
    
    var filteredUserPantryIngredients: [UserIngredient] {
        if searchText.isEmpty {
            return viewModel.userIngredients
        } else {
            return viewModel.userIngredients.filter {
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
                ForEach(filteredUserPantryIngredients, id: \.ingredientId) { userIngredient in
                    ZStack {
                        ZStack {
                            Color(red: 0.97, green: 1, blue: 0.77) // Background color
                                .cornerRadius(10)
                            Text(userIngredient.ingredientName_Original)
                                .frame(width: boxSize, height: boxSize) // Fixed size for each box
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .background(BackgroundColor)
            .padding()
        }
    }
}

struct UserDeleteView: View {
    @ObservedObject var viewModel = AddIngredientViewModel()
    
    let boxSize: CGFloat = 110 // Fixed size for each box
    
    var searchText: String
    
    var filteredUserDeleteIngredients: [UserIngredient] {
        if searchText.isEmpty {
            return viewModel.userIngredients
        } else {
            return viewModel.userIngredients.filter {
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
                ForEach(filteredUserDeleteIngredients, id: \.ingredientId) { userIngredient in
                    ZStack {
                        ZStack {
                            Color(red: 0.97, green: 1, blue: 0.77) // Background color
                                .cornerRadius(10)
                            Text(userIngredient.ingredientName_Original)
                                .frame(width: boxSize, height: boxSize) // Fixed size for each box
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            // Call the delete function in the viewModel
                            viewModel.deleteIngredientFromUserPantry(userIngredient)
                            viewModel.load_UserPantryDataList()
                        }) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 30, height: 30) // Adjust circle size
                                .overlay(
                                    Image(systemName: "trash.fill")
                                        .foregroundColor(.white)
                                )
                        }
                        
                        .position(x: boxSize - 15, y: 15) // Adjust position to top-right
                    }
                }
            }
            .background(BackgroundColor)
            .padding()
        }
    }
}

struct SearchbarIngredientsView: View {
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
    FridgePantry101()
}
