//
//  NavigationManager.swift
//  Guardian Angel
//
//  Created by Oluwaseun Odueso on 10/01/2026.
//

import Foundation
internal import Combine

class NavigationManager: ObservableObject {
    @Published var selectedTab: Tab = .home
    
    enum Tab {
        case home
        case emergencyContacts
        case incidentLogs
        case trustedLocations
        case profile
    }
    
    func navigate(to tab: Tab) {
        selectedTab = tab
    }
}
