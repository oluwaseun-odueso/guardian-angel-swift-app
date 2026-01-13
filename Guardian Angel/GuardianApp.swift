//
//  Guardian_AngelApp.swift
//  Guardian Angel
//
//  Created by Oluwaseun Odueso on 28/12/2025.

import SwiftUI

@main
struct Guardian_AngelApp: App {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var navigationManager = NavigationManager()

    init() {
        AuthManager.shared.logout()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                if authManager.isAuthenticated {
                    MainAppView()
                        .environmentObject(navigationManager)
                } else {
                    NavigationView {
                        SignUpView()
//                        ResponderDashboardView()
                    }
                }
            }
            .navigationViewStyle(.stack)
            .environmentObject(authManager)
        }
    }
}

// MARK: - Main App View with Tab Navigation
struct MainAppView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @ObservedObject private var authManager = AuthManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Content based on selected tab
            switch navigationManager.selectedTab {
            case .home:
                DashboardView()
                    .navigationBarHidden(true)
            case .emergencyContacts:
                EmergencyContactsView()
                    .navigationBarHidden(true)
            case .incidentLogs:
                IncidentLogsView()
                    .navigationBarHidden(true)
            case .trustedLocations:
                TrustedLocationsView()
                    .navigationBarHidden(true)
            case .profile:
                ProfileView()
                    .navigationBarHidden(true)
            }
            
            // Universal Tab Bar
            UniversalTabBar(
                userName: authManager.currentUser?.fullName ?? "User",
                profileImage: "profileImage",
                selectedTab: navigationManager.selectedTab
            )
            .environmentObject(navigationManager)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

