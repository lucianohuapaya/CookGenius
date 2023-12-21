//
//  FridgePantryView.swift
//  GroceryPack
//
//  Created by Luciano Huapaya on 2/14/23.
//
//https://foodshare.com/wp-content/uploads/2018/06/Food-Shelf-Life-Guide.pdf

//creating list from Json file https://www.hackingwithswift.com/quick-start/swiftui/building-a-menu-using-list

//used for introduction to proper Firtestore usage. @7.02 shows model.
//https://www.youtube.com/watch?v=1NfW5wa2GJc

//Cloud Firestore Get Data (and other operations) with SwiftUI
//https://www.youtube.com/watch?v=xkxGoNfpLXs
/*

import Foundation
import FirebaseCore
import FirebaseFirestore
import Firebase
import SwiftUI
import Combine

//fetching data from JSON file
struct Item: Codable {
    var ingredientName_Original: String
    var ingredientId: Int
    var FridgeorPantry: String
    var ingredientName_Combined: String
    var Ingredient_Category: String
    var Avg_Expiration_Date: Int
    
    // CodingKeys for mapping between struct properties and JSON keys
    enum CodingKeys: String, CodingKey {
        case ingredientName_Original
        case ingredientId
        case FridgeorPantry
        case ingredientName_Combined
        case Ingredient_Category
        case Avg_Expiration_Date
    }
}


func search(items: [Item], query: String, category: String) -> [Item] {
    let lowercaseQuery = query.lowercased()
    let lowercaseCategory = category.lowercased()

    return items.filter { item in
        let itemNameWords = item.ingredientName_Original.lowercased().split(separator: " ")
        let categoryWords = item.Ingredient_Category.lowercased().split(separator: " ")
        
        // Check if any of the words in the item name or category start with the search query
        return itemNameWords.contains { $0.hasPrefix(lowercaseQuery) } &&
            categoryWords.contains { $0.hasPrefix(lowercaseCategory) }
    }
}


class UserFridgeItems: ObservableObject {
    @Published var items: [Item] = []
    
    init() {
        loadItems()
    }
    
    func loadItems() {
        if let url = Bundle.main.url(forResource: "FridgePantryItemsJSON", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                items = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error loading items: \(error)")
            }
        } else {
            print("Could not find items.json")
        }
    }
}


struct FridgePantryView: View {
    //Environments
    @EnvironmentObject var viewModel: AuthViewModel
    
    //standard navigation path.
    @State var path = NavigationPath()
    
    //Firebase Observable Model that connects to Firestore.
    @ObservedObject var FridgeItemsDB = FridgeandPantryModel()
    
    //needed for search bar
    @State private var searchText = ""
    @State private var isSearching = false
    
    //State Objects for calling JSON classes for search bar
    @StateObject var store = UserFridgeItems()
    
    //needed for selected Option
    @State private var selectedOption: String?
    @State private var isShowingList = false
    
    //used for
    @State private var numItems: Int = 0
    
    var body: some View {
        
        ZStack() {
            ZStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Fridge")
                            .multilineTextAlignment(.leading)
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                        
                        Spacer()
                        
                    }
                    .padding(.vertical, 1)
                    .padding(.horizontal, 12)
                    
                    
                    
                    //list fetching from the database.
                    HStack {
                        Text("Name")
                        
                            .padding(.horizontal, 12)
                            .bold(true)
                            .underline(true)
                        Spacer()
                        Text("Expiration")
                            .bold(true)
                            .underline(true)
                        Spacer()
                        Text("Quantity")
                            .padding(.horizontal, 12)
                            .bold(true)
                            .underline(true)
                    }
                    List {
                        //creating the title for our list. hardcoded!!!!
                        
                        //used for fetching data.
                        ForEach(FridgeItemsDB.FridgeData) { item in
                            HStack {
                                VStack {
                                    Text(item.name)
                                }
                                Spacer()
                                
                                Text("\(item.expirationDate) days")
                                    .padding(.leading, 30)
                                    .frame(alignment: .center)
                                
                                Spacer()
                                HStack {
                                    Button(action: {
                                        FridgeItemsDB.decreaseQuantity(item: item){}
                                    }) {
                                        Image(systemName: "minus.circle")
                                    }
                                    
                                    .buttonStyle(BorderedButtonStyle())
                                    Text("\(item.quantity)")
                                        
                                    
                                    Button(action: {
                                        FridgeItemsDB.increaseQuantity(item: item){}
                                    }) {
                                        Image(systemName: "plus.circle")
                                    }
                                    .buttonStyle(BorderedButtonStyle())
                                }
                                
                            }
                            .swipeActions(allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    FridgeItemsDB.deleteData(deleteFridgeItem: item)
                                } label: {
                                    Label("Delete", systemImage: "trash.fill")
                                }
                            }
                            
                        }
                    }
                    .frame(minHeight: 0, maxHeight: 200) // use valid height values
                    .listStyle(.plain)
                    
                    //.scrollContentBackground(.hidden)
                    
                    
                    HStack {
                        Text("Pantry")
                            .multilineTextAlignment(.leading)
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .padding()
                        Spacer()
                        Image(systemName: "plus")
                            .padding()
                        Image(systemName: "chevron.down")
                            .padding()
                        
                    }
                    .padding(.leastNonzeroMagnitude)
                    
                    //list fetching from the database
                    List {
                        //creating the title for our list. hardcoded!!!!
                        HStack {
                            Text("Name")
                                .bold(true)
                                .underline(true)
                            Spacer()
                            Text("Notes")
                                .bold(true)
                                .underline(true)
                        }
                        
                        
                        
                    }
                    .frame(minHeight: 0, maxHeight: 200) // use valid height values
                    .listStyle(.inset)
                    .padding(.leastNonzeroMagnitude)
                }
            }
            .zIndex(0)
            ZStack() {
                
                SearchBar(searchText: $searchText, isSearching: $isSearching)
                    .padding(.horizontal, 50)
                
            }
            .zIndex(1)
        }
    }
}


struct SearchBar: View {
    @Binding var searchText: String
    @Binding var isSearching: Bool
    
    //State Objects for calling JSON classes for search bar
    @StateObject var userFridgeItems = UserFridgeItems()
    
    //needed for selected Option
    @State private var selectedOption: String?
    @State private var isShowingList = false
    
    //Firebase Observable Model that connects to Firestore.
    @ObservedObject var FridgeItemsDB = FridgeandPantryModel()
    
    var body: some View {
        ZStack() {
            VStack(alignment: .center) {
                HStack {
                    TextField("Search ...", text: $searchText)
                        .padding(.leading, 24)
                    Spacer()
                    Button(action: {
                        self.searchText = ""
                        self.isSearching = false
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .padding(.trailing, 24)
                    }
                    .opacity(searchText == "" ? 0 : 1)
                }
                
                .padding(.vertical, 10)
                .background(Color(.systemGray5))
                .cornerRadius(80)
                .onTapGesture {
                    self.isSearching = true
                }
                HStack {
                    GeometryReader { geometry in
                        if let options = getMatchingItems(searchText: searchText) {
                            List(options, id: \.self) {
                                option in
                                    HStack {
                                        Text(option)
                                        Spacer()
                                        Button(action: {
                                            addSelectedItemToDatabase(itemName: option)
                                            self.isSearching = false // Hide the search results list after an item is selected
                                        }) {
                                            Image(systemName: "plus.circle")
                                        }
                                }
                                
                            }
                            .listStyle(.plain)
                            .frame(minHeight: 0, maxHeight: 200)
                        }
                    }
                }
            }
            .padding()
        }
        
    }
    
    // Function to add selected item to the Firebase Firestore database
    func addSelectedItemToDatabase(itemName: String) {
        FridgeItemsDB.addData(name: itemName, quantity: 1, selectedItemName: itemName) {}
    }

    
    // Update the function to access userFridgeItems correctly
    func getMatchingItems(searchText: String) -> [String]? {
        if !searchText.isEmpty {
            let matchingItems = userFridgeItems.items
                .filter { $0.ingredientName_Original.lowercased().hasPrefix(searchText.lowercased()) }
            if matchingItems.count > 0 {
                return matchingItems.map { $0.ingredientName_Original }
            }
        }
        return nil
    }



}



struct FridgePantryView_Previews: PreviewProvider {
    static var previews: some View {
        FridgePantryView()
    }
}
 */
