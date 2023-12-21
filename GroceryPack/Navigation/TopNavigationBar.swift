//
//  NavigationBar.swift
//  GroceryPack
//
//  Created by Luciano Huapaya on 2/9/23.
//

import SwiftUI

struct TopNavigationBar: View {
    var title = "Home Page"
    
    var body: some View {

        ZStack{
            Color.clear
                .background(.ultraThinMaterial)
                .blur(radius: 10)
            
            Text(title)
                .font(.largeTitle.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
        }
        .frame(height: 70)
        .frame(maxHeight: .infinity, alignment: .center)
    }
}

struct NavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        TopNavigationBar()
    }
}
