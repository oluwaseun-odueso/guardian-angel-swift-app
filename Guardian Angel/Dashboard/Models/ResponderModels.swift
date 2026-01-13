////
////  ResponderModels.swift
////  Guardian Angel
////
////  Created by Oluwaseun Odueso on 12/01/2026.
////
//
//import Foundation
//
//// MARK: - Responder Profile Models
//struct ResponderProfileResponse: Codable {
//    let success: Bool
//    let message: String?
//    let error: String?
//    let data: ResponderProfile
//    let timestamp: String
//}
//
//struct ResponderProfile: Codable {
//    let id: String
//    let userId: UserData
//    let fullName: String
//    let email: String
//    let phone: String
//    let hospital: String
//    let role: String
//    let certifications: [String]
//    let experienceYears: Int
//    let vehicleType: String
//    let licenseNumber: String
//    let availability: AvailabilitySchedule
//    let maxDistance: Int
//    let bio: String
//    let status: String
//    let currentLocation: ResponderLocation
//    let rating: Double
//    let totalAssignments: Int
//    let successfulAssignments: Int
//    let responseTimeAvg: Double
//    let lastPing: String
//    let isActive: Bool
//    let isVerified: Bool
//    let createdAt: String
//    let updatedAt: String
//    
//    enum CodingKeys: String, CodingKey {
//        case id = "_id"
//        case userId, fullName, email, phone, hospital, role, certifications
//        case experienceYears, vehicleType, licenseNumber, availability
//        case maxDistance, bio, status, currentLocation, rating
//        case totalAssignments, successfulAssignments, responseTimeAvg
//        case lastPing, isActive, isVerified, createdAt, updatedAt
//    }
//}
//
//struct UserData: Codable {
//    let id: String
//    let email: String
//    let fullName: String
//    let phone: String
//    
//    enum CodingKeys: String, CodingKey {
//        case id = "_id"
//        case email, fullName, phone
//    }
//}
//
//struct ResponderLocation: Codable {
//    let type: String
//    let coordinates: [Double]
//    let updatedAt: String
//}
//
//// MARK: - Alert Models
//struct ResponderAlertsResponse: Codable {
//    let success: Bool
//    let message: String?
//    let error: String?
//    let data: [ResponderAlert]
//    let timestamp: String
//}
//
//struct ResponderAlert: Codable, Identifiable {
//    let id: String
//    let userId: AlertUser
//    let status: String
//    let type: String
//    let assignedHospital: String?
//    let location: AlertLocation
//    let assignedResponder: AssignedResponder
//    let tracking: TrackingInfo
//    let createdAt: String
//    let updatedAt: String
//    
//    enum CodingKeys: String, CodingKey {
//        case id = "_id"
//        case userId, status, type, assignedHospital, location
//        case assignedResponder, tracking, createdAt, updatedAt
//    }
//}
//
//struct AlertUser: Codable {
//    let id: String
//    let fullName: String
//    let phone: String
//    let medicalInfo: MedicalInfo
//    
//    enum CodingKeys: String, CodingKey {
//        case id = "_id"
//        case fullName, phone, medicalInfo
//    }
//}
//
//struct MedicalInfo: Codable {
//    let conditions: [String]
//    let bloodType: String?
//    let allergies: [String]
//}
//
//struct AlertLocation: Codable {
//    let geocodedData: GeocodedData
//    let type: String
//    let coordinates: [Double]
//    let accuracy: Double
//    let address: String
//    let staticMapUrl: String
//}
//
//struct GeocodedData: Codable {
//    let formattedAddress: String
//    let street: String
//    let city: String
//    let state: String
//    let country: String
//    let postalCode: String
//    let neighborhood: String
//    let placeId: String
//}
//
//struct AssignedResponder: Codable {
//    let routeInfo: RouteInfo
//    let responderId: String
//    let assignedAt: String
//    let status: String
//    let estimatedDistance: Double?
//    let acknowledgedAt: String?
//    let arrivedAt: String?
//    let cancelledAt: String?
//}
//
//struct RouteInfo: Codable {
//    let distance: RouteDistance
//    let duration: RouteDuration
//    let estimatedArrival: String
//}
//
//struct RouteDistance: Codable {
//    let text: String
//    let value: Int
//}
//
//struct RouteDuration: Codable {
//    let text: String
//    let value: Int
//}
//
//struct TrackingInfo: Codable {
//    let lastUserLocation: [Double]
//    let lastUpdated: String
//    let lastResponderLocation: [Double]
//}
//
//// MARK: - Alert Action Models
//struct AlertActionResponse: Codable {
//    let success: Bool
//    let message: String?
//    let error: String?
//    let data: ResponderAlert?
//    let timestamp: String
//}
//
//struct CancelAlertRequest: Codable {
//    let reason: String
//}
