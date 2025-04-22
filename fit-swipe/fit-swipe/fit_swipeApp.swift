//
//  fit_swipeApp.swift
//  fit-swipe
//
//  Created by 何振民 on 2025/4/21.
//

import SwiftUI
import Firebase



@main
struct fit_swipeApp: App {
    init() {
            FirebaseApp.configure()
            print("🔥 Firebase initialized")
    }
    
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}
