import SwiftUI

struct NumerologyView: View {
    @EnvironmentObject var profile: UserProfile
    @State private var reading = ""
    @State private var isLoading = false
    @State private var hasReading = false
    @State private var animateNumber = false
    @State private var karmaResult = ""
    @State private var isLoadingKarma = false
    @State private var personalYearResult = ""
    @State private var isLoadingYear = false
    @State private var nameAnalysis = ""
    @State private var isLoadingName = false
    @State private var showKarma = false
    @State private var showYear = false
    @State private var showName = false

    var lifePath: Int { profile.lifePathNumber }

    let lifePathMeanings: [Int: (title: String, essence: String)] = [
        1: ("The Pioneer", "Independence · Leadership · Creation"),
        2: ("The Diplomat", "Balance · Harmony · Intuition"),
        3: ("The Creator", "Expression · Joy · Communication"),
        4: ("The Builder", "Stability · Order · Devotion"),
        5: ("The Explorer", "Freedom · Change · Adventure"),
        6: ("The Nurturer", "Love · Responsibility · Healing"),
        7: ("The Seeker", "Wisdom · Mystery · Solitude"),
        8: ("The Achiever", "Power · Abundance · Authority"),
        9: ("The Sage", "Compassion · Completion · Service"),
        11: ("The Illuminator", "Intuition · Revelation · Mastery"),
        22: ("The Master Builder", "Vision · Manifestation · Legacy"),
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                VStack(spacing: 8) {
                    Text("∞")
                        .font(.system(size: 44, weight: .ultraLight))
                        .foregroundColor(Color(hex: "a78bfa"))
                    Text("SACRED NUMEROLOGY")
                        .font(.system(size: 11, weight: .ultraLight)).tracking(6)
                        .foregroundColor(.white.opacity(0.4))
                    Text("The Numbers of Your Soul")
                        .font(.system(size: 22, weight: .thin)).tracking(1).foregroundColor(.white)
                }
                .padding(.top, 28).padding(.bottom, 28)

                ZStack {
                    Circle().fill(Color(hex: "7c3aed").opacity(0.08))
                        .frame(width: 190, height: 190).blur(radius: 30)
                    Circle().stroke(
                        LinearGradient(colors: [Color(hex: "7c3aed").opacity(0.5),
                                                Color(hex: "3b0764").opacity(0.2)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1).frame(width: 148, height: 148)
                    VStack(spacing: 4) {
                        Text("\(lifePath)")
                            .font(.system(size: 68, weight: .ultraLight)).foregroundColor(.white)
                            .scaleEffect(animateNumber ? 1 : 0.6).opacity(animateNumber ? 1 : 0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: animateNumber)
                        Text("LIFE PATH")
                            .font(.system(size: 9, weight: .medium)).tracking(4)
                            .foregroundColor(Color(hex: "a78bfa").opacity(0.7))
                    }
                }
                .padding(.bottom, 20)

                if let meaning = lifePathMeanings[lifePath] {
                    VStack(spacing: 6) {
                        Text(meaning.title)
                            .font(.system(size: 26, weight: .thin)).tracking(2).foregroundColor(.white)
                        Text(meaning.essence)
                            .font(.system(size: 12, weight: .light)).tracking(2)
                            .foregroundColor(Color(hex: "a78bfa").opacity(0.7))
                    }
                    .padding(.bottom, 28)
                    .opacity(animateNumber ? 1 : 0)
                    .animation(.easeIn(duration: 0.5).delay(0.4), value: animateNumber)
                }

                HStack(spacing: 10) {
                    NumCard(label: "Life Path", value: "\(lifePath)", icon: "∞")
                    NumCard(label: "Expression", value: "\(expressionNumber)", icon: "◈")
                    NumCard(label: "Soul Urge", value: "\(soulNumber)", icon: "◉")
                }
                .padding(.horizontal, 20).padding(.bottom, 10)
                .opacity(animateNumber ? 1 : 0)
                .animation(.easeIn(duration: 0.5).delay(0.5), value: animateNumber)

                HStack(spacing: 10) {
                    NumCard(label: "Personal Year", value: "\(personalYearNumber)", icon: "◷")
                    NumCard(label: "Destiny", value: "\(destinyNumber)", icon: "✦")
                }
                .padding(.horizontal, 20).padding(.bottom, 28)
                .opacity(animateNumber ? 1 : 0)
                .animation(.easeIn(duration: 0.5).delay(0.6), value: animateNumber)

                SectionHeader(icon: "sparkles", title: "NUMEROLOGY READINGS")
                    .padding(.horizontal, 20).padding(.bottom, 14)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    QuickActionCard(
                        icon: "📖", title: "Deep Life Path",
                        subtitle: "Full soul blueprint reading",
                        isLoading: isLoading
                    ) { fetchDeepReading() }

                    QuickActionCard(
                        icon: "🔮", title: "Karmic Lessons",
                        subtitle: "Past life & karma numbers",
                        isLoading: isLoadingKarma
                    ) { fetchKarma() }

                    QuickActionCard(
                        icon: "📅", title: "Personal Year",
                        subtitle: "This year's cosmic theme",
                        isLoading: isLoadingYear
                    ) { fetchPersonalYear() }

                    QuickActionCard(
                        icon: "🔤", title: "Name Analysis",
                        subtitle: "Vibration of your name",
                        isLoading: isLoadingName
                    ) { fetchNameAnalysis() }
                }
                .padding(.horizontal, 20).padding(.bottom, 20)

                if hasReading && !reading.isEmpty {
                    ExpandedCard(title: "◈ LIFE PATH \(lifePath) — SOUL BLUEPRINT", content: reading)
                        .padding(.horizontal, 20).padding(.bottom, 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                if showKarma && !karmaResult.isEmpty {
                    ExpandedCard(title: "🔮 KARMIC LESSONS", content: karmaResult)
                        .padding(.horizontal, 20).padding(.bottom, 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                if showYear && !personalYearResult.isEmpty {
                    ExpandedCard(title: "📅 PERSONAL YEAR \(personalYearNumber)", content: personalYearResult)
                        .padding(.horizontal, 20).padding(.bottom, 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                if showName && !nameAnalysis.isEmpty {
                    ExpandedCard(title: "🔤 NAME VIBRATION", content: nameAnalysis)
                        .padding(.horizontal, 20).padding(.bottom, 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer(minLength: 48)
            }
        }
        .onAppear { withAnimation { animateNumber = true } }
    }

    // MARK: - AI Calls
    func fetchDeepReading() {
        guard let user = profile.currentUser else { return }
        isLoading = true
        Task {
            let result = await AIService.numerologyReading(lifePath: lifePath,
                                                            name: user.name, zodiac: user.zodiacSign)
            await MainActor.run { reading = result; hasReading = true; isLoading = false }
        }
    }

    func fetchKarma() {
        guard let user = profile.currentUser else { return }
        isLoadingKarma = true; showKarma = false
        Task {
            let prompt = """
            You are a karmic numerologist. Analyze \(user.name)'s karmic profile.
            Life Path: \(lifePath), Expression: \(expressionNumber), Soul Urge: \(soulNumber)
            Zodiac: \(user.zodiacSign)
            Reveal:
            1. Karmic debt numbers and past life patterns
            2. Karmic lessons in this lifetime
            3. Karmic gifts brought from past lives
            4. A message from their higher self
            Be mystical, profound, and compassionate.
            """
            let result = await AIService.callClaude(prompt: prompt, maxTokens: 600)
            await MainActor.run {
                karmaResult = result; isLoadingKarma = false
                withAnimation(.spring()) { showKarma = true }
            }
        }
    }

    func fetchPersonalYear() {
        guard let user = profile.currentUser else { return }
        isLoadingYear = true; showYear = false
        Task {
            let prompt = """
            Analyze Personal Year \(personalYearNumber) for \(user.name), a \(user.zodiacSign).
            Cover: overall theme, focus areas, biggest opportunity, what to release, and a mantra.
            Be specific, insightful, and cosmic in tone.
            """
            let result = await AIService.callClaude(prompt: prompt, maxTokens: 500)
            await MainActor.run {
                personalYearResult = result; isLoadingYear = false
                withAnimation(.spring()) { showYear = true }
            }
        }
    }

    func fetchNameAnalysis() {
        guard let user = profile.currentUser else { return }
        isLoadingName = true; showName = false
        Task {
            let prompt = """
            Analyze the name "\(user.name)" numerologically.
            Expression: \(expressionNumber), Soul Urge: \(soulNumber), Zodiac: \(user.zodiacSign)
            Cover: vibrational frequency, energy broadcast, hidden power, alignment with zodiac,
            and one word capturing its essence. Be mystical and deeply personal.
            """
            let result = await AIService.callClaude(prompt: prompt, maxTokens: 400)
            await MainActor.run {
                nameAnalysis = result; isLoadingName = false
                withAnimation(.spring()) { showName = true }
            }
        }
    }

    // MARK: - Calculations
    var expressionNumber: Int {
        guard let name = profile.currentUser?.name.lowercased() else { return 1 }
        let values: [Character: Int] = [
            "a":1,"b":2,"c":3,"d":4,"e":5,"f":6,"g":7,"h":8,"i":9,
            "j":1,"k":2,"l":3,"m":4,"n":5,"o":6,"p":7,"q":8,"r":9,
            "s":1,"t":2,"u":3,"v":4,"w":5,"x":6,"y":7,"z":8
        ]
        var sum = name.compactMap { values[$0] }.reduce(0, +)
        while sum > 9 && sum != 11 && sum != 22 {
            sum = String(sum).compactMap { $0.wholeNumberValue }.reduce(0, +)
        }
        return max(1, sum)
    }

    var soulNumber: Int {
        guard let name = profile.currentUser?.name.lowercased() else { return 1 }
        let values: [Character: Int] = ["a":1,"e":5,"i":9,"o":6,"u":3]
        var sum = name.compactMap { values[$0] }.reduce(0, +)
        if sum == 0 { sum = 1 }
        while sum > 9 && sum != 11 && sum != 22 {
            sum = String(sum).compactMap { $0.wholeNumberValue }.reduce(0, +)
        }
        return sum
    }

    var personalYearNumber: Int {
        guard let dob = profile.currentUser?.birthDate else { return 1 }
        let cal = Calendar.current
        let month = cal.component(.month, from: dob)
        let day = cal.component(.day, from: dob)
        let year = cal.component(.year, from: Date())
        var sum = digitSum(day) + digitSum(month) + digitSum(year)
        while sum > 9 && sum != 11 && sum != 22 {
            sum = String(sum).compactMap { $0.wholeNumberValue }.reduce(0, +)
        }
        return max(1, sum)
    }

    var destinyNumber: Int {
        guard let dob = profile.currentUser?.birthDate else { return 1 }
        let cal = Calendar.current
        let d = cal.component(.day, from: dob)
        let m = cal.component(.month, from: dob)
        let y = cal.component(.year, from: dob)
        var sum = digitSum(d) + digitSum(m) + digitSum(y)
        while sum > 9 && sum != 11 && sum != 22 {
            sum = String(sum).compactMap { $0.wholeNumberValue }.reduce(0, +)
        }
        return max(1, sum)
    }

    func digitSum(_ n: Int) -> Int {
        String(n).compactMap { $0.wholeNumberValue }.reduce(0, +)
    }
}

// MARK: - NumCard (local to avoid conflict)
struct NumCard: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "a78bfa").opacity(0.6))
            Text(value)
                .font(.system(size: 32, weight: .ultraLight))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .tracking(1.5)
                .foregroundColor(.white.opacity(0.3))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.04))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(hex: "7c3aed").opacity(0.2), lineWidth: 1)
        )
    }
}
