//
//  MedicalInfoCard.swift
//  Guardian Angel
//
//  Created by Oluwaseun Odueso on 30/12/2025.
//

import SwiftUI

struct MedicalInfoCard: View {

    let bloodType: String
    let allergies: String
    let conditions: String

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Your medical Information:")
                .font(.custom("Poppins-Bold", size: 13))
                .padding(.vertical, 10)

            VStack(spacing: 16) {

                infoRow(title: "Blood Type:", value: bloodType)
                Divider().opacity(0.3)
                    .padding(.vertical, 10)
                    .font(.custom("Poppins-Medium", size: 10))
                
                infoRow(title: "Allergies:", value: allergies)
                Divider().opacity(0.3)
                .padding(.vertical, 10)
                
                infoRow(title: "Conditions:", value: conditions)
                .padding(.vertical, 10)
            }
        }
        .padding(16)
        .background(Color.gray.opacity(0.12))
        .cornerRadius(5)
    }

    private func infoRow(title: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.custom("Poppins-SemiBold", size: 13))

            Text(value)
                .font(.custom("Poppins-Regular", size: 13))

            Spacer()
        }
    }
}
