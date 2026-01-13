import SwiftUI

struct GAInputField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    @State private var isPasswordVisible: Bool = false

    var body: some View {
        HStack(spacing: 8) {
            if isSecure {
                Group {
                    if isPasswordVisible {
                        TextField(placeholder, text: $text)
                            .textContentType(.password)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    } else {
                        SecureField(placeholder, text: $text)
                            .textContentType(.password)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                }

                Button(action: { isPasswordVisible.toggle() }) {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            } else {
                TextField(placeholder, text: $text)
                    .textInputAutocapitalization(.none)
                    .disableAutocorrection(true)
                    .keyboardType(keyboardTypeForPlaceholder())
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }

    private func keyboardTypeForPlaceholder() -> UIKeyboardType {
        let lower = placeholder.lowercased()
        if lower.contains("email") { return .emailAddress }
        if lower.contains("phone") { return .phonePad }
        return .default
    }
}

// Preview for rapid iteration
#Preview {
    VStack(spacing: 16) {
        GAInputField(placeholder: "Email", text: .constant(""))
        GAInputField(placeholder: "Full name", text: .constant(""))
        GAInputField(placeholder: "Phone number", text: .constant(""))
        GAInputField(placeholder: "Password", text: .constant(""), isSecure: true)
    }
    .padding()
}
