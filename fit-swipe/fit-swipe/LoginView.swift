//
//  Untitled.swift
//  fit-swipe
//
//  Created by 何振民 on 2025/4/21.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var isSignUp = false
    @State private var errorMessage: String?
    @State private var isLoggedIn = false
    
    private var actionButton: some View {
        Button(action: {
            print("🖱 Button tapped, isSignUp: \(isSignUp)")
            if isSignUp {
                print("📩 Calling signUp()")
                signUp()
            } else {
                print("🔐 Calling login()")
                login()
            }
        }) {
            Text(isSignUp ? "Sign Up" : "Log In")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(isSignUp ? "Create Account" : "Log In")
                .font(.largeTitle)
                .bold()

            if isSignUp {
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
            }

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }

            actionButton

            Button(isSignUp ? "Already have an account?" : "Create a new account") {
                isSignUp.toggle()
                errorMessage = nil
                print("🔄 isSignUp toggled: \(isSignUp)")
            }
        }
        .padding()
        .fullScreenCover(isPresented: $isLoggedIn) {
            ContentView()
        }
    }

    // MARK: Sign Up Function
    func signUp() {
        print("📩 Sign Up button tapped")
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }

            guard let uid = result?.user.uid else { return }

            let userData: [String: Any] = [
                "username": username,
                "email": email,
                "avatarURL": ""
            ]

            Firestore.firestore().collection("users").document(uid).setData(userData) { error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    self.isLoggedIn = true
                }
            }
        }
    }

    // MARK: Log In Function
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                self.isLoggedIn = true
            }
        }
    }
}

