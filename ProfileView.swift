import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var profile: UserProfile
    @EnvironmentObject var store: AppStore
    @State private var animateIn = false
    @State private var showEditSheet = false
    @State private var editField: EditField = .name
    @State private var editValue = ""
    @State private var editDate = Date()
    @State private var showSignOutAlert = false
    @State private var avatarColor: Int = 0

    enum EditField {
        case name, email, birthDate, avatarColor
    }

    let avatarColors = [
        ("7c3aed", "4c1d95"),
        ("1d4ed8", "1e3a5f"),
        ("be185d", "831843"),
        ("065f46", "064e3b"),
        ("b45309", "92400e"),
        ("0f766e", "134e4a"),
    ]

    var currentGradient: (String, String) {
        avatarColors[avatarColor % avatarColors.count]
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // ── Hero ──
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: currentGradient.0).opacity(0.2))
                            .frame(width: 130, height: 130)
                            .blur(radius: 20)

                        Circle()
                            .stroke(LinearGradient(
                                colors: [Color(hex: currentGradient.0),
                                         Color(hex: currentGradient.1)],
                                startPoint: .topLeading, endPoint: .bottomTrailing),
                                    lineWidth: 2)
                            .frame(width: 100, height: 100)

                        Circle()
                            .fill(LinearGradient(
                                colors: [Color(hex: currentGradient.0),
                                         Color(hex: currentGradient.1)],
                                startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 92, height: 92)

                        Text(String(profile.currentUser?.name.prefix(1).uppercased() ?? "✦"))
                            .font(.system(size: 40, weight: .thin))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(animateIn ? 1 : 0.7)
                    .opacity(animateIn ? 1 : 0)
                    .onTapGesture {
                        editField = .avatarColor
                        showEditSheet = true
                    }
                    .overlay(
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "7c3aed"))
                                        .frame(width: 28, height: 28)
                                    Image(systemName: "pencil")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .offset(x: -4, y: -4)
                            }
                        }
                        .frame(width: 100, height: 100)
                    )

                    VStack(spacing: 6) {
                        Text(profile.currentUser?.name ?? "")
                            .font(.system(size: 26, weight: .thin))
                            .tracking(2).foregroundColor(.white)
                        Text(profile.currentUser?.zodiacSign ?? "")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "a78bfa"))
                        HStack(spacing: 12) {
                            Text(profile.currentUser?.element ?? "")
                            Text("·")
                            Text(profile.currentUser?.planet ?? "")
                        }
                        .font(.system(size: 12, weight: .light)).tracking(1)
                        .foregroundColor(.white.opacity(0.35))

                        if store.isPremium {
                            HStack(spacing: 6) {
                                Image(systemName: "crown.fill").font(.system(size: 10))
                                Text("PREMIUM MEMBER")
                                    .font(.system(size: 10, weight: .semibold)).tracking(2)
                            }
                            .foregroundColor(Color(hex: "fbbf24"))
                            .padding(.horizontal, 14).padding(.vertical, 6)
                            .background(Color(hex: "fbbf24").opacity(0.1)).cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(hex: "fbbf24").opacity(0.3), lineWidth: 1))
                        }
                    }
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 10)
                }
                .padding(.top, 36).padding(.bottom, 28)

                // ── Stats ──
                HStack(spacing: 12) {
                    ProfileStat(value: "\(profile.currentUser?.readingsCount ?? 0)",
                                label: "Readings", icon: "sparkles")
                    ProfileStat(value: "\(profile.dreams.count)",
                                label: "Dreams", icon: "cloud.moon.fill")
                    ProfileStat(value: "\(profile.lifePathNumber)",
                                label: "Life Path", icon: "infinity")
                }
                .padding(.horizontal, 20).padding(.bottom, 20)
                .opacity(animateIn ? 1 : 0)

                // ── Premium upsell ──
                if !store.isPremium {
                    Button(action: { store.unlock() }) {
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(hex: "fbbf24"))
                                    Text("UNLOCK PREMIUM")
                                        .font(.system(size: 13, weight: .semibold)).tracking(2)
                                        .foregroundColor(Color(hex: "fbbf24"))
                                }
                                Text("Unlimited readings · Advanced charts · No limits")
                                    .font(.system(size: 11, weight: .light)).tracking(0.5)
                                    .foregroundColor(.white.opacity(0.45))
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "fbbf24").opacity(0.6))
                        }
                        .padding(20)
                        .background(LinearGradient(
                            colors: [Color(hex: "1c1400"), Color(hex: "2d1a00")],
                            startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(18)
                        .overlay(RoundedRectangle(cornerRadius: 18)
                            .stroke(Color(hex: "fbbf24").opacity(0.25), lineWidth: 1))
                    }
                    .padding(.horizontal, 20).padding(.bottom, 16)
                }

                // ── Editable Identity Card ──
                ProfileSection(title: "COSMIC IDENTITY") {
                    EditableRow(
                        icon: "person.fill",
                        label: "Name",
                        value: profile.currentUser?.name ?? ""
                    ) {
                        editField = .name
                        editValue = profile.currentUser?.name ?? ""
                        showEditSheet = true
                    }

                    Divider().background(Color(hex: "7c3aed").opacity(0.15))

                    EditableRow(
                        icon: "envelope.fill",
                        label: "Email",
                        value: profile.currentUser?.email ?? ""
                    ) {
                        editField = .email
                        editValue = profile.currentUser?.email ?? ""
                        showEditSheet = true
                    }

                    Divider().background(Color(hex: "7c3aed").opacity(0.15))

                    EditableRow(
                        icon: "calendar",
                        label: "Date of Birth",
                        value: profile.currentUser?.birthDate
                            .formatted(date: .long, time: .omitted) ?? ""
                    ) {
                        editField = .birthDate
                        editDate = profile.currentUser?.birthDate ?? Date()
                        showEditSheet = true
                    }

                    Divider().background(Color(hex: "7c3aed").opacity(0.15))

                    HStack {
                        Image(systemName: "sparkles")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "a78bfa"))
                            .frame(width: 28)
                        Text("Zodiac Sign")
                            .font(.system(size: 13, weight: .light))
                            .foregroundColor(.white.opacity(0.4))
                        Spacer()
                        Text(profile.currentUser?.zodiacSign ?? "")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.7))
                        Text("(auto)")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.2))
                    }
                    .padding(.vertical, 4)

                    Divider().background(Color(hex: "7c3aed").opacity(0.15))

                    HStack {
                        Image(systemName: "infinity")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "a78bfa"))
                            .frame(width: 28)
                        Text("Life Path")
                            .font(.system(size: 13, weight: .light))
                            .foregroundColor(.white.opacity(0.4))
                        Spacer()
                        Text("\(profile.lifePathNumber)")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.7))
                        Text("(auto)")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.2))
                    }
                    .padding(.vertical, 4)
                }
                .padding(.horizontal, 20).padding(.bottom, 16)
                .opacity(animateIn ? 1 : 0)

                // ── Avatar Color Picker ──
                ProfileSection(title: "AVATAR COLOR") {
                    HStack(spacing: 14) {
                        ForEach(0..<avatarColors.count, id: \.self) { i in
                            Button(action: {
                                withAnimation(.spring()) { avatarColor = i }
                                UserDefaults.standard.set(i, forKey: "avatarColor")
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(LinearGradient(
                                            colors: [Color(hex: avatarColors[i].0),
                                                     Color(hex: avatarColors[i].1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing))
                                        .frame(width: 40, height: 40)

                                    if avatarColor == i {
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                            .frame(width: 44, height: 44)
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .padding(.horizontal, 20).padding(.bottom, 16)

                // ── Recent Dreams ──
                if !profile.dreams.isEmpty {
                    ProfileSection(title: "RECENT DREAMS") {
                        ForEach(profile.dreams.prefix(3)) { dream in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(dream.text)
                                    .font(.system(size: 13, weight: .light))
                                    .foregroundColor(.white.opacity(0.65))
                                    .lineLimit(2).lineSpacing(4)
                                HStack {
                                    Text(dream.date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.system(size: 10))
                                        .foregroundColor(.white.opacity(0.3))
                                    if !dream.mood.isEmpty {
                                        Text("· \(dream.mood)")
                                            .font(.system(size: 10))
                                            .foregroundColor(Color(hex: "a78bfa").opacity(0.5))
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                            if dream.id != profile.dreams.prefix(3).last?.id {
                                Divider().background(Color(hex: "7c3aed").opacity(0.15))
                            }
                        }
                    }
                    .padding(.horizontal, 20).padding(.bottom, 16)
                }

                // ── Danger Zone ──
                ProfileSection(title: "ACCOUNT") {
                    Button(action: { showSignOutAlert = true }) {
                        HStack(spacing: 12) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "f87171"))
                            Text("Sign Out")
                                .font(.system(size: 14, weight: .light))
                                .foregroundColor(Color(hex: "f87171"))
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }

                    Divider().background(Color(hex: "7c3aed").opacity(0.15))

                    Button(action: { resetAllData() }) {
                        HStack(spacing: 12) {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "f87171").opacity(0.6))
                            Text("Clear All Data")
                                .font(.system(size: 14, weight: .light))
                                .foregroundColor(Color(hex: "f87171").opacity(0.6))
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(.horizontal, 20).padding(.bottom, 16)

                Text("AstralVeil · Built with ✦ and SwiftUI")
                    .font(.system(size: 10, weight: .light)).tracking(1)
                    .foregroundColor(.white.opacity(0.15))
                    .padding(.bottom, 48)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animateIn = true
            }
            avatarColor = UserDefaults.standard.integer(forKey: "avatarColor")
        }
        .sheet(isPresented: $showEditSheet) {
            EditSheet(
                field: editField,
                textValue: $editValue,
                dateValue: $editDate,
                onSave: saveEdit
            )
            .environmentObject(profile)
        }
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Sign Out", role: .destructive) { profile.signOut() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }

    func saveEdit() {
        switch editField {
        case .name:
            let trimmed = editValue.trimmingCharacters(in: .whitespaces)
            if !trimmed.isEmpty {
                profile.currentUser?.name = trimmed
                profile.save()
            }
        case .email:
            let trimmed = editValue.lowercased().trimmingCharacters(in: .whitespaces)
            if trimmed.contains("@") {
                profile.currentUser?.email = trimmed
                profile.save()
            }
        case .birthDate:
            profile.currentUser?.birthDate = editDate
            profile.currentUser?.zodiacSign = UserProfile.zodiac(from: editDate)
            profile.currentUser?.element = UserProfile.element(for: UserProfile.zodiac(from: editDate))
            profile.currentUser?.planet = UserProfile.planet(for: UserProfile.zodiac(from: editDate))
            profile.birthDate = editDate
            profile.save()
        case .avatarColor:
            break
        }
    }

    func resetAllData() {
        UserDefaults.standard.removeObject(forKey: "dreams")
        UserDefaults.standard.removeObject(forKey: "readings")
        UserDefaults.standard.removeObject(forKey: "moodHistory")
        profile.dreams = []
        profile.readings = []
        profile.currentUser?.readingsCount = 0
        profile.save()
    }
}

// MARK: - Edit Sheet
struct EditSheet: View {
    @EnvironmentObject var profile: UserProfile
    @Environment(\.dismiss) var dismiss
    let field: ProfileView.EditField
    @Binding var textValue: String
    @Binding var dateValue: Date
    let onSave: () -> Void

    var title: String {
        switch field {
        case .name: return "Edit Name"
        case .email: return "Edit Email"
        case .birthDate: return "Edit Date of Birth"
        case .avatarColor: return "Choose Avatar Color"
        }
    }

    var body: some View {
        ZStack {
            Color(hex: "07030f").ignoresSafeArea()
            RadialGradient(colors: [Color(hex: "2d0a5c").opacity(0.5), .clear],
                           center: .top, startRadius: 0, endRadius: 400)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                // Handle bar
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 40, height: 4)
                    .padding(.top, 16)

                Text(title)
                    .font(.system(size: 18, weight: .thin))
                    .tracking(3).foregroundColor(.white)

                VStack(spacing: 20) {
                    switch field {
                    case .name:
                        EditInputField(
                            icon: "person.fill",
                            placeholder: "Your name",
                            text: $textValue
                        )

                    case .email:
                        EditInputField(
                            icon: "envelope.fill",
                            placeholder: "Email address",
                            text: $textValue,
                            keyboardType: .emailAddress
                        )

                    case .birthDate:
                        VStack(spacing: 12) {
                            Text("Select your date of birth")
                                .font(.system(size: 12, weight: .light)).tracking(2)
                                .foregroundColor(Color(hex: "a78bfa").opacity(0.7))

                            DatePicker("", selection: $dateValue, displayedComponents: .date)
                                .datePickerStyle(.wheel)
                                .colorScheme(.dark)
                                .labelsHidden()
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(16)

                            // Preview new zodiac
                            let newZodiac = UserProfile.zodiac(from: dateValue)
                            HStack(spacing: 8) {
                                Text("New zodiac:")
                                    .font(.system(size: 12, weight: .light))
                                    .foregroundColor(.white.opacity(0.4))
                                Text(newZodiac)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color(hex: "a78bfa"))
                            }
                        }
                        .padding(.horizontal, 32)

                    case .avatarColor:
                        Text("Tap a color on the profile page")
                            .foregroundColor(.white.opacity(0.5))
                    }
                }

                Spacer()

                VStack(spacing: 12) {
                    Button(action: {
                        onSave()
                        dismiss()
                    }) {
                        Text("SAVE CHANGES")
                            .font(.system(size: 13, weight: .semibold)).tracking(3)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 18)
                            .background(LinearGradient(
                                colors: [Color(hex: "7c3aed"), Color(hex: "4c1d95")],
                                startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(16)
                            .shadow(color: Color(hex: "7c3aed").opacity(0.4), radius: 16, y: 6)
                    }
                    .padding(.horizontal, 32)

                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                .padding(.bottom, 48)
            }
        }
    }
}

struct EditInputField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(focused ? Color(hex: "a78bfa") : .white.opacity(0.3))
                .frame(width: 20)
            TextField("", text: $text,
                      prompt: Text(placeholder).foregroundColor(.white.opacity(0.25)))
                .font(.system(size: 16, weight: .light))
                .foregroundColor(.white)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .tint(Color(hex: "a78bfa"))
                .focused($focused)
        }
        .padding(.horizontal, 20).padding(.vertical, 18)
        .background(Color.white.opacity(focused ? 0.08 : 0.05))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14)
            .stroke(focused
                ? Color(hex: "7c3aed").opacity(0.7)
                : Color(hex: "7c3aed").opacity(0.15), lineWidth: 1))
        .animation(.easeInOut(duration: 0.2), value: focused)
        .padding(.horizontal, 32)
        .onAppear { focused = true }
    }
}

// MARK: - Reusable Profile Components
struct ProfileSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Rectangle().fill(Color(hex: "7c3aed"))
                    .frame(width: 3, height: 14).cornerRadius(2)
                Text(title)
                    .font(.system(size: 11, weight: .semibold)).tracking(3)
                    .foregroundColor(Color(hex: "a78bfa"))
            }
            VStack(spacing: 12) { content }
        }
        .padding(20)
        .background(Color.white.opacity(0.04))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20)
            .stroke(Color(hex: "7c3aed").opacity(0.15), lineWidth: 1))
    }
}

struct EditableRow: View {
    let icon: String
    let label: String
    let value: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "a78bfa"))
                    .frame(width: 28)
                Text(label)
                    .font(.system(size: 13, weight: .light))
                    .foregroundColor(.white.opacity(0.4))
                Spacer()
                Text(value)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)
                Image(systemName: "pencil")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "7c3aed").opacity(0.6))
            }
            .padding(.vertical, 4)
        }
    }
}

struct ProfileStat: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "a78bfa").opacity(0.6))
            Text(value)
                .font(.system(size: 28, weight: .ultraLight)).foregroundColor(.white)
            Text(label)
                .font(.system(size: 9, weight: .medium)).tracking(2)
                .foregroundColor(.white.opacity(0.3))
        }
        .frame(maxWidth: .infinity).padding(.vertical, 20)
        .background(Color.white.opacity(0.04)).cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18)
            .stroke(Color(hex: "7c3aed").opacity(0.15), lineWidth: 1))
    }
}
