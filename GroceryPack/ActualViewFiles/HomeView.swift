//
//  HomePage.swift
//  GroceryPack
//
//  Created by Luciano Huapaya on 2/9/23.

import SwiftUI

//Colors
let BackNavigationButtonColor = Color(red: 247/255, green: 177/255, blue: 108/255)
let BackgroundColor = Color(red: 0.996, green: 1, blue: 0.973)

struct HomeView: View {
    var title = "SwiftUIToolbar"
    @State var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path){
            VStack(){
                HeaderView(path: $path)
                
                TabView {
                    FridgePantry101()
                        .background(BackgroundColor)
                        .tabItem {
                            Image(systemName: "carrot")
                            Text("Fridge & Pantry")
                        }
                    
                    RecipeMainView()
                        .background(BackgroundColor)
                        .tabItem {
                            Image(systemName: "fork.knife")
                            Text("Recipes")
                        }
                    
                    Text("Account")
                        .background(BackgroundColor)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .tabItem {
                            Image(systemName: "person")
                            Text("Account")
                        }
                }
            }
            .background(BackgroundColor)
            .navigationDestination(for: SettingsRoute.self) { route in
                switch route {
                case .UserProfile:
                    SettingsView()
                }
                
            }
        }
    }
}

enum SettingsRoute: Hashable {
    case UserProfile
}

struct HeaderView: View {
    @Binding var path: NavigationPath
    
    var body: some View {
        HStack {
            Spacer()
            
            // Click Through for Settings View
            NavigationLink("UserProfile", destination: SettingsView())
                .padding(.horizontal, 30)
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
