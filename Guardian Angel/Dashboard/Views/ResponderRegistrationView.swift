//
//  ResponderRegistrationView.swift
//  Guardian Angel
//
//  Created by Oluwaseun Odueso on 10/01/2026.
//

import SwiftUI

struct ResponderRegistrationView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var authManager = AuthManager.shared
    @StateObject private var locationManager = LocationManager()
    
    // Form Fields
    @State private var selectedHospital: Hospital?
    @State private var customHospitalName = ""
    @State private var certifications: [String] = []
    @State private var newCertification = ""
    @State private var experienceYears = ""
    @State private var selectedVehicleType = "car"
    @State private var licenseNumber = ""
    @State private var maxDistance = "25"
    @State private var bio = ""
    
    // Availability Schedule
    @State private var availability = AvailabilitySchedule()
    
    // UI State
    @State private var hospitals: [Hospital] = []
    @State private var isLoading = false
    @State private var isLoadingHospitals = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var showingHospitalDropdown = false
    @State private var isUsingCustomHospital = false
    
    // Vehicle types
    private let vehicleTypes = ["car", "motorcycle", "bicycle", "ambulance", "suv", "van", "other"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerView
                
                // Hospital Selection
                hospitalSelectionView
                
                // Certifications
                certificationsView
                
                // Experience & Vehicle
                experienceVehicleView
                
                // License & Distance
                licenseDistanceView
                
                // Bio
                bioView
                
                // Availability Schedule
                availabilityScheduleView
                
                // Submit Button
                submitButton
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color(hex: "F8F9FA"))
        .navigationBarHidden(true)
        .onAppear {
            fetchHospitals()
            locationManager.requestLocation()
        }
//        .alert("Success", isPresented: $showSuccessAlert) {
//            Button("OK", role: .cancel) {
//                presentationMode.wrappedValue.dismiss()
//            }
        
//        } message: {
//            Text(alertMessage)
//        }
//        .alert("Error", isPresented: $showErrorAlert) {
//            Button("OK", role: .cancel) { }
        
        .alert("Success", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) {
                // Already marked as responder in submitRegistration
                // Just dismiss the view
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text(alertMessage)
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.custom("Poppins-Medium", size: 14))
                    }
                    .foregroundColor(Color.Guardian.navy)
                }
                
                Spacer()
                
                Text("Become a Responder")
                    .font(.custom("Poppins-SemiBold", size: 16))
                    .foregroundColor(.black)
                
                
                Spacer()
                
                // Empty view for balance
                Color.clear.frame(width: 60, height: 1)
            }
            
            Text("Join our network of emergency responders and help save lives in your community.")
                .font(.custom("Poppins-Regular", size: 12))
                .foregroundColor(Color.Guardian.grey)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            
            Divider()
                .background(Color.gray.opacity(0.3))
        }
        .padding(.top, 16)
    }
    
    // MARK: - Hospital Selection View
    private var hospitalSelectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hospital / Organization")
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundColor(.black)
            
            // Hospital Selection Toggle
            Picker("Hospital Selection", selection: $isUsingCustomHospital) {
                Text("Select from list").tag(false)
                    .font(.custom("Poppins-Regular", size: 12))
                Text("Type manually").tag(true)
                    .font(.custom("Poppins-Regular", size: 12))
            }
            .pickerStyle(SegmentedPickerStyle())
            
            if isUsingCustomHospital {
                // Manual Hospital Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hospital Name")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(Color.Guardian.black)
                        .padding(.top, 16)
                    
                    TextField("Enter hospital name", text: $customHospitalName)
                        .font(.custom("Poppins-Regular", size: 12))
                        .padding()
                        .foregroundColor(Color.Guardian.grey)
                        .background(Color.white)
                        .cornerRadius(10)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//                        )
                }
            } else {
                // Hospital Dropdown
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select Hospital")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.black)
                        .padding(.top, 16)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 10)
//                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//                            )
                        
                        Menu {
                            if isLoadingHospitals {
                                Text("Loading hospitals...")
                            } else {
                                ForEach(hospitals) { hospital in
                                    Button(hospital.name) {
                                        selectedHospital = hospital
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedHospital?.name ?? "Select a hospital")
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundColor(selectedHospital == nil ? Color.Guardian.grey : .black)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                    }
                    .frame(height: 50)
                }
            }
        }
    }
    
    // MARK: - Certifications View
    private var certificationsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Certifications")
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundColor(.black)
                .padding(.top, 12)
            
            // Certification Input
            HStack {
                TextField("Add certification (e.g., CPR, First Aid)", text: $newCertification)
                    .font(.custom("Poppins-Regular", size: 13))
                    .foregroundColor(Color.Guardian.grey)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//                    )
//                
                Button(action: addCertification) {
                    Image(systemName: "plus.circle.fill")
//                        .font(.system(size: 24))
                        .font(.custom("Poppins-Regular", size: 12))
                        .foregroundColor(Color.Guardian.navy)
                }
                .disabled(newCertification.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            
            // Certifications List
            if !certifications.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Certifications")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.gray)
                        .padding(.top, 12)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(certifications, id: \.self) { certification in
                            HStack(spacing: 4) {
                                Text(certification)
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundColor(Color.Guardian.navy)
                                
                                Button(action: {
                                    removeCertification(certification)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.Guardian.navy.opacity(0.1))
                            .cornerRadius(15)
                        }
                    }
                }
            }
            
            // Common Certifications
            VStack(alignment: .leading, spacing: 8) {
                Text("Common Certifications")
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.black)
                    .padding(.top, 14)
                
                FlowLayout(spacing: 8) {
                    ForEach(["CPR", "First Aid", "EMT", "BLS", "ACLS", "PALS", "Paramedic", "Nurse"], id: \.self) { commonCert in
                        Button(action: {
                            if !certifications.contains(commonCert) {
                                certifications.append(commonCert)
                            }
                        }) {
                            Text(commonCert)
                                .font(.custom("Poppins-Regular", size: 12))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.Guardian.navy)
                                .cornerRadius(15)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Experience & Vehicle View
    private var experienceVehicleView: some View {
        HStack(spacing: 16) {
            // Experience Years
            VStack(alignment: .leading, spacing: 8) {
                Text("Experience (Years)")
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.black)
                
                TextField("0", text: $experienceYears)
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(Color.Guardian.grey)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//                    )
            }
//            .padding(.top, 12)
            
            // Vehicle Type
            VStack(alignment: .leading, spacing: 8) {
                Text("Vehicle Type")
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.black)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//                        )
                    
                    Picker("Vehicle Type", selection: $selectedVehicleType) {
                        ForEach(vehicleTypes, id: \.self) { type in
                            Text(type.capitalized)
                                .tag(type)
                                .foregroundColor(Color.Guardian.grey)
                                .font(.custom("Poppins-Regular", size: 12))
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                }
                .frame(height: 50)
            }
        }
    }
    
    // MARK: - License & Distance View
    private var licenseDistanceView: some View {
        HStack(spacing: 16) {
            // License Number
            VStack(alignment: .leading, spacing: 10) {
                Text("License Number")
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.black)
                
                TextField("Enter license number", text: $licenseNumber)
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(Color.Guardian.grey)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//                    )
            }
            
            // Max Distance
            VStack(alignment: .leading, spacing: 10) {
                Text("Max Distance (km)")
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.black)
                
                TextField("25", text: $maxDistance)
                    .keyboardType(.numberPad)
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(Color.Guardian.grey)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//                    )
            }
        }
    }
    
    // MARK: - Bio View
    private var bioView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bio / Description")
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundColor(.black)
            
            Text("Tell us about your experience and why you want to be a responder.")
                .font(.custom("Poppins-Regular", size: 12))
                .foregroundColor(.gray)
            
            TextEditor(text: $bio)
                .frame(height: 120)
                .padding(8)
                .background(Color.white)
                .cornerRadius(10)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 10)
//                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//                )
                .font(.custom("Poppins-Regular", size: 14))
            
            Text("\(bio.count)/500 characters")
                .font(.custom("Poppins-Regular", size: 12))
                .foregroundColor(bio.count > 500 ? .red : .gray)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
    
    // MARK: - Availability Schedule View
    private var availabilityScheduleView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Availability Schedule")
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundColor(.black)
            
            Text("Select the hours you're available each day (24-hour format)")
                .font(.custom("Poppins-Regular", size: 12))
                .foregroundColor(.gray)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(DayOfWeek.allCases, id: \.self) { day in
                        DayAvailabilityView(
                            day: day,
                            availability: bindingForDay(day)
                        )
                    }
                }
                .padding(.bottom, 8)
            }
            
            // Quick Select Buttons
            HStack(spacing: 12) {
                Button("Weekdays 9-5") {
                    setWeekdayHours(start: 9, end: 17)
                }
                .font(.custom("Poppins-Regular", size: 12))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
                
                Button("Weekends All Day") {
                    setWeekendAllDay()
                }
                .font(.custom("Poppins-Regular", size: 12))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
                
                Button("Clear All") {
                    clearAllAvailability()
                }
                .font(.custom("Poppins-Regular", size: 12))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
            }
        }
    }
    
    // MARK: - Submit Button
    private var submitButton: some View {
        Button(action: submitRegistration) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(height: 24)
            } else {
                Text("Submit Registration")
                    .font(.custom("Poppins-Regular", size: 16))
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.Guardian.navy)
        .cornerRadius(10)
        .disabled(isLoading || !isFormValid)
        .opacity((isLoading || !isFormValid) ? 0.7 : 1)
    }
    
    // MARK: - Helper Functions
    
    private func addCertification() {
        let trimmedCert = newCertification.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedCert.isEmpty && !certifications.contains(trimmedCert) {
            certifications.append(trimmedCert)
            newCertification = ""
        }
    }
    
    private func removeCertification(_ certification: String) {
        certifications.removeAll { $0 == certification }
    }
    
    private func bindingForDay(_ day: DayOfWeek) -> Binding<[Bool]> {
        switch day {
        case .monday: return $availability.monday
        case .tuesday: return $availability.tuesday
        case .wednesday: return $availability.wednesday
        case .thursday: return $availability.thursday
        case .friday: return $availability.friday
        case .saturday: return $availability.saturday
        case .sunday: return $availability.sunday
        }
    }
    
    private func setWeekdayHours(start: Int, end: Int) {
        for hour in 0..<24 {
            let isAvailable = hour >= start && hour < end
            availability.monday[hour] = isAvailable
            availability.tuesday[hour] = isAvailable
            availability.wednesday[hour] = isAvailable
            availability.thursday[hour] = isAvailable
            availability.friday[hour] = isAvailable
            availability.saturday[hour] = false
            availability.sunday[hour] = false
        }
    }
    
    private func setWeekendAllDay() {
        for hour in 0..<24 {
            availability.monday[hour] = false
            availability.tuesday[hour] = false
            availability.wednesday[hour] = false
            availability.thursday[hour] = false
            availability.friday[hour] = false
            availability.saturday[hour] = true
            availability.sunday[hour] = true
        }
    }
    
    private func clearAllAvailability() {
        for hour in 0..<24 {
            availability.monday[hour] = false
            availability.tuesday[hour] = false
            availability.wednesday[hour] = false
            availability.thursday[hour] = false
            availability.friday[hour] = false
            availability.saturday[hour] = false
            availability.sunday[hour] = false
        }
    }
    
    private var isFormValid: Bool {
        // Check hospital
        if isUsingCustomHospital {
            if customHospitalName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return false
            }
        } else {
            if selectedHospital == nil {
                return false
            }
        }
        
        // Check other required fields
        if certifications.isEmpty { return false }
        if experienceYears.isEmpty || Int(experienceYears) == nil { return false }
        if licenseNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return false }
        if maxDistance.isEmpty || Int(maxDistance) == nil { return false }
        if bio.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || bio.count > 500 { return false }
        
        // Check location
        if locationManager.latitude == nil || locationManager.longitude == nil {
            return false
        }
        
        return true
    }
    
    // MARK: - API Functions
    
    private func fetchHospitals() {
        guard let token = authManager.authToken else {
            alertMessage = "Please login to continue"
            showErrorAlert = true
            return
        }
        
        isLoadingHospitals = true
        
        let urlString = "https://guardian-fwpg.onrender.com/api/v1/hospitals"
        guard let url = URL(string: urlString) else {
            isLoadingHospitals = false
            alertMessage = "Invalid server URL"
            showErrorAlert = true
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoadingHospitals = false
                
                if let error = error {
                    self.alertMessage = "Network error: \(error.localizedDescription)"
                    self.showErrorAlert = true
                    return
                }
                
                guard let data = data else {
                    self.alertMessage = "No response from server"
                    self.showErrorAlert = true
                    return
                }
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("🏥 Hospitals response: \(responseString)")
                }
                
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(HospitalsResponse.self, from: data)
                    
                    if response.success {
                        self.hospitals = response.data
                        print("✅ Loaded \(self.hospitals.count) hospitals")
                    } else {
                        self.alertMessage = response.error ?? response.message ?? "Failed to load hospitals"
                        self.showErrorAlert = true
                    }
                } catch {
                    self.alertMessage = "Failed to parse response: \(error.localizedDescription)"
                    self.showErrorAlert = true
                    print("❌ Decoding error: \(error)")
                }
            }
        }.resume()
    }
    
    private func submitRegistration() {
        guard let token = authManager.authToken else {
            print("❌ No auth token found!")
            alertMessage = "Please login to continue"
            showErrorAlert = true
            return
        }
        
        print("✅ Auth token found: \(token.prefix(20))...")
        
        guard let lat = locationManager.latitude,
              let lng = locationManager.longitude else {
            alertMessage = "Unable to get your location. Please enable location services."
            showErrorAlert = true
            return
        }
        
        isLoading = true
        
        // Prepare hospital field
        let hospitalValue = isUsingCustomHospital ?
            customHospitalName.trimmingCharacters(in: .whitespacesAndNewlines) :
            selectedHospital?.id ?? ""
        
        if hospitalValue.isEmpty {
            isLoading = false
            alertMessage = "Please select a hospital or enter a valid hospital name"
            showErrorAlert = true
            return
        }
        
        // Prepare request body
        let requestBody: [String: Any] = [
            "hospital": hospitalValue,
            "certifications": certifications,
            "experienceYears": Int(experienceYears) ?? 0,
            "vehicleType": selectedVehicleType,
            "licenseNumber": licenseNumber.trimmingCharacters(in: .whitespacesAndNewlines),
            "maxDistance": Int(maxDistance) ?? 25,
            "bio": bio.trimmingCharacters(in: .whitespacesAndNewlines),
            "currentLocation": [
                "type": "Point",
                "coordinates": [lng, lat]
            ],
            "availability": [
                "monday": availability.monday,
                "tuesday": availability.tuesday,
                "wednesday": availability.wednesday,
                "thursday": availability.thursday,
                "friday": availability.friday,
                "saturday": availability.saturday,
                "sunday": availability.sunday
            ]
        ]
        
        print("📤 Submitting responder registration: \(requestBody)")
        
        let urlString = "https://guardian-fwpg.onrender.com/api/v1/responder/register"
        guard let url = URL(string: urlString) else {
            isLoading = false
            alertMessage = "Invalid server URL"
            showErrorAlert = true
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print("🔐 Using Authorization header: Bearer \(token.prefix(20))...")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            request.httpBody = jsonData
        } catch {
            isLoading = false
            alertMessage = "Failed to prepare registration data"
            showErrorAlert = true
            return
        }
        
        request.timeoutInterval = 30
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    self.alertMessage = "Network error: \(error.localizedDescription)"
                    self.showErrorAlert = true
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 HTTP Status: \(httpResponse.statusCode)")
                    
                    guard let data = data else {
                        self.alertMessage = "No response data from server"
                        self.showErrorAlert = true
                        return
                    }
                    
                    // Print raw response for debugging
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("📦 Raw response: \(responseString)")
                    }
                    
                    // Handle different status codes
                    switch httpResponse.statusCode {
                    case 200, 201:
                        // Parse the response to get the responder token
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                               let success = json["success"] as? Bool, success {
                                
                                // Extract the new responder token
                                if let data = json["data"] as? [String: Any],
                                   let tokens = data["tokens"] as? [String: Any],
                                   let accessToken = tokens["accessToken"] as? String {
                                    
                                    print("✅ Responder token received: \(accessToken.prefix(20))...")
                                    
                                    // Save the new responder token in AuthManager
                                    self.authManager.saveResponderToken(accessToken)
                                    
                                    // Also mark user as responder
                                    self.authManager.markAsResponder()
                                    
                                    // Navigate to responder dashboard immediately
                                    // We'll use a notification to trigger navigation
                                    NotificationCenter.default.post(
                                        name: NSNotification.Name("ResponderRegistrationSuccess"),
                                        object: nil,
                                        userInfo: ["token": accessToken]
                                    )
                                    
                                    self.alertMessage = "Registration successful! Redirecting to responder dashboard..."
                                    self.showSuccessAlert = true
                                    
                                } else {
                                    // Fallback: if token not found, still mark as responder
                                    print("⚠️ Could not extract responder token from response")
                                    self.authManager.markAsResponder()
                                    self.alertMessage = "Registration successful! You are now a responder."
                                    self.showSuccessAlert = true
                                }
                            } else {
                                self.alertMessage = "Registration failed. Please try again."
                                self.showErrorAlert = true
                            }
                        } catch {
                            print("❌ Error parsing response: \(error)")
                            self.alertMessage = "Registration successful! (Could not parse full response)"
                            self.authManager.markAsResponder()
                            self.showSuccessAlert = true
                        }
                        
                    case 400:
                        self.alertMessage = "Bad request. Please check your information and try again."
                        self.showErrorAlert = true
                        
                    case 401:
                        self.alertMessage = "Authentication error. Please check your login and try again."
                        self.showErrorAlert = true
                        
                    case 409:
                        self.alertMessage = "You are already registered as a responder."
                        self.showErrorAlert = true
                        
                    case 422:
                        self.alertMessage = "Invalid data. Please check all fields and try again."
                        self.showErrorAlert = true
                        
                    default:
                        self.alertMessage = "Server error. Please try again later."
                        self.showErrorAlert = true
                    }
                } else {
                    self.alertMessage = "No response from server"
                    self.showErrorAlert = true
                }
            }
        }.resume()
    }
    
//    private func submitRegistration() {
//        guard let token = authManager.authToken else {
//            print("❌ No auth token found!")
//            alertMessage = "Please login to continue"
//            showErrorAlert = true
//            return
//        }
//        
//        print("✅ Auth token found: \(token.prefix(20))...")
//        
//        guard let lat = locationManager.latitude,
//              let lng = locationManager.longitude else {
//            alertMessage = "Unable to get your location. Please enable location services."
//            showErrorAlert = true
//            return
//        }
//        
//        isLoading = true
//        
//        // Prepare hospital field
//        let hospitalValue = isUsingCustomHospital ?
//            customHospitalName.trimmingCharacters(in: .whitespacesAndNewlines) :
//            selectedHospital?.id ?? ""
//        
//        if hospitalValue.isEmpty {
//                isLoading = false
//                alertMessage = "Please select a hospital or enter a valid hospital name"
//                showErrorAlert = true
//                return
//            }
//        
//        // Prepare request body
//        let requestBody: [String: Any] = [
//            "hospital": hospitalValue,
//            "certifications": certifications,
//            "experienceYears": Int(experienceYears) ?? 0,
//            "vehicleType": selectedVehicleType,
//            "licenseNumber": licenseNumber.trimmingCharacters(in: .whitespacesAndNewlines),
//            "maxDistance": Int(maxDistance) ?? 25,
//            "bio": bio.trimmingCharacters(in: .whitespacesAndNewlines),
//            "currentLocation": [
//                "type": "Point",
//                "coordinates": [lng, lat]
//            ],
//            "availability": [
//                "monday": availability.monday,
//                "tuesday": availability.tuesday,
//                "wednesday": availability.wednesday,
//                "thursday": availability.thursday,
//                "friday": availability.friday,
//                "saturday": availability.saturday,
//                "sunday": availability.sunday
//            ]
//        ]
//        
//        print("📤 Submitting responder registration: \(requestBody)")
//        
//        let urlString = "https://guardian-fwpg.onrender.com/api/v1/responder/register"
//        guard let url = URL(string: urlString) else {
//            isLoading = false
//            alertMessage = "Invalid server URL"
//            showErrorAlert = true
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        print("🔐 Using Authorization header: Bearer \(token.prefix(20))...")
//        
//        
//        // FIX: Try different token formats
////        print("🔐 Using Authorization header: Bearer \(token.prefix(20))...")
////        
////        // Log the full request for debugging
////        print("🌐 URL: \(urlString)")
////        print("📝 Headers: \(request.allHTTPHeaderFields ?? [:])")
//        
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
//            request.httpBody = jsonData
//            
//            // Print the request body for debugging
////            if let jsonString = String(data: jsonData, encoding: .utf8) {
////                print("📦 Request Body: \(jsonString)")
////            }
//        } catch {
//            isLoading = false
//            alertMessage = "Failed to prepare registration data"
//            showErrorAlert = true
//            return
//        }
//        
//        request.timeoutInterval = 30
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            DispatchQueue.main.async {
//                self.isLoading = false
//                
//                if let error = error {
//                    print("❌ Network error: \(error.localizedDescription)")
//                    self.alertMessage = "Network error: \(error.localizedDescription)"
//                    self.showErrorAlert = true
//                    return
//                }
//                
//                if let httpResponse = response as? HTTPURLResponse {
//                    print("📡 HTTP Status: \(httpResponse.statusCode)")
//                    
//                    // Print response headers for debugging
//                    print("📋 Response Headers: \(httpResponse.allHeaderFields)")
//                    
//                    guard let data = data else {
//                        self.alertMessage = "No response data from server"
//                        self.showErrorAlert = true
//                        return
//                    }
//                    
//                    // Print raw response for debugging
//                    if let responseString = String(data: data, encoding: .utf8) {
//                        print("📦 Raw response: \(responseString)")
//                    }
//                    
//                    // Handle different status codes
//                    switch httpResponse.statusCode {
//                    case 200, 201:
//                        // Success!
//                        self.authManager.markAsResponder()
//                        
//                        // Parse the response to get the responder token
//                        do {
//                            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
//                               let success = json["success"] as? Bool, success,
//                               let data = json["data"] as? [String: Any],
//                               let token = data["token"] as? String {
//                                // Save the responder token if provided
//                                print("✅ Responder token received: \(token.prefix(20))...")
//                                // You might want to save this token separately
//                            }
//                        } catch {
//                            print("⚠️ Could not parse responder token from response")
//                        }
//                        
//                        self.alertMessage = "Registration successful! You are now a responder."
//                        self.showSuccessAlert = true
//                        
//                    case 400:
//                        self.alertMessage = "Bad request. Please check your information and try again."
//                        self.showErrorAlert = true
//                        
//                    case 401:
//                        // Try to parse the specific error
//                        do {
//                            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
//                               let errorMsg = json["message"] as? String ?? json["error"] as? String {
//                                self.alertMessage = "Authentication failed: \(errorMsg)"
//                            } else {
//                                self.alertMessage = "Authentication error. Please check your login and try again."
//                            }
//                        } catch {
//                            self.alertMessage = "Authentication error. Your session may have expired."
//                        }
//                        self.showErrorAlert = true
//                        
//                    case 409:
//                        self.alertMessage = "You are already registered as a responder."
//                        self.showErrorAlert = true
//                        
//                    case 422:
//                        self.alertMessage = "Invalid data. Please check all fields and try again."
//                        self.showErrorAlert = true
//                        
//                    default:
//                        self.alertMessage = "Server error. Please try again later."
//                        self.showErrorAlert = true
//                    }
//                } else {
//                    self.alertMessage = "No response from server"
//                    self.showErrorAlert = true
//                }
//            }
//        }.resume()
//    }
}

// MARK: - Supporting Enums and Views

enum DayOfWeek: String, CaseIterable {
    case monday = "Mon"
    case tuesday = "Tue"
    case wednesday = "Wed"
    case thursday = "Thu"
    case friday = "Fri"
    case saturday = "Sat"
    case sunday = "Sun"
}

struct DayAvailabilityView: View {
    let day: DayOfWeek
    @Binding var availability: [Bool]
    
    var body: some View {
        VStack(spacing: 8) {
            Text(day.rawValue)
                .font(.custom("Poppins-SemiBold", size: 12))
                .foregroundColor(.black)
            
            VStack(spacing: 4) {
                ForEach(0..<6) { row in
                    HStack(spacing: 2) {
                        ForEach(0..<4) { col in
                            let hour = row * 4 + col
                            if hour < 24 {
                                HourButton(
                                    hour: hour,
                                    isAvailable: $availability[hour]
                                )
                            }
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct HourButton: View {
    let hour: Int
    @Binding var isAvailable: Bool
    
    var body: some View {
        Button(action: {
            isAvailable.toggle()
        }) {
            Text("\(hour)")
                .font(.custom("Poppins-Regular", size: 10))
                .frame(width: 24, height: 24)
                .background(isAvailable ? Color.Guardian.navy : Color.gray.opacity(0.1))
                .foregroundColor(isAvailable ? .white : .gray)
                .cornerRadius(4)
        }
    }
}

// MARK: - Flow Layout for Tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? 0
        var height: CGFloat = 0
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if rowWidth + size.width + spacing > maxWidth {
                height += rowHeight + spacing
                rowWidth = size.width
                rowHeight = size.height
            } else {
                rowWidth += size.width + spacing
                rowHeight = max(rowHeight, size.height)
            }
        }
        
        height += rowHeight
        
        return CGSize(width: maxWidth, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxWidth = bounds.width
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}


//
//  ResponderRegistrationView.swift
//  Guardian Angel
//
//  Created by Oluwaseun Odueso on 10/01/2026.
//
//
//import SwiftUI
//
//struct ResponderRegistrationView: View {
//    @Environment(\.presentationMode) var presentationMode
//    @ObservedObject private var authManager = AuthManager.shared
//    @StateObject private var locationManager = LocationManager()
//    
//    // Form Fields
//    @State private var selectedHospital: Hospital?
//    @State private var customHospitalName = ""
//    @State private var certifications: [String] = []
//    @State private var newCertification = ""
//    @State private var experienceYears = ""
//    @State private var selectedVehicleType = "car"
//    @State private var licenseNumber = ""
//    @State private var maxDistance = "25"
//    @State private var bio = ""
//    
//    // Availability Schedule
//    @State private var availability = AvailabilitySchedule()
//    
//    // UI State
//    @State private var hospitals: [Hospital] = []
//    @State private var isLoading = false
//    @State private var isLoadingHospitals = false
//    @State private var showSuccessAlert = false
//    @State private var showErrorAlert = false
//    @State private var alertMessage = ""
//    @State private var showingHospitalDropdown = false
//    @State private var isUsingCustomHospital = false
//    
//    // Vehicle types
//    private let vehicleTypes = ["car", "motorcycle", "bicycle", "ambulance", "suv", "van", "other"]
//    
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 24) {
//                // Header
//                headerView
//                
//                // Hospital Selection
//                hospitalSelectionView
//                
//                // Certifications
//                certificationsView
//                
//                // Experience & Vehicle
//                experienceVehicleView
//                
//                // License & Distance
//                licenseDistanceView
//                
//                // Bio
//                bioView
//                
//                // Availability Schedule
//                availabilityScheduleView
//                
//                // Submit Button
//                submitButton
//            }
//            .padding(.horizontal, 20)
//            .padding(.bottom, 40)
//        }
//        .background(Color(hex: "F8F9FA"))
//        .navigationBarHidden(true)
//        .onAppear {
//            fetchHospitals()
//            locationManager.requestLocation()
//        }
//        .alert("Success", isPresented: $showSuccessAlert) {
//            Button("OK", role: .cancel) {
//                // Dismiss this view and let the app handle navigation
//                presentationMode.wrappedValue.dismiss()
//            }
//        } message: {
//            Text(alertMessage)
//        }
//        .alert("Error", isPresented: $showErrorAlert) {
//            Button("OK", role: .cancel) { }
//        } message: {
//            Text(alertMessage)
//        }
//    }
//    
//    // MARK: - Header View
//    private var headerView: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            HStack {
//                Button(action: {
//                    presentationMode.wrappedValue.dismiss()
//                }) {
//                    HStack(spacing: 8) {
//                        Image(systemName: "chevron.left")
//                            .font(.system(size: 16, weight: .semibold))
//                        Text("Back")
//                            .font(.custom("Poppins-Medium", size: 14))
//                    }
//                    .foregroundColor(Color.Guardian.navy)
//                }
//                
//                Spacer()
//                
//                Text("Become a Responder")
//                    .font(.custom("Poppins-SemiBold", size: 16))
//                    .foregroundColor(.black)
//                
//                Spacer()
//                
//                // Empty view for balance
//                Color.clear.frame(width: 60, height: 1)
//            }
//            
//            Text("Join our network of emergency responders and help save lives in your community.")
//                .font(.custom("Poppins-Regular", size: 12))
//                .foregroundColor(Color.Guardian.grey)
//                .multilineTextAlignment(.leading)
//                .fixedSize(horizontal: false, vertical: true)
//            
//            Divider()
//                .background(Color.gray.opacity(0.3))
//        }
//        .padding(.top, 16)
//    }
//    
//    // MARK: - Hospital Selection View
//    private var hospitalSelectionView: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("Hospital / Organization")
//                .font(.custom("Poppins-Regular", size: 14))
//                .foregroundColor(.black)
//            
//            // Hospital Selection Toggle
//            Picker("Hospital Selection", selection: $isUsingCustomHospital) {
//                Text("Select from list").tag(false)
//                    .font(.custom("Poppins-Regular", size: 12))
//                Text("Type manually").tag(true)
//                    .font(.custom("Poppins-Regular", size: 12))
//            }
//            .pickerStyle(SegmentedPickerStyle())
//            
//            if isUsingCustomHospital {
//                // Manual Hospital Input
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Hospital Name")
//                        .font(.custom("Poppins-Regular", size: 14))
//                        .foregroundColor(Color.Guardian.black)
//                        .padding(.top, 16)
//                    
//                    TextField("Enter hospital name", text: $customHospitalName)
//                        .font(.custom("Poppins-Regular", size: 12))
//                        .padding()
//                        .foregroundColor(Color.Guardian.grey)
//                        .background(Color.white)
//                        .cornerRadius(10)
//                }
//            } else {
//                // Hospital Dropdown
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Select Hospital")
//                        .font(.custom("Poppins-Regular", size: 14))
//                        .foregroundColor(.black)
//                        .padding(.top, 16)
//                    
//                    ZStack {
//                        RoundedRectangle(cornerRadius: 10)
//                            .fill(Color.white)
//                        
//                        Menu {
//                            if isLoadingHospitals {
//                                Text("Loading hospitals...")
//                            } else {
//                                ForEach(hospitals) { hospital in
//                                    Button(hospital.name) {
//                                        selectedHospital = hospital
//                                    }
//                                }
//                            }
//                        } label: {
//                            HStack {
//                                Text(selectedHospital?.name ?? "Select a hospital")
//                                    .font(.custom("Poppins-Regular", size: 12))
//                                    .foregroundColor(selectedHospital == nil ? Color.Guardian.grey : .black)
//                                    .lineLimit(1)
//                                
//                                Spacer()
//                                
//                                Image(systemName: "chevron.down")
//                                    .foregroundColor(.gray)
//                            }
//                            .padding(.horizontal, 16)
//                            .padding(.vertical, 14)
//                        }
//                    }
//                    .frame(height: 50)
//                }
//            }
//        }
//    }
//    
//    // MARK: - Certifications View
//    private var certificationsView: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("Certifications")
//                .font(.custom("Poppins-Regular", size: 14))
//                .foregroundColor(.black)
//                .padding(.top, 12)
//            
//            // Certification Input
//            HStack {
//                TextField("Add certification (e.g., CPR, First Aid)", text: $newCertification)
//                    .font(.custom("Poppins-Regular", size: 13))
//                    .foregroundColor(Color.Guardian.grey)
//                    .padding()
//                    .background(Color.white)
//                    .cornerRadius(10)
//                
//                Button(action: addCertification) {
//                    Image(systemName: "plus.circle.fill")
//                        .font(.custom("Poppins-Regular", size: 12))
//                        .foregroundColor(Color.Guardian.navy)
//                }
//                .disabled(newCertification.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
//            }
//            
//            // Certifications List
//            if !certifications.isEmpty {
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Your Certifications")
//                        .font(.custom("Poppins-Regular", size: 14))
//                        .foregroundColor(.gray)
//                        .padding(.top, 12)
//                    
//                    FlowLayout(spacing: 8) {
//                        ForEach(certifications, id: \.self) { certification in
//                            HStack(spacing: 4) {
//                                Text(certification)
//                                    .font(.custom("Poppins-Regular", size: 12))
//                                    .foregroundColor(Color.Guardian.navy)
//                                
//                                Button(action: {
//                                    removeCertification(certification)
//                                }) {
//                                    Image(systemName: "xmark.circle.fill")
//                                        .font(.system(size: 12))
//                                        .foregroundColor(.gray)
//                                }
//                            }
//                            .padding(.horizontal, 12)
//                            .padding(.vertical, 6)
//                            .background(Color.Guardian.navy.opacity(0.1))
//                            .cornerRadius(15)
//                        }
//                    }
//                }
//            }
//            
//            // Common Certifications
//            VStack(alignment: .leading, spacing: 8) {
//                Text("Common Certifications")
//                    .font(.custom("Poppins-Regular", size: 14))
//                    .foregroundColor(.black)
//                    .padding(.top, 14)
//                
//                FlowLayout(spacing: 8) {
//                    ForEach(["CPR", "First Aid", "EMT", "BLS", "ACLS", "PALS", "Paramedic", "Nurse"], id: \.self) { commonCert in
//                        Button(action: {
//                            if !certifications.contains(commonCert) {
//                                certifications.append(commonCert)
//                            }
//                        }) {
//                            Text(commonCert)
//                                .font(.custom("Poppins-Regular", size: 12))
//                                .foregroundColor(.white)
//                                .padding(.horizontal, 12)
//                                .padding(.vertical, 6)
//                                .background(Color.Guardian.navy)
//                                .cornerRadius(15)
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    // MARK: - Experience & Vehicle View
//    private var experienceVehicleView: some View {
//        HStack(spacing: 16) {
//            // Experience Years
//            VStack(alignment: .leading, spacing: 8) {
//                Text("Experience (Years)")
//                    .font(.custom("Poppins-Regular", size: 14))
//                    .foregroundColor(.black)
//                
//                TextField("0", text: $experienceYears)
//                    .font(.custom("Poppins-Regular", size: 12))
//                    .foregroundColor(Color.Guardian.grey)
//                    .padding()
//                    .background(Color.white)
//                    .cornerRadius(10)
//            }
//            
//            // Vehicle Type
//            VStack(alignment: .leading, spacing: 8) {
//                Text("Vehicle Type")
//                    .font(.custom("Poppins-Regular", size: 14))
//                    .foregroundColor(.black)
//                
//                ZStack {
//                    RoundedRectangle(cornerRadius: 10)
//                        .fill(Color.white)
//                    
//                    Picker("Vehicle Type", selection: $selectedVehicleType) {
//                        ForEach(vehicleTypes, id: \.self) { type in
//                            Text(type.capitalized)
//                                .tag(type)
//                                .foregroundColor(Color.Guardian.grey)
//                                .font(.custom("Poppins-Regular", size: 12))
//                        }
//                    }
//                    .pickerStyle(MenuPickerStyle())
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.horizontal, 16)
//                }
//                .frame(height: 50)
//            }
//        }
//    }
//    
//    // MARK: - License & Distance View
//    private var licenseDistanceView: some View {
//        HStack(spacing: 16) {
//            // License Number
//            VStack(alignment: .leading, spacing: 10) {
//                Text("License Number")
//                    .font(.custom("Poppins-Regular", size: 14))
//                    .foregroundColor(.black)
//                
//                TextField("Enter license number", text: $licenseNumber)
//                    .font(.custom("Poppins-Regular", size: 12))
//                    .foregroundColor(Color.Guardian.grey)
//                    .padding()
//                    .background(Color.white)
//                    .cornerRadius(10)
//            }
//            
//            // Max Distance
//            VStack(alignment: .leading, spacing: 10) {
//                Text("Max Distance (km)")
//                    .font(.custom("Poppins-Regular", size: 14))
//                    .foregroundColor(.black)
//                
//                TextField("25", text: $maxDistance)
//                    .keyboardType(.numberPad)
//                    .font(.custom("Poppins-Regular", size: 12))
//                    .foregroundColor(Color.Guardian.grey)
//                    .padding()
//                    .background(Color.white)
//                    .cornerRadius(10)
//            }
//        }
//    }
//    
//    // MARK: - Bio View
//    private var bioView: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("Bio / Description")
//                .font(.custom("Poppins-Regular", size: 14))
//                .foregroundColor(.black)
//            
//            Text("Tell us about your experience and why you want to be a responder.")
//                .font(.custom("Poppins-Regular", size: 12))
//                .foregroundColor(.gray)
//            
//            TextEditor(text: $bio)
//                .frame(height: 120)
//                .padding(8)
//                .background(Color.white)
//                .cornerRadius(10)
//                .font(.custom("Poppins-Regular", size: 14))
//            
//            Text("\(bio.count)/500 characters")
//                .font(.custom("Poppins-Regular", size: 12))
//                .foregroundColor(bio.count > 500 ? .red : .gray)
//                .frame(maxWidth: .infinity, alignment: .trailing)
//        }
//    }
//    
//    // MARK: - Availability Schedule View
//    private var availabilityScheduleView: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            Text("Availability Schedule")
//                .font(.custom("Poppins-Regular", size: 14))
//                .foregroundColor(.black)
//            
//            Text("Select the hours you're available each day (24-hour format)")
//                .font(.custom("Poppins-Regular", size: 12))
//                .foregroundColor(.gray)
//            
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 16) {
//                    ForEach(DayOfWeek.allCases, id: \.self) { day in
//                        DayAvailabilityView(
//                            day: day,
//                            availability: bindingForDay(day)
//                        )
//                    }
//                }
//                .padding(.bottom, 8)
//            }
//            
//            // Quick Select Buttons
//            HStack(spacing: 12) {
//                Button("Weekdays 9-5") {
//                    setWeekdayHours(start: 9, end: 17)
//                }
//                .font(.custom("Poppins-Regular", size: 12))
//                .padding(.horizontal, 12)
//                .padding(.vertical, 6)
//                .background(Color.gray.opacity(0.1))
//                .cornerRadius(15)
//                
//                Button("Weekends All Day") {
//                    setWeekendAllDay()
//                }
//                .font(.custom("Poppins-Regular", size: 12))
//                .padding(.horizontal, 12)
//                .padding(.vertical, 6)
//                .background(Color.gray.opacity(0.1))
//                .cornerRadius(15)
//                
//                Button("Clear All") {
//                    clearAllAvailability()
//                }
//                .font(.custom("Poppins-Regular", size: 12))
//                .padding(.horizontal, 12)
//                .padding(.vertical, 6)
//                .background(Color.gray.opacity(0.1))
//                .cornerRadius(15)
//            }
//        }
//    }
//    
//    // MARK: - Submit Button
//    private var submitButton: some View {
//        Button(action: submitRegistration) {
//            if isLoading {
//                ProgressView()
//                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                    .frame(height: 24)
//            } else {
//                Text("Submit Registration")
//                    .font(.custom("Poppins-Regular", size: 16))
//                    .foregroundColor(.white)
//            }
//        }
//        .frame(maxWidth: .infinity)
//        .padding()
//        .background(Color.Guardian.navy)
//        .cornerRadius(10)
//        .disabled(isLoading || !isFormValid)
//        .opacity((isLoading || !isFormValid) ? 0.7 : 1)
//    }
//    
//    // MARK: - Helper Functions
//    
//    private func addCertification() {
//        let trimmedCert = newCertification.trimmingCharacters(in: .whitespacesAndNewlines)
//        if !trimmedCert.isEmpty && !certifications.contains(trimmedCert) {
//            certifications.append(trimmedCert)
//            newCertification = ""
//        }
//    }
//    
//    private func removeCertification(_ certification: String) {
//        certifications.removeAll { $0 == certification }
//    }
//    
//    private func bindingForDay(_ day: DayOfWeek) -> Binding<[Bool]> {
//        switch day {
//        case .monday: return $availability.monday
//        case .tuesday: return $availability.tuesday
//        case .wednesday: return $availability.wednesday
//        case .thursday: return $availability.thursday
//        case .friday: return $availability.friday
//        case .saturday: return $availability.saturday
//        case .sunday: return $availability.sunday
//        }
//    }
//    
//    private func setWeekdayHours(start: Int, end: Int) {
//        for hour in 0..<24 {
//            let isAvailable = hour >= start && hour < end
//            availability.monday[hour] = isAvailable
//            availability.tuesday[hour] = isAvailable
//            availability.wednesday[hour] = isAvailable
//            availability.thursday[hour] = isAvailable
//            availability.friday[hour] = isAvailable
//            availability.saturday[hour] = false
//            availability.sunday[hour] = false
//        }
//    }
//    
//    private func setWeekendAllDay() {
//        for hour in 0..<24 {
//            availability.monday[hour] = false
//            availability.tuesday[hour] = false
//            availability.wednesday[hour] = false
//            availability.thursday[hour] = false
//            availability.friday[hour] = false
//            availability.saturday[hour] = true
//            availability.sunday[hour] = true
//        }
//    }
//    
//    private func clearAllAvailability() {
//        for hour in 0..<24 {
//            availability.monday[hour] = false
//            availability.tuesday[hour] = false
//            availability.wednesday[hour] = false
//            availability.thursday[hour] = false
//            availability.friday[hour] = false
//            availability.saturday[hour] = false
//            availability.sunday[hour] = false
//        }
//    }
//    
//    private var isFormValid: Bool {
//        // Check hospital
//        if isUsingCustomHospital {
//            if customHospitalName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//                return false
//            }
//        } else {
//            if selectedHospital == nil {
//                return false
//            }
//        }
//        
//        // Check other required fields
//        if certifications.isEmpty { return false }
//        if experienceYears.isEmpty || Int(experienceYears) == nil { return false }
//        if licenseNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return false }
//        if maxDistance.isEmpty || Int(maxDistance) == nil { return false }
//        if bio.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || bio.count > 500 { return false }
//        
//        // Check location
//        if locationManager.latitude == nil || locationManager.longitude == nil {
//            return false
//        }
//        
//        return true
//    }
//    
//    // MARK: - API Functions
//    
//    private func fetchHospitals() {
//        guard let token = authManager.authToken else {
//            alertMessage = "Please login to continue"
//            showErrorAlert = true
//            return
//        }
//        
//        isLoadingHospitals = true
//        
//        let urlString = "https://guardian-fwpg.onrender.com/api/v1/hospitals"
//        guard let url = URL(string: urlString) else {
//            isLoadingHospitals = false
//            alertMessage = "Invalid server URL"
//            showErrorAlert = true
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            DispatchQueue.main.async {
//                self.isLoadingHospitals = false
//                
//                if let error = error {
//                    self.alertMessage = "Network error: \(error.localizedDescription)"
//                    self.showErrorAlert = true
//                    return
//                }
//                
//                guard let data = data else {
//                    self.alertMessage = "No response from server"
//                    self.showErrorAlert = true
//                    return
//                }
//                
//                if let responseString = String(data: data, encoding: .utf8) {
//                    print("🏥 Hospitals response: \(responseString)")
//                }
//                
//                do {
//                    let decoder = JSONDecoder()
//                    let response = try decoder.decode(HospitalsResponse.self, from: data)
//                    
//                    if response.success {
//                        self.hospitals = response.data
//                        print("✅ Loaded \(self.hospitals.count) hospitals")
//                    } else {
//                        self.alertMessage = response.error ?? response.message ?? "Failed to load hospitals"
//                        self.showErrorAlert = true
//                    }
//                } catch {
//                    self.alertMessage = "Failed to parse response: \(error.localizedDescription)"
//                    self.showErrorAlert = true
//                    print("❌ Decoding error: \(error)")
//                }
//            }
//        }.resume()
//    }
//    
//    private func submitRegistration() {
//        guard let token = authManager.authToken else {
//            alertMessage = "Please login to continue"
//            showErrorAlert = true
//            return
//        }
//        
//        guard let lat = locationManager.latitude,
//              let lng = locationManager.longitude else {
//            alertMessage = "Unable to get your location. Please enable location services."
//            showErrorAlert = true
//            return
//        }
//        
//        isLoading = true
//        
//        // Prepare hospital field
//        let hospitalValue = isUsingCustomHospital ?
//            customHospitalName.trimmingCharacters(in: .whitespacesAndNewlines) :
//            selectedHospital?.id ?? ""
//        
//        // Prepare request body
//        let requestBody: [String: Any] = [
//            "hospital": hospitalValue,
//            "certifications": certifications,
//            "experienceYears": Int(experienceYears) ?? 0,
//            "vehicleType": selectedVehicleType,
//            "licenseNumber": licenseNumber.trimmingCharacters(in: .whitespacesAndNewlines),
//            "maxDistance": Int(maxDistance) ?? 25,
//            "bio": bio.trimmingCharacters(in: .whitespacesAndNewlines),
//            "currentLocation": [
//                "type": "Point",
//                "coordinates": [lng, lat]
//            ],
//            "availability": [
//                "monday": availability.monday,
//                "tuesday": availability.tuesday,
//                "wednesday": availability.wednesday,
//                "thursday": availability.thursday,
//                "friday": availability.friday,
//                "saturday": availability.saturday,
//                "sunday": availability.sunday
//            ]
//        ]
//        
//        print("📤 Submitting responder registration: \(requestBody)")
//        
//        let urlString = "https://guardian-fwpg.onrender.com/api/v1/responder/register"
//        guard let url = URL(string: urlString) else {
//            isLoading = false
//            alertMessage = "Invalid server URL"
//            showErrorAlert = true
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
//        } catch {
//            isLoading = false
//            alertMessage = "Failed to prepare registration data"
//            showErrorAlert = true
//            return
//        }
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            DispatchQueue.main.async {
//                self.isLoading = false
//                
//                if let error = error {
//                    self.alertMessage = "Network error: \(error.localizedDescription)"
//                    self.showErrorAlert = true
//                    return
//                }
//                
//                if let httpResponse = response as? HTTPURLResponse {
//                    print("📡 HTTP Status: \(httpResponse.statusCode)")
//                    
//                    if httpResponse.statusCode == 401 {
//                        self.alertMessage = "Session expired. Please login again."
//                        self.showErrorAlert = true
//                        return
//                    }
//                    
//                    if httpResponse.statusCode == 400 {
//                        self.alertMessage = "Bad request. Please check your information."
//                        self.showErrorAlert = true
//                    }
//                    
//                    if httpResponse.statusCode == 409 {
//                        // Conflict - user already registered as responder
//                        self.alertMessage = "You are already registered as a responder."
//                        self.showErrorAlert = true
//                    }
//                }
//                
//                guard let data = data else {
//                    self.alertMessage = "No response from server"
//                    self.showErrorAlert = true
//                    return
//                }
//                
//                // Print response for debugging
//                if let responseString = String(data: data, encoding: .utf8) {
//                    print("📦 Response: \(responseString)")
//                }
//                
//                do {
//                    let decoder = JSONDecoder()
//                    let response = try decoder.decode(ResponderRegistrationResponse.self, from: data)
//                    
//                    if response.success {
//                        // MARK USER AS RESPONDENT IN AUTH MANAGER
//                        self.authManager.markAsResponder()
//                        
//                        self.alertMessage = "Registration successful! You are now a responder."
//                        self.showSuccessAlert = true
//                        
//                        // Success alert will dismiss automatically, then app will handle navigation
//                    } else {
//                        // Try to get error from either error or message field
//                        let errorMessage = response.error ?? response.message ?? "Registration failed"
//                        self.alertMessage = errorMessage
//                        
//                        // Check for specific error messages
//                        if errorMessage.lowercased().contains("already registered") {
//                            self.alertMessage = "You are already registered as a responder."
//                        } else if errorMessage.lowercased().contains("hospital") && errorMessage.lowercased().contains("not found") {
//                            self.alertMessage = "Hospital not found. Please select a valid hospital."
//                        }
//                        
//                        self.showErrorAlert = true
//                    }
//                } catch {
//                    // If decoding fails, try to parse as generic JSON
//                    do {
//                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
//                            if let success = json["success"] as? Bool, !success {
//                                let errorMessage = json["error"] as? String ?? json["message"] as? String ?? "Registration failed"
//                                self.alertMessage = errorMessage
//                                self.showErrorAlert = true
//                            } else if let message = json["message"] as? String {
//                                // Even if we can't decode properly, if server says success, mark as responder
//                                if message.lowercased().contains("success") {
//                                    self.authManager.markAsResponder()
//                                    self.alertMessage = "Registration successful! You are now a responder."
//                                    self.showSuccessAlert = true
//                                } else {
//                                    self.alertMessage = message
//                                    self.showErrorAlert = true
//                                }
//                            }
//                        } else {
//                            self.alertMessage = "Failed to process response"
//                            self.showErrorAlert = true
//                        }
//                    } catch {
//                        self.alertMessage = "Failed to process response: \(error.localizedDescription)"
//                        self.showErrorAlert = true
//                    }
//                }
//            }
//        }.resume()
//    }
//}
//
//// MARK: - Supporting Enums and Views
//
//enum DayOfWeek: String, CaseIterable {
//    case monday = "Mon"
//    case tuesday = "Tue"
//    case wednesday = "Wed"
//    case thursday = "Thu"
//    case friday = "Fri"
//    case saturday = "Sat"
//    case sunday = "Sun"
//}
//
//struct DayAvailabilityView: View {
//    let day: DayOfWeek
//    @Binding var availability: [Bool]
//    
//    var body: some View {
//        VStack(spacing: 8) {
//            Text(day.rawValue)
//                .font(.custom("Poppins-SemiBold", size: 12))
//                .foregroundColor(.black)
//            
//            VStack(spacing: 4) {
//                ForEach(0..<6) { row in
//                    HStack(spacing: 2) {
//                        ForEach(0..<4) { col in
//                            let hour = row * 4 + col
//                            if hour < 24 {
//                                HourButton(
//                                    hour: hour,
//                                    isAvailable: $availability[hour]
//                                )
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        .padding(12)
//        .background(Color.white)
//        .cornerRadius(12)
//        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
//    }
//}
//
//struct HourButton: View {
//    let hour: Int
//    @Binding var isAvailable: Bool
//    
//    var body: some View {
//        Button(action: {
//            isAvailable.toggle()
//        }) {
//            Text("\(hour)")
//                .font(.custom("Poppins-Regular", size: 10))
//                .frame(width: 24, height: 24)
//                .background(isAvailable ? Color.Guardian.navy : Color.gray.opacity(0.1))
//                .foregroundColor(isAvailable ? .white : .gray)
//                .cornerRadius(4)
//        }
//    }
//}
//
//// MARK: - Flow Layout for Tags
//struct FlowLayout: Layout {
//    var spacing: CGFloat = 8
//    
//    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
//        let maxWidth = proposal.width ?? 0
//        var height: CGFloat = 0
//        var rowWidth: CGFloat = 0
//        var rowHeight: CGFloat = 0
//        
//        for subview in subviews {
//            let size = subview.sizeThatFits(.unspecified)
//            
//            if rowWidth + size.width + spacing > maxWidth {
//                height += rowHeight + spacing
//                rowWidth = size.width
//                rowHeight = size.height
//            } else {
//                rowWidth += size.width + spacing
//                rowHeight = max(rowHeight, size.height)
//            }
//        }
//        
//        height += rowHeight
//        
//        return CGSize(width: maxWidth, height: height)
//    }
//    
//    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
//        let maxWidth = bounds.width
//        var x = bounds.minX
//        var y = bounds.minY
//        var rowHeight: CGFloat = 0
//        
//        for subview in subviews {
//            let size = subview.sizeThatFits(.unspecified)
//            
//            if x + size.width > bounds.maxX {
//                x = bounds.minX
//                y += rowHeight + spacing
//                rowHeight = 0
//            }
//            
//            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
//            
//            x += size.width + spacing
//            rowHeight = max(rowHeight, size.height)
//        }
//    }
//}
//
//// MARK: - Response Models
//struct ResponderRegistrationResponse: Decodable {
//    let success: Bool
//    let message: String?
//    let error: String?
//    let data: ResponderRegistrationData?
//    let timestamp: String
//}
//
//struct ResponderRegistrationData: Decodable {
//    let id: String
//    let userId: String
//    let hospital: String
//    let certifications: [String]
//    let experienceYears: Int
//    let vehicleType: String
//    let licenseNumber: String
//    let availability: [String: [Bool]]
//    let maxDistance: Int
//    let bio: String
//    let status: String
//    let currentLocation: ResponderLocation?
//    let rating: Double
//    let totalAssignments: Int
//    let successfulAssignments: Int
//    let responseTimeAvg: Double
//    
//    enum CodingKeys: String, CodingKey {
//        case id = "_id"
//        case userId, hospital, certifications, experienceYears, vehicleType
//        case licenseNumber, availability, maxDistance, bio, status
//        case currentLocation, rating, totalAssignments, successfulAssignments
//        case responseTimeAvg
//    }
//}
//
//struct ResponderLocation: Decodable {
//    let type: String
//    let coordinates: [Double]
//    let updatedAt: String
//}
//
//struct HospitalsResponse: Decodable {
//    let success: Bool
//    let message: String?
//    let error: String?
//    let data: [Hospital]
//    let timestamp: String
//}
//
//struct Hospital: Decodable, Identifiable {
//    let id: String
//    let name: String
//    let address: String
//    let contact: String?
//    
//    enum CodingKeys: String, CodingKey {
//        case id = "_id"
//        case name, address, contact
//    }
//}
//
//// MARK: - Availability Schedule Struct
//struct AvailabilitySchedule {
//    var monday = Array(repeating: false, count: 24)
//    var tuesday = Array(repeating: false, count: 24)
//    var wednesday = Array(repeating: false, count: 24)
//    var thursday = Array(repeating: false, count: 24)
//    var friday = Array(repeating: false, count: 24)
//    var saturday = Array(repeating: false, count: 24)
//    var sunday = Array(repeating: false, count: 24)
//}
