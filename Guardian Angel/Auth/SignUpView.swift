//
//  SignUpView.swift
//  Guardian Angel
//
//  Created by Oluwaseun Odueso on 28/12/2025.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject private var authManager: AuthManager
    // REMOVE AppState completely
    
    @State private var email = ""
    @State private var fullName = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Top Image
                Image("signUpImage")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .clipped()
                
                VStack(spacing: 20) {
                    // Logo + App Name
                    HStack(spacing: 8) {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                        
                        Text("Guardian")
                            .font(.custom("Poppins-Bold", size: 22))
                            .foregroundColor(Color(hex: "000000"))
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Subtitle
                    Text("Join Guardian Angel – Your Safety Network")
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(Color(hex: "000000"))
                    
                    // Email Field
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Email")
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundColor(Color(hex: "000000"))
                        
                        TextField("johndoe@gmail.com", text: $email)
                            .foregroundColor(Color(hex: "#555555"))
                            .padding(15)
                            .background(Color(hex: "#F4F4F4"))
                            .cornerRadius(10)
                            .autocapitalization(.words)
                            .submitLabel(.next)
                    }
                    
                    // Full Name Field
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Full name")
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundColor(Color(hex: "000000"))
                        
                        TextField("John Doe", text: $fullName)
                            .foregroundColor(Color(hex: "555555"))
                            .padding(15)
                            .background(Color(hex: "F4F4F4"))
                            .cornerRadius(10)
                            .autocapitalization(.words)
                            .submitLabel(.next)
                    }
                    
                    // Phone Field
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Phone number")
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundColor(Color(hex: "000000"))
                        
                        TextField("+44 34---", text: $phone)
                            .foregroundColor(Color(hex: "555555"))
                            .padding(15)
                            .background(Color(hex: "F4F4F4"))
                            .cornerRadius(10)
                            .keyboardType(.phonePad)
                            .submitLabel(.next)
                    }
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Password")
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundColor(Color(hex: "000000"))
                        
                        SecureField("********", text: $password)
                            .foregroundColor(Color(hex: "555555"))
                            .padding(15)
                            .background(Color(hex: "F4F4F4"))
                            .cornerRadius(10)
                            .submitLabel(.done)
                    }
                    
                    // Register Button
                    Button(action: register) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            HStack {
                                Text("Register")
                                    .font(.custom("Poppins-Medium", size: 16))
                                Image(systemName: "arrow.right")
                            }
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "002147"))
                    .cornerRadius(14)
                    .disabled(isLoading)
                    .opacity(isLoading ? 0.7 : 1)
                    .padding(.top, 12)
                    
                    // SIMPLE Login Button - just show LoginView directly
                    HStack {
                        Text("you already have an account? click on")
                            .font(.custom("Poppins-Regular", size: 13))
                        
                        // Use NavigationLink instead of custom navigation
                        NavigationLink(destination: LoginView()) {
                            Text("Login")
                                .font(.custom("Poppins-Bold", size: 13))
                                .foregroundColor(Color.Guardian.navy)
                        }
                    }
                    .padding(.top, 12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color(hex: "FFFFFF"))
        .navigationBarHidden(true)
        .alert("Registration Successful", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) {
                // Auto-navigate to main app when registration is successful
                // AuthManager will handle this via isAuthenticated
            }
        } message: {
            Text("Your account has been created successfully!")
        }
        .alert("Registration Failed", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func register() {
        // Hide keyboard
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        // Basic validation
        guard !email.isEmpty else {
            showError(message: "Please enter your email")
            return
        }
        
        guard email.contains("@") else {
            showError(message: "Please enter a valid email")
            return
        }
        
        guard !fullName.isEmpty else {
            showError(message: "Please enter your full name")
            return
        }
        
        guard !phone.isEmpty else {
            showError(message: "Please enter your phone number")
            return
        }
        
        guard !password.isEmpty else {
            showError(message: "Please enter your password")
            return
        }
        
        guard password.count >= 8 else {
            showError(message: "Password must be at least 8 characters")
            return
        }
        
        isLoading = true
        
        authManager.signup(email: email, fullName: fullName, phone: phone, password: password) { result in
            isLoading = false
            
            switch result {
            case .success(let user):
                print("✅ Registration successful for: \(user.email)")
                showSuccessAlert = true
            case .failure(let error):
                showError(message: error.localizedDescription)
            }
        }
    }
    
    private func showError(message: String) {
        alertMessage = message
        showErrorAlert = true
    }
}

// MARK: - Preview
struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .environmentObject(AuthManager.shared)
    }
}
