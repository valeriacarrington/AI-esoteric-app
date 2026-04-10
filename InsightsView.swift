import SwiftUI

// MARK: - Insights & Dashboard View
struct InsightsView: View {
    @EnvironmentObject var profile: UserProfile
    @State private var animateIn = false
    @State private var moonPhase = ""
    @State private var moonResult = ""
    @State private var isLoadingMoon = false
    @State private var planetResult = ""
    @State private var isLoadingPlanet = false
    @State private var showPlanet = false
    @State private var tarotCard = ""
    @State private var tarotMeaning = ""
    @State private var isLoadingTarot = false
    @State private var showTarot = false
    @State private var journalText = ""
    @State private var journalEntries: [JournalEntry] = []
    @State private var showJournalInput = false
    @State private var isSavingJournal = false
    @State private var selectedPlanet = "Mercury"
    @State private var showRetrograde = false
    @State private var retrogradeResult = ""
    @State private var isLoadingRetrograde = false
    @FocusState private var journalFocused: Bool

    let planets = ["Mercury", "Venus", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune", "Pluto"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // ── Header ──
                VStack(spacing: 8) {
                    Text("◉")
                        .font(.system(size: 40, weight: .ultraLight))
                        .foregroundColor(Color(hex: "a78bfa"))
                        .scaleEffect(animateIn ? 1 : 0.5)
                        .opacity(animateIn ? 1 : 0)
                    Text("COSMIC INSIGHTS")
                        .font(.system(size: 11, weight: .ultraLight)).tracking(6)
                        .foregroundColor(.white.opacity(0.4))
                        .opacity(animateIn ? 1 : 0)
                    Text("Your Universe Today")
                        .font(.system(size: 22, weight: .thin)).tracking(1)
                        .foregroundColor(.white)
                        .opacity(animateIn ? 1 : 0)
                }
                .padding(.top, 28).padding(.bottom, 28)

                // ── Moon Phase Card ──
                MoonPhaseCard()
                    .padding(.horizontal, 20).padding(.bottom, 16)
                    .opacity(animateIn ? 1 : 0)

                // ── Daily Cosmic Stats ──
                SectionHeader(icon: "chart.bar.fill", title: "TODAY'S ENERGIES")
                    .padding(.horizontal, 20).padding(.bottom, 12)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    EnergyCard(title: "Emotional", value: emotionalEnergy, color: "be185d", icon: "heart.fill")
                    EnergyCard(title: "Creative", value: creativeEnergy, color: "7c3aed", icon: "paintbrush.fill")
                    EnergyCard(title: "Physical", value: physicalEnergy, color: "b45309", icon: "bolt.fill")
                    EnergyCard(title: "Spiritual", value: spiritualEnergy, color: "065f46", icon: "sparkles")
                }
                .padding(.horizontal, 20).padding(.bottom, 20)
                .opacity(animateIn ? 1 : 0)

                // ── Tarot of the Day ──
                SectionHeader(icon: "rectangle.portrait.fill", title: "DAILY TAROT")
                    .padding(.horizontal, 20).padding(.bottom, 12)

                VStack(spacing: 14) {
                    if !showTarot {
                        Button(action: drawTarot) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(LinearGradient(
                                        colors: [Color(hex: "1e1b4b"), Color(hex: "2d0a5c")],
                                        startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(height: 160)
                                    .overlay(RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color(hex: "7c3aed").opacity(0.3), lineWidth: 1))

                                if isLoadingTarot {
                                    VStack(spacing: 12) {
                                        ProgressView().tint(Color(hex: "a78bfa"))
                                        Text("The cards are speaking...")
                                            .font(.system(size: 12, weight: .light)).tracking(2)
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                } else {
                                    VStack(spacing: 12) {
                                        Text("🃏")
                                            .font(.system(size: 44))
                                        Text("DRAW YOUR CARD")
                                            .font(.system(size: 12, weight: .semibold)).tracking(3)
                                            .foregroundColor(Color(hex: "a78bfa"))
                                        Text("Tap to receive today's tarot wisdom")
                                            .font(.system(size: 11, weight: .light))
                                            .foregroundColor(.white.opacity(0.35))
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    } else {
                        TarotCardDisplay(card: tarotCard, meaning: tarotMeaning)
                            .padding(.horizontal, 20)
                            .transition(.scale.combined(with: .opacity))

                        Button(action: {
                            withAnimation { showTarot = false; tarotCard = ""; tarotMeaning = "" }
                        }) {
                            Text("Draw Another Card")
                                .font(.system(size: 12, weight: .light)).tracking(2)
                                .foregroundColor(Color(hex: "a78bfa").opacity(0.7))
                        }
                    }
                }
                .padding(.bottom, 20)

                // ── Planet Retrograde ──
                SectionHeader(icon: "arrow.counterclockwise", title: "PLANETARY ENERGY")
                    .padding(.horizontal, 20).padding(.bottom, 12)

                VStack(spacing: 12) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(planets, id: \.self) { planet in
                                Button(action: {
                                    selectedPlanet = planet
                                    fetchPlanetEnergy(planet: planet)
                                }) {
                                    Text(planet)
                                        .font(.system(size: 12, weight: .light)).tracking(1)
                                        .foregroundColor(selectedPlanet == planet
                                            ? .white : .white.opacity(0.45))
                                        .padding(.horizontal, 16).padding(.vertical, 9)
                                        .background(selectedPlanet == planet
                                            ? Color(hex: "7c3aed").opacity(0.5)
                                            : Color.white.opacity(0.05))
                                        .cornerRadius(20)
                                        .overlay(RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color(hex: "7c3aed").opacity(
                                                selectedPlanet == planet ? 0.8 : 0.15), lineWidth: 1))
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    if isLoadingPlanet {
                        HStack(spacing: 10) {
                            ProgressView().tint(Color(hex: "a78bfa")).scaleEffect(0.8)
                            Text("Consulting the cosmos...")
                                .font(.system(size: 12, weight: .light))
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .padding()
                    } else if showPlanet && !planetResult.isEmpty {
                        ExpandedCard(title: "◎ \(selectedPlanet.uppercased()) ENERGY", content: planetResult)
                            .padding(.horizontal, 20)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(.bottom, 20)

                // ── Cosmic Journal ──
                SectionHeader(icon: "book.fill", title: "COSMIC JOURNAL")
                    .padding(.horizontal, 20).padding(.bottom, 12)

                VStack(spacing: 12) {
                    Button(action: { withAnimation { showJournalInput.toggle() }; journalFocused = true }) {
                        HStack(spacing: 10) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "7c3aed"))
                            Text("New Journal Entry")
                                .font(.system(size: 14, weight: .light)).tracking(1)
                                .foregroundColor(.white.opacity(0.7))
                            Spacer()
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(hex: "7c3aed").opacity(0.2), lineWidth: 1))
                    }
                    .padding(.horizontal, 20)

                    if showJournalInput {
                        VStack(spacing: 12) {
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.05))
                                    .overlay(RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(hex: "7c3aed").opacity(0.3), lineWidth: 1))

                                if journalText.isEmpty {
                                    Text("Write your cosmic thoughts, intentions, gratitude...")
                                        .font(.system(size: 13, weight: .light))
                                        .foregroundColor(.white.opacity(0.25))
                                        .padding(.horizontal, 16).padding(.top, 14)
                                        .allowsHitTesting(false)
                                }

                                TextEditor(text: $journalText)
                                    .focused($journalFocused)
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundColor(.white)
                                    .scrollContentBackground(.hidden)
                                    .tint(Color(hex: "a78bfa"))
                                    .padding(12)
                            }
                            .frame(minHeight: 120)

                            HStack(spacing: 12) {
                                Button(action: { withAnimation { showJournalInput = false; journalText = "" }}) {
                                    Text("Cancel")
                                        .font(.system(size: 13, weight: .light))
                                        .foregroundColor(.white.opacity(0.35))
                                        .frame(maxWidth: .infinity).padding(.vertical, 14)
                                        .background(Color.white.opacity(0.04)).cornerRadius(12)
                                }

                                Button(action: saveJournalEntry) {
                                    ZStack {
                                        if isSavingJournal {
                                            ProgressView().tint(.white).scaleEffect(0.8)
                                        } else {
                                            Text("Save & Reflect")
                                                .font(.system(size: 13, weight: .semibold)).tracking(1)
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                                    .background(LinearGradient(
                                        colors: [Color(hex: "7c3aed"), Color(hex: "4c1d95")],
                                        startPoint: .leading, endPoint: .trailing))
                                    .cornerRadius(12)
                                }
                                .disabled(journalText.isEmpty || isSavingJournal)
                            }
                        }
                        .padding(.horizontal, 20)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // Journal entries list
                    ForEach(journalEntries.prefix(5)) { entry in
                        JournalCard(entry: entry)
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 20)

                // ── Cosmic Tip of the Day ──
                CosmicTipCard(zodiac: profile.currentUser?.zodiacSign ?? "")
                    .padding(.horizontal, 20).padding(.bottom, 20)
                    .opacity(animateIn ? 1 : 0)

                Spacer(minLength: 48)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animateIn = true
            }
            loadJournalEntries()
        }
    }

    // MARK: - Computed energies based on date + zodiac
    var emotionalEnergy: Int {
        let day = Calendar.current.component(.day, from: Date())
        let base = (day * 7 + (profile.lifePathNumber * 3)) % 10
        return max(3, base + 1)
    }
    var creativeEnergy: Int {
        let day = Calendar.current.component(.day, from: Date())
        let base = (day * 3 + (profile.lifePathNumber * 7)) % 10
        return max(2, base + 1)
    }
    var physicalEnergy: Int {
        let day = Calendar.current.component(.day, from: Date())
        let base = (day * 11 + profile.lifePathNumber) % 10
        return max(2, base + 1)
    }
    var spiritualEnergy: Int {
        let day = Calendar.current.component(.day, from: Date())
        let base = (day * 5 + (profile.lifePathNumber * 5)) % 10
        return max(4, base + 1)
    }

    // MARK: - AI Calls
    func drawTarot() {
        isLoadingTarot = true
        Task {
            let zodiac = profile.currentUser?.zodiacSign ?? "unknown"
            let mood = profile.todayMood.isEmpty ? "open" : profile.todayMood
            let prompt = """
            You are a master tarot reader. Draw one tarot card for a \(zodiac) who feels \(mood) today.
            
            Respond in JSON only, no markdown:
            {
              "card": "Full card name (e.g. The Moon, Three of Cups, Knight of Swords)",
              "meaning": "3-4 sentences interpreting this card specifically for a \(zodiac). Include the card's energy, what it reveals about today, and one action or awareness it calls for. Be mystical and personal."
            }
            """
            let raw = await AIService.callOpenRouter(prompt: prompt, maxTokens: 300)
            await MainActor.run {
                if let data = raw.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let card = json["card"] as? String,
                   let meaning = json["meaning"] as? String {
                    tarotCard = card
                    tarotMeaning = meaning
                } else {
                    tarotCard = "The Star"
                    tarotMeaning = raw
                }
                isLoadingTarot = false
                withAnimation(.spring()) { showTarot = true }
            }
        }
    }

    func fetchPlanetEnergy(planet: String) {
        isLoadingPlanet = true; showPlanet = false; planetResult = ""
        Task {
            let zodiac = profile.currentUser?.zodiacSign ?? "unknown"
            let prompt = """
            You are an astrologer explaining planetary energy.
            Planet: \(planet)
            Person's zodiac: \(zodiac)
            
            In 3-4 sentences explain:
            1. \(planet)'s current cosmic energy and what it governs
            2. How this specifically affects a \(zodiac) right now
            3. One practical way to work with this energy today
            
            Be specific, mystical, and actionable.
            """
            let result = await AIService.callOpenRouter(prompt: prompt, maxTokens: 300)
            await MainActor.run {
                planetResult = result; isLoadingPlanet = false
                withAnimation(.spring()) { showPlanet = true }
            }
        }
    }

    func saveJournalEntry() {
        isSavingJournal = true
        Task {
            let zodiac = profile.currentUser?.zodiacSign ?? ""
            let prompt = """
            You are a cosmic journaling guide. Someone wrote this journal entry:
            "\(journalText)"
            They are a \(zodiac). Their current mood: \(profile.todayMood.isEmpty ? "unknown" : profile.todayMood)
            
            Give a 2-sentence cosmic reflection on their entry — validate their feelings,
            offer an astrological insight, and end with an empowering question for them to sit with.
            Be warm, mystical, and deeply personal.
            """
            let reflection = await AIService.callOpenRouter(prompt: prompt, maxTokens: 200)
            await MainActor.run {
                let entry = JournalEntry(
                    text: journalText,
                    reflection: reflection,
                    date: Date(),
                    mood: profile.todayMood,
                    moodEmoji: profile.todayMoodEmoji
                )
                journalEntries.insert(entry, at: 0)
                saveJournalEntries()
                journalText = ""
                isSavingJournal = false
                withAnimation { showJournalInput = false }
            }
        }
    }

    func loadJournalEntries() {
        if let data = UserDefaults.standard.data(forKey: "journalEntries"),
           let saved = try? JSONDecoder().decode([JournalEntry].self, from: data) {
            journalEntries = saved
        }
    }

    func saveJournalEntries() {
        if let data = try? JSONEncoder().encode(journalEntries) {
            UserDefaults.standard.set(data, forKey: "journalEntries")
        }
    }
}

// MARK: - Journal Entry Model
struct JournalEntry: Identifiable, Codable {
    var id = UUID()
    var text: String
    var reflection: String
    var date: Date
    var mood: String
    var moodEmoji: String
}

// MARK: - Moon Phase Card
struct MoonPhaseCard: View {
    @State private var phase = ""
    @State private var description = ""
    @State private var isLoading = false
    @State private var loaded = false

    var currentMoonPhase: (name: String, emoji: String, description: String) {
        let day = Calendar.current.component(.day, from: Date())
        let cycle = day % 30
        switch cycle {
        case 0...2: return ("New Moon", "🌑", "Set powerful intentions. Plant seeds of new beginnings.")
        case 3...6: return ("Waxing Crescent", "🌒", "Take action. Build momentum toward your goals.")
        case 7...9: return ("First Quarter", "🌓", "Overcome challenges. Push through resistance.")
        case 10...13: return ("Waxing Gibbous", "🌔", "Refine and perfect. Almost there — keep going.")
        case 14...16: return ("Full Moon", "🌕", "Peak energy. Release, celebrate, and illuminate truth.")
        case 17...20: return ("Waning Gibbous", "🌖", "Share wisdom. Express gratitude and give back.")
        case 21...23: return ("Last Quarter", "🌗", "Release and forgive. Let go of what no longer serves.")
        default: return ("Waning Crescent", "🌘", "Rest, reflect, and surrender. Prepare for renewal.")
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "1e1b4b").opacity(0.8))
                        .frame(width: 80, height: 80)
                    Text(currentMoonPhase.emoji)
                        .font(.system(size: 44))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("MOON PHASE")
                        .font(.system(size: 9, weight: .medium)).tracking(3)
                        .foregroundColor(Color(hex: "a78bfa").opacity(0.6))
                    Text(currentMoonPhase.name)
                        .font(.system(size: 20, weight: .thin)).tracking(1)
                        .foregroundColor(.white)
                    Text(currentMoonPhase.description)
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(.white.opacity(0.55))
                        .lineSpacing(4)
                    Text(Date().formatted(date: .long, time: .omitted))
                        .font(.system(size: 10, weight: .light)).tracking(1)
                        .foregroundColor(.white.opacity(0.3))
                }
                Spacer()
            }
            .padding(20)

            VStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 4)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(LinearGradient(
                                colors: [Color(hex: "7c3aed"), Color(hex: "c4b5fd")],
                                startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * moonProgress, height: 4)
                    }
                }
                .frame(height: 4)

                HStack {
                    Text("🌑 New").font(.system(size: 9)).foregroundColor(.white.opacity(0.3))
                    Spacer()
                    Text("\(Int(moonProgress * 100))% through cycle")
                        .font(.system(size: 9)).foregroundColor(.white.opacity(0.3))
                    Spacer()
                    Text("🌕 Full").font(.system(size: 9)).foregroundColor(.white.opacity(0.3))
                }
            }
            .padding(.horizontal, 20).padding(.bottom, 16)
        }
        .background(Color.white.opacity(0.04))
        .cornerRadius(22)
        .overlay(RoundedRectangle(cornerRadius: 22)
            .stroke(Color(hex: "7c3aed").opacity(0.2), lineWidth: 1))
    }

    var moonProgress: CGFloat {
        let day = Calendar.current.component(.day, from: Date())
        return CGFloat(day % 30) / 30.0
    }
}

// MARK: - Energy Card
struct EnergyCard: View {
    let title: String
    let value: Int
    let color: String
    let icon: String
    @State private var animate = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: color))
                Spacer()
                Text("\(value)/10")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
            }
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 4)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(hex: color).opacity(0.8))
                        .frame(width: animate
                               ? geo.size.width * CGFloat(value) / 10.0
                               : 0, height: 4)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.3),
                                   value: animate)
                }
            }
            .frame(height: 4)

            Text(energyLabel)
                .font(.system(size: 9, weight: .light)).tracking(1)
                .foregroundColor(Color(hex: color).opacity(0.7))
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16)
            .stroke(Color(hex: color).opacity(0.2), lineWidth: 1))
        .onAppear { animate = true }
    }

    var energyLabel: String {
        switch value {
        case 8...10: return "PEAK ENERGY"
        case 6...7: return "FLOWING WELL"
        case 4...5: return "MODERATE"
        default: return "RESTORE & REST"
        }
    }
}

// MARK: - Tarot Card Display
struct TarotCardDisplay: View {
    let card: String
    let meaning: String
    @State private var flipped = false

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(
                        colors: [Color(hex: "1e1b4b"), Color(hex: "2d0a5c"), Color(hex: "1e1b4b")],
                        startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 200)
                    .overlay(RoundedRectangle(cornerRadius: 20)
                        .stroke(LinearGradient(
                            colors: [Color(hex: "a78bfa").opacity(0.6),
                                     Color(hex: "7c3aed").opacity(0.2)],
                            startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))

                VStack(spacing: 12) {
                    Text("🃏")
                        .font(.system(size: 52))
                    Text(card)
                        .font(.system(size: 20, weight: .thin)).tracking(2)
                        .foregroundColor(.white)
                    Text("TODAY'S CARD")
                        .font(.system(size: 9, weight: .medium)).tracking(4)
                        .foregroundColor(Color(hex: "a78bfa").opacity(0.6))
                }
            }

            Text(meaning)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineSpacing(7)
                .padding(.horizontal, 4)
        }
        .padding(20)
        .background(Color.white.opacity(0.03))
        .cornerRadius(22)
        .overlay(RoundedRectangle(cornerRadius: 22)
            .stroke(Color(hex: "7c3aed").opacity(0.2), lineWidth: 1))
    }
}

// MARK: - Journal Card
struct JournalCard: View {
    let entry: JournalEntry
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                if !entry.moodEmoji.isEmpty {
                    Text(entry.moodEmoji).font(.system(size: 16))
                }
                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 10, weight: .medium)).tracking(1)
                    .foregroundColor(Color(hex: "a78bfa").opacity(0.5))
                Spacer()
                Image(systemName: expanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 10)).foregroundColor(.white.opacity(0.2))
            }

            Text(entry.text)
                .font(.system(size: 13, weight: .light))
                .foregroundColor(.white.opacity(0.7))
                .lineLimit(expanded ? nil : 2).lineSpacing(4)

            if expanded && !entry.reflection.isEmpty {
                Rectangle().fill(Color(hex: "7c3aed").opacity(0.2)).frame(height: 0.5)

                HStack(alignment: .top, spacing: 8) {
                    Text("✦").font(.system(size: 10)).foregroundColor(Color(hex: "a78bfa"))
                        .padding(.top, 2)
                    Text(entry.reflection)
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(Color(hex: "c4b5fd").opacity(0.85))
                        .lineSpacing(5).italic()
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.03))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16)
            .stroke(Color(hex: "7c3aed").opacity(0.1), lineWidth: 1))
        .onTapGesture {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { expanded.toggle() }
        }
    }
}

// MARK: - Cosmic Tip Card
struct CosmicTipCard: View {
    let zodiac: String
    @State private var tip = ""
    @State private var isLoading = false
    @State private var loaded = false

    let staticTips = [
        "The universe conspires in your favor when you align action with intention.",
        "What you resist persists. What you embrace transforms.",
        "Your energy is your most sacred resource. Guard it wisely.",
        "Every ending is a doorway dressed in disguise.",
        "The stars don't control your fate — they illuminate your path.",
        "Stillness is not emptiness. It is where clarity is born.",
        "You are always exactly where your soul needs to be.",
    ]

    var dailyTip: String {
        let day = Calendar.current.component(.dayOfYear, from: Date())
        return staticTips[day % staticTips.count]
    }

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "fbbf24"))
                Text("COSMIC TIP OF THE DAY")
                    .font(.system(size: 10, weight: .semibold)).tracking(3)
                    .foregroundColor(Color(hex: "fbbf24"))
                Spacer()
            }

            Text(isLoading ? "..." : (tip.isEmpty ? dailyTip : tip))
                .font(.system(size: 15, weight: .light))
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineSpacing(7)
                .italic()

            if !loaded {
                Button(action: fetchPersonalTip) {
                    Text(isLoading ? "Loading..." : "Get Personalized Tip →")
                        .font(.system(size: 11, weight: .medium)).tracking(1)
                        .foregroundColor(Color(hex: "fbbf24").opacity(0.8))
                }
                .disabled(isLoading)
            }
        }
        .padding(20)
        .background(LinearGradient(
            colors: [Color(hex: "1c1400").opacity(0.8), Color(hex: "0a0800")],
            startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20)
            .stroke(Color(hex: "fbbf24").opacity(0.2), lineWidth: 1))
    }

    func fetchPersonalTip() {
        isLoading = true
        Task {
            let prompt = """
            Give one short, powerful cosmic tip for a \(zodiac) for today.
            It should be 1-2 sentences, poetic, actionable, and deeply specific to \(zodiac) energy.
            No fluff. Make it land like a revelation.
            """
            let result = await AIService.callOpenRouter(prompt: prompt, maxTokens: 100)
            await MainActor.run { tip = result; isLoading = false; loaded = true }
        }
    }
}

extension Calendar {
    func component(_ component: Calendar.Component, from date: Date) -> Int {
        self.dateComponents([component], from: date).value(for: component) ?? 0
    }
}
