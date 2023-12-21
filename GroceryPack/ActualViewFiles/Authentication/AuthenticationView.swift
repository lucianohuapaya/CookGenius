// Created 02/08/2023

// followed this tutorial to get a working FireBase Authentication
//https://www.youtube.com/watch?v=vPCEIPL0U_k

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseCore
import FirebaseStorage

import AuthenticationServices


//AuthenticationView - Joins SignIn & SignUp View.
struct AuthenticationView: View {
    @State var email = ""
    @State var password = ""
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            if viewModel.signedIn {
                VStack{
                    //HomePage if Signed In.
                    HomeView()
                }
            }
            else  {
                SignInView()
            }
        }
        .onAppear{
            viewModel.signedIn = viewModel.isSignedIn
            
            //required listener to use when calling user's creditials
            ///1. email
            ///2. password
            ///etc
            viewModel.listenToAuthState()
        }
    }
}


//SignIn View that requires proper authenication to FirebaseAuth.
struct SignInView: View {
    @State var email = ""
    @State var password = ""
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    //needed to delcare VM for alart
    @StateObject var vm = AuthViewModel()
    
    @Environment(\.dismiss) var dismiss
    
    private func signInWithGoogle() {
        Task {
            if await viewModel.signInWithGoogle() == true {
                dismiss()
            }
        }
    }
    
    var body: some View {
        VStack {

                
                ZStack {
                    BackgroundImage() // Set a lower z-index for the image
                    
                    BackgroundRectView() // Set a higher z-index for the background rectangle
                    VStack {
                        SignInText_View()
                        
                        SignInMethod_View()

                        
                        Spacer()
                        Privacy_View()
                        
                    }
                    .frame(width: 350, height: 300)
                    .zIndex(2)
                }

        }
        .alert(isPresented: $viewModel.showError, content: {Alert(title:  Text(viewModel.errorMessage))})
    }
}

//SignUp View that requires proper authenication to FirebaseAuth.
struct SignUpView: View {
    @State var email = ""
    @State var password = ""
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack {
            Image("GroceryPack_backgroundImage1")
                .resizable()
                .aspectRatio(contentMode: .fit)
            VStack{
                TextField("Email Address", text: $email)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                SecureField("Password", text: $password)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                Button(action: {
                    guard !email.isEmpty,!password.isEmpty else {
                        return
                    }
                    
                    viewModel.signUp(email: email, password: password)
                }, label: {
                    Text("Create Account")
                        .frame(width: 220, height: 60)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                        .padding()
                })
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle("Create Account")
        
    }
}

struct Privacy_View: View {
    var body: some View {
        Text("By using this app, you agree to our Terms and Privacy Policy")
            .font(Font.custom("Jost", size: 14))
            .multilineTextAlignment(.center)
            .foregroundColor(Color(red: 0.06, green: 0.06, blue: 0.06).opacity(0.7))
            .frame(width: 217, alignment: .top)
            .padding(.bottom, 25)
    }
}

struct SignInMethod_View: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    private func signInWithGoogle() {
        Task {
            if await viewModel.signInWithGoogle() == true {
                dismiss()
            }
        }
    }
    var body: some View {
        VStack(alignment: .center) {
            SignInWithAppleButton(.signIn) { request in
                    viewModel.handleSignInWithAppleRequest(request)
                } onCompletion: { result in
                    viewModel.handleSignInWithAppleCompletion(result)
                }
                .font(.system(size: 18))
                .frame(maxWidth: 300, minHeight: 50, maxHeight: 50)
                .cornerRadius(8)
                .padding(.horizontal, 20)

            
            //Text("or")
            
            Button(action: signInWithGoogle) {
                HStack {
                    Image("flat-color-icons_google")
                        .resizable()
                        .frame(width: 25, height: 25)


                    Text("Sign in with Google")
                        .font(.system(size: 18))
                        .foregroundColor(.black) // Set text color to black

                }
                .frame(maxWidth: 300, minHeight: 50, maxHeight: 50)
                .background(Color.white)
                .cornerRadius(8)
                //.padding(.horizontal, 20)
            }
            .buttonStyle(.bordered)

        }

    }
}

struct SignInText_View: View {
    var body: some View {
        Text("Sign In")
            .font(
                Font.custom("Jost", size: 24)
                    .weight(.bold)
            )
            .foregroundColor(Color(red: 0.06, green: 0.06, blue: 0.06).opacity(1))
            .padding(.top, 30)
        
        Text("Please select a social network to log in ")
            .font(Font.custom("Jost", size: 16))
            .multilineTextAlignment(.center)
            .foregroundColor(.black)
            .frame(width: 298, alignment: .top)
            .padding(.top, 2)
    }
}

struct BackgroundImage: View {
    var body: some View {
        Image("LogInView")
            .resizable()
            .edgesIgnoringSafeArea(.all)
            .aspectRatio(contentMode: .fill)
            .zIndex(0)
    }
}

struct BackgroundRectView: View {
    var body: some View {
        Rectangle()
            .foregroundColor(.clear)
            .frame(width: 350, height: 350)
            .background(Color.white.opacity(0.6))
            .cornerRadius(15)
            .zIndex(1)
    }
}



struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = AuthViewModel() // Create an instance of AuthViewModel
        viewModel.signedIn = false // Set the initial state as needed
        
        return AuthenticationView()
            .environmentObject(viewModel) // Inject the viewModel as an environment object
    }
}


