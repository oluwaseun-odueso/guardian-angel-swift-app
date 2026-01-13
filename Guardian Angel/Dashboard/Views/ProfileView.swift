
import SwiftUI

// MARK: - Models for API Response
struct MedicalInfo: Decodable {
    let bloodType: String?
    let allergies: [String]
    let conditions: [String]
}

struct UserProfile: Decodable {
    let fullName: String
    let phone: String
    let email: String
    let medicalInfo: MedicalInfo
    
    // Get formatted address from trusted locations
    var formattedAddress: String {
        // We'll use the first trusted location's address, or a default
        return "Hanley Park, Stoke-on-Trent, Staffordshire, UK" // Default for now
    }
}

struct ProfileResponse: Decodable {
    let success: Bool
    let message: String
    let data: UserProfileData
    let timestamp: String
}

struct UserProfileData: Decodable {
    let medicalInfo: MedicalInfo
    let settings: UserSettings
    let deviceInfo: DeviceInfo
    let _id: String
    let email: String
    let role: String
    let lastName: String?
    let phone: String
    let isActive: Bool
    let emergencyContacts: [EmergencyContactData]
    let createdAt: String
    let updatedAt: String
    let __v: Int
    let fullName: String
    
    // Helper to convert to UserProfile
    func toUserProfile() -> UserProfile {
        return UserProfile(
            fullName: fullName,
            phone: phone,
            email: email,
            medicalInfo: medicalInfo
        )
    }
}

struct UserSettings: Decodable {
    let alertPreferences: AlertPreferences
    let enableFallDetection: Bool
    let trustedLocations: [TrustedLocationData]
}

struct AlertPreferences: Decodable {
    let sms: Bool
    let push: Bool
    let email: Bool
}

struct TrustedLocationData: Decodable {
    let address: AddressData
    let name: String
}

struct AddressData: Decodable {
    let formatted: String
}

struct DeviceInfo: Decodable {
    let batteryHealth: String
}

struct EmergencyContactData: Decodable {
    let name: String
    let phone: String
    let relationship: String
    let _id: String
}

struct ProfileView: View {
    @ObservedObject private var authManager = AuthManager.shared
    @State private var userProfile: UserProfile?
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showingEditProfile = false
    @State private var showingResponderRegistration = false
    
//    @Environment(\.presentationMode) var presentationMode

    // Backend image (nil means no image)
    let profileImage: String? = nil

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - FIXED HEADER
            VStack(spacing: 20) {

                // MARK: Panic Alert + Notification
                HStack(spacing: 12) {

                    HStack(spacing: 12) {
                        Image("alertButton")
                            .resizable()
                            .frame(width: 28, height: 28)

                        Text("Panic Alert")
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(10)

                    Image("notification")
                        .resizable()
                        .frame(width: 14.76, height: 19.09)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 16)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(10)
                }
                .padding(.horizontal, 16)

                // MARK: Profile Header
                VStack(spacing: 8) {

                    HStack(spacing: 8) {
                        Image("profile")
                            .resizable()
                            .frame(width: 14, height: 16)
                            .padding(.horizontal, 10)

                        if let userProfile = userProfile {
                            Text(userProfile.fullName)
                                .font(.custom("Poppins-SemiBold", size: 13))
                        } else {
                            Text("Profile")
                                .font(.custom("Poppins-SemiBold", size: 13))
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 16)

                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 0.5)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.top, 16)
            .background(Color.white)

            // MARK: - SCROLLABLE CONTENT
            if isLoading {
                VStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding()
                    Text("Loading profile...")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                }
            } else if let userProfile = userProfile {
                ScrollView {
                    VStack(spacing: 24) {

                        // MARK: Profile Card
                        HStack(spacing: 16) {

                            ProfileAvatarView(
                                fullName: userProfile.fullName,
                                imageName: profileImage,
                                size: 72,
                                showBorder: false
                            )
                            .padding(.horizontal, 20)

                            VStack(alignment: .leading, spacing: 6) {
                                Text(userProfile.fullName)
                                    .font(.custom("Poppins-SemiBold", size: 13))

                                Text(userProfile.formattedAddress)
                                    .font(.custom("Poppins-Regular", size: 10))

                                Text(userProfile.phone)
                                    .font(.custom("Poppins-Regular", size: 10))
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 16)

                        Divider()
                            .background(Color.gray.opacity(0.1))
                            .padding(.horizontal, 16)

                        // MARK: Edit + Settings Buttons
                        HStack(spacing: 16) {

                            Button {
                                showingEditProfile = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image("editProfile")
                                        .resizable()
                                        .frame(width: 16, height: 16)

                                    Text("Edit Profile")
                                        .font(.custom("Poppins-Regular", size: 11.5))
                                        .foregroundColor(Color.black)
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 12)
                                .background(Color.gray.opacity(0.15))
                                .cornerRadius(5)
                            }

                            Button {
                                showingResponderRegistration = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image("addContact")
                                        .resizable()
                                        .frame(width: 16, height: 16)

                                    Text("Be a Responder")
                                        .font(.custom("Poppins-Regular", size: 11.5))
                                        .foregroundColor(Color.black)
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 12)
                                .background(Color.gray.opacity(0.15))
                                .cornerRadius(5)
                                
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 16)

                        // MARK: Medical Info
                        MedicalInfoCard(
                            bloodType: userProfile.medicalInfo.bloodType ?? "Not specified",
                            allergies: formatArray(userProfile.medicalInfo.allergies),
                            conditions: formatArray(userProfile.medicalInfo.conditions)
                        )
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 20)
                }
            } else {
                VStack(spacing: 20) {
                    Spacer()
                    Image(systemName: "person.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("Profile Not Found")
                        .font(.custom("Poppins-SemiBold", size: 18))
                        .foregroundColor(.black)
                    Text("Unable to load profile information.")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
        }
        .background(Color.white)
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .onAppear {
            fetchProfile()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showingEditProfile) {
            if let userProfile = userProfile {
                EditProfileView(
                    userProfile: $userProfile,  // Pass binding to update parent
                    fullName: userProfile.fullName,
                    phoneNumber: userProfile.phone,
                    location: userProfile.formattedAddress,
                    bloodType: userProfile.medicalInfo.bloodType ?? "",
                    allergies: formatArray(userProfile.medicalInfo.allergies),
                    conditions: formatArray(userProfile.medicalInfo.conditions)
                )
            }
        }
        .sheet(isPresented: $showingResponderRegistration) {
            NavigationView {
                ResponderRegistrationView()
            }
        }
    }
    
    // MARK: - API Methods
    
    private func fetchProfile() {
        guard let token = authManager.authToken else {
            errorMessage = "Please login to view profile"
            showError = true
            return
        }
        
        isLoading = true
        
        let urlString = "https://guardian-fwpg.onrender.com/api/v1/auth/profile"
        print("🌐 Fetching profile from: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            isLoading = false
            errorMessage = "Invalid server URL"
            showError = true
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("🔐 Authorization: Bearer \(token.prefix(20))...")
        print("📤 Sending profile request...")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    self.showError = true
                    print("❌ Profile API error:", error.localizedDescription)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Profile HTTP Status: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 401 {
                        self.errorMessage = "Session expired. Please login again."
                        self.showError = true
                        print("❌ 401 Unauthorized - Token may be expired")
                        return
                    }
                    
                    if httpResponse.statusCode != 200 {
                        self.errorMessage = "Server error (Code: \(httpResponse.statusCode))"
                        self.showError = true
                        return
                    }
                }
                
                guard let data = data else {
                    self.errorMessage = "No response from server"
                    self.showError = true
                    print("❌ No data received for profile")
                    return
                }
                
                // Print raw response for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📦 Profile response: \(jsonString.prefix(1000))...")
                }
                
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(ProfileResponse.self, from: data)
                    
                    if response.success {
                        print("✅ Profile retrieved successfully")
                        self.userProfile = response.data.toUserProfile()
                    } else {
                        self.errorMessage = response.message
                        self.showError = true
                        print("❌ API returned success=false: \(response.message)")
                    }
                    
                } catch let decodingError as DecodingError {
                    self.errorMessage = "Failed to parse server response"
                    self.showError = true
                    print("❌ JSON parsing error: \(decodingError)")
                    
                    // Try to parse manually for debugging
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        print("📋 Manual parse attempt: \(json.keys)")
                        if let message = json["message"] as? String {
                            print("📝 Message: \(message)")
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
    
    private func formatArray(_ array: [String]) -> String {
        if array.isEmpty {
            return "None"
        }
        return array.joined(separator: ", ")
    }
}

