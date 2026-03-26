import SwiftUI

struct AuthView: View {
    @EnvironmentObject var profile: UserProfile
    @State private var isSignUp = true
    @State private var name = ""
    @State private var email = ""
    @State private var birthDate = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
    @State private var animateIn = false
    @State private var errorMsg = ""
    @State private var showError = false
    @State private var isLoading = false

    var body: some View {
        ZStack {
            Color(hex: "07030f").ignoresSafeArea()
            RadialGradient(colors: [Color(hex: "3b0764").opacity(0.7), .clear],
                           center: .top, startRadius: 0, endRadius: 600)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    VStack(spacing: 12) {
                        Text("✦")
                            .font(.system(size: 56))
                            .opacity(animateIn ? 1 : 0)
                            .scaleEffect(animateIn ? 1 : 0.5)
                        Text("ASTRALVEIL")
                            .font(.system(size: 28, weight: .ultraLight))
                            .tracking(10)
                            .foregroundColor(.white)
                            .opacity(animateIn ? 1 : 0)
                        Text("your cosmic oracle")
                            .font(.system(size: 12, weight: .light))
                            .tracking(4)
                            .foregroundColor(Color(hex: "a78bfa"))
                            .opacity(animateIn ? 1 : 0)
                    }
                    .padding(.top, 80)
                    .padding(.bottom, 52)

                    HStack(spacing: 0) {
                        ForEach(["Sign Up", "Sign In"], id: \.self) { label in
                            Button(action: {
                                withAnimation(.spring()) {
                                    isSignUp = label == "Sign Up"
                                    showError = false
                                }
                            }) {
                                Text(label)
                                    .font(.system(size: 13, weight: .medium))
                                    .tracking(2)
                                    .foregroundColor(
                                        (isSignUp && label == "Sign Up") || (!isSignUp && label == "Sign In")
                                        ? .white : Color.white.opacity(0.4)
                                    )
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        (isSignUp && label == "Sign Up") || (!isSignUp && label == "Sign In")
                                        ? Color(hex: "7c3aed") : Color.clear
                                    )
                            }
                        }
                    }
                    .background(Color.white.opacity(0.07))
                    .cornerRadius(12)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
                    .opacity(animateIn ? 1 : 0)

                    VStack(spacing: 16) {
                        if isSignUp {
                            AstralTextField(icon: "person", placeholder: "Your name", text: $name)
                        }

                        AstralTextField(icon: "envelope", placeholder: "Email address", text: $email)

                        if isSignUp {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Date of Birth", systemImage: "calendar.circle")
                                    .font(.system(size: 12, weight: .light))
                                    .tracking(2)
                                    .foregroundColor(Color(hex: "a78bfa"))
                                    .padding(.leading, 4)
                                DatePicker("", selection: $birthDate, displayedComponents: .date)
                                    .datePickerStyle(.wheel)
                                    .colorScheme(.dark)
                                    .labelsHidden()
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(16)
                            }
                            .padding(.horizontal, 32)
                        }

                        if showError {
                            Text(errorMsg)
                                .font(.system(size: 12, weight: .light))
                                .foregroundColor(Color(hex: "f87171"))
                                .padding(.horizontal, 32)
                        }

                        Button(action: handleAuth) {
                            ZStack {
                                if isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text(isSignUp ? "BEGIN MY JOURNEY" : "ENTER THE VEIL")
                                        .font(.system(size: 13, weight: .semibold))
                                        .tracking(3)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(colors: [Color(hex: "7c3aed"), Color(hex: "4c1d95")],
                                               startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(16)
                            .shadow(color: Color(hex: "7c3aed").opacity(0.5), radius: 20, y: 8)
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 8)
                        .disabled(isLoading)
                    }
                    .opacity(animateIn ? 1 : 0)
                    .padding(.bottom, 60)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) { animateIn = true }
        }
    }

    func handleAuth() {
        withAnimation { showError = false }
        if isSignUp {
            guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
                triggerError("Please enter your name"); return
            }
            guard email.contains("@") else {
                triggerError("Please enter a valid email"); return
            }
            isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                profile.signUp(name: name.trimmingCharacters(in: .whitespaces),
                               email: email.lowercased(), birthDate: birthDate)
                isLoading = false
            }
        } else {
            guard email.contains("@") else {
                triggerError("Please enter your email"); return
            }
            isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                let success = profile.signIn(email: email.lowercased())
                if !success { self.triggerError("No account found with this email") }
                isLoading = false
            }
        }
    }

    func triggerError(_ msg: String) {
        errorMsg = msg
        withAnimation { showError = true }
    }
}

struct AstralTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "a78bfa"))
                .frame(width: 20)
            TextField(placeholder, text: $text)
                .font(.system(size: 15, weight: .light))
                .foregroundColor(.white)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .tint(Color(hex: "a78bfa"))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.07))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(hex: "7c3aed").opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 32)
    }
}
