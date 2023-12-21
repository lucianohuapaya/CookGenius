//
//  GroceryPackApp.swift
//  GroceryPack
//
//  Created by Luciano Huapaya on 2/3/23.
//https://www.youtube.com/watch?v=R9Cn-oiWiRk

import Foundation
import SwiftUI
import Firebase
import FirebaseCore
import FirebaseFirestore
import GoogleSignIn

//Thread 1: SIGTERM appears when closing simulator wrong
//Properly close simulator: CMD + Q


@main
//where everything comes together!

struct GroceryPackApp: App {
    //register app delegate for Firebase Setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var sheetManager = SheetManager()
    
    var body: some Scene {
        WindowGroup {
            let viewModel = AuthViewModel()
            AuthenticationView() //calls StartingPage
                .environmentObject(viewModel)
                .environmentObject(sheetManager)
        }
    }
}



class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
