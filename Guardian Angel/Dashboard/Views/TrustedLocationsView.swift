//
//  TrustedLocationsView.swift
//  Guardian Angel
//
//  Created by Oluwaseun Odueso on 30/12/2025.
//

import SwiftUI

struct TrustedLocation: Identifiable, Decodable {
    let id: String
    let name: String
    let address: String
    let staticMap: String
    let radius: Int
    let isHome: Bool
    let isWork: Bool
    let notes: String?
    let createdAt: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case address
        case staticMap
        case radius
        case isHome
        case isWork
        case notes
        case createdAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        
        // Decode the nested address object to get formatted address
        let addressDict = try container.decode([String: String].self, forKey: .address)
        address = addressDict["formatted"] ?? "Unknown Location"
        
        staticMap = try container.decode(String.self, forKey: .staticMap)
        radius = try container.decode(Int.self, forKey: .radius)
        isHome = try container.decode(Bool.self, forKey: .isHome)
        isWork = try container.decode(Bool.self, forKey: .isWork)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        createdAt = try container.decode(String.self, forKey: .createdAt)
    }
    
    init(id: String, name: String, address: String, staticMap: String, radius: Int = 100, isHome: Bool = false, isWork: Bool = false, notes: String? = nil, createdAt: String = "") {
        self.id = id
        self.name = name
        self.address = address
        self.staticMap = staticMap
        self.radius = radius
        self.isHome = isHome
        self.isWork = isWork
        self.notes = notes
        self.createdAt = createdAt
    }
}

struct TrustedLocationsResponse: Decodable {
    let success: Bool
    let message: String
    let data: TrustedLocationsData
    let timestamp: String
}

struct TrustedLocationsData: Decodable {
    let locations: [TrustedLocation]
    let count: Int
}

struct TrustedLocationsView: View {
    @ObservedObject private var authManager = AuthManager.shared
    @EnvironmentObject private var navigationManager: NavigationManager
    
    @State private var trustedLocations: [TrustedLocation] = []
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    // Panic Alert States
    @StateObject private var locationManager = LocationManager()
    @State private var isLoadingPanicAlert = false
    @State private var showPanicAlertSuccess = false
    @State private var showPanicAlertError = false
    @State private var panicAlertSuccessMessage = ""
    @State private var panicAlertErrorMessage = ""
    
//    @Environment(\.presentationMode) var presentationMode
    @State private var showingDeleteAlert = false
    @State private var showingAddLocation = false
    @State private var showingEditLocation = false
    @State private var locationToDelete: TrustedLocation?
    @State private var locationToEdit: TrustedLocation?
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            contentView
//            TrustedLocationsTabBar(
//                userName: authManager.currentUser?.fullName ?? "Seun Odueso",
//                profileImage: "profileImage"
//            )
        }
        .background(Color.white)
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .onAppear {
            fetchTrustedLocations()
            locationManager.requestLocation()
        }
        .onChange(of: locationManager.permissionDenied) { oldValue, denied in
            if denied {
                panicAlertErrorMessage = "Location permission is required to send panic alerts."
                showPanicAlertError = true
                print("❌ Location permission denied")
            }
        }
//        .sheet(isPresented: $showingAddLocation, onDismiss: {
//            fetchTrustedLocations()
//        }) {
//            AddEditTrustedLocationView(isEditing: false, existingLocation: nil)
//        }
//        .sheet(isPresented: $showingEditLocation, onDismiss: {
//            fetchTrustedLocations()
//        }) {
//            if let location = locationToEdit {
//                AddEditTrustedLocationView(isEditing: true, existingLocation: location)
//            }
//        }
        .sheet(isPresented: $showingAddLocation) {
            AddEditTrustedLocationView(isEditing: false, existingLocation: nil) {
                fetchTrustedLocations()
            }
        }

        .sheet(isPresented: $showingEditLocation) {
            if let location = locationToEdit {
                AddEditTrustedLocationView(isEditing: true, existingLocation: location) {
                    fetchTrustedLocations()
                }
            }
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete Location"),
                message: Text("Are you sure you want to delete this trusted location?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let location = locationToDelete {
                        deleteLocation(location)
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
    
    // MARK: - Extracted Subviews
    private var headerView: some View {
        VStack(spacing: 20) {
            // Panic Alert & Notification Row
            HStack(spacing: 12) {
                Button(action: { sendPanicAlert() }) {
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

            // Trusted Locations Header
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image("locations")
                        .resizable()
                        .frame(width: 12, height: 14)
                        .padding(.horizontal, 10)

                    Text("Trusted Locations")
                        .font(.custom("Poppins-SemiBold", size: 14))
                        .foregroundColor(.black)

                    Spacer()

                    Button(action: { showingAddLocation = true }) {
                        Image("plus")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.black)
                            .padding(.horizontal, 10)
                    }
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
    }

    private var contentView: some View {
        Group {
            if isLoading {
                VStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding()
                    Text("Loading trusted locations...")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                }
            } else if trustedLocations.isEmpty {
                VStack(spacing: 20) {
                    Spacer()
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No Trusted Locations")
                        .font(.custom("Poppins-SemiBold", size: 18))
                        .foregroundColor(.black)
                    Text("Add trusted locations to quickly access them during emergencies.")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(trustedLocations.enumerated()), id: \.element.id) { index, location in
                            VStack(spacing: 0) {
                                TrustedLocationCard(
                                    location: location,
                                    onEdit: {
                                        locationToEdit = location
                                        showingEditLocation = true
                                    },
                                    onDelete: {
                                        locationToDelete = location
                                        showingDeleteAlert = true
                                    }
                                )
                                if index < trustedLocations.count - 1 {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 0.3)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                }
                            }
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                }
                .refreshable {
                    await fetchTrustedLocationsAsync()
                }
            }
        }
    }
    
    // MARK: - API Methods
    
    private func fetchTrustedLocations() {
        guard let token = authManager.authToken else {
            errorMessage = "Please login to view trusted locations"
            showError = true
            return
        }
        
        isLoading = true
        
        let urlString = "https://guardian-fwpg.onrender.com/api/v1/trusted-location"
        print("🌐 Fetching trusted locations from: \(urlString)")
        
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
        print("📤 Sending trusted locations request...")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    self.showError = true
                    print("❌ Trusted locations API error:", error.localizedDescription)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Trusted locations HTTP Status: \(httpResponse.statusCode)")
                    
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
                    print("❌ No data received for trusted locations")
                    return
                }
                
                // Print raw response for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📦 Trusted locations response: \(jsonString.prefix(1000))...")
                }
                
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(TrustedLocationsResponse.self, from: data)
                    
                    if response.success {
                        print("✅ Found \(response.data.count) trusted locations")
                        self.trustedLocations = response.data.locations
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
    
    // Async version for pull-to-refresh
    private func fetchTrustedLocationsAsync() async {
        await withCheckedContinuation { continuation in
            fetchTrustedLocations()
            // Add a small delay to ensure the refresh indicator stays visible
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                continuation.resume()
            }
        }
    }
    
    private func deleteLocation(_ location: TrustedLocation) {
        guard let token = authManager.authToken else {
            errorMessage = "Please login to delete trusted locations"
            showError = true
            return
        }
        
        let locationId = location.id
        let urlString = "https://guardian-fwpg.onrender.com/api/v1/trusted-location/\(locationId)"
        print("🌐 Deleting trusted location at: \(urlString)")
        print("🗑️ Location ID: \(locationId)")
        
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid server URL"
            showError = true
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
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    self.showError = true
                    print("❌ Delete trusted location API error:", error.localizedDescription)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Delete trusted location HTTP Status: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 401 {
                        self.errorMessage = "Session expired. Please login again."
                        self.showError = true
                        print("❌ 401 Unauthorized - Token may be expired")
                        return
                    }
                    
                    if httpResponse.statusCode == 404 {
                        self.errorMessage = "Trusted location not found. It may have already been deleted."
                        self.showError = true
                        print("❌ 404 Not Found - Location ID \(locationId) not found")
                        // Still remove from local array since it doesn't exist on server
                        self.trustedLocations.removeAll { $0.id == location.id }
                        return
                    }
                }
                
                guard let data = data else {
                    self.errorMessage = "No response from server"
                    self.showError = true
                    // Remove from local array anyway for better UX
                    self.trustedLocations.removeAll { $0.id == location.id }
                    return
                }
                
                // Print raw response for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📦 Delete trusted location response: \(jsonString)")
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let success = json["success"] as? Bool, success {
                            // Success - remove from local array
                            self.trustedLocations.removeAll { $0.id == location.id }
                            print("✅ Trusted location deleted successfully")
                        } else {
                            if let message = json["message"] as? String {
                                self.errorMessage = "Failed to delete: \(message)"
                                self.showError = true
                                print("❌ Failed to delete trusted location: \(message)")
                            }
                        }
                    }
                } catch {
                    self.errorMessage = "Failed to parse server response"
                    self.showError = true
                    print("❌ JSON parsing error: \(error)")
                    // Remove from local array anyway for better UX
                    self.trustedLocations.removeAll { $0.id == location.id }
                }
            }
        }.resume()
    }
    
    // MARK: - Panic Alert Handler
    private func sendPanicAlert() {
        print("🚨 PANIC ALERT triggered from Trusted Locations View!")
        
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

// MARK: - Trusted Location Card
struct TrustedLocationCard: View {
    let location: TrustedLocation
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Map Image (rounded square)
            mapImageView
                .frame(width: 80, height: 80)
                .clipped()
            
            locationInfoView
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer(minLength: 8)
            
            // Edit and Delete Buttons
            actionButtonsView
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.white)
    }
    
    // MARK: - Subviews
    
    private var mapImageView: some View {
        Group {
            if !location.staticMap.isEmpty, let url = URL(string: location.staticMap) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        loadingView
                    case .success(let image):
                        loadedImageView(image: image)
                    case .failure:
                        fallbackImageView
                    @unknown default:
                        fallbackImageView
                    }
                }
            } else {
                fallbackImageView
            }
        }
    }
    
    private var loadingView: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func loadedImageView(image: Image) -> some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
    }
    
    private var fallbackImageView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            
            Image(systemName: "map.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.gray)
        }
        .frame(width: 80, height: 80)
    }
    
    private var locationInfoView: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Location Name with Home/Work indicators
            nameView
            
            // Address
            Text(location.address)
                .font(.custom("Poppins-Regular", size: 12))
                .foregroundColor(.black)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            // Notes if available
            if let notes = location.notes, !notes.isEmpty {
                Text(notes)
                    .font(.custom("Poppins-Regular", size: 11))
                    .foregroundColor(.gray)
                    .italic()
                    .lineLimit(1)
            }
            
            // Radius and creation date
            metadataView
        }
    }
    
    private var nameView: some View {
        HStack(spacing: 4) {
            Text(location.name)
                .font(.custom("Poppins-SemiBold", size: 16))
                .foregroundColor(.black)
            
            if location.isHome {
                Text("🏠")
                    .font(.caption)
            }
            
            if location.isWork {
                Text("💼")
                    .font(.caption)
            }
        }
    }
    
    private var metadataView: some View {
        HStack(spacing: 8) {
            Text("Radius: \(location.radius)m")
                .font(.custom("Poppins-Regular", size: 10))
                .foregroundColor(.gray)
            
            if !location.createdAt.isEmpty {
                Text("•")
                    .font(.custom("Poppins-Regular", size: 10))
                    .foregroundColor(.gray)
                
                Text(formatDate(location.createdAt))
                    .font(.custom("Poppins-Regular", size: 10))
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var actionButtonsView: some View {
        HStack(spacing: 4) {
            // Edit Button
            Button(action: onEdit) {
                Image("edit")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundColor(.gray)
            }
            .padding(8)
            
            // Delete Button
            Button(action: onDelete) {
                Image("delete")
                    .resizable()
                    .frame(width: 16, height: 18)
                    .foregroundColor(.gray)
            }
            .padding(8)
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .short
            displayFormatter.timeStyle = .none
            return displayFormatter.string(from: date)
        }
        
        return dateString
    }
}

// MARK: - Preview
struct TrustedLocationsView_Previews: PreviewProvider {
    static var previews: some View {
        TrustedLocationsView()
    }
}
