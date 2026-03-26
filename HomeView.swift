import SwiftUI

struct HomeView: View {
    @EnvironmentObject var profile: UserProfile
    @State private var reading = ""
    @State private var readingLines: [String] = []
    @State private var isLoading = false
    @State private var hasReading = false
    @State private var orbPulse = false
    @State private var showHistory = false
    @State private var compatibilitySign = ""
    @State private var compatibilityResult = ""
    @State private var isLoadingCompat = false
    @State private var showCompat = false
    @State private var luckyResult = ""
    @State private var isLoadingLucky = false
    @State private var showLucky = false
    @State private var weeklyForecast = ""
    @State private var isLoadingWeekly = false
    @State private var showWeekly = false

    let zodiacSigns = ["Aries ♈","Taurus ♉","Gemini ♊","Cancer ♋","Leo ♌","Virgo ♍",
                       "Libra ♎","Scorpio ♏","Sagittarius ♐","Capricorn ♑","Aquarius ♒","Pisces ♓"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // ── Orb hero ──
                ZStack {
                    Circle()
                        .fill(Color(hex: "5b21b6").opacity(0.15))
                        .frame(width: 240, height: 240)
                        .blur(radius: orbPulse ? 40 : 28)
                        .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: orbPulse)

                    Circle()
                        .fill(RadialGradient(
                            colors: [Color(hex: "6d28d9").opacity(0.7),
                                     Color(hex: "1e1b4b").opacity(0.85),
                                     Color(hex: "060412").opacity(0.95)],
                            center: .center, startRadius: 0, endRadius: 72))
                        .frame(width: 144, height: 144)
                        .overlay(Circle().stroke(
                            LinearGradient(colors: [Color(hex: "a78bfa").opacity(0.7),
                                                    Color(hex: "7c3aed").opacity(0.2)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 1))

                    Text(profile.currentUser?.zodiacSign.components(separatedBy: " ").last ?? "✦")
                        .font(.system(size: 56))
                }
                .padding(.top, 28)

                VStack(spacing: 6) {
                    Text(profile.currentUser?.zodiacSign.components(separatedBy: " ").first ?? "")
                        .font(.system(size: 30, weight: .ultraLight))
                        .tracking(4).foregroundColor(.white)
                    HStack(spacing: 14) {
                        Text(profile.currentUser?.element ?? "")
                        Text("·")
                        Text(profile.currentUser?.planet ?? "")
                    }
                    .font(.system(size: 11, weight: .light)).tracking(2)
                    .foregroundColor(Color(hex: "a78bfa").opacity(0.7))

                    if !profile.todayMood.isEmpty {
                        HStack(spacing: 6) {
                            Text(profile.todayMoodEmoji)
                            Text(profile.todayMood)
                                .font(.system(size: 12, weight: .light))
                                .foregroundColor(Color(hex: "c4b5fd").opacity(0.8))
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.top, 16).padding(.bottom, 28)

                // ── Daily reading card ──
                if hasReading && !readingLines.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(Array(readingLines.enumerated()), id: \.offset) { i, line in
                            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !trimmed.isEmpty {
                                if i == readingLines.count - 1 {
                                    Text(trimmed)
                                        .font(.system(size: 20, weight: .ultraLight))
                                        .tracking(8)
                                        .foregroundColor(Color(hex: "c4b5fd"))
                                        .padding(.vertical, 22)
                                } else {
                                    Text(trimmed)
                                        .font(.system(size: 15, weight: .light))
                                        .foregroundColor(i == 0 ? Color(hex: "e9d5ff") : .white.opacity(0.78))
                                        .multilineTextAlignment(.center)
                                        .lineSpacing(7)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 16)
                                    if i < readingLines.count - 2 {
                                        Rectangle().fill(Color(hex: "7c3aed").opacity(0.2))
                                            .frame(height: 0.5).padding(.horizontal, 36)
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.04))
                        .overlay(RoundedRectangle(cornerRadius: 24).stroke(
                            LinearGradient(colors: [Color(hex: "7c3aed").opacity(0.45),
                                                    Color(hex: "3b0764").opacity(0.2)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)))
                    .padding(.horizontal, 20).padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))

                } else if !hasReading {
                    Text("The cosmos await your question")
                        .font(.system(size: 14, weight: .light)).tracking(1)
                        .foregroundColor(.white.opacity(0.3))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32).padding(.bottom, 24)
                }

                // ── Oracle button ──
                AIButton(
                    label: hasReading ? "NEW READING" : "CONSULT THE ORACLE",
                    icon: "sparkles", isLoading: isLoading,
                    loadingLabel: "Reading the stars...",
                    color1: "7c3aed", color2: "5b21b6"
                ) { fetchReading() }
                .padding(.horizontal, 20).padding(.bottom, 28)

                // ── Quick action cards ──
                SectionHeader(icon: "wand.and.stars", title: "COSMIC TOOLS")
                    .padding(.horizontal, 20).padding(.bottom, 14)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {

                    // Lucky numbers & colors
                    QuickActionCard(
                        icon: "🍀", title: "Lucky Today",
                        subtitle: "Numbers · Colors · Hours",
                        isLoading: isLoadingLucky
                    ) { fetchLucky() }

                    // Weekly forecast
                    QuickActionCard(
                        icon: "📅", title: "Week Ahead",
                        subtitle: "7-day cosmic forecast",
                        isLoading: isLoadingWeekly
                    ) { fetchWeekly() }

                    // Compatibility
                    QuickActionCard(
                        icon: "💫", title: "Compatibility",
                        subtitle: "Check sign synergy",
                        isLoading: false
                    ) { withAnimation { showCompat.toggle() } }

                    // Affirmation
                    QuickActionCard(
                        icon: "✨", title: "Affirmation",
                        subtitle: "Daily cosmic mantra",
                        isLoading: false
                    ) { fetchAffirmation() }
                }
                .padding(.horizontal, 20).padding(.bottom, 20)

                // Lucky result
                if showLucky && !luckyResult.isEmpty {
                    ExpandedCard(title: "🍀 YOUR LUCKY ENERGIES", content: luckyResult)
                        .padding(.horizontal, 20).padding(.bottom, 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // Weekly forecast result
                if showWeekly && !weeklyForecast.isEmpty {
                    ExpandedCard(title: "📅 YOUR WEEK AHEAD", content: weeklyForecast)
                        .padding(.horizontal, 20).padding(.bottom, 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // Compatibility picker
                if showCompat {
                    VStack(spacing: 14) {
                        Text("CHOOSE A SIGN TO COMPARE")
                            .font(.system(size: 10, weight: .medium)).tracking(3)
                            .foregroundColor(Color(hex: "a78bfa"))

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(zodiacSigns, id: \.self) { sign in
                                    Button(action: {
                                        compatibilitySign = sign
                                        fetchCompatibility(with: sign)
                                    }) {
                                        Text(sign)
                                            .font(.system(size: 12, weight: .light))
                                            .foregroundColor(compatibilitySign == sign
                                                ? .white : .white.opacity(0.5))
                                            .padding(.horizontal, 14).padding(.vertical, 8)
                                            .background(compatibilitySign == sign
                                                ? Color(hex: "7c3aed").opacity(0.5)
                                                : Color.white.opacity(0.05))
                                            .cornerRadius(20)
                                            .overlay(RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color(hex: "7c3aed").opacity(
                                                    compatibilitySign == sign ? 0.8 : 0.15), lineWidth: 1))
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        if isLoadingCompat {
                            HStack(spacing: 10) {
                                ProgressView().tint(Color(hex: "a78bfa"))
                                Text("Calculating cosmic bond...")
                                    .font(.system(size: 12, weight: .light))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .padding()
                        } else if !compatibilityResult.isEmpty {
                            ExpandedCard(title: "💫 COMPATIBILITY READING", content: compatibilityResult)
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.vertical, 20)
                    .background(Color.white.opacity(0.03))
                    .cornerRadius(20)
                    .overlay(RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "7c3aed").opacity(0.15), lineWidth: 1))
                    .padding(.horizontal, 20).padding(.bottom, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // Past readings
                if !profile.readings.isEmpty {
                    VStack(alignment: .leading, spacing: 14) {
                        Button(action: { withAnimation { showHistory.toggle() } }) {
                            HStack {
                                Image(systemName: "clock.fill").font(.system(size: 11))
                                    .foregroundColor(Color(hex: "a78bfa").opacity(0.6))
                                Text("PAST READINGS").font(.system(size: 11, weight: .medium))
                                    .tracking(3).foregroundColor(Color(hex: "a78bfa").opacity(0.6))
                                Spacer()
                                Text("\(profile.readings.count)")
                                    .font(.system(size: 11)).foregroundColor(Color(hex: "7c3aed"))
                                    .padding(.horizontal, 8).padding(.vertical, 3)
                                    .background(Color(hex: "7c3aed").opacity(0.15)).cornerRadius(8)
                                Image(systemName: showHistory ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 10)).foregroundColor(.white.opacity(0.3))
                            }
                        }

                        if showHistory {
                            ForEach(profile.readings.prefix(5)) { entry in
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.system(size: 10, weight: .medium)).tracking(1)
                                        .foregroundColor(Color(hex: "a78bfa").opacity(0.5))
                                    Text(String(entry.text.prefix(140)) + (entry.text.count > 140 ? "..." : ""))
                                        .font(.system(size: 13, weight: .light))
                                        .foregroundColor(.white.opacity(0.55)).lineSpacing(5)
                                }
                                .padding(16).background(Color.white.opacity(0.03)).cornerRadius(14)
                                .overlay(RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color(hex: "7c3aed").opacity(0.1), lineWidth: 1))
                            }
                        }
                    }
                    .padding(20).background(Color.white.opacity(0.03)).cornerRadius(20)
                    .overlay(RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "7c3aed").opacity(0.1), lineWidth: 1))
                    .padding(.horizontal, 20)
                }

                Spacer(minLength: 48)
            }
            .padding(.top, 8)
        }
        .onAppear { orbPulse = true }
    }

    // MARK: - AI Calls
    func fetchReading() {
        guard let user = profile.currentUser else { return }
        isLoading = true; hasReading = false
        Task {
            let result = await AIService.dailyReading(user: user, mood: profile.todayMood,
                                                       dream: profile.dreams.first?.text ?? "")
            await MainActor.run {
                reading = result
                readingLines = result.components(separatedBy: "\n")
                    .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                hasReading = true; isLoading = false
                profile.addReading(result)
            }
        }
    }

    func fetchLucky() {
        guard let user = profile.currentUser else { return }
        isLoadingLucky = true; showLucky = false
        Task {
            let prompt = """
            You are a cosmic numerologist for \(user.zodiacSign) ruled by \(user.planet).
            Today give them:
            - Lucky numbers (3 numbers with brief cosmic reason each)
            - Lucky colors (2 colors with vibrational meaning)
            - Power hours (2 time windows best for important actions)
            - One crystal or stone to carry today
            Format beautifully, use line breaks between sections. Be mystical and specific.
            """
            let result = await AIService.callClaude(prompt: prompt, maxTokens: 400)
            await MainActor.run {
                luckyResult = result; isLoadingLucky = false
                withAnimation(.spring()) { showLucky = true }
            }
        }
    }

    func fetchWeekly() {
        guard let user = profile.currentUser else { return }
        isLoadingWeekly = true; showWeekly = false
        Task {
            let prompt = """
            You are ASTRA, cosmic oracle for \(user.zodiacSign).
            Give a 7-day week ahead forecast structured as:
            Monday through Sunday — each day gets one powerful sentence about its cosmic energy.
            Then add: this week's theme (one phrase), biggest opportunity, and one warning.
            Be poetic, specific to \(user.zodiacSign), and deeply insightful.
            """
            let result = await AIService.callClaude(prompt: prompt, maxTokens: 600)
            await MainActor.run {
                weeklyForecast = result; isLoadingWeekly = false
                withAnimation(.spring()) { showWeekly = true }
            }
        }
    }

    func fetchCompatibility(with sign: String) {
        guard let user = profile.currentUser else { return }
        isLoadingCompat = true; compatibilityResult = ""
        Task {
            let prompt = """
            You are a master astrologer analyzing compatibility.
            Person 1: \(user.zodiacSign) · Element: \(user.element) · Planet: \(user.planet)
            Person 2: \(sign)
            
            Give a detailed compatibility reading covering:
            1. Overall compatibility score (poetic description, not a number)
            2. What draws them together (2 sentences)
            3. Potential friction points (2 sentences)
            4. Their greatest strength as a pair
            5. One cosmic advice for this connection
            
            Be mystical, nuanced, and beautiful in language.
            """
            let result = await AIService.callClaude(prompt: prompt, maxTokens: 500)
            await MainActor.run {
                compatibilityResult = result; isLoadingCompat = false
            }
        }
    }

    func fetchAffirmation() {
        guard let user = profile.currentUser else { return }
        Task {
            let prompt = """
            Create one powerful, poetic daily affirmation specifically for \(user.zodiacSign) 
            ruled by \(user.planet), element \(user.element).
            The affirmation should be 2-3 sentences, deeply personal to this sign's strengths.
            Begin with "I" and make it feel like a cosmic declaration.
            """
            let result = await AIService.callClaude(prompt: prompt, maxTokens: 150)
            await MainActor.run {
                withAnimation {
                    readingLines = [result, "AFFIRM"]
                    hasReading = true
                }
            }
        }
    }
}

// MARK: - Shared UI Components

struct AIButton: View {
    let label: String
    let icon: String
    let isLoading: Bool
    let loadingLabel: String
    let color1: String
    let color2: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    HStack(spacing: 10) {
                        ProgressView().tint(.white).scaleEffect(0.8)
                        Text(loadingLabel)
                            .font(.system(size: 13, weight: .light)).tracking(2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                } else {
                    HStack(spacing: 10) {
                        Image(systemName: icon).font(.system(size: 14))
                        Text(label).font(.system(size: 13, weight: .semibold)).tracking(3)
                    }
                    .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity).padding(.vertical, 18)
            .background(LinearGradient(
                colors: isLoading
                    ? [Color(hex: "4c1d95"), Color(hex: "1e1b4b")]
                    : [Color(hex: color1), Color(hex: color2)],
                startPoint: .leading, endPoint: .trailing))
            .cornerRadius(18)
            .shadow(color: Color(hex: color1).opacity(isLoading ? 0.1 : 0.4), radius: 20, y: 8)
            .scaleEffect(isLoading ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isLoading)
        }
        .disabled(isLoading)
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(icon).font(.system(size: 24))
                    Spacer()
                    if isLoading {
                        ProgressView().tint(Color(hex: "a78bfa")).scaleEffect(0.7)
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.2))
                    }
                }
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 10, weight: .light)).tracking(0.5)
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.04))
            .cornerRadius(18)
            .overlay(RoundedRectangle(cornerRadius: 18)
                .stroke(Color(hex: "7c3aed").opacity(0.2), lineWidth: 1))
        }
    }
}

struct ExpandedCard: View {
    let title: String
    let content: String

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 6) {
                Rectangle().fill(Color(hex: "7c3aed")).frame(width: 3, height: 14).cornerRadius(2)
                Text(title)
                    .font(.system(size: 10, weight: .semibold)).tracking(3)
                    .foregroundColor(Color(hex: "a78bfa"))
                Spacer()
            }
            Text(content)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(.white.opacity(0.82))
                .multilineTextAlignment(.leading)
                .lineSpacing(7)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(Color.white.opacity(0.04))
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18)
            .stroke(Color(hex: "7c3aed").opacity(0.2), lineWidth: 1))
    }
}

struct SectionHeader: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon).font(.system(size: 11))
                .foregroundColor(Color(hex: "a78bfa").opacity(0.6))
            Text(title).font(.system(size: 11, weight: .medium)).tracking(3)
                .foregroundColor(Color(hex: "a78bfa").opacity(0.6))
            Spacer()
        }
    }
}
