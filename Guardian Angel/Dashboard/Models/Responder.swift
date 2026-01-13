//
//  Responder.swift
//  Guardian Angel
//
//  Created by [Your Name] on [Date].
//

import Foundation

struct Responder: Identifiable {
    let id: String
    let name: String
    let address: String
    let distance: String
    let estimatedArrival: String
    let availableResponders: Int
    let image: String
    let rating: Int
    
    // Initializer to map from NearbyFacility
    init(from facility: NearbyFacility) {
        self.id = facility.id
        self.name = facility.name
        self.address = facility.address
        self.distance = facility.formattedDistance
        self.estimatedArrival = facility.estimatedArrival
        self.availableResponders = facility.availableResponders
        self.image = "hospitalPlaceholder" // or map based on facility.type
        self.rating = facility.rating
    }
    
    // Keep your original initializer if needed elsewhere
    init(id: String, name: String, address: String, distance: String, image: String) {
        self.id = id
        self.name = name
        self.address = address
        self.distance = distance
        self.estimatedArrival = "Unknown"
        self.availableResponders = 0
        self.image = image
        self.rating = 0
    }
}
