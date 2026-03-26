import SwiftUI

struct MoodEntry: Codable, Identifiable {
    var id = UUID()
    var emoji: String
    var mood: String
    var date: Date
}

struct MoodView: View {
    @EnvironmentObject var profile: UserProfile
    @State private var oracleMessage = ""
    @State private var isLoading = false
    @State private var showOracle = false
    @State private var ritualText = ""
    @State private var isLoadingRitual = false
    @State private var showRitual = false
    @State private var affirmation = ""
    @State private var isLoadingAffirmation = false
    @State private var breathingActive = false
    @State private var breathScale: CGFloat = 1.0
    @State private var animateIn = false
    @State private var moodHistory: [MoodEntry] = []

    let moods: [(emoji: String, label: String, color: String)] = [
        ("✨", "Inspired", "7c3aed"), ("🌊", "Calm", "1d4ed8"),
        ("🔥", "Passionate", "b45309"), ("🌑", "Melancholy", "374151"),
        ("⚡", "Anxious", "a16207"), ("🌸", "Grateful", "be185d"),
        ("🌀", "Confused", "0f766e"), ("💫", "Euphoric", "6d28d9"),
        ("🍂", "Nostalgic", "92400e"), ("🧊", "Numb", "1e3a5f"),
        ("🦋", "Hopeful", "065f46"), ("🌪️", "Overwhelmed", "4b1d96"),
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // Header
                VStack(spacing: 8) {
                    Text("☽")
                        .font(.system(size: 44))
                        .opacity(animateIn ? 1 : 0)
                        .scaleEffect(animateIn ? 1 : 0.5)
                    Text("EMOTIONAL ALCHEMY")
                        .font(.system(size: 11, weight: .ultraLight)).tracking(6)
                        .foregroundColor(.white.opacity(0.4))
                        .opacity(animateIn ? 1 : 0)
                    Text("How do you feel?")
                        .font(.system(size: 28, weight: .thin)).tracking(1)
                        .foregroundColor(.white)
                        .opacity(animateIn ? 1 : 0)
                }
                .padding(.top, 28).padding(.bottom, 24)

                // Current mood pill
                if !profile.todayMood.isEmpty {
                    HStack(spacing: 10) {
                        Text(profile.todayMoodEmoji).font(.system(size: 22))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Currently feeling")
                                .font(.system(size: 10, weight: .light)).tracking(2)
                                .foregroundColor(.white.opacity(0.35))
                            Text(profile.todayMood)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Button(action: {
                            withAnimation {
                                profile.todayMood = ""
                                profile.todayMoodEmoji = ""
                                showOracle = false
                                showRitual = false
                                affirmation = ""
                                breathingActive = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.2))
                        }
                    }
                    .padding(16)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "7c3aed").opacity(0.25), lineWidth: 1))
                    .padding(.horizontal, 20).padding(.bottom, 20)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                // Mood grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()),
                                     GridItem(.flexible())], spacing: 10) {
                    ForEach(moods, id: \.label) { mood in
                        MoodCell(mood: mood,
                                 isSelected: profile.todayMood == mood.label,
                                 action: { selectMood(mood) })
                    }
                }
                .padding(.horizontal, 20).padding(.bottom, 24)
                .opacity(animateIn ? 1 : 0)

                // AI tools — only show when mood is selected
                if !profile.todayMood.isEmpty {
                    VStack(spacing: 12) {

                        SectionHeader(icon: "wand.and.stars", title: "MOOD TOOLS")
                            .padding(.horizontal, 20)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            QuickActionCard(
                                icon: "🔮", title: "Cosmic Perspective",
                                subtitle: "AI insight on your mood",
                                isLoading: isLoading
                            ) { fetchMoodOracle() }

                            QuickActionCard(
                                icon: "🕯️", title: "Healing Ritual",
                                subtitle: "Custom ritual for now",
                                isLoading: isLoadingRitual
                            ) { fetchRitual() }

                            QuickActionCard(
                                icon: "💬", title: "Daily Affirmation",
                                subtitle: "Mood-specific mantra",
                                isLoading: isLoadingAffirmation
                            ) { fetchMoodAffirmation() }

                            QuickActionCard(
                                icon: "🌬️", title: breathingActive ? "Stop Breathing" : "Breathwork",
                                subtitle: breathingActive ? "Tap to stop" : "Guided breathing",
                                isLoading: false
                            ) { toggleBreathing() }
                        }
                        .padding(.horizontal, 20)

                        // Oracle response
                        if showOracle && !oracleMessage.isEmpty {
                            VStack(spacing: 10) {
                                HStack(spacing: 6) {
                                    Text("✦").font(.system(size: 10))
                                        .foregroundColor(Color(hex: "a78bfa"))
                                    Text("ASTRA SPEAKS")
                                        .font(.system(size: 10, weight: .medium)).tracking(4)
                                        .foregroundColor(Color(hex: "a78bfa"))
                                    Text("✦").font(.system(size: 10))
                                        .foregroundColor(Color(hex: "a78bfa"))
                                }
                                Text(oracleMessage)
                                    .font(.system(size: 15, weight: .light))
                                    .foregroundColor(.white.opacity(0.82))
                                    .multilineTextAlignment(.center).lineSpacing(8)
                            }
                            .padding(22)
                            .background(Color.white.opacity(0.04))
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(hex: "7c3aed").opacity(0.2), lineWidth: 1))
                            .padding(.horizontal, 20)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }

                        // Ritual
                        if showRitual && !ritualText.isEmpty {
                            ExpandedCard(title: "🕯️ YOUR HEALING RITUAL", content: ritualText)
                                .padding(.horizontal, 20)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }

                        // Affirmation
                        if !affirmation.isEmpty {
                            VStack(spacing: 10) {
                                Text("\"")
                                    .font(.system(size: 48, weight: .ultraLight))
                                    .foregroundColor(Color(hex: "7c3aed").opacity(0.5))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 20).padding(.bottom, -20)
                                Text(affirmation)
                                    .font(.system(size: 16, weight: .light))
                                    .foregroundColor(.white.opacity(0.88))
                                    .multilineTextAlignment(.center).lineSpacing(8)
                                    .italic().padding(.horizontal, 28)
                            }
                            .padding(.vertical, 20)
                            .background(Color(hex: "2d0a5c").opacity(0.3))
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(hex: "7c3aed").opacity(0.3), lineWidth: 1))
                            .padding(.horizontal, 20)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }

                        // Breathing exercise
                        if breathingActive {
                            VStack(spacing: 16) {
                                Circle()
                                    .fill(Color(hex: "7c3aed").opacity(0.2))
                                    .frame(width: 100, height: 100)
                                    .scaleEffect(breathScale)
                                    .animation(
                                        .easeInOut(duration: 4).repeatForever(autoreverses: true),
                                        value: breathScale
                                    )
                                    .overlay(Text("🌬️").font(.system(size: 36)))

                                Text(breathScale > 1.3 ? "Breathe in..." : "Breathe out...")
                                    .font(.system(size: 14, weight: .light)).tracking(2)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .padding(24).frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.03)).cornerRadius(20)
                            .padding(.horizontal, 20)
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.bottom, 24)
                }

                // Mood history
                if !moodHistory.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(icon: "chart.line.uptrend.xyaxis", title: "MOOD JOURNEY")

                        ForEach(moodHistory.prefix(7)) { entry in
                            HStack(spacing: 12) {
                                Text(entry.emoji).font(.system(size: 20))
                                Text(entry.mood)
                                    .font(.system(size: 13, weight: .light))
                                    .foregroundColor(.white.opacity(0.7))
                                Spacer()
                                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.3))
                            }
                            .padding(12)
                            .background(Color.white.opacity(0.03))
                            .cornerRadius(12)
                        }
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.03))
                    .cornerRadius(20)
                    .overlay(RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "7c3aed").opacity(0.1), lineWidth: 1))
                    .padding(.horizontal, 20)
                }

                Spacer(minLength: 48)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animateIn = true
            }
            loadMoodHistory()
        }
    }

    // MARK: - Actions
    func selectMood(_ mood: (emoji: String, label: String, color: String)) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            profile.todayMood = mood.label
            profile.todayMoodEmoji = mood.emoji
            showOracle = false
            showRitual = false
            affirmation = ""
            breathingActive = false
        }
        let entry = MoodEntry(emoji: mood.emoji, mood: mood.label, date: Date())
        moodHistory.insert(entry, at: 0)
        saveMoodHistory()
    }

    func fetchMoodOracle() {
        isLoading = true
        Task {
            let result = await AIService.moodOracle(
                mood: profile.todayMood,
                emoji: profile.todayMoodEmoji,
                zodiac: profile.currentUser?.zodiacSign ?? ""
            )
            await MainActor.run {
                oracleMessage = result
                isLoading = false
                withAnimation(.spring()) { showOracle = true }
            }
        }
    }

    func fetchRitual() {
        isLoadingRitual = true
        Task {
            let prompt = """
            Create a personalized healing ritual for someone feeling \(profile.todayMood)
            who is a \(profile.currentUser?.zodiacSign ?? "spiritual seeker").
            Include:
            1. Setting — where and when
            2. Items needed (candles, crystals, herbs)
            3. Step-by-step process (4-5 steps)
            4. A closing intention or prayer
            Be mystical, practical, and deeply attuned to this emotional state.
            """
            let result = await AIService.callClaude(prompt: prompt, maxTokens: 500)
            await MainActor.run {
                ritualText = result
                isLoadingRitual = false
                withAnimation(.spring()) { showRitual = true }
            }
        }
    }

    func fetchMoodAffirmation() {
        isLoadingAffirmation = true
        Task {
            let prompt = """
            Write a powerful affirmation for someone feeling \(profile.todayMood).
            They are \(profile.currentUser?.zodiacSign ?? "a spiritual soul").
            Acknowledge the feeling, transmute it into power, end with a cosmic declaration.
            3 sentences max. Begin with "I".
            """
            let result = await AIService.callClaude(prompt: prompt, maxTokens: 120)
            await MainActor.run {
                affirmation = result
                isLoadingAffirmation = false
                withAnimation(.spring()) {}
            }
        }
    }

    func toggleBreathing() {
        withAnimation(.spring()) { breathingActive.toggle() }
        breathScale = breathingActive ? 1.6 : 1.0
    }

    func loadMoodHistory() {
        if let data = UserDefaults.standard.data(forKey: "moodHistory"),
           let saved = try? JSONDecoder().decode([MoodEntry].self, from: data) {
            moodHistory = saved
        }
    }

    func saveMoodHistory() {
        if let data = try? JSONEncoder().encode(moodHistory) {
            UserDefaults.standard.set(data, forKey: "moodHistory")
        }
    }
}

// MARK: - MoodCell
struct MoodCell: View {
    let mood: (emoji: String, label: String, color: String)
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(mood.emoji)
                    .font(.system(size: 28))
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                Text(mood.label)
                    .font(.system(size: 10, weight: isSelected ? .medium : .light))
                    .tracking(0.5)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(isSelected
                ? Color(hex: mood.color).opacity(0.25)
                : Color.white.opacity(0.04))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected
                    ? Color(hex: mood.color).opacity(0.7)
                    : Color.white.opacity(0.06), lineWidth: 1))
            .shadow(color: isSelected ? Color(hex: mood.color).opacity(0.3) : .clear,
                    radius: 12, y: 4)
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}
