//
//  SettingsView.swift
//  GroceryPack
//
//  Created by Luciano Huapaya on 2/12/23.
//
//inspiration for settings: https://incipia.co/post/app-development/what-should-your-app-include-in-settings/

//Design:https://sarunw.com/posts/swiftui-list-basic/
///Used for design of Lists: https://www.appcoda.com/navigationstack/

//Manage a user:
///https://medium.com/swift-productions/swiftui-firebase-auth-listener-user-signup-manage-fae2294e8192 (view this in incognito mode)
///created a listener to get current user's information such as email address


import SwiftUI

struct PersonalInfo {
    let name: String
}

struct SettingsView: View {
    
    @State private var path = NavigationPath()
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        //VStack for alignming the Menu.
        VStack(){
            
            LogOut()
            
        }
        .background(BackgroundColor)
        
    }
}

//Profile Tab created for list.
struct ProfileView: View {
    //Environments
    @EnvironmentObject private var viewModel: AuthViewModel
    
    //Firebase Observable Model that connects to Firestore
    @ObservedObject var personalDataModel = PersonalDataModel()
    
    var body: some View {
        
        
        VStack {
            
            List() {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Name")
                            .foregroundColor(.gray)
                        ForEach(personalDataModel.personalDataDB) { item in
                            Text("\(item.firstName)")
                        }
                    }
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Email Address")
                            .foregroundColor(.gray)
                        Text("\(viewModel.user?.email ?? "Not found")")
                    }
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Change Password")
                            .foregroundColor(.gray)
                        Text("password")
                    }
                }
                HStack {
                    VStack(alignment: .leading) {
                        Text("Phone Number")
                            .foregroundColor(.gray)
                        Text("(805)427-3633")
                    }
                }
                HStack {
                    VStack(alignment: .leading) {
                        Text("Birthday")
                            .foregroundColor(.gray)
                        Text("02/24/1997")
                    }
                }
            }
            .listStyle(.inset)

        }
    }
    init() {
        personalDataModel.getFirstNameUID()
    }
}





struct Settings: View {
    //delcaring new list within the Profile View
    
    var body: some View {

            VStack {
                Text("HI")
            }
        }
}

struct GiveUsFeedback: View {
    //delcaring new list within the Profile View
    
    var body: some View {

            VStack {
                Text("Give us Feedback!")
            }
        }
}

struct InviteFriends: View {
    //delcaring new list within the Profile View
    
    var body: some View {

            VStack {
                Text("HI")
            }
        }
}

struct HelpSupport: View {
    //delcaring new list within the Profile View
    
    var body: some View {

            VStack {
                Text("HI")
            }
        }
}

struct SavedRecipes: View {
    //delcaring new list within the Profile View
    
    var body: some View {

            VStack {
                Text("HI")
            }
        }
}

struct LogOut: View {
    //needed to signout of the APP
    @EnvironmentObject var viewModel: AuthViewModel
    //delcaring new list within the Profile View
    
    var body: some View {
        
            VStack(alignment: .trailing) {
                signoutButton()
            }
        }
}


struct signoutButton: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        

                Button(action: {
                    viewModel.signOut()
                }, label: {
                    Text("Sign Out")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                        .cornerRadius(8.0)
                })
            
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    @State private var path = NavigationPath()
    
    static var previews: some View {
        NavigationStack {
            SettingsView()
        }
    }
}
