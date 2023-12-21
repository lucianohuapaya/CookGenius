//
//  BottomNavigationBar.swift
//  GroceryPack
//
//  Created by Luciano Huapaya on 2/9/23.
//
//https://www.appcoda.com/swiftui-tabview/
//Need tabview for bottom Tabs

// Changing the color of the tab bar: https://www.bigmountainstudio.com/community/public/posts/86559-how-to-customize-the-tabview-in-swiftui
//Another link: https://stackoverflow.com/questions/56969309/change-tabbed-view-bar-color-swiftui

//

import SwiftUI

struct BottomTab: View {
    var title = "SwiftUIToolbar"
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor.secondarySystemBackground
        
    }
    
    
    var body: some View {
        VStack{
            HStack{
                TabView {
                    ZStack{
                        ScrollView {
                            VStack(alignment: .center){
                                FeaturedItem()
                                    .frame(maxHeight: .infinity,alignment: .center)
                            }
                            
                        }
                    }
                    
                    //Background for Color
                    //.background(Color.blue)
                    
                    //Font for tab
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .tabItem {
                        Image(systemName: "carrot")
                        Text("Fridge & Pantry")
                    }
                    
                    Text("Recipes")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .tabItem {
                            Image(systemName: "fork.knife")
                            Text("Recipes")
                        }
                    
                    Text("Shopping")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .tabItem {
                            Image(systemName: "cart")
                            Text("Shopping")
                        }
                    
//                    Text("Profile Tab")
//                        .font(.system(size: 30, weight: .bold, design: .rounded))
//                        .tabItem {
//                            Image(systemName: "person.crop.circle")
//                            Text("Profile")
//                        }
                }
                
            }
        }
        
    }
}

 
struct BottomTab_Previews: PreviewProvider {
    static var previews: some View {
        BottomTab()
    }
}
