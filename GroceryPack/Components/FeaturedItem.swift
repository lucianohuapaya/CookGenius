//
//  FeaturedItem.swift
//  GroceryPack
//
//  Created by Luciano Huapaya on 2/9/23.
//

import SwiftUI

struct FeaturedItem: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8.0){
            Image("KiritoImages")
                .resizable(resizingMode: .stretch)
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10.0)
                .padding()

                
        }
    }
}

struct FeaturedItem_Previews: PreviewProvider {
    static var previews: some View {
        FeaturedItem()
    }
}
