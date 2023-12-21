//
//  PersonalDataModel.swift
//  GroceryPack
//
//  Created by Luciano Huapaya on 3/22/23.
//

import Foundation
import Firebase
import FirebaseAuth


struct personalData: Identifiable {
    var id: String
    var firstName: String
    var lastName: String
}

struct userFridgeItems: Identifiable {
    var id: String
    var name: String
    var quantity: Int
}


class PersonalDataModel: ObservableObject {
    
    @Published var personalDataDB = [personalData]()
    
    //used from chatGPT
    func getFirstNameUID() {
        //get a refernce to the database
        let db = Firestore.firestore()
        
        // Get the current user's UID
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User is not signed in")
            return
        }
        
        // Define a document reference for the user's data
        let userDocRef = db.collection("todos").document(uid)
        
        userDocRef.getDocument { (document, error)  in
            
            //checks for errors
            print("it works?!?")
            //if no errors
            
            if let document = document, document.exists {
                print("document exists!")
                
                //update the list properity in the main thread

                DispatchQueue.main.async {
                    
                    
                    //create a personalData object from the snapshot
                    let data = document.data()
                    
                    let id = document.documentID
                    let firstName = data?["firstName"] as? String ?? ""
                    let lastName = data?["lastName"] as? String ?? ""
                    print("First Name: \(firstName), Last Name: \(lastName)")
                    
                    
                    //create a new personalData object and add it to the array
                    let newPersonalData = personalData(id: id, firstName: firstName, lastName: lastName)
                    self.personalDataDB.append(newPersonalData)
                }
            }
            else {
                print("Document does not exist")
            }
        }
        
        
        
    }
    
}


//user information for other stuff

//End/Fin



