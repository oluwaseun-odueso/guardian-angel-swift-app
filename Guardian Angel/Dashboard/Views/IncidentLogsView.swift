//
//  IncidentLogsView.swift
//  Guardian Angel
//
//  Created by Oluwaseun Odueso on 30/12/2025.
//

import SwiftUI

enum IncidentStatus: String, CaseIterable {
    case active = "Active"
    case acknowledged = "Acknowledged"
    case resolved = "Resolved"
    case cancelled = "Cancelled"
    case onScene = "OnScene"
    
    var iconName: String {
        switch self {
        case .active: return "active"
        case .acknowledged: return "acknowledged"
        case .resolved: return "resolved"
        case .cancelled: return "cancelled"
        case .onScene: return "onscene"
        }
    }
    
    var statusColor: Color {
        switch self {
        case .active: return .red
        case .acknowledged: return .yellow
        case .resolved: return .green
        case .cancelled: return Color.gray.opacity(0.7)
        case .onScene: return .red
        }
    }
    
    // Convert API status string to IncidentStatus
    static func fromAPIStatus(_ status: String) -> IncidentStatus {
        switch status.lowercased() {
        case "active": return .active
        case "acknowledged": return .acknowledged
        case "resolved": return .resolved
        case "cancelled": return .cancelled
        case "on-scene": return .onScene
        default: return .active
        }
    }
}

struct IncidentLog: Identifiable {
    let id: String
    let title: String
    let address: String
    let status: IncidentStatus
    let mapImageUrl: String
    let date: Date
    let type: String
    let responderName: String?
    let estimatedArrival: String?
    
    init(from alertData: [String: Any]) {
        self.id = alertData["_id"] as? String ?? UUID().uuidString
        
        // Determine title based on alert type
        let alertType = alertData["type"] as? String ?? "panic"
        switch alertType {
        case "panic":
            self.title = "Panic Alert"
        case "manual":
            self.title = "Manual Request"
        default:
            self.title = "Emergency Alert"
        }
        self.type = alertType
        
        // Get address from location data
        if let locationData = alertData["location"] as? [String: Any] {
            self.address = locationData["address"] as? String ?? "Unknown Location"
        } else {
            self.address = "Unknown Location"
        }
        
        // Get status
        let statusString = alertData["status"] as? String ?? "active"
        self.status = IncidentStatus.fromAPIStatus(statusString)
        
        // Get static map URL
        if let locationData = alertData["location"] as? [String: Any] {
            self.mapImageUrl = locationData["staticMapUrl"] as? String ?? ""
        } else {
            self.mapImageUrl = ""
        }
        
        // Get date
        if let createdAtString = alertData["createdAt"] as? String,
           let date = ISO8601DateFormatter().date(from: createdAtString) {
            self.date = date
        } else {
            self.date = Date()
        }
        
        // Get responder information
        if let assignedResponder = alertData["assignedResponder"] as? [String: Any],
           let responderId = assignedResponder["responderId"] as? [String: Any] {
            self.responderName = responderId["fullName"] as? String
        } else {
            self.responderName = nil
        }
        
        // Get estimated arrival
        if let assignedResponder = alertData["assignedResponder"] as? [String: Any],
           let routeInfo = assignedResponder["routeInfo"] as? [String: Any] {
            self.estimatedArrival = routeInfo["estimatedArrival"] as? String
        } else {
            self.estimatedArrival = nil
        }
    }
    
    init(id: String, title: String, address: String, status: IncidentStatus, mapImageUrl: String, date: Date, type: String = "panic", responderName: String? = nil, estimatedArrival: String? = nil) {
        self.id = id
        self.title = title
        self.address = address
        self.status = status
        self.mapImageUrl = mapImageUrl
        self.date = date
        self.type = type
        self.responderName = responderName
        self.estimatedArrival = estimatedArrival
    }
}

struct IncidentLogsView: View {
    @State private var incidentLogs: [IncidentLog] = []
    @ObservedObject private var authManager = AuthManager.shared
    @EnvironmentObject private var navigationManager: NavigationManager
    @State private var isLoading = false
    @State private var isDeleting = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    @State private var successMessage = ""
    
    @State private var isLoadingPanicAlert = false
    @State private var showPanicAlertSuccess = false
    @StateObject private var locationManager = LocationManager()
    
//    @Environment(\.presentationMode) var presentationMode
    @State private var showingDeleteAlert = false
    @State private var incidentToDelete: IncidentLog?
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - FIXED HEADER (Does NOT scroll)
            VStack(spacing: 20) {
                // MARK: - Panic Alert & Notification Row
                HStack(spacing: 12) {
                    // Panic Alert Button - Now clickable
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
                
                // MARK: - Incident Logs Header
                VStack(spacing: 8) {
                    // Incident Logs icon and title ONLY
                    HStack(spacing: 8) {
                        Image("incidentLogs")
                            .resizable()
                            .frame(width: 14, height: 14)
                            .padding(.horizontal, 10)
                        
                        Text("Incident Logs")
                            .font(.custom("Poppins-SemiBold", size: 14))
                            .foregroundColor(.black)
                        
                        Spacer()
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
            
            // MARK: - SCROLLABLE INCIDENT LOGS LIST
            if isLoading {
                VStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding()
                    Text("Loading incident logs...")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                }
            } else if incidentLogs.isEmpty {
                VStack(spacing: 20) {
                    Spacer()
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No Incident Logs")
                        .font(.custom("Poppins-SemiBold", size: 18))
                        .foregroundColor(.black)
                    Text("You haven't made any emergency alerts yet.")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(incidentLogs.enumerated()), id: \.element.id) { index, incident in
                            VStack(spacing: 0) {
                                IncidentLogCard(
                                    incident: incident,
                                    isDeleting: isDeleting && incidentToDelete?.id == incident.id,
                                    onDelete: {
                                        incidentToDelete = incident
                                        showingDeleteAlert = true
                                    }
                                )
                                
                                // Add thin divider line after each card except the last one
                                if index < incidentLogs.count - 1 {
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
                    await fetchIncidentLogs()
                }
            }
            
            // MARK: - Bottom Navigation (Fixed)
//            IncidentLogsTabBar(
//                userName: authManager.currentUser?.fullName ?? "Seun Odueso",
//                profileImage: "profileImage"
//            )
        }
        .background(Color.white)
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .onAppear {
            fetchIncidentLogs()
            locationManager.requestLocation()
        }
        .onChange(of: locationManager.permissionDenied) { oldValue, denied in
            if denied {
                errorMessage = "Location permission is required to send panic alerts."
                showError = true
                print("❌ Location permission denied")
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .alert("Success", isPresented: $showSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(successMessage)
        }
        .alert("Panic Alert Sent", isPresented: $showPanicAlertSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(successMessage)
        }
        .alert(isPresented: $showingDeleteAlert) {
            if let incident = incidentToDelete {
                if canDeleteIncident(incident) {
                    return Alert(
                        title: Text("Delete Incident"),
                        message: Text("Are you sure you want to delete this incident log? This action cannot be undone."),
                        primaryButton: .destructive(Text("Delete")) {
                            deleteIncidentLog(incident)
                        },
                        secondaryButton: .cancel()
                    )
                } else {
                    return Alert(
                        title: Text("Cannot Delete"),
                        message: Text("Alerts with '\(incident.status.rawValue)' status cannot be deleted. Please wait until the alert is resolved or cancelled."),
                        dismissButton: .default(Text("OK"))
                    )
                }
            } else {
                return Alert(
                    title: Text("Error"),
                    message: Text("No incident selected for deletion."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    // MARK: - Panic Alert Handler (same as in DashboardView)
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
                                // Refresh incident logs to show the new alert
                                self.fetchIncidentLogs()
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
                        
                        // Refresh incident logs to show the new alert
                        self.fetchIncidentLogs()
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
    
    // MARK: - API Methods
    
    private func fetchIncidentLogs() {
        guard let token = authManager.authToken else {
            errorMessage = "Please login to view incident logs"
            showError = true
            return
        }
        
        isLoading = true
        
        let urlString = "https://guardian-fwpg.onrender.com/api/v1/alert/user-alerts"
        print("🌐 Fetching incident logs from: \(urlString)")
        
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
        print("📤 Sending incident logs request...")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    self.showError = true
                    print("❌ Incident logs API error:", error.localizedDescription)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Incident logs HTTP Status: \(httpResponse.statusCode)")
                    
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
                    print("❌ No data received for incident logs")
                    return
                }
                
                // Print raw response for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📦 Incident logs response: \(jsonString.prefix(1000))...")
                }
                
                do {
                    // Parse the response
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let success = json["success"] as? Bool, success {
                            if let dataArray = json["data"] as? [[String: Any]] {
                                
                                print("✅ Found \(dataArray.count) incident logs")
                                
                                // Map API data to IncidentLog objects
                                let logs = dataArray.map { alertData in
                                    return IncidentLog(from: alertData)
                                }
                                
                                // Sort by date (newest first)
                                self.incidentLogs = logs.sorted { $0.date > $1.date }
                            } else {
                                print("⚠️ No data field found in response")
                                self.incidentLogs = []
                            }
                        } else {
                            if let message = json["message"] as? String {
                                self.errorMessage = message
                                self.showError = true
                                print("❌ API returned success=false: \(message)")
                            }
                        }
                    }
                } catch {
                    self.errorMessage = "Failed to parse server response"
                    self.showError = true
                    print("❌ JSON parsing error: \(error)")
                }
            }
        }.resume()
    }
    
    private func deleteIncidentLog(_ incident: IncidentLog) {
        guard let token = authManager.authToken else {
            errorMessage = "Please login to delete incident logs"
            showError = true
            return
        }
        
        isDeleting = true
        
        let alertId = incident.id
        let urlString = "https://guardian-fwpg.onrender.com/api/v1/alert/user-alerts/\(alertId)"
        print("🌐 Deleting incident log at: \(urlString)")
        print("🗑️ Alert ID: \(alertId)")
        print("📊 Alert Status: \(incident.status.rawValue)")
        
        guard let url = URL(string: urlString) else {
            isDeleting = false
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
                self.isDeleting = false
                
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    self.showError = true
                    print("❌ Delete incident log API error:", error.localizedDescription)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Delete incident log HTTP Status: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 401 {
                        self.errorMessage = "Session expired. Please login again."
                        self.showError = true
                        print("❌ 401 Unauthorized - Token may be expired")
                        return
                    }
                    
                    if httpResponse.statusCode == 404 {
                        self.errorMessage = "Incident log not found. It may have already been deleted."
                        self.showError = true
                        print("❌ 404 Not Found - Alert ID \(alertId) not found")
                        // Still remove from local array since it doesn't exist on server
                        self.incidentLogs.removeAll { $0.id == incident.id }
                        return
                    }
                }
                
                guard let data = data else {
                    self.errorMessage = "No response from server"
                    self.showError = true
                    print("❌ No data received from delete request")
                    return
                }
                
                // Print raw response for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📦 Delete incident log raw response: \(jsonString)")
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        
                        // Check if the response has a success flag
                        if let success = json["success"] as? Bool {
                            if success {
                                // Success - remove from local array
                                self.incidentLogs.removeAll { $0.id == incident.id }
                                self.successMessage = "Incident log deleted successfully"
                                self.showSuccess = true
                                print("✅ Incident log deleted successfully")
                            } else {
                                // Handle error from backend
                                if let errorMessage = json["error"] as? String {
                                    // Check for specific error messages about alert status
                                    if errorMessage.lowercased().contains("cannot delete") &&
                                       errorMessage.lowercased().contains("status") {
                                        // Extract the status from error message if available
                                        var statusSpecificMessage = errorMessage
                                        
                                        // You could also parse the status from the error message:
                                        // Example: "Cannot delete alert with status: acknowledged"
                                        let alertStatus = incident.status.rawValue
                                        self.errorMessage = "Cannot delete alert with '\(alertStatus)' status. Please wait until the alert is resolved or cancelled."
                                    } else {
                                        self.errorMessage = errorMessage
                                    }
                                } else if let message = json["message"] as? String {
                                    self.errorMessage = message
                                } else {
                                    self.errorMessage = "Failed to delete incident log"
                                }
                                
                                self.showError = true
                                print("❌ Delete failed: \(self.errorMessage)")
                            }
                        } else if let message = json["message"] as? String {
                            // Handle responses that might not have a "success" field
                            if message.lowercased().contains("deleted") ||
                               message.lowercased().contains("success") {
                                // Success message without success flag
                                self.incidentLogs.removeAll { $0.id == incident.id }
                                self.successMessage = message
                                self.showSuccess = true
                                print("✅ Incident log deleted: \(message)")
                            } else {
                                // Error message
                                self.errorMessage = message
                                self.showError = true
                                print("❌ Delete failed: \(message)")
                            }
                        } else {
                            // No success flag or message field found
                            self.errorMessage = "Unexpected response from server"
                            self.showError = true
                            print("❌ Unexpected response format")
                        }
                    } else {
                        self.errorMessage = "Invalid response from server"
                        self.showError = true
                        print("❌ Invalid JSON response")
                    }
                } catch {
                    self.errorMessage = "Failed to parse server response: \(error.localizedDescription)"
                    self.showError = true
                    print("❌ JSON parsing error: \(error)")
                }
            }
        }.resume()
    }
    
    private func canDeleteIncident(_ incident: IncidentLog) -> Bool {
        // Define which statuses cannot be deleted
        let nonDeletableStatuses: [IncidentStatus] = [.active, .acknowledged, .onScene]
        
        // Return true if status is NOT in non-deletable statuses
        return !nonDeletableStatuses.contains(incident.status)
    }
}

// MARK: - Incident Log Card
struct IncidentLogCard: View {
    let incident: IncidentLog
    let isDeleting: Bool
    let onDelete: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Map Image (rounded square) - Using AsyncImage for URL loading
            if !incident.mapImageUrl.isEmpty {
                AsyncImage(url: URL(string: incident.mapImageUrl)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 80, height: 80)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    case .failure:
                        // Fallback image if URL fails
                        Image(systemName: "map.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                            .frame(width: 80, height: 80)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                // Placeholder if no map URL
                Image(systemName: "map.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
                    .frame(width: 80, height: 80)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            }
            
            VStack(alignment: .leading, spacing: 8) {
                // Title and Type
                VStack(alignment: .leading, spacing: 2) {
                    Text(incident.title)
                        .font(.custom("Poppins-SemiBold", size: 16))
                        .foregroundColor(.black)
                    
                    // Show responder name if available
                    if let responderName = incident.responderName {
                        Text("Responder: \(responderName)")
                            .font(.custom("Poppins-Regular", size: 11))
                            .foregroundColor(.gray)
                    }
                }
                
                // Address
                Text(incident.address)
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Date
                Text(formatDate(incident.date))
                    .font(.custom("Poppins-Regular", size: 11))
                    .foregroundColor(.gray)
                
                // Status Enclosure (light gray background)
                HStack(spacing: 6) {
                    Image(incident.status.iconName)
                        .resizable()
                        .frame(width: 12, height: 12)
                    
                    Text(incident.status.rawValue)
                        .font(.custom("Poppins-Regular", size: 11))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(4)
            }
            
            Spacer()
            
            // Delete Button with loading state
            if isDeleting {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                    .scaleEffect(0.8)
                    .frame(width: 30, height: 30)
            } else if canDeleteIncident(incident) {
                Button(action: onDelete) {
                    Image("delete")
                        .resizable()
                        .frame(width: 16.15, height: 18.48)
                        .foregroundColor(.gray)
                }
                .padding(8)
            } else {
                // Show disabled delete button or info icon for non-deletable incidents
                Image("delete")
                    .resizable()
                    .frame(width: 16.15, height: 18.48)
                    .foregroundColor(.gray.opacity(0.3))
                    .padding(8)
                    .onTapGesture {
                        // Optionally show a tooltip or message explaining why it can't be deleted
                        print("Cannot delete alert with status: \(incident.status.rawValue)")
                    }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.white)
        .opacity(isDeleting ? 0.6 : 1.0)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func canDeleteIncident(_ incident: IncidentLog) -> Bool {
        // Define which statuses cannot be deleted
        let nonDeletableStatuses: [IncidentStatus] = [.active, .acknowledged, .onScene]
        
        // Return true if status is NOT in non-deletable statuses
        return !nonDeletableStatuses.contains(incident.status)
    }
}

// MARK: - Modified Tab Bar for Incident Logs (Active State)
//struct IncidentLogsTabBar: View {
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
//            // Emergency Contacts Tab (Inactive)
//            TabBarItemView(
//                icon: "emergencyContacts",
//                title: "Emergency Contacts"
//            )
//            
//            // Incident Logs Tab (Active)
//            TabBarItemView(
//                icon: "clickedIncidentLogs",
//                title: "Incident Logs",
//                active: true
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
struct IncidentLogsView_Previews: PreviewProvider {
    static var previews: some View {
        IncidentLogsView()
    }
}
