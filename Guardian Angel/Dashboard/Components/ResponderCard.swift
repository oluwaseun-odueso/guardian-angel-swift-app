//
//  ResponderCard.swift
//  Guardian Angel
//
//  Created by Oluwaseun Odueso on 02/01/2026.
//

import SwiftUI

struct ResponderCard: View {
    let responder: Responder
    var onRequestTapped: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Facility Image
                Image(responder.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .clipped()
                
                // Facility Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(responder.name)
                        .font(.custom("Poppins-SemiBold", size: 13))
                        .lineLimit(1)
                    
                    Text(responder.address)
                        .font(.custom("Poppins-Regular", size: 10))
                        .foregroundColor(.black)
                        .lineLimit(2)
                    
                    HStack(spacing: 8) {
                        // Distance
                        HStack(spacing: 4) {
//                            Image(systemName: "location.fill")
                            Image("locations")
                                .font(.system(size: 10))
                                .foregroundColor(.blue)
                            Text(responder.distance)
                                .font(.custom("Poppins-Regular", size: 11))
                                .foregroundColor(.blue)
                        }
                        
                        // Estimated Arrival
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.green)
                            Text(responder.estimatedArrival)
                                .font(.custom("Poppins-Regular", size: 11))
                                .foregroundColor(.green)
                        }
                        
                        Spacer()
                        
                        // Available Responders Badge
                        if responder.availableResponders > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 10))
                                Text("\(responder.availableResponders)")
                                    .font(.custom("Poppins-SemiBold", size: 11))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green)
                            .cornerRadius(12)
                        }
                    }
                }
                
                Spacer()
                
                Button(action: {
                    onRequestTapped?()
                }) {
                    Text("Request")
                        .font(.custom("Poppins-Regular", size: 10))
                        .foregroundColor(.white)
                        .frame(width: 63, height: 13)
                        .padding(.vertical, 8)
                        .background(Color.black)
                        .cornerRadius(5)
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Preview
struct ResponderCard_Previews: PreviewProvider {
    static var previews: some View {
        ResponderCard(responder: Responder(
            id: "1",
            name: "DFO Medical Clinic",
            address: "Pako B/stop, 1 Banji Adewole Lane, Akoka Road, Lagos",
            distance: "0.6 km",
            image: "hospitalPlaceholder"
        ))
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

