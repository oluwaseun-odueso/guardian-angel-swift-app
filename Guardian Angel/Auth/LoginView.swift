//
//  LoginView.swift
//  Guardian Angel
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authManager: AuthManager
    
    @State private var email = ""
    @State private var password = ""
    @State private var loginType: String = "Patient"  // Default to Patient
    @State private var isLoading = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    
    // Login type options
    private let loginTypes = ["Patient", "Respondent"]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Top Image
                Image("loginImage")
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

                    // Subtitle
                    Text("It's nice having you back on Guardian Angel")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(Color(hex: "000000"))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // MARK: - Login Type Dropdown
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Login as")
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundColor(Color(hex: "000000"))

                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: "F4F4F4"))
                                .frame(height: 50)
                            
                            Menu {
                                ForEach(loginTypes, id: \.self) { type in
                                    Button(action: {
                                        loginType = type
                                    }) {
                                        HStack {
                                            Text(type)
                                            if loginType == type {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(loginType)
                                        .font(.custom("Poppins-Regular", size: 14))
                                        .foregroundColor(Color(hex: "000000"))
                                        .padding(.leading, 15)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(Color(hex: "666666"))
                                        .padding(.trailing, 15)
                                }
                            }
                        }
                    }

                    // MARK: - Email
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Email")
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundColor(Color(hex: "000000"))

                        TextField("johndoe@gmail.com", text: $email)
                            .padding(15)
                            .background(Color(hex: "F4F4F4"))
                            .cornerRadius(10)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }

                    // MARK: - Password
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Password")
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundColor(Color(hex: "000000"))

                        SecureField("********", text: $password)
                            .padding(15)
                            .background(Color(hex: "F4F4F4"))
                            .cornerRadius(10)
                    }

                    // Login Button
                    Button(action: login) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            HStack {
                                Text("Login")
                                    .font(.custom("Poppins-Medium", size: 16))
                                Image(systemName: "arrow.right")
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.Guardian.navy)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(isLoading)
                    .opacity(isLoading ? 0.7 : 1)

                    // SIMPLE Signup link
                    HStack {
                        Text("You don't have an account?")
                            .font(.custom("Poppins-Regular", size: 13))

                        NavigationLink(destination: SignUpView()) {
                            Text("Create account")
                                .font(.custom("Poppins-Bold", size: 13))
                                .foregroundColor(Color.Guardian.navy)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color.Guardian.white)
        .navigationBarHidden(true)
        .alert("Login Successful", isPresented: $showSuccessAlert) {
            Button("OK") {
                // Auto-navigate to main app via authManager.isAuthenticated
            }
        } message: {
            Text("Welcome back!")
        }
        .alert("Login Failed", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    private func login() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
        
        guard email.contains("@") else {
            showError("Enter a valid email")
            return
        }
        
        guard !password.isEmpty else {
            showError("Enter your password")
            return
        }
        
        isLoading = true
        
        // Convert display type to backend role
        let role = loginType == "Patient" ? "user" : "respondent"
        
        authManager.login(email: email, password: password, role: role) { result in
            isLoading = false
            
            switch result {
            case .success(let user):
                print("✅ Login successful for: \(user.email) as \(user.role)")
                showSuccessAlert = true
            case .failure(let error):
                showError(error.localizedDescription)
            }
        }
    }

    private func showError(_ message: String) {
        alertMessage = message
        showErrorAlert = true
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthManager.shared)
    }
}
