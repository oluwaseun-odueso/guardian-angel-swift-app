//
//  ResponderRegistrationData.swift
//  Guardian Angel
//
//  Created by Oluwaseun Odueso on 10/01/2026.
//
//

import Foundation

struct ResponderRegistrationRequest: Codable {
    let hospital: String // Can be ID or name
    let certifications: [String]
    let experienceYears: Int
    let vehicleType: String
    let licenseNumber: String
    let maxDistance: Int
    let bio: String
    let currentLocation: GeoJSONPoint
    let availability: AvailabilitySchedule
    
    struct GeoJSONPoint: Codable {
        let type: String = "Point"
        let coordinates: [Double] // [longitude, latitude]
    }
}

struct AvailabilitySchedule: Codable {
    var monday: [Bool]
    var tuesday: [Bool]
    var wednesday: [Bool]
    var thursday: [Bool]
    var friday: [Bool]
    var saturday: [Bool]
    var sunday: [Bool]
    
    init(monday: [Bool] = Array(repeating: false, count: 24),
         tuesday: [Bool] = Array(repeating: false, count: 24),
         wednesday: [Bool] = Array(repeating: false, count: 24),
         thursday: [Bool] = Array(repeating: false, count: 24),
         friday: [Bool] = Array(repeating: false, count: 24),
         saturday: [Bool] = Array(repeating: false, count: 24),
         sunday: [Bool] = Array(repeating: false, count: 24)) {
        self.monday = monday
        self.tuesday = tuesday
        self.wednesday = wednesday
        self.thursday = thursday
        self.friday = friday
        self.saturday = saturday
        self.sunday = sunday
    }
}

struct ResponderRegistrationResponse: Codable {
    let success: Bool
    let message: String?
    let error: String?
    let data: ResponderData?
    let timestamp: String
}

struct ResponderData: Codable {
    let _id: String
    let userId: String
    let hospital: String
    let certifications: [String]
    let experienceYears: Int
    let vehicleType: String
    let licenseNumber: String
    let maxDistance: Int
    let bio: String
    let currentLocation: GeoJSONPoint
    let availability: AvailabilitySchedule
    let status: String
    let createdAt: String
    let updatedAt: String
    let __v: Int
    
    struct GeoJSONPoint: Codable {
        let type: String
        let coordinates: [Double]
    }
}
