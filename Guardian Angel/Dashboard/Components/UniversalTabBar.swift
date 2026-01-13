//
//  UniversalTabBar.swift
//  Guardian Angel
//
//  Created by Oluwaseun Odueso on 10/01/2026.
//

import SwiftUI

struct UniversalTabBar: View {
    let userName: String
    let profileImage: String
    let selectedTab: NavigationManager.Tab
    
    @EnvironmentObject private var navigationManager: NavigationManager
    
    var body: some View {
        HStack(spacing: 0) {
            // Home Tab
            TabButton(
                icon: selectedTab == .home ? "clickedHome" : "home",
                title: "Home",
                isSelected: selectedTab == .home,
                action: { navigationManager.navigate(to: .home) }
            )
            
            // Emergency Contacts Tab
            TabButton(
                icon: selectedTab == .emergencyContacts ? "clickedEmergencyContacts" : "emergencyContacts",
                title: "Emergency Contacts",
                isSelected: selectedTab == .emergencyContacts,
                action: { navigationManager.navigate(to: .emergencyContacts) }
            )
            
            // Incident Logs Tab
            TabButton(
                icon: selectedTab == .incidentLogs ? "clickedIncidentLogs" : "incidentLogs",
                title: "Incident Logs",
                isSelected: selectedTab == .incidentLogs,
                action: { navigationManager.navigate(to: .incidentLogs) }
            )
            
            // Trusted Locations Tab
            TabButton(
                icon: selectedTab == .trustedLocations ? "clickedLocations" : "locations",
                title: "Trusted Locations",
                isSelected: selectedTab == .trustedLocations,
                action: { navigationManager.navigate(to: .trustedLocations) }
            )
            
            // Profile Tab
            ProfileTabButton(
                userName: userName,
                profileImage: profileImage,
                isSelected: selectedTab == .profile,
                action: { navigationManager.navigate(to: .profile) }
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .padding(.bottom, 10)
        .background(Color.white)
        .shadow(
            color: Color.black.opacity(0.08),
            radius: 1,
            x: 0,
            y: -1
        )
    }
}

struct TabButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(icon)
                    .resizable()
                    .frame(width: 20, height: 20)
                
                Text(title)
                    .font(.custom("Poppins-Regular", size: 8))
                    .foregroundColor(isSelected ? .black : .gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }
}

struct ProfileTabButton: View {
    let userName: String
    let profileImage: String
    let isSelected: Bool
    let action: () -> Void
    let size = 25.0
    
    private var initials: String {
        let components = userName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: " ")

        let first = components.first?.first
        let last = components.dropFirst().first?.first

        if let first, let last {
            return "\(first)\(last)".uppercased()
        }

        return components.first?.prefix(1).uppercased() ?? "?"
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                if UIImage(named: profileImage) != nil {
                    Image(profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 25, height: 25)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(isSelected ? Color(hex: "#8C1946") : Color.gray.opacity(0.5))
                        .frame(width: 25, height: 25)
                        .overlay(
                            Text(initials)
                                .font(.custom("Poppins-SemiBold", size: size * 0.38))
                                .foregroundColor(.white)
                        )
                }
                
                Text(userName)
                    .font(.custom("Poppins-Regular", size: 9))
                    .foregroundColor(isSelected ? .black : .gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
