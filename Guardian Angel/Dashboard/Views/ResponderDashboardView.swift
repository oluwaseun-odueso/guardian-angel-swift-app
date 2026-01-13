//
//  ResponderDashboardView.swift
//  Guardian Angel
//
//  Created by Oluwaseun Odueso on 12/01/2026.
//

import SwiftUI
import MapKit
internal import Combine
internal 
struct ResponderDashboardView: View {
    @EnvironmentObject private var authManager: AuthManager
    @StateObject private var alertManager = ResponderAlertManager()
    @State private var selectedTab = 0
    @State private var showingProfile = false
    @State private var showingCancelAlert = false
    @State private var selectedAlertForCancel: AlertItem?
    @State private var cancelReason = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Tabs
                tabView
                
                // Content based on selected tab
                ZStack {
                    if alertManager.isLoadingProfile || alertManager.isLoadingAlerts {
                        loadingView
                    } else if alertManager.profile == nil {
                        errorView
                    } else {
                        contentView
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(hex: "F8F9FA"))
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingProfile) {
                if let profile = alertManager.profile {
                    ResponderProfileView(profile: profile)
                }
            }
            .alert("Cancel Alert", isPresented: $showingCancelAlert) {
                TextField("Reason for cancellation", text: $cancelReason)
                Button("Cancel", role: .destructive) {
                    showingCancelAlert = false
                    cancelReason = ""
                }
                Button("Submit", role: .cancel) {
                    if let alert = selectedAlertForCancel {
                        alertManager.cancelAlert(alert.id, reason: cancelReason)
                        cancelReason = ""
                        showingCancelAlert = false
                    }
                }
                .disabled(cancelReason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            } message: {
                Text("Please provide a reason for cancelling this alert.")
            }
            .onAppear {
                if authManager.currentUser?.role == "respondent" {
                    alertManager.fetchProfileAndAlerts()
                }
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let profile = alertManager.profile {
                        Text("Welcome, \(profile.fullName)")
                            .font(.custom("Poppins-SemiBold", size: 18))
                            .foregroundColor(Color(hex: "002147"))
                    } else {
                        Text("Welcome, Responder")
                            .font(.custom("Poppins-SemiBold", size: 18))
                            .foregroundColor(Color(hex: "002147"))
                    }
                    
                    if let status = alertManager.profile?.status {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(statusColor(for: status))
                                .frame(width: 8, height: 8)
                            Text(status.capitalized)
                                .font(.custom("Poppins-Regular", size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Spacer()
                
                // Profile Button
                Button(action: {
                    showingProfile = true
                }) {
                    if let profile = alertManager.profile {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "002147").opacity(0.1))
                                .frame(width: 40, height: 40)
                            
                            Text(profile.fullName.prefix(1).uppercased())
                                .font(.custom("Poppins-SemiBold", size: 16))
                                .foregroundColor(Color(hex: "002147"))
                        }
                    } else {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "002147"))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 8)
            
            // Stats Cards
            if let profile = alertManager.profile {
                statsCardsView(profile: profile)
            }
        }
        .padding(.bottom, 16)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func statsCardsView(profile: ResponderProfile) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Rating Card
                statsCard(
                    title: "Rating",
                    value: String(format: "%.1f", profile.rating),
                    icon: "star.fill",
                    color: Color(hex: "FFD700")
                )
                
                // Assignments Card
                statsCard(
                    title: "Assignments",
                    value: "\(profile.totalAssignments)",
                    icon: "checkmark.circle.fill",
                    color: Color(hex: "47D63A")
                )
                
                // Success Rate Card
                let successRate = profile.totalAssignments > 0 ?
                    Int(Double(profile.successfulAssignments) / Double(profile.totalAssignments) * 100) : 0
                statsCard(
                    title: "Success Rate",
                    value: "\(successRate)%",
                    icon: "chart.bar.fill",
                    color: Color(hex: "007AFF")
                )
                
                // Response Time Card
                statsCard(
                    title: "Avg Response",
                    value: "\(Int(profile.responseTimeAvg))s",
                    icon: "clock.fill",
                    color: Color(hex: "FF9500")
                )
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func statsCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            Text(value)
                .font(.custom("Poppins-Bold", size: 18))
                .foregroundColor(Color(hex: "002147"))
            
            Text(title)
                .font(.custom("Poppins-Regular", size: 11))
                .foregroundColor(.gray)
        }
        .padding(12)
        .frame(width: 120)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Tab View
    private var tabView: some View {
        HStack(spacing: 0) {
            TabButton(title: "Active", count: alertManager.activeAlerts.count, isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            
            TabButton(title: "All Alerts", count: alertManager.allAlerts.count, isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            
            TabButton(title: "History", count: alertManager.historyAlerts.count, isSelected: selectedTab == 2) {
                selectedTab = 2
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private struct TabButton: View {
        let title: String
        let count: Int
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: 6) {
                    Text(title)
                        .font(.custom(isSelected ? "Poppins-SemiBold" : "Poppins-Regular", size: 14))
                        .foregroundColor(isSelected ? Color(hex: "002147") : .gray)
                    
                    if count > 0 {
                        Text("\(count)")
                            .font(.custom("Poppins-SemiBold", size: 10))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(isSelected ? Color(hex: "002147") : Color.gray)
                            .cornerRadius(10)
                    }
                    
                    Rectangle()
                        .fill(isSelected ? Color(hex: "002147") : Color.clear)
                        .frame(height: 2)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Content View
    private var contentView: some View {
        VStack(spacing: 0) {
            // Filter and Search (optional)
            if selectedTab == 1 {
                filterView
            }
            
            // Alerts List
            ScrollView {
                VStack(spacing: 16) {
                    let alerts = alertsForSelectedTab
                    
                    if alerts.isEmpty {
                        emptyStateView
                    } else {
                        ForEach(alerts) { alert in
                            AlertCardView(
                                alert: alert,
                                onAcknowledge: {
                                    alertManager.acknowledgeAlert(alert.id)
                                },
                                onResolve: {
                                    alertManager.resolveAlert(alert.id)
                                },
                                onCancel: {
                                    selectedAlertForCancel = alert
                                    showingCancelAlert = true
                                }
                            )
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.vertical, 16)
            }
            .refreshable {
                await refreshData()
            }
        }
    }
    
    private var alertsForSelectedTab: [AlertItem] {
        switch selectedTab {
        case 0: return alertManager.activeAlerts
        case 1: return alertManager.allAlerts
        case 2: return alertManager.historyAlerts
        default: return []
        }
    }
    
    // MARK: - Filter View
    private var filterView: some View {
        HStack {
            Menu {
                Button("All Status", action: { alertManager.selectedFilter = .all })
                Button("Active", action: { alertManager.selectedFilter = .active })
                Button("Acknowledged", action: { alertManager.selectedFilter = .acknowledged })
                Button("Resolved", action: { alertManager.selectedFilter = .resolved })
                Button("Cancelled", action: { alertManager.selectedFilter = .cancelled })
            } label: {
                HStack {
                    Text(alertManager.selectedFilter.rawValue)
                        .font(.custom("Poppins-Regular", size: 12))
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                }
                .foregroundColor(.gray)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
            
            Menu {
                Button("All Types", action: { alertManager.selectedAlertType = .all })
                Button("Panic", action: { alertManager.selectedAlertType = .panic })
                Button("Manual", action: { alertManager.selectedAlertType = .manual })
            } label: {
                HStack {
                    Text(alertManager.selectedAlertType.rawValue)
                        .font(.custom("Poppins-Regular", size: 12))
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                }
                .foregroundColor(.gray)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
            
            Spacer()
            
            Button(action: {
                alertManager.sortNewestFirst.toggle()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 10))
                    
                    Text(alertManager.sortNewestFirst ? "Newest" : "Oldest")
                        .font(.custom("Poppins-Regular", size: 12))
                }
                .foregroundColor(.gray)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(hex: "F8F9FA"))
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: emptyStateIcon)
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.3))
            
            Text(emptyStateTitle)
                .font(.custom("Poppins-SemiBold", size: 16))
                .foregroundColor(.gray)
            
            Text(emptyStateMessage)
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundColor(.gray.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.vertical, 60)
    }
    
    private var emptyStateIcon: String {
        switch selectedTab {
        case 0: return "bell.slash"
        case 1: return "doc.text.magnifyingglass"
        case 2: return "clock.arrow.circlepath"
        default: return "tray"
        }
    }
    
    private var emptyStateTitle: String {
        switch selectedTab {
        case 0: return "No Active Alerts"
        case 1: return "No Alerts Found"
        case 2: return "No History Available"
        default: return "No Data"
        }
    }
    
    private var emptyStateMessage: String {
        switch selectedTab {
        case 0: return "You don't have any active alerts at the moment. All assigned alerts will appear here."
        case 1: return "No alerts match your current filters. Try adjusting your filter settings."
        case 2: return "Your alert history will appear here once you complete assignments."
        default: return ""
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading Dashboard...")
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundColor(.gray)
        }
    }
    
    // MARK: - Error View
    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Unable to Load Dashboard")
                .font(.custom("Poppins-SemiBold", size: 16))
                .foregroundColor(.gray)
            
            Text(alertManager.errorMessage ?? "Please check your connection and try again.")
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundColor(.gray.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button("Retry") {
                alertManager.fetchProfileAndAlerts()
            }
            .font(.custom("Poppins-SemiBold", size: 14))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color(hex: "002147"))
            .cornerRadius(8)
        }
        .padding(.vertical, 60)
    }
    
    // MARK: - Helper Functions
    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "available": return Color(hex: "47D63A")
        case "busy": return Color(hex: "EEC408")
        case "offline": return Color(hex: "3A3A3A")
        default: return .gray
        }
    }
    
    private func refreshData() async {
        alertManager.fetchProfileAndAlerts()
        try? await Task.sleep(nanoseconds: 500_000_000)
    }
}

// MARK: - Alert Card View
struct AlertCardView: View {
    let alert: AlertItem
    let onAcknowledge: () -> Void
    let onResolve: () -> Void
    let onCancel: () -> Void
    
    @State private var showingMap = false
    @State private var showingUserDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with status and time
            HStack {
                // Status badge
                HStack(spacing: 6) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)
                    
                    Text(alert.status.capitalized)
                        .font(.custom("Poppins-SemiBold", size: 12))
                        .foregroundColor(statusColor)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.1))
                .cornerRadius(6)
                
                Spacer()
                
                // Time and distance
                VStack(alignment: .trailing, spacing: 2) {
                    Text(timeAgo)
                        .font(.custom("Poppins-Regular", size: 11))
                        .foregroundColor(.gray)
                    
                    if let distance = alert.assignedResponder?.routeInfo?.distance?.text, distance != "1 ft" {
                        Text("• \(distance)")
                            .font(.custom("Poppins-Regular", size: 11))
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // User and location info
            VStack(alignment: .leading, spacing: 12) {
                // User info
                Button(action: { showingUserDetails = true }) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "002147").opacity(0.1))
                                .frame(width: 40, height: 40)
                            
                            Text(alert.userId.fullName.prefix(1).uppercased())
                                .font(.custom("Poppins-SemiBold", size: 16))
                                .foregroundColor(Color(hex: "002147"))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(alert.userId.fullName)
                                .font(.custom("Poppins-SemiBold", size: 14))
                                .foregroundColor(Color(hex: "002147"))
                            
                            HStack(spacing: 12) {
                                Label(alert.userId.phone, systemImage: "phone.fill")
                                    .font(.custom("Poppins-Regular", size: 11))
                                    .foregroundColor(.gray)
                                
                                if let bloodType = alert.userId.medicalInfo?.bloodType {
                                    Label(bloodType, systemImage: "drop.fill")
                                        .font(.custom("Poppins-Regular", size: 11))
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                
                // Location info with map preview
                Button(action: { showingMap = true }) {
                    HStack(spacing: 12) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "002147"))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            if let street = alert.location.geocodedData?.street {
                                Text(street)
                                    .font(.custom("Poppins-Regular", size: 13))
                                    .foregroundColor(.black)
                            }
                            
                            if let city = alert.location.geocodedData?.city {
                                Text("\(city), \(alert.location.geocodedData?.state ?? "")")
                                    .font(.custom("Poppins-Regular", size: 11))
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "map.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Alert type and actions
            HStack {
                // Alert type
                HStack(spacing: 6) {
                    Image(systemName: alert.type == "panic" ? "exclamationmark.triangle.fill" : "hand.raised.fill")
                        .font(.system(size: 10))
                    
                    Text(alert.type.capitalized)
                        .font(.custom("Poppins-Regular", size: 11))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(alert.type == "panic" ? Color.red : Color.orange)
                .cornerRadius(6)
                
                Spacer()
                
                // Action buttons based on status
                actionButtons
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .sheet(isPresented: $showingMap) {
            if let coordinates = alert.location.coordinates,
               coordinates.count == 2 {
                AlertMapView(
                    latitude: coordinates[1],
                    longitude: coordinates[0],
                    address: alert.location.address ?? alert.location.geocodedData?.formattedAddress ?? ""
                )
            }
        }
        .sheet(isPresented: $showingUserDetails) {
            UserDetailsView(
                user: alert.userId,
                medicalInfo: alert.userId.medicalInfo
            )
        }
    }
    
    private var statusColor: Color {
        switch alert.status {
        case "active": return Color(hex: "FF0000")
        case "acknowledged": return Color(hex: "EEC408")
        case "resolved": return Color(hex: "47D63A")
        case "cancelled": return Color(hex: "3A3A3A")
        default: return .gray
        }
    }
    
    private var timeAgo: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = dateFormatter.date(from: alert.createdAt) {
            let now = Date()
            let interval = now.timeIntervalSince(date)
            
            if interval < 60 {
                return "Just now"
            } else if interval < 3600 {
                let minutes = Int(interval / 60)
                return "\(minutes)m ago"
            } else if interval < 86400 {
                let hours = Int(interval / 3600)
                return "\(hours)h ago"
            } else {
                let days = Int(interval / 86400)
                return "\(days)d ago"
            }
        }
        
        return alert.createdAt
    }
    
    @ViewBuilder
    private var actionButtons: some View {
        HStack(spacing: 8) {
            switch alert.status {
            case "active":
                Button(action: onAcknowledge) {
                    Text("Acknowledge")
                        .font(.custom("Poppins-SemiBold", size: 12))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(hex: "002147"))
                        .cornerRadius(8)
                }
                
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.custom("Poppins-SemiBold", size: 12))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red)
                        .cornerRadius(8)
                }
                
            case "acknowledged":
                Button(action: onResolve) {
                    Text("Resolve")
                        .font(.custom("Poppins-SemiBold", size: 12))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green)
                        .cornerRadius(8)
                }
                
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.custom("Poppins-SemiBold", size: 12))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red)
                        .cornerRadius(8)
                }
                
            case "resolved", "cancelled":
                Text("Completed")
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(.gray)
                    .italic()
                
            default:
                EmptyView()
            }
        }
    }
}

// MARK: - Alert Map View
struct AlertMapView: View {
    let latitude: Double
    let longitude: Double
    let address: String
    
    @State private var region: MKCoordinateRegion
    @Environment(\.dismiss) private var dismiss
    
    init(latitude: Double, longitude: Double, address: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        _region = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Map(coordinateRegion: $region, annotationItems: [AnnotationItem(coordinate: region.center)]) { item in
                    MapMarker(coordinate: item.coordinate, tint: .red)
                }
                .frame(height: 300)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Alert Location")
                        .font(.custom("Poppins-SemiBold", size: 16))
                        .foregroundColor(Color(hex: "002147"))
                    
                    Text(address)
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.red)
                        
                        Text(String(format: "%.6f, %.6f", latitude, longitude))
                            .font(.custom("Poppins-Regular", size: 12))
                            .foregroundColor(.gray)
                    }
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(12)
                .padding(16)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Location Details")
                        .font(.custom("Poppins-SemiBold", size: 16))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.custom("Poppins-SemiBold", size: 14))
                }
            }
        }
    }
}

struct AnnotationItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// MARK: - User Details View (Using your MedicalInfoCard)
struct UserDetailsView: View {
    let user: AlertUser
    let medicalInfo: MedicalInfo?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // User Profile
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "002147").opacity(0.1))
                                .frame(width: 80, height: 80)
                            
                            Text(user.fullName.prefix(1).uppercased())
                                .font(.custom("Poppins-Bold", size: 32))
                                .foregroundColor(Color(hex: "002147"))
                        }
                        
                        VStack(spacing: 4) {
                            Text(user.fullName)
                                .font(.custom("Poppins-SemiBold", size: 18))
                                .foregroundColor(Color(hex: "002147"))
                            
                            Text(user.phone)
                                .font(.custom("Poppins-Regular", size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Medical Information using your existing MedicalInfoCard
                    if let medicalInfo = medicalInfo {
                        MedicalInfoCard(
                            bloodType: medicalInfo.bloodType ?? "Not specified",
                            allergies: medicalInfo.allergies.joined(separator: ", "),
                            conditions: medicalInfo.conditions.joined(separator: ", ")
                        )
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 30)
            }
            .background(Color(hex: "F8F9FA"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("User Details")
                        .font(.custom("Poppins-SemiBold", size: 16))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.custom("Poppins-SemiBold", size: 14))
                }
            }
        }
    }
}

// MARK: - Responder Profile View
struct ResponderProfileView: View {
    let profile: ResponderProfile
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    profileHeader
                    
                    // Contact Info
                    contactInfo
                    
                    // Professional Info
                    professionalInfo
                    
                    // Certifications
                    certificationsView
                    
                    // Availability
                    availabilityView
                    
                    // Stats
                    statsView
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(Color(hex: "F8F9FA"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Profile")
                        .font(.custom("Poppins-SemiBold", size: 16))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.custom("Poppins-SemiBold", size: 14))
                }
            }
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: "002147").opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Text(profile.fullName.prefix(1).uppercased())
                    .font(.custom("Poppins-Bold", size: 40))
                    .foregroundColor(Color(hex: "002147"))
            }
            
            VStack(spacing: 4) {
                Text(profile.fullName)
                    .font(.custom("Poppins-SemiBold", size: 20))
                    .foregroundColor(Color(hex: "002147"))
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(statusColor(for: profile.status))
                        .frame(width: 8, height: 8)
                    
                    Text(profile.status.capitalized)
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.top, 20)
    }
    
    private var contactInfo: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Contact Information")
                .font(.custom("Poppins-SemiBold", size: 16))
                .foregroundColor(Color(hex: "002147"))
            
            detailRow(icon: "envelope.fill", title: "Email", value: profile.email)
            detailRow(icon: "phone.fill", title: "Phone", value: profile.phone)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var professionalInfo: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Professional Information")
                .font(.custom("Poppins-SemiBold", size: 16))
                .foregroundColor(Color(hex: "002147"))
            
            detailRow(icon: "stethoscope", title: "Experience", value: "\(profile.experienceYears) years")
            detailRow(icon: "car.fill", title: "Vehicle", value: profile.vehicleType.capitalized)
            detailRow(icon: "doc.text.fill", title: "License", value: profile.licenseNumber)
            detailRow(icon: "map.fill", title: "Max Distance", value: "\(profile.maxDistance) km")
            
            if !profile.bio.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Bio", systemImage: "text.quote")
                        .font(.custom("Poppins-SemiBold", size: 14))
                        .foregroundColor(.gray)
                    
                    Text(profile.bio)
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var certificationsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Certifications")
                .font(.custom("Poppins-SemiBold", size: 16))
                .foregroundColor(Color(hex: "002147"))
            
            FlowLayout(spacing: 8) {
                ForEach(profile.certifications, id: \.self) { certification in
                    Text(certification)
                        .font(.custom("Poppins-Regular", size: 12))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(hex: "002147"))
                        .cornerRadius(15)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var availabilityView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Availability")
                .font(.custom("Poppins-SemiBold", size: 16))
                .foregroundColor(Color(hex: "002147"))
            
            VStack(spacing: 12) {
                ForEach(ResponderDayOfWeek.allCases, id: \.self) { day in
                    HStack {
                        Text(day.rawValue)
                            .font(.custom("Poppins-SemiBold", size: 14))
                            .foregroundColor(Color(hex: "002147"))
                            .frame(width: 60, alignment: .leading)
                        
                        availabilityBar(for: day)
                        
                        Text(availableHours(for: day))
                            .font(.custom("Poppins-Regular", size: 12))
                            .foregroundColor(.gray)
                            .frame(width: 80, alignment: .trailing)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var statsView: some View {
        HStack(spacing: 12) {
            statsCard(title: "Rating", value: String(format: "%.1f", profile.rating), icon: "star.fill")
            statsCard(title: "Total", value: "\(profile.totalAssignments)", icon: "checkmark.circle.fill")
            statsCard(title: "Success", value: "\(profile.successfulAssignments)", icon: "trophy.fill")
            statsCard(title: "Avg Time", value: "\(Int(profile.responseTimeAvg))s", icon: "clock.fill")
        }
    }
    
    private func availabilityBar(for day: ResponderDayOfWeek) -> some View {
        let hours = availabilityForDay(day)
        let availableCount = hours.filter { $0 }.count
        
        return HStack(spacing: 2) {
            ForEach(0..<24) { hour in
                Rectangle()
                    .fill(hours[hour] ? Color(hex: "47D63A") : Color.gray.opacity(0.2))
                    .frame(height: 8)
                    .cornerRadius(2)
            }
        }
    }
    
    private func availableHours(for day: ResponderDayOfWeek) -> String {
        let hours = availabilityForDay(day)
        guard let firstHour = hours.firstIndex(of: true),
              let lastHour = hours.lastIndex(of: true) else {
            return "Unavailable"
        }
        
        return "\(firstHour):00-\(lastHour + 1):00"
    }
    
    private func availabilityForDay(_ day: ResponderDayOfWeek) -> [Bool] {
        switch day {
        case .monday: return profile.availability.monday
        case .tuesday: return profile.availability.tuesday
        case .wednesday: return profile.availability.wednesday
        case .thursday: return profile.availability.thursday
        case .friday: return profile.availability.friday
        case .saturday: return profile.availability.saturday
        case .sunday: return profile.availability.sunday
        }
    }
    
    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "002147"))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.custom("Poppins-SemiBold", size: 14))
                    .foregroundColor(.black)
            }
            
            Spacer()
        }
    }
    
    private func statsCard(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "002147"))
            
            Text(value)
                .font(.custom("Poppins-Bold", size: 18))
                .foregroundColor(Color(hex: "002147"))
            
            Text(title)
                .font(.custom("Poppins-Regular", size: 11))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "available": return Color(hex: "47D63A")
        case "busy": return Color(hex: "EEC408")
        case "offline": return Color(hex: "3A3A3A")
        default: return .gray
        }
    }
}

// MARK: - Responder Alert Manager
@MainActor class ResponderAlertManager: ObservableObject {
    
    @Published var profile: ResponderProfile?
    @Published var allAlerts: [AlertItem] = []
    @Published var isLoadingProfile = false
    @Published var isLoadingAlerts = false
    @Published var errorMessage: String?
    @Published var selectedFilter: AlertFilter = .all
    @Published var selectedAlertType: AlertType = .all
    @Published var sortNewestFirst = true
    
    var activeAlerts: [AlertItem] {
        let filtered = allAlerts.filter { $0.status == "active" }
        return sortAlerts(filtered)
    }
    
    var historyAlerts: [AlertItem] {
        let filtered = allAlerts.filter { $0.status == "resolved" || $0.status == "cancelled" }
        return sortAlerts(filtered)
    }
    
    private func sortAlerts(_ alerts: [AlertItem]) -> [AlertItem] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        return alerts.sorted { alert1, alert2 in
            guard let date1 = dateFormatter.date(from: alert1.createdAt),
                  let date2 = dateFormatter.date(from: alert2.createdAt) else {
                return false
            }
            
            return sortNewestFirst ? date1 > date2 : date1 < date2
        }
    }
    
    func fetchProfileAndAlerts() {
        fetchProfile()
        fetchAlerts()
    }
    
    func fetchProfile() {
        guard let token = AuthManager.shared.authToken else { return }
        
        isLoadingProfile = true
        errorMessage = nil
        
        let url = URL(string: "https://guardian-fwpg.onrender.com/api/v1/responder/profile")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 30
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoadingProfile = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No response data"
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    let response = try decoder.decode(ResponderProfileResponse.self, from: data)
                    
                    if response.success {
                        self.profile = response.data
                    } else {
                        self.errorMessage = response.message
                    }
                } catch {
                    self.errorMessage = "Failed to parse profile: \(error.localizedDescription)"
                    print("❌ Profile parsing error: \(error)")
                }
            }
        }.resume()
    }
    
    func fetchAlerts() {
        guard let token = AuthManager.shared.authToken else { return }
        
        isLoadingAlerts = true
        
        let url = URL(string: "https://guardian-fwpg.onrender.com/api/v1/responder/alerts/assigned-alerts")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 30
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoadingAlerts = false
                
                if let error = error {
                    print("❌ Alerts fetch error: \(error)")
                    return
                }
                
                guard let data = data else {
                    print("❌ No alerts data")
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    let response = try decoder.decode(AssignedAlertsResponse.self, from: data)
                    
                    if response.success {
                        self.allAlerts = response.data
                        print("✅ Loaded \(self.allAlerts.count) alerts")
                    } else {
                        print("❌ Alerts fetch failed: \(response.message)")
                    }
                } catch {
                    print("❌ Alerts parsing error: \(error)")
                }
            }
        }.resume()
    }
    
    func acknowledgeAlert(_ alertId: String) {
        updateAlertStatus(endpoint: "acknowledge/\(alertId)", method: "POST")
    }
    
    func resolveAlert(_ alertId: String) {
        updateAlertStatus(endpoint: "resolve/\(alertId)", method: "POST")
    }
    
    func cancelAlert(_ alertId: String, reason: String) {
        guard let token = AuthManager.shared.authToken else { return }
        
        let url = URL(string: "https://guardian-fwpg.onrender.com/api/v1/responder/alerts/cancel/\(alertId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["reason": reason]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("❌ Cancel alert JSON error: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Cancel alert error: \(error)")
                    return
                }
                
                print("✅ Alert cancelled")
                self.fetchAlerts() // Refresh alerts
            }
        }.resume()
    }
    
    private func updateAlertStatus(endpoint: String, method: String) {
        guard let token = AuthManager.shared.authToken else { return }
        
        let url = URL(string: "https://guardian-fwpg.onrender.com/api/v1/responder/alerts/\(endpoint)")!
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 30
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Alert update error: \(error)")
                    return
                }
                
                print("✅ Alert status updated")
                self.fetchAlerts() // Refresh alerts
            }
        }.resume()
    }
}

// MARK: - Supporting Models and Enums

enum AlertFilter: String, CaseIterable {
    case all = "All"
    case active = "Active"
    case acknowledged = "Acknowledged"
    case resolved = "Resolved"
    case cancelled = "Cancelled"
}

enum AlertType: String, CaseIterable {
    case all = "All"
    case panic = "Panic"
    case manual = "Manual"
}

// MARK: - Data Models (Add these to your existing models or create new file)

struct ResponderProfileResponse: Codable {
    let success: Bool
    let message: String
    let data: ResponderProfile
    let timestamp: String
}

struct ResponderProfile: Codable, Identifiable {
    let id: String
    let userId: UserId
    let fullName: String
    let email: String
    let phone: String
    let hospital: String
    let role: String
    let certifications: [String]
    let experienceYears: Int
    let vehicleType: String
    let licenseNumber: String
    let availability: Availability
    let maxDistance: Int
    let bio: String
    let status: String
    let currentLocation: CurrentLocation?
    let rating: Double
    let totalAssignments: Int
    let successfulAssignments: Int
    let responseTimeAvg: Double
    let lastPing: String
    let isActive: Bool
    let isVerified: Bool
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId, fullName, email, phone, hospital, role, certifications
        case experienceYears, vehicleType, licenseNumber, availability
        case maxDistance, bio, status, currentLocation, rating
        case totalAssignments, successfulAssignments, responseTimeAvg
        case lastPing, isActive, isVerified, createdAt, updatedAt
    }
}

struct UserId: Codable {
    let id: String
    let email: String
    let fullName: String
    let phone: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case email, fullName, phone
    }
}

struct Availability: Codable {
    let monday: [Bool]
    let tuesday: [Bool]
    let wednesday: [Bool]
    let thursday: [Bool]
    let friday: [Bool]
    let saturday: [Bool]
    let sunday: [Bool]
}

struct CurrentLocation: Codable {
    let type: String
    let coordinates: [Double]
    let updatedAt: String
}

struct AssignedAlertsResponse: Decodable {
    let success: Bool
    let message: String
    let data: [AlertItem]
    let timestamp: String
}

struct AlertItem: Decodable, Identifiable {
    let id: String
    let userId: AlertUser
    let status: String
    let type: String
    let location: AlertLocation
    let assignedResponder: AssignedResponder?
    let tracking: Tracking
    let createdAt: String
    let updatedAt: String
    let assignedHospital: String?
    let resolvedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId, status, type, location, assignedResponder, tracking
        case createdAt, updatedAt, assignedHospital, resolvedAt
    }
}

//struct AlertUser: Codable {
//    let id: String
//    let fullName: String
//    let phone: String
//    let medicalInfo: MedicalInfo?
//    
//    enum CodingKeys: String, CodingKey {
//        case id = "_id"
//        case fullName, phone, medicalInfo
//    }
//}

struct AlertUser: Decodable {
    let id: String
    let fullName: String
    let phone: String
    let medicalInfo: MedicalInfo?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case fullName, phone, medicalInfo
    }
}

// struct MedicalInfo: Codable {
//     let conditions: [String]
//     let bloodType: String?
//     let allergies: [String]
// }

struct AlertLocation: Codable {
    let geocodedData: GeocodedData?
    let type: String
    let coordinates: [Double]?
    let accuracy: Double?
    let address: String?
    let staticMapUrl: String?
}

struct GeocodedData: Codable {
    let formattedAddress: String?
    let street: String?
    let city: String?
    let state: String?
    let country: String?
    let postalCode: String?
    let neighborhood: String?
    let placeId: String?
}

struct AssignedResponder: Codable {
    let routeInfo: RouteInfo?
    let responderId: String
    let assignedAt: String
    let status: String
    let estimatedDistance: Double?
    let acknowledgedAt: String?
    let arrivedAt: String?
    let cancelledAt: String?
}

struct RouteInfo: Codable {
    let distance: RouteDistance?
    let duration: RouteDuration?
    let estimatedArrival: String?
}

struct RouteDistance: Codable {
    let text: String
    let value: Int
}

struct RouteDuration: Codable {
    let text: String
    let value: Int
}

struct Tracking: Codable {
    let lastUserLocation: [Double]
    let lastUpdated: String
    let lastResponderLocation: [Double]
}

// MARK: - ResponderDayOfWeek Enum (Add if not already exists)
enum ResponderDayOfWeek: String, CaseIterable {
    case monday = "Mon"
    case tuesday = "Tue"
    case wednesday = "Wed"
    case thursday = "Thu"
    case friday = "Fri"
    case saturday = "Sat"
    case sunday = "Sun"
}

// MARK: - Preview
struct ResponderDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        ResponderDashboardView()
            .environmentObject(AuthManager.shared)
    }
}

