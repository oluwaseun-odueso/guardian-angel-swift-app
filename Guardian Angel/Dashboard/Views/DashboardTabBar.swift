//
//  DashboardTabBar.swift
//  Guardian Angel
//
//  Created by Oluwaseun Odueso on 28/12/2025.
//

import SwiftUI

struct DashboardTabBar: View {
    let userName: String
    let profileImage: String
    
    var body: some View {
        HStack(spacing: 0) {
            TabBarItemView(
                icon: "clickedHome",
                title: "Home",
                active: true
            )
            
            TabBarItemView(
                icon: "emergencyContacts",
                title: "Emergency Contacts"
            )
            
            TabBarItemView(
                icon: "incidentLogs",
                title: "Incident Logs"
            )
            
            TabBarItemView(
                icon: "locations",
                title: "Trusted Locations"
            )
            
            ProfileTabItem(
                userName: userName,
                profileImage: profileImage
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

// MARK: - Tab Item (Separate structs, not nested)
struct TabBarItemView: View {
    let icon: String
    let title: String
    var active: Bool = false
    
    var body: some View {
        VStack(spacing: 6) {
            Image(icon)
                .resizable()
                .frame(width: 20, height: 20)
            
            Text(title)
                .font(.custom("Poppins-Regular", size: 8))
                .foregroundColor(active ? .black : .gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }
}

struct ProfileTabItem: View {
    let userName: String
    let profileImage: String
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
        VStack(spacing: 4) {
            if UIImage(named: profileImage) != nil {
                Image(profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 25, height: 25)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color(hex: "#8C1946"))
                    .frame(width: 25, height: 25)
                    .overlay(
                        Text(initials)
                            .font(.custom("Poppins-SemiBold", size: size * 0.38))
                            .foregroundColor(.white)
                    )
            }
            
            Text(userName)
                .font(.custom("Poppins-Regular", size: 9))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview
struct DashboardTabBar_Previews: PreviewProvider {
    static var previews: some View {
        DashboardTabBar(
            userName: "John Doe",
            profileImage: "profile_placeholder"
        )
    }
}
