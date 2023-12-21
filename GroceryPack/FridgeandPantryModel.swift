//
//  ViewModel.swift
//  GroceryPack
//
//  Created by Luciano Huapaya on 3/5/23.
//

import Foundation
import Firebase


//from Firestore Database
struct FridgeItemArray: Identifiable, Hashable {
    var id: String
    var name: String
    var quantity: Int
    var expirationDate: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(quantity)
    }
}
struct userIngredientsDB: Identifiable, Hashable {
    var id: String
    var name: String
}

//Fridge and Pantry Model used for 1 tab
/*
class FridgeandPantryModel: ObservableObject {
    
    @Published var FridgeData = [FridgeItemArray]()
    
    var numItems = 0
    
    
    init() {
        getData1 {}
    }
    
    //updating items???
    func updateFridgeItems(updateFridgeItems: FridgeItemArray, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        
        db.collection("userData").document("Dw2Tbrg99xSkqOGnu6q09U7r2f22").collection("FridgeItems").document(updateFridgeItems.id).setData(["name": "Updated:\(updateFridgeItems.name)"], merge: true) { error in
            if error == nil {
                self.getData1 {
                    completion()
                }
            }
        }
    }
    
    
    //decreases quantity by 1
    func decreaseQuantity(item: FridgeItemArray, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        
        /*
         // Get the current user's UID
         guard let uid = Auth.auth().currentUser?.uid else {
         print("User is not signed in")
         return
         }
         */
        
        let userDocRef = db.collection("userData").document("Dw2Tbrg99xSkqOGnu6q09U7r2f22").collection("FridgeItems")
        
        userDocRef.document(item.id).setData(["quantity": item.quantity - 1], merge: true) {error in
            
            //check for error
            if error == nil {
                //updatelist
                self.getData1 {
                    completion()
                }
            }
        }
    }
    
    //decreases quantity by 1
    func increaseQuantity(item: FridgeItemArray, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        
        /*
         // Get the current user's UID
         guard let uid = Auth.auth().currentUser?.uid else {
         print("User is not signed in")
         return
         }
         */
        
        let userDocRef = db.collection("userData").document("Dw2Tbrg99xSkqOGnu6q09U7r2f22").collection("FridgeItems")
        
        userDocRef.document(item.id).setData(["quantity": item.quantity + 1], merge: true) {error in
            
            //check for error
            if error == nil {
                //updatelist
                self.getData1{
                    completion()
                }
                //print("\([FridgeItemArray])")
            }
        }
    }
    
    
    //Standard way of deleting items
    func deleteData(deleteFridgeItem: FridgeItemArray) {
        //get a refernce to the database
        let db = Firestore.firestore()
        
        // Get the current user's UID
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User is not signed in")
            return
        }
        
        // Define a document reference for the user's data
        let userDocRef = db.collection("userData").document(uid).collection("FridgeItems")
        
        //Specify the document to delete
        userDocRef.document(deleteFridgeItem.id).delete { error in
            
            //Check for errors
            if error == nil {
                
                DispatchQueue.main.async {
                    
                    
                    //No errors
                    self.FridgeData.removeAll { todo in
                        //check for the todo to remove
                        return todo.id == deleteFridgeItem.id
                    }
                }
            }
            
        }
        
    }
    
    //deleting items via swipe of list to remove
    
    
    func loadItemsFromJSON() -> [Item] {
        var items: [Item] = []
        
        if let url = Bundle.main.url(forResource: "FridgePantryItemsJSON", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                items = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error loading items from JSON: \(error)")
            }
        } else {
            print("Could not find FridgePantryItemsJSON.json")
        }
        
        return items
    }
    
    
    //standard way of adding items
    // Standard way of adding items
    func addData(name: String, quantity: Int, selectedItemName: String, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let userDocRef = db.collection("userData").document("Dw2Tbrg99xSkqOGnu6q09U7r2f22").collection("FridgeItems")
        
        let currentDate = Date() // Get the current date
        
        if let selectedItem = UserFridgeItems().items.first(where: { $0.ingredientName_Original == selectedItemName }) {
            let avgExpirationDate = selectedItem.Avg_Expiration_Date
            
            // Calculate the expiration date by adding avgExpirationDate (in days) to the current date
            var expirationDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: currentDate)
            expirationDateComponents.hour = 23
            expirationDateComponents.minute = 59
            
            let expirationDate = Calendar.current.date(from: expirationDateComponents)!
            
            let finalExpirationDate = Calendar.current.date(byAdding: .day, value: avgExpirationDate, to: expirationDate)!
            let expirationTimestamp = Timestamp(date: finalExpirationDate)
            
            userDocRef.addDocument(data: ["name": name, "quantity": quantity, "expirationDate": expirationTimestamp]) { error in
                if let error = error {
                    print("Error adding document: \(error)")
                } else {
                    print("Document added successfully")
                    DispatchQueue.main.async {
                        self.getData1 {
                            completion()
                        }
                    }
                }
            }
        }
    }

    
    
    //this is dynamic. after every change it does something.
    
    func getData1(completion: @escaping () -> Void) {
        // Get a reference to the Firestore database
        let db = Firestore.firestore()
        
        // Get the document reference for the user's fridge items
        let userDocRef = db.collection("userData").document("Dw2Tbrg99xSkqOGnu6q09U7r2f22").collection("FridgeItems")
        
        // Add a listener for any changes to the fridge items collection
        userDocRef.addSnapshotListener { (querySnapshot, error) in
            
            // Check for any errors
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            // If there are no errors, update the FridgeData array
            self.FridgeData = documents.map { (queryDocumentSnapshot) -> FridgeItemArray in
                
                // Get the data from the document snapshot
                let data = queryDocumentSnapshot.data()
                let id = queryDocumentSnapshot.documentID
                
                // Set up a date formatter for converting timestamp to date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy"
                
                // Convert the expiration date timestamp to a date object
                let expirationDate = data["expirationDate"] as? Timestamp ?? Timestamp()
                print("\(expirationDate) = FS data value")
                let date = expirationDate.dateValue()
                print("\(date) = FS data value")
                
                // Calculate the number of days left until the expiration date
                let calendar = Calendar.current
                let currentDate = Date()
                print("\(currentDate) = today's current date")
                let daysUntilExpiration = calendar.dateComponents([.day], from: currentDate, to: date).day ?? 0
                
                // Get the name and quantity data for the item
                let itemName = data["name"] as? String ?? ""
                let quantityItem = data["quantity"] as? Int ?? 0
                
                print("\(daysUntilExpiration) = days left")
                
                // Create a FridgeItemArray object from the data
                return FridgeItemArray(id: id,
                                       name: itemName,
                                       quantity: quantityItem,
                                       expirationDate: daysUntilExpiration)
            }

            print("Fridge items updated")
            // Call the completion handler to indicate that the function has completed
            completion()
        }
    }
}
*/

