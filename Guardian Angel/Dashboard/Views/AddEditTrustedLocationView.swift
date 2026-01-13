//
//  AddEditTrustedLocationView.swift
//  Guardian Angel
//
//  Created by Oluwaseun Odueso on 30/12/2025.
//

import SwiftUI
import CoreLocation

struct AddressSuggestion: Identifiable {
    let id = UUID()
    let address: String
    let secondaryText: String?
}

struct AddEditTrustedLocationView: View {
    @Environment(\.presentationMode) var presentationMode
    let isEditing: Bool
    let existingLocation: TrustedLocation?
    var onSave: (() -> Void)? = nil
    
    @ObservedObject private var authManager = AuthManager.shared
    
    @State private var locationName: String = ""
    @State private var address: String = ""
    @State private var notes: String = ""
    @State private var isHome: Bool = false
    @State private var isWork: Bool = false
    @State private var suggestions: [AddressSuggestion] = []
    @State private var isLoading = false
    @State private var isSaving = false
    @State private var showCurrentLocationAlert = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    @State private var successMessage = ""
    
    @State private var locationManager = CLLocationManager()
    @State private var userLocation: CLLocation?
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            VStack(spacing: 20) {
                // MARK: - Add/Edit Header
                VStack(spacing: 8) {
                    // Title
                    HStack(spacing: 8) {
                        Image("locations")
                            .resizable()
                            .frame(width: 12, height: 14)
                            .padding(.horizontal, 10)
                        
                        Text(isEditing ? "Edit Location" : "Add Trusted Location")
                            .font(.custom("Poppins-SemiBold", size: 14))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        // Close Button
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .resizable()
                                .frame(width: 14, height: 14)
                                .foregroundColor(.black)
                        }
                        .padding(.trailing, 10)
                    }
                    .padding(.horizontal, 16)
                    
                    // Very thin divider line
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 0.5)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.top, 16)
            .background(Color.white)
            
            // MARK: - Form Content
            ScrollView {
                VStack(spacing: 24) {
                    // Location Name Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Location Name")
                            .font(.custom("Poppins-Medium", size: 14))
                            .foregroundColor(.black)
                        
                        TextField("e.g., Home, Work, School", text: $locationName)
                            .font(.custom("Poppins-Regular", size: 14))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    
                    // Address Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Address")
                            .font(.custom("Poppins-Medium", size: 14))
                            .foregroundColor(.black)
                        
                        TextField("Enter full address...", text: $address)
                            .font(.custom("Poppins-Regular", size: 14))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 16)
                    
                    // Notes Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes (Optional)")
                            .font(.custom("Poppins-Medium", size: 14))
                            .foregroundColor(.black)
                        
                        TextField("Additional information...", text: $notes)
                            .font(.custom("Poppins-Regular", size: 14))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 16)
                    
                    // Location Type Checkboxes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Location Type")
                            .font(.custom("Poppins-Medium", size: 14))
                            .foregroundColor(.black)
                        
                        HStack(spacing: 20) {
                            Button(action: {
                                isHome.toggle()
                                if isHome { isWork = false }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: isHome ? "checkmark.square.fill" : "square")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(isHome ? Color(hex: "002147") : .gray)
                                    
                                    Text("Home")
                                        .font(.custom("Poppins-Regular", size: 14))
                                        .foregroundColor(.black)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: {
                                isWork.toggle()
                                if isWork { isHome = false }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: isWork ? "checkmark.square.fill" : "square")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(isWork ? Color(hex: "002147") : .gray)
                                    
                                    Text("Work")
                                        .font(.custom("Poppins-Regular", size: 14))
                                        .foregroundColor(.black)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer()
                }
                .padding(.bottom, 20)
            }
            .background(Color.white)
            
            // MARK: - Save Button
            if isSaving {
                HStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.2)
                        .padding()
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
                .padding(.top, 20)
            } else {
                Button(action: {
                    saveLocation()
                }) {
                    Text(isEditing ? "Save Changes" : "Add Location")
                        .font(.custom("Poppins-SemiBold", size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "002147"))
                        .cornerRadius(10)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
                .padding(.top, 20)
                .disabled(locationName.isEmpty || address.isEmpty)
                .opacity((locationName.isEmpty || address.isEmpty) ? 0.6 : 1)
            }
            
            // MARK: - Bottom Navigation (Fixed)
            AddEditTabBar(
                userName: authManager.currentUser?.fullName ?? "Seun Odueso",
                profileImage: "profileImage"
            )
        }
        .background(Color.white)
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            if let existing = existingLocation {
                locationName = existing.name
                address = existing.address
                notes = existing.notes ?? ""
                isHome = existing.isHome
                isWork = existing.isWork
            }
        }
        .alert(isPresented: $showCurrentLocationAlert) {
            Alert(
                title: Text("Location Access Required"),
                message: Text("Please enable location access in Settings to use your current location."),
                primaryButton: .default(Text("Settings")) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .alert("Success", isPresented: $showSuccess) {
            Button("OK", role: .cancel) {
                presentationMode.wrappedValue.dismiss()
                onSave?()
            }
        } message: {
            Text(successMessage)
        }
    }
    
    // MARK: - Methods
    
    private func saveLocation() {
        guard !locationName.isEmpty, !address.isEmpty else {
            errorMessage = "Please fill in all required fields"
            showError = true
            return
        }
        
        guard let token = authManager.authToken else {
            errorMessage = "Please login to save trusted locations"
            showError = true
            return
        }
        
        isSaving = true
        
        let urlString: String
        let httpMethod: String
        
        if isEditing, let locationId = existingLocation?.id {
            urlString = "https://guardian-fwpg.onrender.com/api/v1/trusted-location/\(locationId)"
            httpMethod = "PUT"
        } else {
            urlString = "https://guardian-fwpg.onrender.com/api/v1/trusted-location"
            httpMethod = "POST"
        }
        
        print("🌐 \(isEditing ? "Updating" : "Adding") trusted location at: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            isSaving = false
            errorMessage = "Invalid server URL"
            showError = true
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.httpMethod = httpMethod
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Prepare request body
        let requestBody: [String: Any] = [
            "name": locationName,
            "address": address,
            "isHome": isHome,
            "isWork": isWork,
            "notes": notes.isEmpty ? nil : notes
        ].compactMapValues { $0 }
        
        print("📤 Request body: \(requestBody)")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            isSaving = false
            errorMessage = "Failed to prepare location data"
            showError = true
            print("❌ JSON Serialization error: \(error)")
            return
        }
        
        print("🔐 Authorization: Bearer \(token.prefix(20))...")
        print("📤 Sending \(isEditing ? "update" : "add") location request...")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isSaving = false
                
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    self.showError = true
                    print("❌ \(self.isEditing ? "Update" : "Add") location API error:", error.localizedDescription)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 \(self.isEditing ? "Update" : "Add") location HTTP Status: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 401 {
                        self.errorMessage = "Session expired. Please login again."
                        self.showError = true
                        print("❌ 401 Unauthorized - Token may be expired")
                        return
                    }
                    
                    if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
                        print("⚠️ Server returned \(httpResponse.statusCode)")
                    }
                }
                
                guard let data = data else {
                    self.errorMessage = "No response from server"
                    self.showError = true
                    print("❌ No data received for \(self.isEditing ? "update" : "add") location")
                    return
                }
                
                // Print raw response for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📦 \(self.isEditing ? "Update" : "Add") location response: \(jsonString)")
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let success = json["success"] as? Bool, success {
                            if let message = json["message"] as? String {
                                self.successMessage = message
                                self.showSuccess = true
                                print("✅ \(self.isEditing ? "Updated" : "Added") location successfully: \(message)")
                            } else {
                                self.successMessage = self.isEditing ? "Location updated successfully" : "Location added successfully"
                                self.showSuccess = true
                            }
                        } else {
                            if let message = json["message"] as? String {
                                self.errorMessage = message
                                self.showError = true
                                print("❌ Failed to \(self.isEditing ? "update" : "add") location: \(message)")
                            } else if let errorMsg = json["error"] as? String {
                                self.errorMessage = errorMsg
                                self.showError = true
                            } else {
                                self.errorMessage = "Failed to \(self.isEditing ? "update" : "add") location"
                                self.showError = true
                            }
                        }
                    } else {
                        self.errorMessage = "Invalid response from server"
                        self.showError = true
                    }
                } catch {
                    self.errorMessage = "Failed to parse server response"
                    self.showError = true
                    print("❌ JSON parsing error: \(error)")
                }
            }
        }.resume()
    }
}

// MARK: - Tab Bar for Add/Edit View (Trusted Locations Active)
struct AddEditTabBar: View {
    let userName: String
    let profileImage: String
    
    var body: some View {
        HStack(spacing: 0) {
            // Home Tab (Inactive)
            TabBarItemView(
                icon: "home",
                title: "Home"
            )
            
            // Emergency Contacts Tab (Inactive)
            TabBarItemView(
                icon: "emergencyContacts",
                title: "Emergency Contacts"
            )
            
            // Incident Logs Tab (Inactive)
            TabBarItemView(
                icon: "incidentLogs",
                title: "Incident Logs"
            )
            
            // Trusted Locations Tab (Active)
            TabBarItemView(
                icon: "clickedLocations",
                title: "Trusted Locations",
                active: true
            )
            
            // Profile Tab
            ProfileTabItem(
                userName: userName,
                profileImage: profileImage
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.white)
        .shadow(
            color: Color.black.opacity(0.08),
            radius: 1,
            x: 0,
            y: -1
        )
    }
}

// MARK: - Preview
struct AddEditTrustedLocationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AddEditTrustedLocationView(isEditing: false, existingLocation: nil)
            
            AddEditTrustedLocationView(
                isEditing: true,
                existingLocation: TrustedLocation(
                    id: "1",
                    name: "Home Address",
                    address: "Hanley Park, Stoke-on-trent, Staffordshire, UK",
                    staticMap: "https://maps.googleapis.com/maps/api/staticmap?center=52.9939342,-2.1901442&zoom=15&size=300x200&key=AIzaSyBkqkEKXvVa0V2TL-dmdEjvNCSM7o6YFBU&markers=color:green|label:🏠|52.9939342,-2.1901442",
                    radius: 100,
                    isHome: true,
                    isWork: false,
                    notes: "My home address",
                    createdAt: "2026-01-07T13:55:17.140Z"
                )
            )
        }
    }
}
