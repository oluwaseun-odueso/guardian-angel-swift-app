//
//  DashboardView.swift
//  Guardian Angel
//
//  Created by Oluwaseun Odueso on 02/01/2026.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var locationManager = LocationManager()
    @ObservedObject private var authManager = AuthManager.shared
    @EnvironmentObject private var navigationManager: NavigationManager
    
    @State private var responders: [Responder] = []
    @State private var isLoading = false
    @State private var isLoadingPanicAlert = false
    @State private var isLoadingManualRequest = false
    @State private var showError = false
    @State private var showPanicAlertSuccess = false
    @State private var showManualRequestSuccess = false
    @State private var errorMessage = ""
    @State private var successMessage = ""
    @State private var manualRequestSuccessMessage = ""
    @State private var hasAttemptedFetch = false
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - HEADER
            VStack(spacing: 20) {
                HStack(spacing: 12) {
                    // Panic Alert Button - Now clickable
                    Button(action: {
                        sendPanicAlert()
                    }) {
                        HStack(spacing: 12) {
                            if isLoadingPanicAlert {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
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
                        .background(Color.gray.opacity(0.10))
                        .cornerRadius(10)
                    }
                    .disabled(isLoadingPanicAlert)
                    
                    Image("notification")
                        .resizable()
                        .frame(width: 14.76, height: 19.09)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 16)
                        .background(Color.gray.opacity(0.10))
                        .cornerRadius(10)
                }
                .padding(.horizontal, 16)
                
                VStack(spacing: 8) {
                    HStack {
                        Image("search")
                            .resizable()
                            .frame(width: 14, height: 14)
                            .padding(.horizontal, 6)
                        
                        Text("Respondents")
                            .font(.custom("Poppins-SemiBold", size: 14))
                        
                        Spacer()
                        
                        Text("\(responders.count) available")
                            .font(.custom("Poppins-Regular", size: 12))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 16)
                    
                    Divider()
                }
            }
            .padding(.top, 16)
            .background(Color(hex: "FFFFFF"))
            
            // MARK: - LIST
            if locationManager.permissionDenied {
                LocationPermissionDeniedView()
            } else {
                ScrollView {
                    if isLoading {
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .padding(.top, 60)
                            Text("Fetching nearby respondents...")
                                .font(.custom("Poppins-Regular", size: 14))
                                .foregroundColor(.gray)
                                .padding(.top, 12)
                            
                            if let lat = locationManager.latitude, let lng = locationManager.longitude {
                                Text("Location: \(lat, specifier: "%.4f"), \(lng, specifier: "%.4f")")
                                    .font(.custom("Poppins-Regular", size: 11))
                                    .foregroundColor(.gray.opacity(0.7))
                            }
                        }
                    } else if responders.isEmpty && !isLoading && hasAttemptedFetch {
                        EmptyRespondersView()
                    } else if responders.isEmpty && !isLoading {
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .padding(.top, 60)
                            Text("Getting your location...")
                                .font(.custom("Poppins-Regular", size: 14))
                                .foregroundColor(.gray)
                                .padding(.top, 12)
                        }
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(responders) { responder in
                                ResponderCard(responder: responder) {
                                    sendManualRequest(for: responder)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 20)
                    }
                }
                .refreshable {
                    await refreshData()
                }
            }
            
//            DashboardTabBar(
//                userName: authManager.currentUser?.fullName ?? "User",
//                profileImage: "profileImage"
//            )
        }
        .onAppear {
            print("📍 DashboardView appeared")
            print("🔐 Auth token present: \(authManager.authToken != nil)")
            if let token = authManager.authToken {
                print("🔐 Token: \(token.prefix(20))...")
            }
            locationManager.requestLocation()
        }
        .onChange(of: locationManager.latitude) { oldValue, newValue in
            if let newValue {
                print("📍 Latitude updated: \(newValue)")
                fetchFacilitiesIfReady()
            }
        }
        .onChange(of: locationManager.longitude) { oldValue, newValue in
            if let newValue {
                print("📍 Longitude updated: \(newValue)")
            }
        }
        .onChange(of: locationManager.permissionDenied) { oldValue, denied in
            if denied {
                errorMessage = "Location permission is required to find nearby respondents."
                showError = true
                print("❌ Location permission denied")
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .alert("Panic Alert Sent", isPresented: $showPanicAlertSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(successMessage)
        }
        .alert("Request Sent", isPresented: $showManualRequestSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(manualRequestSuccessMessage)
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    // MARK: - Manual Request Handler
    private func sendManualRequest(for responder: Responder) {
        print("🚨 MANUAL REQUEST for: \(responder.name)")
        print("🏥 Hospital ID: \(responder.id)")
        
        // Check if we have location
        guard let lat = locationManager.latitude,
              let lng = locationManager.longitude else {
            errorMessage = "Unable to get your location. Please ensure location services are enabled."
            showError = true
            return
        }
        
        // Check if we have authentication token
        guard let token = authManager.authToken else {
            errorMessage = "Please login to send requests"
            showError = true
            return
        }
        
        isLoadingManualRequest = true
        
        // Prepare request body according to API specification
        let requestBody: [String: Any] = [
            "hospitalId": responder.id,
            "location": [
                "coordinates": [lat, lng],
                "accuracy": 50
            ]
        ]
        
        print("📍 Sending manual request to: \(responder.name)")
        print("📤 Request body: \(requestBody)")
        
        // Make API call
        createManualRequest(hospitalId: responder.id, lat: lat, lng: lng, token: token, body: requestBody)
    }
    
    private func createManualRequest(hospitalId: String, lat: Double, lng: Double, token: String, body: [String: Any]) {
        let urlString = "https://guardian-fwpg.onrender.com/api/v1/alert/manual"
        print("🌐 Manual request URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            isLoadingManualRequest = false
            errorMessage = "Invalid server URL"
            showError = true
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
            isLoadingManualRequest = false
            errorMessage = "Failed to prepare request data"
            showError = true
            print("❌ JSON Serialization error: \(error)")
            return
        }
        
        print("🔐 Authorization: Bearer \(token.prefix(20))...")
        print("📤 Sending manual request...")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoadingManualRequest = false
                
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    self.showError = true
                    print("❌ Manual request API error:", error.localizedDescription)
                    return
                }
                
                // Check HTTP status code
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Manual request HTTP Status: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 401 {
                        self.errorMessage = "Session expired. Please login again."
                        self.showError = true
                        print("❌ 401 Unauthorized - Token may be expired")
                        return
                    }
                    
                    if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
                        print("⚠️ Server returned \(httpResponse.statusCode) - checking response body for error details")
                    }
                }
                
                guard let data = data else {
                    self.errorMessage = "No response from server"
                    self.showError = true
                    print("❌ No data received for manual request")
                    return
                }
                
                // Print raw response for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📦 Manual request response: \(jsonString)")
                    
                    // Try to parse the error message
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let message = json["message"] as? String {
                            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
                                self.errorMessage = "Error \(httpResponse.statusCode): \(message)"
                                self.showError = true
                            } else if let success = json["success"] as? Bool, !success {
                                self.errorMessage = message
                                self.showError = true
                            } else {
                                // Success - get more details
                                var successMsg = message
                                
                                // Try to get hospital name and responder details
                                if let data = json["data"] as? [String: Any] {
                                    if let hospital = data["hospital"] as? [String: Any],
                                       let hospitalName = hospital["name"] as? String {
                                        successMsg += "\n\nHospital: \(hospitalName)"
                                    }
                                    
                                    if let assignedResponder = data["assignedResponder"] as? [String: Any],
                                       let responderName = assignedResponder["name"] as? String,
                                       let estimatedTime = data["estimatedTime"] as? String {
                                        successMsg += "\nResponder: \(responderName)\nETA: \(estimatedTime)"
                                    }
                                    
                                    if let locationDetails = data["locationDetails"] as? [String: Any],
                                       let address = locationDetails["address"] as? String {
                                        successMsg += "\n\nAddress: \(address)"
                                    }
                                }
                                
                                self.manualRequestSuccessMessage = successMsg
                                self.showManualRequestSuccess = true
                            }
                            return
                        }
                        
                        if let errorMsg = json["error"] as? String {
                            self.errorMessage = errorMsg
                            self.showError = true
                            return
                        }
                    }
                }
                
                do {
                    // Create response model for manual request
                    struct ManualRequestResponse: Decodable {
                        let success: Bool
                        let message: String
                        let data: ManualRequestData?
                        let timestamp: String
                    }
                    
                    struct ManualRequestData: Decodable {
                        let hospital: Hospital?
                        let assignedResponder: AssignedResponder?
                        let estimatedTime: String?
                        let locationDetails: LocationDetails?
                    }
                    
                    struct Hospital: Decodable {
                        let name: String
                    }
                    
                    struct AssignedResponder: Decodable {
                        let name: String
                    }
                    
                    struct LocationDetails: Decodable {
                        let address: String
                    }
                    
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(ManualRequestResponse.self, from: data)
                    
                    if response.success {
                        var successMsg = response.message
                        
                        if let data = response.data {
                            if let hospital = data.hospital {
                                successMsg += "\n\nHospital: \(hospital.name)"
                            }
                            
                            if let responder = data.assignedResponder,
                               let estimatedTime = data.estimatedTime {
                                successMsg += "\nResponder: \(responder.name)\nETA: \(estimatedTime)"
                            }
                            
                            if let location = data.locationDetails {
                                successMsg += "\n\nAddress: \(location.address)"
                            }
                        }
                        
                        self.manualRequestSuccessMessage = successMsg
                        self.showManualRequestSuccess = true
                        print("✅ Manual request created successfully!")
                    } else {
                        self.errorMessage = response.message
                        self.showError = true
                        print("❌ Manual request failed: \(response.message)")
                    }
                    
                } catch let decodingError as DecodingError {
                    self.errorMessage = "Failed to process server response"
                    self.showError = true
                    print("❌ Decoding error: \(decodingError)")
                    
                    // Try one more time with a simpler approach
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        print("📋 Parsed JSON keys: \(json.keys)")
                    }
                } catch {
                    self.errorMessage = "Unexpected error: \(error.localizedDescription)"
                    self.showError = true
                    print("❌ Unknown error:", error)
                }
            }
        }.resume()
    }
    
    // MARK: - Panic Alert Handler (keep your existing panic alert code)
    private func sendPanicAlert() {
        print("🚨 PANIC ALERT triggered!")
        
        // Check if we have location
        guard let lat = locationManager.latitude,
              let lng = locationManager.longitude else {
            errorMessage = "Unable to get your location. Please ensure location services are enabled."
            showError = true
            return
        }
        
        // Check if we have authentication token
        guard let token = authManager.authToken else {
            errorMessage = "Please login to send panic alerts"
            showError = true
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
            errorMessage = "Invalid server URL"
            showError = true
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
            errorMessage = "Failed to prepare alert data"
            showError = true
            print("❌ JSON Serialization error: \(error)")
            return
        }
        
        print("🔐 Authorization: Bearer \(token.prefix(20))...")
        print("📤 Sending panic alert request...")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoadingPanicAlert = false
                
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    self.showError = true
                    print("❌ Panic alert API error:", error.localizedDescription)
                    return
                }
                
                // Check HTTP status code
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Panic alert HTTP Status: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 401 {
                        self.errorMessage = "Session expired. Please login again."
                        self.showError = true
                        print("❌ 401 Unauthorized - Token may be expired")
                        return
                    }
                    
                    if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
                        print("⚠️ Server returned \(httpResponse.statusCode) - checking response body for error details")
                    }
                }
                
                guard let data = data else {
                    self.errorMessage = "No response from server"
                    self.showError = true
                    print("❌ No data received for panic alert")
                    return
                }
                
                // Print raw response for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📦 Panic alert response: \(jsonString)")
                    
                    // Try to parse the error message
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let message = json["message"] as? String {
                            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
                                self.errorMessage = "Error \(httpResponse.statusCode): \(message)"
                                self.showError = true
                            } else if let success = json["success"] as? Bool, !success {
                                self.errorMessage = message
                                self.showError = true
                            } else {
                                self.successMessage = message
                                self.showPanicAlertSuccess = true
                            }
                            return
                        }
                        
                        if let errorMsg = json["error"] as? String {
                            self.errorMessage = errorMsg
                            self.showError = true
                            return
                        }
                    }
                }
                
                do {
                    // Create response model for panic alert
                    struct PanicAlertResponse: Decodable {
                        let success: Bool
                        let message: String
                        let data: PanicAlertData?
                        let timestamp: String
                    }
                    
                    struct PanicAlertData: Decodable {
                        let alert: Alert?
                        let assignedResponder: AssignedResponder?
                        let locationDetails: LocationDetails?
                    }
                    
                    struct Alert: Decodable {
                        let status: String
                        let type: String
                        let location: AlertLocation
                    }
                    
                    struct AlertLocation: Decodable {
                        let coordinates: [Double]
                        let address: String
                    }
                    
                    struct AssignedResponder: Decodable {
                        let name: String
                        let distance: Double
                        let estimatedTime: String
                    }
                    
                    struct LocationDetails: Decodable {
                        let address: String
                    }
                    
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(PanicAlertResponse.self, from: data)
                    
                    if response.success {
                        if let data = response.data {
                            var message = response.message
                            if let responder = data.assignedResponder {
                                message += "\n\nResponder: \(responder.name)\nETA: \(responder.estimatedTime)"
                            }
                            if let location = data.locationDetails {
                                message += "\nAddress: \(location.address)"
                            }
                            self.successMessage = message
                        } else {
                            self.successMessage = response.message
                        }
                        self.showPanicAlertSuccess = true
                        print("✅ Panic alert created successfully!")
                    } else {
                        self.errorMessage = response.message
                        self.showError = true
                        print("❌ Panic alert failed: \(response.message)")
                    }
                    
                } catch let decodingError as DecodingError {
                    self.errorMessage = "Failed to process server response"
                    self.showError = true
                    print("❌ Decoding error: \(decodingError)")
                    
                    // Try one more time with a simpler approach
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        print("📋 Parsed JSON keys: \(json.keys)")
                    }
                } catch {
                    self.errorMessage = "Unexpected error: \(error.localizedDescription)"
                    self.showError = true
                    print("❌ Unknown error:", error)
                }
            }
        }.resume()
    }
    
    // MARK: - API CALL for fetching facilities
    private func fetchFacilitiesIfReady() {
        guard
            let lat = locationManager.latitude,
            let lng = locationManager.longitude,
            !isLoading
        else {
            print("⏳ Waiting for location... lat: \(String(describing: locationManager.latitude)), lng: \(String(describing: locationManager.longitude))")
            return
        }
        
        // Check if we have an auth token
        guard let token = authManager.authToken else {
            print("❌ No auth token available. User needs to login.")
            errorMessage = "Please login to continue"
            showError = true
            return
        }
        
        print("✅ Location ready, fetching facilities...")
        fetchNearbyFacilities(lat: lat, lng: lng, token: token)
    }
    
    private func fetchNearbyFacilities(lat: Double, lng: Double, token: String) {
        isLoading = true
        hasAttemptedFetch = true
        
        // Format URL with proper query parameters
        let urlString = "https://guardian-fwpg.onrender.com/api/v1/alert/available-responders?lat=\(lat)&lng=\(lng)"
        print("🌐 Fetching from URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            isLoading = false
            errorMessage = "Invalid URL"
            showError = true
            print("❌ Invalid URL: \(urlString)")
            return
        }
        
        // Create URLRequest with timeout and authentication
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("🔐 Authorization header added: Bearer \(token.prefix(20))...")
        print("📤 Sending request...")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    self.showError = true
                    print("❌ API error:", error.localizedDescription)
                    return
                }
                
                // Check HTTP status code
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 HTTP Status: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 401 {
                        self.errorMessage = "Session expired. Please login again."
                        self.showError = true
                        print("❌ 401 Unauthorized - Token may be expired")
                        
                        // Optionally logout the user
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.authManager.logout()
                        }
                        return
                    }
                    
                    if httpResponse.statusCode != 200 {
                        self.errorMessage = "Server error (Code: \(httpResponse.statusCode))"
                        self.showError = true
                        return
                    }
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received from server"
                    self.showError = true
                    print("❌ No data received")
                    return
                }
                
                // Debug: Print raw response
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📦 Raw response (\(data.count) bytes):")
                    print(jsonString.prefix(500)) // Print first 500 chars
                }
                
                do {
                    let decoder = JSONDecoder()
                    let decoded = try decoder.decode(
                        NearbyFacilitiesResponse.self,
                        from: data
                    )
                    
                    print("✅ Decoded response - Success: \(decoded.success)")
                    print("✅ Message: \(decoded.message)")
                    print("✅ Facilities count: \(decoded.data.facilities.count)")
                    
                    if decoded.success {
                        // Map facilities to responders
                        let mappedResponders = decoded.data.facilities.map { facility in
                            Responder(from: facility)
                        }
                        
                        // Sort by distance (closest first)
                        self.responders = mappedResponders.sorted { responder1, responder2 in
                            // Extract numeric distance from formatted string
                            let dist1 = Double(responder1.distance.split(separator: " ").first.flatMap { String($0) } ?? "0") ?? 0
                            let dist2 = Double(responder2.distance.split(separator: " ").first.flatMap { String($0) } ?? "0") ?? 0
                            return dist1 < dist2
                        }
                        
                        print("✅ Successfully loaded \(self.responders.count) respondents")
                        
                        // Print first responder for debugging
                        if let first = self.responders.first {
                            print("📍 First responder: \(first.name) - \(first.distance)")
                        }
                    } else {
                        self.errorMessage = decoded.message
                        self.showError = true
                        print("❌ API returned success=false: \(decoded.message)")
                    }
                    
                } catch let decodingError as DecodingError {
                    self.errorMessage = "Failed to decode response"
                    self.showError = true
                    print("❌ Decoding error:")
                    
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("  Key '\(key.stringValue)' not found: \(context.debugDescription)")
                        print("  Path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
                    case .typeMismatch(let type, let context):
                        print("  Type '\(type)' mismatch: \(context.debugDescription)")
                        print("  Path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
                    case .valueNotFound(let type, let context):
                        print("  Value '\(type)' not found: \(context.debugDescription)")
                        print("  Path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
                    case .dataCorrupted(let context):
                        print("  Data corrupted: \(context.debugDescription)")
                        print("  Path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
                    @unknown default:
                        print("  Unknown decoding error")
                    }
                } catch {
                    self.errorMessage = "Unexpected error: \(error.localizedDescription)"
                    self.showError = true
                    print("❌ Unknown error:", error)
                }
            }
        }.resume()
    }
    
    // MARK: - Pull to refresh
    private func refreshData() async {
        guard
            let lat = locationManager.latitude,
            let lng = locationManager.longitude,
            let token = authManager.authToken
        else {
            print("🔄 Refresh: Missing location or token")
            if authManager.authToken == nil {
                print("❌ No auth token for refresh")
                return
            }
            
            locationManager.requestLocation()
            
            // Wait a bit for location to be retrieved
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            
            if let lat = locationManager.latitude,
               let lng = locationManager.longitude,
               let token = authManager.authToken {
                await performRefresh(lat: lat, lng: lng, token: token)
            }
            return
        }
        
        await performRefresh(lat: lat, lng: lng, token: token)
    }
    
    private func performRefresh(lat: Double, lng: Double, token: String) async {
        await withCheckedContinuation { continuation in
            fetchNearbyFacilities(lat: lat, lng: lng, token: token)
            // Add a small delay to ensure UI updates
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                continuation.resume()
            }
        }
    }
}

// MARK: - Supporting Views
struct LocationPermissionDeniedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.slash")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Location Permission Required")
                .font(.custom("Poppins-SemiBold", size: 18))
            
            Text("Please enable location services in Settings to find nearby respondents.")
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .font(.custom("Poppins-Medium", size: 16))
            .foregroundColor(.white)
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .background(Color.black)
            .cornerRadius(10)
        }
        .padding(.top, 80)
    }
}

struct EmptyRespondersView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "building.2")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Respondents Found")
                .font(.custom("Poppins-SemiBold", size: 18))
            
            Text("There are no available medical facilities in your area at the moment.")
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.top, 80)
    }
}


struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
