//
//  AddEditEmergencyContactView.swift
//  Guardian Angel
//
//  Created by Oluwaseun Odueso on 30/12/2025.
//

import SwiftUI
import ContactsUI

struct AddEditEmergencyContactView: View {
    @Environment(\.presentationMode) var presentationMode
    let isEditing: Bool
    let existingContact: EmergencyContact?
    let onSave: ([String: Any], String?) -> Void // Modified to include contact ID
    
    // New color palette
    let primaryColor = Color(hex: "002147")
    let secondaryColor = Color(hex: "002147")
    let backgroundColor = Color(hex: "F8F9FA")
    
    @State private var contactName: String = ""
    @State private var phoneNumber: String = ""
    @State private var relationship: String = ""
    @State private var showingContactPicker = false
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isLoading = false
    
    // Relationship options
    let relationshipOptions = [
        "Family", "Friend", "Care Supporter", "Doctor",
        "Neighbor", "Colleague", "Other"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            VStack(spacing: 8) {
                // Title
                HStack(spacing: 8) {
                    Image("emergencyContacts")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .padding(.horizontal, 10)
                    
                    Text(isEditing ? "Edit Contact" : "Add Emergency Contact")
                        .font(.custom("Poppins-SemiBold", size: 16))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    // Close Button
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 14, height: 14)
                            .foregroundColor(.black)
                    }
                    .padding(.trailing, 10)
                }
                .padding(.horizontal, 16)
                
                // Thin divider line
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 0.5)
                    .padding(.horizontal, 16)
            }
            .padding(.top, 20)
            .background(Color.white)
            
            // MARK: - Form Content
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Picture Section
                    VStack(spacing: 16) {
                        // Profile Picture Circle with edit button
                        ZStack {
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(primaryColor.opacity(0.1))
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Text(contactName.prefix(1).uppercased())
                                            .font(.custom("Poppins-SemiBold", size: 32))
                                            .foregroundColor(primaryColor)
                                    )
                            }
                            
                            // Edit Photo Button
                            Button(action: {
                                showingImagePicker = true
                            }) {
                                Circle()
                                    .fill(primaryColor)
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Image(systemName: "camera.fill")
                                            .resizable()
                                            .frame(width: 16, height: 14)
                                            .foregroundColor(.white)
                                    )
                            }
                            .offset(x: 35, y: 35)
                        }
                        
                        Text("Tap to add photo")
                            .font(.custom("Poppins-Regular", size: 12))
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 24)
                    
                    // OR Divider
                    HStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 0.5)
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 0.5)
                    }
                    .padding(.horizontal, 16)
                    
                    // Import from Contacts Button
                    Button(action: {
                        showingContactPicker = true
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(primaryColor)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Import from Contacts")
                                    .font(.custom("Poppins-SemiBold", size: 14))
                                    .foregroundColor(primaryColor)
                                
                                Text("Select from your phone's address book")
                                    .font(.custom("Poppins-Regular", size: 11))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .resizable()
                                .frame(width: 8, height: 12)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(primaryColor.opacity(0.05))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(primaryColor.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 16)
                    
                    Text("OR")
                        .font(.custom("Poppins-Regular", size: 12))
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                    
                    // Manual Entry Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Manual Entry")
                            .font(.custom("Poppins-SemiBold", size: 14))
                            .foregroundColor(.black)
                            .padding(.horizontal, 16)
                        
                        // Name Field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Full Name")
                                .font(.custom("Poppins-Medium", size: 13))
                                .foregroundColor(.black)
                            
                            TextField("Enter full name", text: $contactName)
                                .font(.custom("Poppins-Regular", size: 14))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, 16)
                        
                        // Phone Number Field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Phone Number")
                                .font(.custom("Poppins-Medium", size: 13))
                                .foregroundColor(.black)
                            
                            HStack {
                                TextField("Enter phone number", text: $phoneNumber)
                                    .font(.custom("Poppins-Regular", size: 14))
                                    .keyboardType(.phonePad)
                                
                                // Call button if number is valid
                                if !phoneNumber.isEmpty && phoneNumber.filter({ $0.isNumber }).count >= 7 {
                                    Button(action: {
                                        openPhoneDialer(with: phoneNumber)
                                    }) {
                                        Image(systemName: "phone.fill")
                                            .resizable()
                                            .frame(width: 14, height: 14)
                                            .foregroundColor(secondaryColor)
                                            .padding(8)
                                            .background(secondaryColor.opacity(0.1))
                                            .clipShape(Circle())
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 16)
                        
                        // Relationship Picker
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Relationship")
                                .font(.custom("Poppins-Medium", size: 13))
                                .foregroundColor(.black)
                            
                            Menu {
                                ForEach(relationshipOptions, id: \.self) { option in
                                    Button(action: {
                                        relationship = option
                                    }) {
                                        Text(option)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(relationship.isEmpty ? "Select relationship" : relationship)
                                        .font(.custom("Poppins-Regular", size: 14))
                                        .foregroundColor(relationship.isEmpty ? .gray : .black)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.down")
                                        .resizable()
                                        .frame(width: 12, height: 6)
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // Important Note
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .resizable()
                                .frame(width: 16, height: 16)
                                .foregroundColor(primaryColor)
                            
                            Text("Important Note")
                                .font(.custom("Poppins-SemiBold", size: 13))
                                .foregroundColor(primaryColor)
                        }
                        
                        Text("Emergency contacts will be notified during panic alerts. Make sure to inform them that they've been added as your emergency contact.")
                            .font(.custom("Poppins-Regular", size: 12))
                            .foregroundColor(.gray)
                            .lineSpacing(2)
                    }
                    .padding(16)
                    .background(primaryColor.opacity(0.05))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(primaryColor.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                    
                    Spacer(minLength: 40)
                }
            }
            .background(backgroundColor)
            
            // MARK: - Save Button
            Button(action: {
                saveContact()
            }) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: isEditing ? "checkmark.circle.fill" : "plus.circle.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                        
                        Text(isEditing ? "Update Contact" : "Add Emergency Contact")
                            .font(.custom("Poppins-SemiBold", size: 16))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(primaryColor)
                .cornerRadius(12)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
            .padding(.top, 20)
            .disabled(contactName.isEmpty || phoneNumber.isEmpty || relationship.isEmpty || isLoading)
            .opacity((contactName.isEmpty || phoneNumber.isEmpty || relationship.isEmpty || isLoading) ? 0.6 : 1)
            
            // MARK: - Bottom Navigation (Fixed)
            AddEditEmergencyContactTabBar(
                userName: "Seun Odueso",
                profileImage: "profileImage"
            )
        }
        .background(Color.white)
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            if let existing = existingContact {
                contactName = existing.name
                phoneNumber = existing.phone
                relationship = existing.relationship
            }
        }
        .sheet(isPresented: $showingContactPicker) {
            ContactPickerView { contact in
                if let contact = contact {
                    contactName = contact.name
                    phoneNumber = contact.phone
                    // You could also try to extract relationship from contact notes
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePickerView(selectedImage: $selectedImage)
        }
    }
    
    // MARK: - Methods
    
    private func saveContact() {
        // Validate inputs
        guard !contactName.isEmpty, !phoneNumber.isEmpty, !relationship.isEmpty else {
            print("❌ All fields are required")
            return
        }
        
        isLoading = true
        
        // Prepare the request body
        let contactData: [String: Any] = [
            "name": contactName,
            "phone": phoneNumber,
            "relationship": relationship
        ]
        
        print("📤 Saving contact data: \(contactData)")
        
        // Get the contact ID if editing
        let contactId = isEditing ? existingContact?.id : nil
        
        // Call the onSave callback with the contact data and ID
        onSave(contactData, contactId)
        
        // Dismiss after a short delay to show loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func openPhoneDialer(with phoneNumber: String) {
        let cleanedNumber = phoneNumber.filter { $0.isNumber || $0 == "+" }
        
        if let url = URL(string: "telprompt://\(cleanedNumber)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else if let fallbackUrl = URL(string: "tel://\(cleanedNumber)") {
                UIApplication.shared.open(fallbackUrl, options: [:], completionHandler: nil)
            }
        }
    }
}

// MARK: - Contact Picker View (Simplified)
struct ContactPickerView: UIViewControllerRepresentable {
    let onContactSelected: ((ContactInfo?) -> Void)
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        
        // Show a simple alert for now
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Contact Picker",
                message: "This would show your phone's contact picker. For now, you can manually enter the contact details.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            controller.present(alert, animated: true)
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

// MARK: - Image Picker View (Simplified)
struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Image Picker",
                message: "This would show image picker options. For now, you can continue without an image.",
                preferredStyle: .actionSheet
            )
            
            alert.addAction(UIAlertAction(title: "Take Photo", style: .default) { _ in
                // Placeholder for camera
            })
            
            alert.addAction(UIAlertAction(title: "Choose from Library", style: .default) { _ in
                // Placeholder for photo library
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            controller.present(alert, animated: true)
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

// MARK: - Contact Info Model
struct ContactInfo {
    let name: String
    let phone: String
    let email: String?
    let image: UIImage?
}

// MARK: - Tab Bar for Add/Edit Emergency Contact (Active)
struct AddEditEmergencyContactTabBar: View {
    let userName: String
    let profileImage: String
    
    var body: some View {
        HStack(spacing: 0) {
            // Home Tab (Inactive)
            TabBarItemView(
                icon: "home",
                title: "Home"
            )
            
            // Emergency Contacts Tab (Active)
            TabBarItemView(
                icon: "clickedEmergencyContacts",
                title: "Emergency Contacts",
                active: true
            )
            
            // Incident Logs Tab (Inactive)
            TabBarItemView(
                icon: "incidentLogs",
                title: "Incident Logs"
            )
            
            // Trusted Locations Tab (Inactive)
            TabBarItemView(
                icon: "locations",
                title: "Trusted Locations"
            )
            
            // Profile Tab
            ProfileTabItem(
                userName: userName,
                profileImage: profileImage
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.white)
        .shadow(
            color: Color.black.opacity(0.08),
            radius: 1,
            x: 0,
            y: -1
        )
    }
}

// MARK: - Preview
struct AddEditEmergencyContactView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AddEditEmergencyContactView(
                isEditing: false,
                existingContact: nil,
                onSave: { _, _ in }
            )
            
            AddEditEmergencyContactView(
                isEditing: true,
                existingContact: EmergencyContact(
                    id: "1",
                    name: "Big Sis",
                    relationship: "Sister",
                    phone: "+44964703365",
                    profileImage: nil
                ),
                onSave: { _, _ in }
            )
        }
    }
}
