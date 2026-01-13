////
////  AuthManager.swift
////  Guardian Angel
////
////  Created by Oluwaseun Odueso on 29/12/2025.
////
//
//
//import Foundation
//import SwiftUI
//internal import Combine
//
//class AuthManager: ObservableObject {
//    @Published var isAuthenticated = false
//    @Published var currentUser: User?
//    @Published var authToken: String?
//    
//    static let shared = AuthManager()
//    
//    private let tokenKey = "guardian_auth_token"
//    private let userKey = "guardian_user_data"
//    
//    init() {
//        print("🔐 AuthManager initializing...")
//        
//        // Check for saved token on app launch
//        if let token = UserDefaults.standard.string(forKey: tokenKey) {
//            print("🔄 Found saved token: \(token.prefix(10))...")
//            self.authToken = token
//            self.isAuthenticated = true
//            
//            // Load saved user data
//            if let userData = UserDefaults.standard.data(forKey: userKey) {
//                print("🔄 Loading saved user data...")
//                do {
//                    let user = try JSONDecoder().decode(User.self, from: userData)
//                    print("✅ Loaded saved user: \(user.email) (role: \(user.role))")
//                    self.currentUser = user
//                } catch {
//                    print("❌ Could not decode saved user data: \(error)")
//                }
//            } else {
//                print("⚠️ No saved user data found")
//            }
//        } else {
//            print("🔐 No saved token found - starting fresh")
//        }
//    }
//    
//    // MARK: - Login (Updated to include role parameter)
//    func login(email: String, password: String, role: String = "user", completion: @escaping (Result<User, Error>) -> Void) {
//        print("🔐 Login attempt for: \(email) as \(role)")
//        
//        let url = URL(string: "https://guardian-fwpg.onrender.com/api/v1/auth/login")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.timeoutInterval = 30
//        
//        let body: [String: Any] = [
//            "email": email.lowercased(),
//            "password": password,
//            "loginType": role  // Added role parameter
//        ]
//        
//        print("📡 Login Request Body: \(body)")
//        
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: body)
//            if let jsonString = String(data: request.httpBody!, encoding: .utf8) {
//                print("📄 JSON Being Sent: \(jsonString)")
//            }
//        } catch {
//            print("❌ JSON Serialization Error: \(error)")
//            completion(.failure(error))
//            return
//        }
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    print("❌ Network Error: \(error.localizedDescription)")
//                    completion(.failure(error))
//                    return
//                }
//                
//                guard let httpResponse = response as? HTTPURLResponse else {
//                    print("❌ No HTTP Response")
//                    completion(.failure(NSError(domain: "Invalid server response", code: 0)))
//                    return
//                }
//                
//                print("📊 Login Status Code: \(httpResponse.statusCode)")
//                
//                guard let data = data else {
//                    print("❌ No response data")
//                    completion(.failure(NSError(domain: "No response data", code: httpResponse.statusCode)))
//                    return
//                }
//                
//                // Print raw response for debugging
//                if let responseString = String(data: data, encoding: .utf8) {
//                    print("📄 Raw Login Response: \(responseString)")
//                }
//                
//                // Try to decode the response
//                do {
//                    let decoder = JSONDecoder()
//                    decoder.keyDecodingStrategy = .convertFromSnakeCase
//                    
//                    let apiResponse = try decoder.decode(LoginResponse.self, from: data)
//                    print("✅ Login API Response: \(apiResponse.message)")
//                    
//                    if apiResponse.success {
//                        // Save token and user data
//                        let token = apiResponse.data.tokens.accessToken
//                        let user = apiResponse.data.user
//                        
//                        self.saveAuthData(token: token, user: user)
//                        
//                        // Update state
//                        self.authToken = token
//                        self.currentUser = user
//                        self.isAuthenticated = true
//                        
//                        print("✅ Login successful! Token: \(token.prefix(10))..., User: \(user.email) as \(user.role)")
//                        completion(.success(user))
//                    } else {
//                        print("❌ Login failed: \(apiResponse.message)")
//                        completion(.failure(NSError(domain: apiResponse.message, code: httpResponse.statusCode)))
//                    }
//                } catch {
//                    print("❌ Decoding Error: \(error)")
//                    print("Error details: \(error.localizedDescription)")
//                    
//                    // Try to get error message from raw JSON
//                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
//                       let message = json["message"] as? String {
//                        print("📋 Error message from server: \(message)")
//                        completion(.failure(NSError(domain: message, code: httpResponse.statusCode)))
//                    } else {
//                        completion(.failure(error))
//                    }
//                }
//            }
//        }.resume()
//    }
//    
//    // MARK: - Signup (Updated to include role parameter)
//    func signup(email: String, fullName: String, phone: String, password: String, role: String = "user", completion: @escaping (Result<User, Error>) -> Void) {
//        print("🔐 Signup attempt for: \(email) as \(role)")
//        
//        let url = URL(string: "https://guardian-fwpg.onrender.com/api/v1/auth/signup")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.timeoutInterval = 30
//        
//        let body: [String: Any] = [
//            "email": email,
//            "fullName": fullName,
//            "phone": phone,
//            "password": password,
//            "role": role  // Added role parameter
//        ]
//        
//        print("📡 Signup Request Body: \(body)")
//        
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: body)
//            if let jsonString = String(data: request.httpBody!, encoding: .utf8) {
//                print("📄 JSON Being Sent: \(jsonString)")
//            }
//        } catch {
//            print("❌ JSON Serialization Error: \(error)")
//            completion(.failure(error))
//            return
//        }
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    print("❌ Network Error: \(error.localizedDescription)")
//                    completion(.failure(error))
//                    return
//                }
//                
//                guard let httpResponse = response as? HTTPURLResponse else {
//                    print("❌ No HTTP Response")
//                    completion(.failure(NSError(domain: "Invalid server response", code: 0)))
//                    return
//                }
//                
//                print("📊 Signup Status Code: \(httpResponse.statusCode)")
//                
//                guard let data = data else {
//                    print("❌ No response data")
//                    completion(.failure(NSError(domain: "No response data", code: httpResponse.statusCode)))
//                    return
//                }
//                
//                // Print raw response for debugging
//                if let responseString = String(data: data, encoding: .utf8) {
//                    print("📄 Raw Signup Response: \(responseString)")
//                }
//                
//                // Try to decode the response
//                do {
//                    let decoder = JSONDecoder()
//                    decoder.keyDecodingStrategy = .convertFromSnakeCase
//                    
//                    let apiResponse = try decoder.decode(SignupResponse.self, from: data)
//                    print("✅ Signup API Response: \(apiResponse.message)")
//                    
//                    if apiResponse.success {
//                        // Save token and user data
//                        let token = apiResponse.data.tokens.accessToken
//                        let user = apiResponse.data.user
//                        
//                        self.saveAuthData(token: token, user: user)
//                        
//                        // Update state
//                        self.authToken = token
//                        self.currentUser = user
//                        self.isAuthenticated = true
//                        
//                        print("✅ Signup successful! Token: \(token.prefix(10))..., User: \(user.email) as \(user.role)")
//                        completion(.success(user))
//                    } else {
//                        print("❌ Signup failed: \(apiResponse.message)")
//                        completion(.failure(NSError(domain: apiResponse.message, code: httpResponse.statusCode)))
//                    }
//                } catch {
//                    print("❌ Decoding Error: \(error)")
//                    print("Error details: \(error.localizedDescription)")
//                    
//                    // Try to get error message from raw JSON
//                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
//                       let message = json["message"] as? String {
//                        print("📋 Error message from server: \(message)")
//                        completion(.failure(NSError(domain: message, code: httpResponse.statusCode)))
//                    } else {
//                        completion(.failure(error))
//                    }
//                }
//            }
//        }.resume()
//    }
//    
//    // MARK: - Logout
//    func logout() {
//        print("🔐 Logging out...")
//        
//        // Clear saved data
//        UserDefaults.standard.removeObject(forKey: tokenKey)
//        UserDefaults.standard.removeObject(forKey: userKey)
//        
//        // Update state
//        DispatchQueue.main.async {
//            self.isAuthenticated = false
//            self.currentUser = nil
//            self.authToken = nil
//        }
//        
//        print("✅ Logout complete")
//    }
//    
//    // MARK: - Helper Methods
//    private func saveAuthData(token: String, user: User) {
//        print("💾 Saving auth data...")
//        
//        UserDefaults.standard.set(token, forKey: tokenKey)
//        print("💾 Token saved: \(token.prefix(10))...")
//        
//        do {
//            let userData = try JSONEncoder().encode(user)
//            UserDefaults.standard.set(userData, forKey: userKey)
//            print("💾 User data saved for: \(user.email) (role: \(user.role))")
//        } catch {
//            print("❌ Failed to encode user data: \(error)")
//        }
//    }
//    
//    private func parseErrorMessage(from data: Data) -> String? {
//        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
//            return json["message"] as? String ?? json["error"] as? String
//        }
//        return nil
//    }
//}
//
//// MARK: - Response Models
//struct LoginResponse: Codable {
//    let success: Bool
//    let message: String
//    let data: LoginData
//    let timestamp: String
//}
//
//struct LoginData: Codable {
//    let user: User
//    let tokens: Tokens
//}
//
//struct SignupResponse: Codable {
//    let success: Bool
//    let message: String
//    let data: SignupData
//    let timestamp: String
//}
//
//struct SignupData: Codable {
//    let user: User
//    let tokens: Tokens
//}
//
//struct Tokens: Codable {
//    let accessToken: String
//    let refreshToken: String
//    let expiresIn: Int
//}
//
//struct User: Codable {
//    let id: String
//    let email: String
//    let role: String
//    let fullName: String
//    let phone: String
//    
//    enum CodingKeys: String, CodingKey {
//        case id = "_id"
//        case email, role, fullName, phone
//    }
//    
//    // Custom initializer for flexibility
//    init(id: String, email: String, role: String, fullName: String, phone: String) {
//        self.id = id
//        self.email = email
//        self.role = role
//        self.fullName = fullName
//        self.phone = phone
//    }
//}
//
//// MARK: - Extension for UserDefaults convenience
//extension UserDefaults {
//    func setCodable<T: Codable>(_ value: T, forKey key: String) {
//        if let data = try? JSONEncoder().encode(value) {
//            set(data, forKey: key)
//        }
//    }
//    
//    func codable<T: Codable>(forKey key: String) -> T? {
//        if let data = data(forKey: key) {
//            return try? JSONDecoder().decode(T.self, from: data)
//        }
//        return nil
//    }
//}


//
//  AuthManager.swift
//  Guardian Angel
//
//  Created by Oluwaseun Odueso on 29/12/2025.
//

import Foundation
import SwiftUI
internal import Combine

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var authToken: String?
    @Published var shouldNavigateToResponderDashboard = false
    @Published var shouldShowResponderDashboard = false
    
//    static let shared = AuthManager()
    
    private let tokenKey = "guardian_auth_token"
    private let userKey = "guardian_user_data"
    
    init() {
        print("🔐 AuthManager initializing...")
        print("🧠 AuthManager instance:", ObjectIdentifier(self))

        
        // Check for saved token on app launch
        if let token = UserDefaults.standard.string(forKey: tokenKey) {
            print("🔄 Found saved token: \(token.prefix(10))...")
            self.authToken = token
            self.isAuthenticated = true
            
            // Load saved user data
            if let userData = UserDefaults.standard.data(forKey: userKey) {
                print("🔄 Loading saved user data...")
                do {
                    let user = try JSONDecoder().decode(User.self, from: userData)
                    print("✅ Loaded saved user: \(user.email) (role: \(user.role))")
                    self.currentUser = user
                    
                    // Check if we should navigate to responder dashboard
                    if user.role == "respondent" {
                        self.shouldNavigateToResponderDashboard = true
                        print("🎯 Saved user is a respondent - will navigate to responder dashboard")
                    }
                } catch {
                    print("❌ Could not decode saved user data: \(error)")
                }
            } else {
                print("⚠️ No saved user data found")
            }
        } else {
            print("🔐 No saved token found - starting fresh")
        }
    }
    
    // MARK: - Login (Updated to include role parameter)
    func login(email: String, password: String, role: String = "user", completion: @escaping (Result<User, Error>) -> Void) {
        print("🔐 Login attempt for: \(email) as \(role)")
        
        let url = URL(string: "https://guardian-fwpg.onrender.com/api/v1/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        let body: [String: Any] = [
            "email": email.lowercased(),
            "password": password,
            "loginType": role  // Added role parameter
        ]
        
        print("📡 Login Request Body: \(body)")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            if let jsonString = String(data: request.httpBody!, encoding: .utf8) {
                print("📄 JSON Being Sent: \(jsonString)")
            }
        } catch {
            print("❌ JSON Serialization Error: \(error)")
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Network Error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ No HTTP Response")
                    completion(.failure(NSError(domain: "Invalid server response", code: 0)))
                    return
                }
                
                print("📊 Login Status Code: \(httpResponse.statusCode)")
                
                guard let data = data else {
                    print("❌ No response data")
                    completion(.failure(NSError(domain: "No response data", code: httpResponse.statusCode)))
                    return
                }
                
                // Print raw response for debugging
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📄 Raw Login Response: \(responseString)")
                }
                
                // Try to decode the response
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    let apiResponse = try decoder.decode(LoginResponse.self, from: data)
                    print("✅ Login API Response: \(apiResponse.message)")
                    
                    if apiResponse.success {
                        // Save token and user data
                        let token = apiResponse.data.tokens.accessToken
                        let user = apiResponse.data.user
                        
                        self.saveAuthData(token: token, user: user)
                        
                        // Update state
                        self.authToken = token
                        self.currentUser = user
                        self.isAuthenticated = true
                        
                        // Check if user is a respondent
                        if user.role == "respondent" {
                            self.shouldNavigateToResponderDashboard = true
                            print("🎯 User is a respondent - will navigate to responder dashboard")
                        } else {
                            self.shouldNavigateToResponderDashboard = false
                        }
                        
                        print("✅ Login successful! Token: \(token.prefix(10))..., User: \(user.email) as \(user.role)")
                        completion(.success(user))
                    } else {
                        print("❌ Login failed: \(apiResponse.message)")
                        completion(.failure(NSError(domain: apiResponse.message, code: httpResponse.statusCode)))
                    }
                } catch {
                    print("❌ Decoding Error: \(error)")
                    print("Error details: \(error.localizedDescription)")
                    
                    // Try to get error message from raw JSON
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let message = json["message"] as? String {
                        print("📋 Error message from server: \(message)")
                        completion(.failure(NSError(domain: message, code: httpResponse.statusCode)))
                    } else {
                        completion(.failure(error))
                    }
                }
            }
        }.resume()
    }
    
    // MARK: - Signup (Updated to include role parameter)
    func signup(email: String, fullName: String, phone: String, password: String, role: String = "user", completion: @escaping (Result<User, Error>) -> Void) {
        print("🔐 Signup attempt for: \(email) as \(role)")
        
        let url = URL(string: "https://guardian-fwpg.onrender.com/api/v1/auth/signup")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        let body: [String: Any] = [
            "email": email,
            "fullName": fullName,
            "phone": phone,
            "password": password,
            "role": role  // Added role parameter
        ]
        
        print("📡 Signup Request Body: \(body)")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            if let jsonString = String(data: request.httpBody!, encoding: .utf8) {
                print("📄 JSON Being Sent: \(jsonString)")
            }
        } catch {
            print("❌ JSON Serialization Error: \(error)")
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Network Error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ No HTTP Response")
                    completion(.failure(NSError(domain: "Invalid server response", code: 0)))
                    return
                }
                
                print("📊 Signup Status Code: \(httpResponse.statusCode)")
                
                guard let data = data else {
                    print("❌ No response data")
                    completion(.failure(NSError(domain: "No response data", code: httpResponse.statusCode)))
                    return
                }
                
                // Print raw response for debugging
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📄 Raw Signup Response: \(responseString)")
                }
                
                // Try to decode the response
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    let apiResponse = try decoder.decode(SignupResponse.self, from: data)
                    print("✅ Signup API Response: \(apiResponse.message)")
                    
                    if apiResponse.success {
                        // Save token and user data
                        let token = apiResponse.data.tokens.accessToken
                        let user = apiResponse.data.user
                        
                        self.saveAuthData(token: token, user: user)
                        
                        // Update state
                        self.authToken = token
                        self.currentUser = user
                        self.isAuthenticated = true
                        
                        // Check if user signed up as a respondent
                        if user.role == "respondent" {
                            self.shouldNavigateToResponderDashboard = true
                            print("🎯 User signed up as respondent - will navigate to responder dashboard")
                        } else {
                            self.shouldNavigateToResponderDashboard = false
                        }
                        
                        print("✅ Signup successful! Token: \(token.prefix(10))..., User: \(user.email) as \(user.role)")
                        completion(.success(user))
                    } else {
                        print("❌ Signup failed: \(apiResponse.message)")
                        completion(.failure(NSError(domain: apiResponse.message, code: httpResponse.statusCode)))
                    }
                } catch {
                    print("❌ Decoding Error: \(error)")
                    print("Error details: \(error.localizedDescription)")
                    
                    // Try to get error message from raw JSON
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let message = json["message"] as? String {
                        print("📋 Error message from server: \(message)")
                        completion(.failure(NSError(domain: message, code: httpResponse.statusCode)))
                    } else {
                        completion(.failure(error))
                    }
                }
            }
        }.resume()
    }
    
    // MARK: - Update User Role
    func updateUserRole(to role: String) {
//        guard var currentUser = currentUser else { return }
//        
//        // Create updated user with new role
//        let updatedUser = User(
//            id: currentUser.id,
//            email: currentUser.email,
//            role: role,
//            fullName: currentUser.fullName,
//            phone: currentUser.phone
//        )
//        
//        // Update current user
//        self.currentUser = updatedUser
//        
//        // Save to UserDefaults
//        saveAuthData(token: authToken ?? "", user: updatedUser)
//        
//        // Update navigation state if becoming respondent
//        if role == "respondent" {
//            shouldNavigateToResponderDashboard = true
//            print("🔄 Updated user role to respondent - will navigate to responder dashboard")
//        } else {
//            shouldNavigateToResponderDashboard = false
//        }
        DispatchQueue.main.async {
            guard let currentUser = self.currentUser else { return }
            
            print("🔄 Updating user role from '\(currentUser.role)' to '\(role)'")
            
            // Create updated user with new role
            let updatedUser = User(
                id: currentUser.id,
                email: currentUser.email,
                role: role,
                fullName: currentUser.fullName,
                phone: currentUser.phone
            )
            
            // Update current user
            self.currentUser = updatedUser
            self.isAuthenticated = true
            
            // Save to UserDefaults
            self.saveAuthData(token: self.authToken ?? "", user: updatedUser)
            
            // Update navigation state
            if role == "respondent" {
                self.shouldNavigateToResponderDashboard = true
                print("✅ User marked as respondent - navigation flag set")
                print("🎯 User role updated to respondent - shouldNavigateToResponderDashboard set to true")
            } else {
                self.shouldNavigateToResponderDashboard = false
            }
            
            self.objectWillChange.send()
            
            // Send notification for navigation
//            NotificationCenter.default.post(
//                name: NSNotification.Name("UserRoleUpdated"),
//                object: nil,
//                userInfo: ["role": role]
//            )
        }
    }
    
    // MARK: - Logout
    func logout() {
        print("🔐 Logging out...")
        
        // Clear saved data
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userKey)
        
        // Update state
        DispatchQueue.main.async {
            self.isAuthenticated = false
            self.currentUser = nil
            self.authToken = nil
            self.shouldNavigateToResponderDashboard = false
        }
        
        print("✅ Logout complete")
    }
    
    // MARK: - Helper Methods
    private func saveAuthData(token: String, user: User) {
        print("💾 Saving auth data...")
        
        UserDefaults.standard.set(token, forKey: tokenKey)
        print("💾 Token saved: \(token.prefix(10))...")
        
        do {
            let userData = try JSONEncoder().encode(user)
            UserDefaults.standard.set(userData, forKey: userKey)
            print("💾 User data saved for: \(user.email) (role: \(user.role))")
        } catch {
            print("❌ Failed to encode user data: \(error)")
        }
    }
    
    func saveResponderToken(_ token: String) {
        print("💾 Saving responder token: \(token.prefix(20))...")
        
        // Save to UserDefaults
        UserDefaults.standard.set(token, forKey: "responderToken")
        UserDefaults.standard.synchronize()
        
        // Update the current auth token with the responder token
        // This might be what you need for the dashboard
        self.authToken = token
        
        // You might want to keep both tokens separate
        // So let's also save the original user token if needed
        if let originalToken = UserDefaults.standard.string(forKey: "originalUserToken") {
            // Keep original token as backup
        } else if let currentToken = self.authToken {
            // Save current token as original before replacing
            UserDefaults.standard.set(currentToken, forKey: "originalUserToken")
        }
    }
    
    // Optional: Method to get original user token if needed
    func getOriginalUserToken() -> String? {
        return UserDefaults.standard.string(forKey: "originalUserToken")
    }
    
    // Optional: Method to restore original token if needed
    func restoreOriginalToken() {
        if let originalToken = UserDefaults.standard.string(forKey: "originalUserToken") {
            self.authToken = originalToken
            print("🔄 Restored original user token")
        }
    }
    
    // MARK: - Navigation State Management
    func resetNavigationState() {
        shouldNavigateToResponderDashboard = false
    }
    
    func markAsResponder() {
        print("🔄 Marking user as responder...")
        updateUserRole(to: "respondent")
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: NSNotification.Name("ResponderRegistrationSuccess"),
                object: nil
            )
            print("📢 Posted ResponderRegistrationSuccess notification")
        }
    }
    
    var isResponder: Bool {
        return currentUser?.role == "respondent"
    }
    
    private func parseErrorMessage(from data: Data) -> String? {
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return json["message"] as? String ?? json["error"] as? String
        }
        return nil
    }
}

// MARK: - Response Models
struct LoginResponse: Codable {
    let success: Bool
    let message: String
    let data: LoginData
    let timestamp: String
}

struct LoginData: Codable {
    let user: User
    let tokens: Tokens
}

struct SignupResponse: Codable {
    let success: Bool
    let message: String
    let data: SignupData
    let timestamp: String
}

struct SignupData: Codable {
    let user: User
    let tokens: Tokens
}

struct Tokens: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
}

struct User: Codable {
    let id: String
    let email: String
    let role: String
    let fullName: String
    let phone: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case email, role, fullName, phone
    }
    
    // Custom initializer for flexibility
    init(id: String, email: String, role: String, fullName: String, phone: String) {
        self.id = id
        self.email = email
        self.role = role
        self.fullName = fullName
        self.phone = phone
    }
}

// MARK: - Extension for UserDefaults convenience
extension UserDefaults {
    func setCodable<T: Codable>(_ value: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            set(data, forKey: key)
        }
    }
    
    func codable<T: Codable>(forKey key: String) -> T? {
        if let data = data(forKey: key) {
            return try? JSONDecoder().decode(T.self, from: data)
        }
        return nil
    }
}
