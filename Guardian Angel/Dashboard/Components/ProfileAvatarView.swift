//
//  ProfileAvatarView.swift
//  Guardian Angel
//
//  Created by Oluwaseun Odueso on 30/12/2025.
//

import SwiftUI


struct ProfileAvatarView: View {

    let fullName: String
    let imageName: String?
    let size: CGFloat
    let showBorder: Bool

    // MARK: - Initials (e.g. MJ)
    private var initials: String {
        let components = fullName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: " ")

        let first = components.first?.first
        let last = components.dropFirst().first?.first

        if let first, let last {
            return "\(first)\(last)".uppercased()
        }

        return components.first?.prefix(1).uppercased() ?? "?"
    }

    private var hasValidImage: Bool {
        guard let imageName else { return false }
        return !imageName.isEmpty
    }

    var body: some View {
        ZStack {
            if hasValidImage {
                Image(imageName!)
                    .resizable()
                    .scaledToFill()
            } else {
                Text(initials)
                    .font(.custom("Poppins-SemiBold", size: size * 0.38))
                    .foregroundColor(.white)
                    .frame(width: size, height: size)
                    .background(Color.Guardian.navy)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(
                    showBorder ? Color.Guardian.navy : Color.clear,
                    lineWidth: showBorder ? 1.5 : 0
                )
        )
    }
}
