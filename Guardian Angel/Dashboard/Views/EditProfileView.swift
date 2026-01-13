//
//  EditProfileView.swift
//
//  Created by Oluwaseun Odueso on 01/01/2026.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode

    // MARK: - Editable State (passed from parent)
    @Binding var userProfile: UserProfile?  // Changed to Binding to update parent
    @State var fullName: String
    @State var phoneNumber: String
    @State var location: String
    @State var bloodType: String
    @State var allergies: String
    @State var conditions: String

    @ObservedObject private var authManager = AuthManager.shared
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    @State private var successMessage = ""

    // MARK: - Profile Image
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - FIXED HEADER
            VStack(spacing: 20) {
                // Title + Back
                VStack(spacing: 8) {

                    HStack {
                        Text("Edit Profile")
                            .font(.custom("Poppins-SemiBold", size: 14))
                        Spacer()
                        
                        // Close Button
//                        Button(action: {
//                            presentationMode.wrappedValue.dismiss()
//                        }) {
//                            Image(systemName: "xmark")
//                                .resizable()
//                                .frame(width: 14, height: 14)
//                                .foregroundColor(.black)
//                        }
                    }
                    .padding(.horizontal, 16)

                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 0.5)
                        .padding(.horizontal, 16)

                    HStack {
//                        Button {
//                            presentationMode.wrappedValue.dismiss()
//                        } label: {
//                            HStack(spacing: 8) {
//                                Image("arrowLeft")
//                                    .resizable()
//                                    .frame(width: 13, height: 9.38)
//
//                                Text("Back")
//                                    .font(.custom("Poppins-Regular", size: 12))
//                                    .foregroundColor(.black)
//                            }
//                        }
//                        Spacer()
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.top, 16)
            .background(Color.white)

            // MARK: - SCROLLABLE FORM
            ScrollView {
                VStack(spacing: 24) {

                    // MARK: Profile Image Editor
                    VStack(spacing: 12) {

                        ZStack {
                            if let selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 90, height: 90)
                                    .clipShape(Circle())
                            } else {
                                ProfileAvatarView(
                                    fullName: fullName,
                                    imageName: nil,
                                    size: 90,
                                    showBorder: false
                                )
                            }
                        }

                        Button("Change Photo") {
                            showImagePicker = true
                        }
                        .font(.custom("Poppins-Regular", size: 12))
                        .foregroundColor(Color.Guardian.navy)
                    }
                    .padding(.top, 20)

                    // MARK: Personal Info
                    EditableCard(title: "Personal Information") {
                        EditableField(title: "Full Name", text: $fullName)
                        EditableField(title: "Phone Number", text: $phoneNumber)
                        EditableField(title: "Location", text: $location)
                    }

                    // MARK: Medical Info
                    EditableCard(title: "Medical Information") {
                        EditableField(title: "Blood Type", text: $bloodType, placeholder: "e.g., O+")
                        EditableField(title: "Allergies", text: $allergies, placeholder: "e.g., Peanuts, Penicillin")
                        EditableField(title: "Conditions", text: $conditions, placeholder: "e.g., Asthma, Diabetes")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 120)
            }

            // MARK: - SAVE BUTTON
            if isSaving {
                HStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.2)
                        .padding()
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: -2)
            } else {
                Button {
                    saveProfileChanges()
                } label: {
                    Text("Save Changes")
                        .font(.custom("Poppins-SemiBold", size: 14))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.Guardian.navy)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: -2)
            }
        }
        .background(Color.white)
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .alert("Success", isPresented: $showSuccess) {
            Button("OK", role: .cancel) {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text(successMessage)
        }
    }
    
    // MARK: - Save Profile Method
    private func saveProfileChanges() {
        guard let token = authManager.authToken else {
            errorMessage = "Please login to save profile changes"
            showError = true
            return
        }
        
        isSaving = true
        
        // Updated to use the correct endpoint
        let urlString = "https://guardian-fwpg.onrender.com/api/v1/auth/profile"
        print("🌐 Updating profile at: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            isSaving = false
            errorMessage = "Invalid server URL"
            showError = true
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.httpMethod = "PUT"  // Changed from PATCH to PUT
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Prepare request body matching the API specification
        let requestBody: [String: Any] = [
            "fullName": fullName,
            "phone": phoneNumber,
            "medicalInfo": [
                "bloodType": bloodType.isEmpty ? nil : bloodType,
//                "bloodType": bloodType.isEmpty ? NSNull() : bloodType,
                "allergies": parseCommaSeparated(allergies),
                "conditions": parseCommaSeparated(conditions)
            ]
        ]
        
        print("📤 Request body: \(requestBody)")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            isSaving = false
            errorMessage = "Failed to prepare profile data"
            showError = true
            print("❌ JSON Serialization error: \(error)")
            return
        }
        
        print("🔐 Authorization: Bearer \(token.prefix(20))...")
        print("📤 Sending profile update request...")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isSaving = false
                
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    self.showError = true
                    print("❌ Profile update API error:", error.localizedDescription)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Profile update HTTP Status: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 401 {
                        self.errorMessage = "Session expired. Please login again."
                        self.showError = true
                        print("❌ 401 Unauthorized - Token may be expired")
                        return
                    }
                }
                
                guard let data = data else {
                    self.errorMessage = "No response from server"
                    self.showError = true
                    print("❌ No data received from profile update")
                    return
                }
                
                // Print raw response for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📦 Profile update response: \(jsonString)")
                }
                
                // Parse response
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(ProfileResponse.self, from: data)
                    
                    if response.success {
                        // Update the parent's userProfile with new data
                        self.userProfile = response.data.toUserProfile()
                        
                        self.successMessage = response.message
                        self.showSuccess = true
                        print("✅ Profile updated successfully")
                    } else {
                        self.errorMessage = response.message
                        self.showError = true
                        print("❌ Failed to update profile: \(response.message)")
                    }
                } catch let decodingError as DecodingError {
                    self.errorMessage = "Failed to parse server response"
                    self.showError = true
                    print("❌ JSON parsing error: \(decodingError)")
                    
                    // Try to parse manually for debugging
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        print("📋 Manual parse attempt: \(json)")
                        if let message = json["message"] as? String {
                            self.errorMessage = message
                        }
                    }
                } catch {
                    self.errorMessage = "Unexpected error: \(error.localizedDescription)"
                    self.showError = true
                    print("❌ Unknown error:", error)
                }
            }
        }.resume()
    }
    
    private func parseCommaSeparated(_ text: String) -> [String] {
        if text.isEmpty {
            return []
        }
        return text.components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}

struct EditableCard<Content: View>: View {

    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.custom("Poppins-SemiBold", size: 13))

            content
        }
        .padding(16)
        .background(Color.gray.opacity(0.12))
        .cornerRadius(8)
    }
}

struct EditableField: View {

    let title: String
    @Binding var text: String
    var placeholder: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.custom("Poppins-Regular", size: 11))
                .foregroundColor(.gray)

            TextField(placeholder, text: $text)
                .font(.custom("Poppins-Regular", size: 13))
                .padding(10)
                .background(Color.white)
                .cornerRadius(6)
        }
    }
}
