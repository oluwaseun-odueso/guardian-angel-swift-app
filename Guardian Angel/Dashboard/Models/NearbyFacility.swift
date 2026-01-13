//
//  NearbyFacility.swift
//  Guardian Angel
//
//  Created by Oluwaseun Odueso on 02/01/2026.
//

import Foundation

// MARK: - API RESPONSE
struct NearbyFacilitiesResponse: Decodable {
    let success: Bool
    let message: String
    let data: FacilitiesData
    let timestamp: String
}

struct FacilitiesData: Decodable {
    let facilities: [NearbyFacility]
    let pagination: Pagination
    let metadata: Metadata
}

struct Pagination: Decodable {
    let total: Int
    let page: Int
    let limit: Int
    let totalPages: Int
    let hasNextPage: Bool
    let hasPrevPage: Bool
}

struct Metadata: Decodable {
    let location: Coordinates
    let searchRadius: Int
    let totalFound: Int
    let autoRegistered: Bool
    let timestamp: String
}

struct Coordinates: Decodable {
    let latitude: Double
    let longitude: Double
}

// MARK: - FACILITY MODEL
struct NearbyFacility: Decodable, Identifiable {
    let name: String
    let googlePlaceId: String
    let address: String
    let coordinates: FacilityCoordinates
    let type: String
    let services: [String]
    let emergencyServices: Bool
    let registrationStatus: String
    let country: String
    let city: String
    let distance: Double
    let formattedDistance: String
    let id: String
    let availableResponders: Int
    let totalAssignments: Int
    let successfulAssignments: Int
    let successRate: Int
    let avgResponseTime: Int
    let rating: Int
    let totalRatings: Int
    let estimatedArrival: String
    
    struct FacilityCoordinates: Decodable {
        let latitude: Double
        let longitude: Double
    }
}
