//
//  RecipeGeneratorComponents.swift
//  GroceryPack
//
//  Created by Luciano Huapaya on 12/18/23.
//

import Foundation
import SafariServices
import SwiftUI
import UIKit

//Source Button View to go to Source via web.
struct SourcewithLinkView: View {
    @Binding var isShowingSafariView: Bool
    let sourceURL: String?
    
    var body: some View {
        if let sourceURL = URL(string: sourceURL ?? "") {
            Button(action: {
                isShowingSafariView = true
            }) {
                Text("View Source")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            .sheet(isPresented: $isShowingSafariView) {
                SafariView(url: sourceURL)
            }
        }
    }
}

//This is supplement to the SourcewithLinkView. This will open a UIViewController of the Source in a pop-up safari view.
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
    }
}
