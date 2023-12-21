//
//  Routes.swift
//  GroceryPack
//
//  Created by Luciano Huapaya on 3/13/23.
//

import Foundation
import Firebase
import FirebaseAuth

//Import's for Google Sign In
import GoogleSignIn
import GoogleSignInSwift

// For Sign in with Apple
import AuthenticationServices
import CryptoKit

//Enmulator to define Error variables
enum SignInError: Error {
    case empty
    case short
    
}


//TODO: Notify user about error
//FireBase Authenitication to Backend
class AuthViewModel: ObservableObject {
    
    //simplying step to not get confused.
    let auth = Auth.auth()
    
    //initializing user
    var user: User? {
        didSet {
            objectWillChange.send()
        }
    }
    
    //Published for signedIn & Error Messages
    @Published var signedIn = false
    @Published var showError = false
    
    var errorMessage = ""
    var handle: AuthStateDidChangeListenerHandle?
    @Published var displayName: String = ""
    
    //Listener for authentication state
    
    private var currentNonce: String?
    
    
    // variable function established for bool.
    var isSignedIn: Bool {
        return auth.currentUser != nil
    }
    
    
    //listener function
    func listenToAuthState() {
        auth.addStateDidChangeListener { [weak self] _, user in
            guard let self = self else {
                return
            }
            self.user = user
        }
    }
    
    //Sign In Function
    ///Current gets: email & password
    func signIn(email: String, password: String) {
        auth.signIn(withEmail: email, password: password) {
            [self] (authResult, error) in switch error {
            case .some(let error as NSError) where error.code == AuthErrorCode.wrongPassword.rawValue:
                showError(message: "Wrong Password")
                print("wrong password")
            case .some (let error):
                print("Login error: \(error.localizedDescription)")
            case .none:
                if let user = authResult?.user {
                    print(user.uid)
                    
                    DispatchQueue.main.async {
                        //Success
                        self.signedIn = true
                    }
                }
            }
            
        }
        
    }
    
    
    //SignUp function for Auth.
    ///Current gets: email & password
    func signUp(email: String, password: String) {
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                // Handle sign up error
                print("Error signing up: \(error.localizedDescription)")
                return
            }
            
            guard let user = result?.user else {
                // Handle missing user error
                print("Missing user in sign up result")
                return
            }
            
            let db = Firestore.firestore()
            let userRef = db.collection("userData").document(user.uid)
            
            // Create a new document with the user's UID as the document ID
            userRef.setData(["email": user.email ?? "", "uid": user.uid]) { error in
                if let error = error {
                    // Handle Firestore error
                    print("Error creating user document: \(error.localizedDescription)")
                } else {
                    // Success: Update signedIn property and user object
                    self.signedIn = true
                    self.user = user
                }
            }
            
        }
    }
    
    //Signout try
    func signOut(){
        try? auth.signOut()
        self.signedIn = false
    }
    
    //Show Error Message on "wrong password"
    func showError (message: String) {
        errorMessage = message
        showError = true
    }
    
    
    
}

enum AuthenticationError: Error {
    case tokenError(message: String)
}

//Sign in with Google
extension AuthViewModel {
    func signInWithGoogle() async -> Bool {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("No client ID found in Firebase configuration")
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = await windowScene.windows.first,
              let rootViewController = await window.rootViewController else {
            print("There is no root view controller!")
            return false
        }
        
        do {
            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            let user = userAuthentication.user
            guard let idToken = user.idToken else {
                throw AuthenticationError.tokenError(message: "ID token missing")
            }
            let accessToken = user.accessToken
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString,
                                                           accessToken: accessToken.tokenString)
            
            let result = try await Auth.auth().signIn(with: credential)
            let firebaseUser = result.user
            print("User \(firebaseUser.uid) signed in with email \(firebaseUser.email ?? "unknown")")
            
            // Update signedIn property
            DispatchQueue.main.async {
                self.signedIn = true
            }
            
            return true
        } catch {
            print(error.localizedDescription)
            self.errorMessage = error.localizedDescription
            return false
        }
    }
}


// MARK: Sign in with Apple

extension AuthViewModel {
    
    
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
    }
    
    func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        if case .failure(let failure) = result {
            errorMessage = failure.localizedDescription
        } else if case .success(let authorization) = result {
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = currentNonce else {
                    fatalError("Invalid state: a login callback was received, but no login request was sent.")
                }
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print("Unable to fetch identity token.")
                    return
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                    return
                }
                
                let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: idTokenString,
                                                          rawNonce: nonce)
                Task {
                    do {
                        let result = try await Auth.auth().signIn(with: credential)
                        await updateDisplayName(for: result.user, with: appleIDCredential)
                        
                        // Update signedIn property
                        DispatchQueue.main.async {
                            self.signedIn = true
                        }
                    } catch {
                        print("Error authenticating: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    
    func updateDisplayName(for user: User, with appleIDCredential: ASAuthorizationAppleIDCredential, force: Bool = false) async {
        if let currentDisplayName = Auth.auth().currentUser?.displayName, !currentDisplayName.isEmpty {
            // current user is non-empty, don't overwrite it
        }
        else {
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = appleIDCredential.displayName()
            do {
                try await changeRequest.commitChanges()
                self.displayName = Auth.auth().currentUser?.displayName ?? ""
            }
            catch {
                print("Unable to update the user's displayname: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func verifySignInWithAppleAuthenticationState() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let providerData = Auth.auth().currentUser?.providerData
        if let appleProviderData = providerData?.first(where: { $0.providerID == "apple.com" }) {
            Task {
                do {
                    let credentialState = try await appleIDProvider.credentialState(forUserID: appleProviderData.uid)
                    switch credentialState {
                    case .authorized:
                        break // The Apple ID credential is valid.
                    case .revoked, .notFound:
                        // The Apple ID credential is either revoked or was not found, so show the sign-in UI.
                        self.signOut()
                    default:
                        break
                    }
                }
                catch {
                }
            }
        }
    }
    
}

extension ASAuthorizationAppleIDCredential {
    func displayName() -> String {
        return [self.fullName?.givenName, self.fullName?.familyName]
            .compactMap( {$0})
            .joined(separator: " ")
    }
}

// Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] =
    Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    
    while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError(
                    "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                )
            }
            return random
        }
        
        randoms.forEach { random in
            if remainingLength == 0 {
                return
            }
            
            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }
    
    return result
}

private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
    }.joined()
    
    return hashString
}
