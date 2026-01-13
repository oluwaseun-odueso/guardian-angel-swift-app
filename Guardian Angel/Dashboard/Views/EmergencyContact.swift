//
//  EmergencyContactsView.swift
//  Guardian Angel
//
//  Created by Oluwaseun Odueso on 29/12/2025.
//

import SwiftUI

struct EmergencyContact: Identifiable {
    let id: String
    let name: String
    let relationship: String
    let phone: String
    let profileImage: String?
    
    init(from contactData: [String: Any]) {
        self.id = contactData["_id"] as? String ?? UUID().uuidString
        self.name = contactData["name"] as? String ?? ""
        self.relationship = contactData["relationship"] as? String ?? "Contact"
        self.phone = contactData["phone"] as? String ?? ""
        self.profileImage = nil
    }
    
    // For mock data
    init(id: String, name: String, relationship: String, phone: String, profileImage: String? = nil) {
        self.id = id
        self.name = name
        self.relationship = relationship
        self.phone = phone
        self.profileImage = profileImage
    }
}

struct EmergencyContactsView: View {
    @State private var emergencyContacts: [EmergencyContact] = []
    @ObservedObject private var authManager = AuthManager.shared
    @EnvironmentObject private var navigationManager: NavigationManager
    @State private var isLoading = false
    
//    @Environment(\.presentationMode) var presentationMode
    @State private var showingAddContact = false
    @State private var showingEditContact = false
    @State private var showingDeleteAlert = false
    @State private var contactToEdit: EmergencyContact?
    @State private var contactToDelete: EmergencyContact?
    
    // Panic Alert States
    @StateObject private var locationManager = LocationManager()
    @State private var isLoadingPanicAlert = false
    @State private var showPanicAlertSuccess = false
    @State private var showPanicAlertError = false
    @State private var panicAlertSuccessMessage = ""
    @State private var panicAlertErrorMessage = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - FIXED HEADER (Does NOT scroll)
            VStack(spacing: 20) {
                // MARK: - Panic Alert & Notification Row
                HStack(spacing: 12) {
                    // Panic Alert Button - Connected to API
                    Button(action: {
                        sendPanicAlert()
                    }) {
                        HStack(spacing: 12) {
                            if isLoadingPanicAlert {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                    .scaleEffect(0.8)
                            } else {
                                Image("alertButton")
                                    .resizable()
                                    .frame(width: 28, height: 28)
                            }
                            
                            Text("Panic Alert")
                                .font(.custom("Poppins-Regular", size: 16))
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(10)
                    }
                    .disabled(isLoadingPanicAlert)
                    
                    // Notification Button
                    Button(action: {}) {
                        Image("notification")
                            .resizable()
                            .frame(width: 14.76, height: 19.09)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 16)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(10)
                }
                .padding(.horizontal, 16)
                
                // MARK: - Emergency Contacts Header
                VStack(spacing: 8) {
                    // Emergency Contacts icon and title WITH Plus icon on extreme right
                    HStack(spacing: 8) {
                        Image("emergencyContacts")
                            .resizable()
                            .frame(width: 14, height: 14)
                            .padding(.horizontal, 10)
                        
                        Text("Emergency Contacts")
                            .font(.custom("Poppins-SemiBold", size: 14))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        // Plus icon on extreme right (no "Add" text)
                        Button(action: {
                            showingAddContact = true
                        }) {
                            Image("plus")
                                .resizable()
                                .frame(width: 16, height: 16)
                                .foregroundColor(.black)
                                .padding(.horizontal, 10)
                        }
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
            
            // MARK: - SCROLLABLE EMERGENCY CONTACTS LIST
            if isLoading {
                VStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding()
                    Text("Loading emergency contacts...")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                }
            } else if emergencyContacts.isEmpty {
                VStack(spacing: 20) {
                    Spacer()
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No Emergency Contacts")
                        .font(.custom("Poppins-SemiBold", size: 18))
                        .foregroundColor(.black)
                    Text("Add your emergency contacts to reach them quickly during emergencies.")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(emergencyContacts) { contact in
                            EmergencyContactCard(
                                contact: contact,
                                onEdit: {
                                    contactToEdit = contact
                                    showingEditContact = true
                                },
                                onDelete: {
                                    contactToDelete = contact
                                    showingDeleteAlert = true
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                }
                .refreshable {
                    await fetchEmergencyContactsAsync()
                }
            }
            
            // MARK: - Bottom Navigation (Fixed)
//            EmergencyContactsTabBar(
//                userName: authManager.currentUser?.fullName ?? "Seun Odueso",
//                profileImage: "profileImage"
//            )
        }
        .background(Color.white)
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .onAppear {
            fetchEmergencyContacts()
            locationManager.requestLocation()
        }
        .onChange(of: locationManager.permissionDenied) { oldValue, denied in
            if denied {
                panicAlertErrorMessage = "Location permission is required to send panic alerts."
                showPanicAlertError = true
                print("❌ Location permission denied")
            }
        }
        .sheet(isPresented: $showingAddContact) {
            AddEditEmergencyContactView(
                isEditing: false,
                existingContact: nil,
                onSave: { newContact, _ in
                    // For adding, we don't need the contact ID
                    addEmergencyContact(newContact)
                }
            )
        }
        .sheet(isPresented: $showingEditContact) {
            if let contact = contactToEdit {
                AddEditEmergencyContactView(
                    isEditing: true,
                    existingContact: contact,
                    onSave: { updatedContact, _ in
                        // For editing, we already have contactToEdit with ID
                        updateEmergencyContact(updatedContact)
                    }
                )
            }
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete Contact"),
                message: Text("Are you sure you want to delete this emergency contact?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let contact = contactToDelete {
                        deleteContactFromAPI(contact)
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .alert("Panic Alert Sent", isPresented: $showPanicAlertSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(panicAlertSuccessMessage)
        }
        .alert("Error", isPresented: $showPanicAlertError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(panicAlertErrorMessage)
        }
    }
    
    // MARK: - API Methods
    
    private func fetchEmergencyContacts() {
        guard let token = authManager.authToken else {
            print("❌ No auth token available")
            return
        }
        
        isLoading = true
        
        let urlString = "https://guardian-fwpg.onrender.com/api/v1/auth/profile"
        print("🌐 Fetching emergency contacts from: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            isLoading = false
            print("❌ Invalid URL")
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
                    print("❌ Profile API error:", error.localizedDescription)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Profile HTTP Status: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 401 {
                        print("❌ 401 Unauthorized - Token may be expired")
                        return
                    }
                }
                
                guard let data = data else {
                    print("❌ No data received for profile")
                    return
                }
                
                // Print raw response for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📦 Profile response: \(jsonString.prefix(500))...")
                }
                
                do {
                    // Parse the response
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let success = json["success"] as? Bool, success {
                            if let dataDict = json["data"] as? [String: Any],
                               let emergencyContactsArray = dataDict["emergencyContacts"] as? [[String: Any]] {
                                
                                print("✅ Found \(emergencyContactsArray.count) emergency contacts")
                                
                                // Map API data to EmergencyContact objects
                                let contacts = emergencyContactsArray.map { contactData in
                                    return EmergencyContact(from: contactData)
                                }
                                
                                self.emergencyContacts = contacts
                            } else {
                                print("⚠️ No emergencyContacts field found in response")
                                // Clear contacts if none exist
                                self.emergencyContacts = []
                            }
                        } else {
                            if let message = json["message"] as? String {
                                print("❌ API returned success=false: \(message)")
                            }
                        }
                    }
                } catch {
                    print("❌ JSON parsing error: \(error)")
                }
            }
        }.resume()
    }
    
    // Async version for pull-to-refresh
    private func fetchEmergencyContactsAsync() async {
        await withCheckedContinuation { continuation in
            fetchEmergencyContacts()
            // Add a small delay to ensure the refresh indicator stays visible
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                continuation.resume()
            }
        }
    }
    
    private func addEmergencyContact(_ contactData: [String: Any]) {
        guard let token = authManager.authToken else {
            print("❌ No auth token available")
            return
        }
        
        let urlString = "https://guardian-fwpg.onrender.com/api/v1/user/emergency-contacts"
        print("🌐 Adding emergency contact to: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: contactData)
        } catch {
            print("❌ JSON Serialization error: \(error)")
            return
        }
        
        print("📤 Request body: \(contactData)")
        print("🔐 Authorization: Bearer \(token.prefix(20))...")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Add contact API error:", error.localizedDescription)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Add contact HTTP Status: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 401 {
                        print("❌ 401 Unauthorized - Token may be expired")
                        return
                    }
                }
                
                guard let data = data else {
                    print("❌ No data received for add contact")
                    return
                }
                
                // Print raw response for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📦 Add contact response: \(jsonString)")
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let success = json["success"] as? Bool, success {
                            print("✅ Contact added successfully")
                            // Refresh the contacts list
                            fetchEmergencyContacts()
                        } else {
                            if let message = json["message"] as? String {
                                print("❌ Failed to add contact: \(message)")
                            }
                        }
                    }
                } catch {
                    print("❌ JSON parsing error: \(error)")
                }
            }
        }.resume()
    }
    
    private func updateEmergencyContact(_ contactData: [String: Any]) {
        guard let token = authManager.authToken else {
            print("❌ No auth token available")
            return
        }
        
        guard let contactToEdit = contactToEdit else {
            print("❌ No contact selected for editing")
            return
        }
        
        let contactId = contactToEdit.id
        let urlString = "https://guardian-fwpg.onrender.com/api/v1/user/emergency-contacts/\(contactId)"
        print("🌐 Updating emergency contact at: \(urlString)")
        print("📝 Contact ID: \(contactId)")
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.httpMethod = "PATCH" // Using PUT for update
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: contactData)
        } catch {
            print("❌ JSON Serialization error: \(error)")
            return
        }
        
        print("📤 Request body: \(contactData)")
        print("🔐 Authorization: Bearer \(token.prefix(20))...")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Update contact API error:", error.localizedDescription)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Update contact HTTP Status: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 401 {
                        print("❌ 401 Unauthorized - Token may be expired")
                        return
                    }
                    
                    if httpResponse.statusCode == 404 {
                        print("❌ 404 Not Found - Contact ID \(contactId) not found")
                        return
                    }
                }
                
                guard let data = data else {
                    print("❌ No data received for update contact")
                    return
                }
                
                // Print raw response for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📦 Update contact response: \(jsonString)")
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let success = json["success"] as? Bool, success {
                            print("✅ Contact updated successfully")
                            if let message = json["message"] as? String {
                                print("📝 Message: \(message)")
                            }
                            // Refresh the contacts list
                            fetchEmergencyContacts()
                        } else {
                            if let message = json["message"] as? String {
                                print("❌ Failed to update contact: \(message)")
                            }
                        }
                    }
                } catch {
                    print("❌ JSON parsing error: \(error)")
                }
            }
        }.resume()
    }
    
    private func deleteContactFromAPI(_ contact: EmergencyContact) {
        guard let token = authManager.authToken else {
            print("❌ No auth token available")
            return
        }
        
        let contactId = contact.id
        let urlString = "https://guardian-fwpg.onrender.com/api/v1/user/emergency-contacts/\(contactId)"
        print("🌐 Deleting emergency contact at: \(urlString)")
        print("🗑️ Contact ID: \(contactId)")
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("🔐 Authorization: Bearer \(token.prefix(20))...")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Delete contact API error:", error.localizedDescription)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Delete contact HTTP Status: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 401 {
                        print("❌ 401 Unauthorized - Token may be expired")
                        return
                    }
                    
                    if httpResponse.statusCode == 404 {
                        print("❌ 404 Not Found - Contact ID \(contactId) not found")
                        // Still remove from local array since it doesn't exist on server
                        self.emergencyContacts.removeAll { $0.id == contact.id }
                        return
                    }
                }
                
                guard let data = data else {
                    print("❌ No data received for delete contact")
                    // Remove from local array anyway
                    self.emergencyContacts.removeAll { $0.id == contact.id }
                    return
                }
                
                // Print raw response for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📦 Delete contact response: \(jsonString)")
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let success = json["success"] as? Bool, success {
                            print("✅ Contact deleted successfully")
                            // Remove from local array
                            self.emergencyContacts.removeAll { $0.id == contact.id }
                        } else {
                            if let message = json["message"] as? String {
                                print("❌ Failed to delete contact: \(message)")
                                // Still remove from local array for better UX
                                self.emergencyContacts.removeAll { $0.id == contact.id }
                            }
                        }
                    }
                } catch {
                    print("❌ JSON parsing error: \(error)")
                    // Remove from local array anyway
                    self.emergencyContacts.removeAll { $0.id == contact.id }
                }
            }
        }.resume()
    }
    
    // MARK: - Panic Alert Handler
    private func sendPanicAlert() {
        print("🚨 PANIC ALERT triggered from Emergency Contacts View!")
        
        // Check if we have location
        guard let lat = locationManager.latitude,
              let lng = locationManager.longitude else {
            panicAlertErrorMessage = "Unable to get your location. Please ensure location services are enabled."
            showPanicAlertError = true
            return
        }
        
        // Check if we have authentication token
        guard let token = authManager.authToken else {
            panicAlertErrorMessage = "Please login to send panic alerts"
            showPanicAlertError = true
            return
        }
        
        isLoadingPanicAlert = true
        
        // Prepare request body
        let requestBody: [String: Any] = [
            "coordinates": [lat, lng],
            "accuracy": 15
        ]
        
        print("📍 Sending panic alert from location: \(lat), \(lng)")
        print("📤 Request body: \(requestBody)")
        
        // Make API call
        createPanicAlert(lat: lat, lng: lng, token: token, body: requestBody)
    }
    
    private func createPanicAlert(lat: Double, lng: Double, token: String, body: [String: Any]) {
        let urlString = "https://guardian-fwpg.onrender.com/api/v1/alert/panic"
        print("🌐 Panic alert URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            isLoadingPanicAlert = false
            panicAlertErrorMessage = "Invalid server URL"
            showPanicAlertError = true
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            isLoadingPanicAlert = false
            panicAlertErrorMessage = "Failed to prepare alert data"
            showPanicAlertError = true
            print("❌ JSON Serialization error: \(error)")
            return
        }
        
        print("🔐 Authorization: Bearer \(token.prefix(20))...")
        print("📤 Sending panic alert request...")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoadingPanicAlert = false
                
                if let error = error {
                    self.panicAlertErrorMessage = "Network error: \(error.localizedDescription)"
                    self.showPanicAlertError = true
                    print("❌ Panic alert API error:", error.localizedDescription)
                    return
                }
                
                // Check HTTP status code
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Panic alert HTTP Status: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 401 {
                        self.panicAlertErrorMessage = "Session expired. Please login again."
                        self.showPanicAlertError = true
                        print("❌ 401 Unauthorized - Token may be expired")
                        return
                    }
                    
                    if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
                        print("⚠️ Server returned \(httpResponse.statusCode)")
                    }
                }
                
                guard let data = data else {
                    self.panicAlertErrorMessage = "No response from server"
                    self.showPanicAlertError = true
                    print("❌ No data received for panic alert")
                    return
                }
                
                // Print raw response for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📦 Panic alert response: \(jsonString)")
                }
                
                // Parse the response
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let success = json["success"] as? Bool, success {
                        if let message = json["message"] as? String {
                            // Extract additional details if available
                            var successMsg = message
                            
                            if let data = json["data"] as? [String: Any] {
                                if let responder = data["assignedResponder"] as? [String: Any],
                                   let responderName = responder["name"] as? String,
                                   let estimatedTime = responder["estimatedTime"] as? String {
                                    successMsg += "\n\nResponder: \(responderName)\nETA: \(estimatedTime)"
                                }
                                
                                if let location = data["locationDetails"] as? [String: Any],
                                   let address = location["address"] as? String {
                                    successMsg += "\nAddress: \(address)"
                                }
                            }
                            
                            self.panicAlertSuccessMessage = successMsg
                            self.showPanicAlertSuccess = true
                        }
                    } else {
                        if let message = json["message"] as? String {
                            self.panicAlertErrorMessage = message
                            self.showPanicAlertError = true
                        } else if let errorMsg = json["error"] as? String {
                            self.panicAlertErrorMessage = errorMsg
                            self.showPanicAlertError = true
                        } else {
                            self.panicAlertErrorMessage = "Failed to send panic alert"
                            self.showPanicAlertError = true
                        }
                    }
                } else {
                    self.panicAlertErrorMessage = "Invalid response from server"
                    self.showPanicAlertError = true
                }
            }
        }.resume()
    }
}

// MARK: - Emergency Contact Card
struct EmergencyContactCard: View {
    let contact: EmergencyContact
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile Picture Circle
            if let profileImage = contact.profileImage, !profileImage.isEmpty {
                // For URLs, you'd need to use AsyncImage or a proper image loading library
                // For now, using placeholder
                Circle()
                    .fill(Color(hex: "002147").opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(contact.name.prefix(1).uppercased())
                            .font(.custom("Poppins-Medium", size: 18))
                            .foregroundColor(Color(hex: "002147"))
                    )
            } else {
                // Fallback with initials
                Circle()
                    .fill(Color(hex: "002147").opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(contact.name.prefix(1).uppercased())
                            .font(.custom("Poppins-Medium", size: 18))
                            .foregroundColor(Color(hex: "002147"))
                    )
            }
            
            // Name, Phone Number, and Relationship
            VStack(alignment: .leading, spacing: 2) {
                // Name
                Text(contact.name)
                    .font(.custom("Poppins-Medium", size: 16))
                    .foregroundColor(.black)
                
                // Phone Number (in between name and relationship)
                Text(formatPhoneNumber(contact.phone))
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(Color(hex: "002147"))
                
                // Relationship
                Text(contact.relationship)
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Edit, Delete, and Call Buttons
            HStack(spacing: 4) {
                // Edit Button
                Button(action: onEdit) {
                    Image("edit")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundColor(.gray)
                }
                .padding(6)
                
                // Delete Button
                Button(action: onDelete) {
                    Image("delete")
                        .resizable()
                        .frame(width: 16, height: 18)
                        .foregroundColor(.gray)
                }
                .padding(6)
                
                // Call Button
                Button(action: {
                    // Add a slight haptic feedback
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    
                    // Open phone app with number pre-filled in keypad
                    openPhoneDialer(with: contact.phone)
                }) {
                    Image("call")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color(hex: "002147"))
                }
                .padding(6)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(
            color: Color.black.opacity(0.05),
            radius: 4,
            x: 0,
            y: 2
        )
    }
    
    // Helper function to format phone numbers nicely
    private func formatPhoneNumber(_ phone: String) -> String {
        // Remove all non-numeric characters
        let digits = phone.filter { $0.isNumber }
        
        // Format based on number of digits
        if digits.count == 10 {
            // Format as (XXX) XXX-XXXX
            let areaCode = String(digits.prefix(3))
            let firstPart = String(digits.dropFirst(3).prefix(3))
            let secondPart = String(digits.dropFirst(6))
            return "(\(areaCode)) \(firstPart)-\(secondPart)"
        } else if digits.count == 11 && digits.hasPrefix("1") {
            // Format as +1 (XXX) XXX-XXXX
            let areaCode = String(digits.dropFirst(1).prefix(3))
            let firstPart = String(digits.dropFirst(4).prefix(3))
            let secondPart = String(digits.dropFirst(7))
            return "+1 (\(areaCode)) \(firstPart)-\(secondPart)"
        } else if phone.hasPrefix("+") {
            // Keep international format as is, just add spaces for readability
            var formatted = phone
            if let range = phone.range(of: "\\d{3,}", options: .regularExpression) {
                let numbers = phone[range]
                if numbers.count > 6 {
                    let insertIndex = phone.index(phone.startIndex, offsetBy: min(phone.count, 6))
                    formatted.insert(" ", at: insertIndex)
                }
            }
            return formatted
        }
        
        // Return original if no specific format applies
        return phone
    }
    
    // Function to open phone dialer with number pre-filled
    private func openPhoneDialer(with phoneNumber: String) {
        // Clean the phone number - keep only digits and plus sign
        let cleanedNumber = phoneNumber.filter { $0.isNumber || $0 == "+" }
        
        // Check if we have a valid phone number
        guard !cleanedNumber.isEmpty else {
            print("❌ Invalid phone number: \(phoneNumber)")
            return
        }
        
        print("📱 Attempting to call: \(cleanedNumber)")
        
        // Try different URL schemes in order of preference
        let urlSchemes = [
            "telprompt://\(cleanedNumber)",  // Shows confirmation dialog
            "tel://\(cleanedNumber)"         // May initiate call immediately
        ]
        
        for scheme in urlSchemes {
            if let url = URL(string: scheme) {
                if UIApplication.shared.canOpenURL(url) {
                    print("📱 Opening dialer with scheme: \(scheme)")
                    UIApplication.shared.open(url, options: [:], completionHandler: { success in
                        if success {
                            print("✅ Phone dialer opened successfully")
                        } else {
                            print("❌ Failed to open phone dialer")
                        }
                    })
                    return
                }
            }
        }
        
        print("❌ No phone dialer scheme could be opened")
        // You could show an alert to the user here
    }
}

// MARK: - Modified Tab Bar for Emergency Contacts (Active State)
//struct EmergencyContactsTabBar: View {
//    let userName: String
//    let profileImage: String
//    
//    var body: some View {
//        HStack(spacing: 0) {
//            // Home Tab (Inactive)
//            TabBarItemView(
//                icon: "home",
//                title: "Home"
//            )
//            
//            // Emergency Contacts Tab (Active)
//            TabBarItemView(
//                icon: "clickedEmergencyContacts",
//                title: "Emergency Contacts",
//                active: true
//            )
//            
//            // Incident Logs Tab (Inactive)
//            TabBarItemView(
//                icon: "incidentLogs",
//                title: "Incident Logs"
//            )
//            
//            // Trusted Locations Tab (Inactive)
//            TabBarItemView(
//                icon: "locations",
//                title: "Trusted Locations"
//            )
//            
//            // Profile Tab
//            ProfileTabItem(
//                userName: userName,
//                profileImage: profileImage
//            )
//        }
//        .frame(maxWidth: .infinity)
//        .padding(.vertical, 10)
//        .background(Color.white)
//        .shadow(
//            color: Color.black.opacity(0.08),
//            radius: 1,
//            x: 0,
//            y: -1
//        )
//    }
//}

// MARK: - Preview
struct EmergencyContactsView_Previews: PreviewProvider {
    static var previews: some View {
        EmergencyContactsView()
    }
}

// MARK: - Helper Extension
extension Character {
    var isNumber: Bool {
        return "0123456789".contains(self)
    }
}
