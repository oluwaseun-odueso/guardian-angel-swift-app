//
//  Hospital.swift
//  Guardian Angel
//
//  Created by Oluwaseun Odueso on 10/01/2026.
//


import Foundation

struct Hospital: Codable, Identifiable {
    let id: String
    let name: String
    let address: String
    let location: HospitalLocation?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, address, location
    }
}

struct HospitalLocation: Codable {
    let type: String
    let coordinates: [Double]
}

struct HospitalsResponse: Codable {
    let success: Bool
    let message: String?
    let error: String?
    let data: [Hospital]
    let timestamp: String
}
