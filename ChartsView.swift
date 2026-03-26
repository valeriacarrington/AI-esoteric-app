import SwiftUI

struct ChartsView: View {
    @EnvironmentObject var profile: UserProfile
    @State private var animateIn = false
    @State private var selectedChart = 0
    @State private var moodHistory: [MoodEntry] = []

    let chartTypes = ["Mood Flow", "Activity", "Elements", "Moon Cycle"]

    var journalCount: Int {
        if let data = UserDefaults.standard.data(forKey: "journalEntries"),
           let entries = try? JSONDecoder().decode([JournalEntry].self, from: data) {
            return entries.count
        }
        return 0
    }

    var daysSinceJoined: Int {
        guard let joined = profile.currentUser?.joinDate else { return 1 }
        return max(1, Calendar.current.dateComponents([.day], from: joined, to: Date()).day ?? 1)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                VStack(spacing: 8) {
                    Text("📊").font(.system(size: 36)).opacity(animateIn ? 1 : 0)
                    Text("COSMIC ANALYTICS")
                        .font(.system(size: 11, weight: .ultraLight)).tracking(6)
                        .foregroundColor(.white.opacity(0.4)).opacity(animateIn ? 1 : 0)
                    Text("Your Journey in Numbers")
                        .font(.system(size: 22, weight: .thin)).tracking(1)
                        .foregroundColor(.white).opacity(animateIn ? 1 : 0)
                }
                .padding(.top, 24).padding(.bottom, 24)

                // Chart type selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(chartTypes.enumerated()), id: \.offset) { i, type in
                            Button(action: {
                                withAnimation(.spring()) { selectedChart = i }
                            }) {
                                Text(type)
                                    .font(.system(size: 12,
                                                  weight: selectedChart == i ? .medium : .light))
                                    .tracking(1)
                                    .foregroundColor(selectedChart == i
                                        ? .white : .white.opacity(0.4))
                                    .padding(.horizontal, 16).padding(.vertical, 9)
                                    .background(selectedChart == i
                                        ? Color(hex: "7c3aed").opacity(0.5)
                                        : Color.white.opacity(0.05))
                                    .cornerRadius(20)
                                    .overlay(RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color(hex: "7c3aed").opacity(
                                            selectedChart == i ? 0.8 : 0.15), lineWidth: 1))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)

                // Active chart
                VStack {
                    if selectedChart == 0 {
                        MoodLineChart(entries: moodHistory)
                    } else if selectedChart == 1 {
                        ActivityBarChart(profile: profile)
                    } else if selectedChart == 2 {
                        ElementPieChart(
                            zodiac: profile.currentUser?.zodiacSign ?? ""
                        )
                    } else {
                        MoonCycleChart()
                    }
                }
                .padding(.horizontal, 20)
                .opacity(animateIn ? 1 : 0)

                // Stats summary
                VStack(spacing: 16) {
                    SectionHeader(icon: "chart.bar.fill", title: "LIFETIME STATS")
                        .padding(.horizontal, 20)

                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible()),
                                  GridItem(.flexible())],
                        spacing: 12
                    ) {
                        StatBubble(
                            value: "\(profile.currentUser?.readingsCount ?? 0)",
                            label: "Readings", color: "7c3aed")
                        StatBubble(
                            value: "\(profile.dreams.count)",
                            label: "Dreams", color: "1d4ed8")
                        StatBubble(
                            value: "\(moodHistory.count)",
                            label: "Moods", color: "be185d")
                        StatBubble(
                            value: "\(journalCount)",
                            label: "Journal", color: "065f46")
                        StatBubble(
                            value: "\(profile.lifePathNumber)",
                            label: "Life Path", color: "b45309")
                        StatBubble(
                            value: "\(daysSinceJoined)",
                            label: "Days", color: "0f766e")
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 24).padding(.bottom, 20)

                Spacer(minLength: 48)
            }
        }
        .onAppear {
            loadMoods()
            withAnimation(.spring(response: 0.6).delay(0.1)) { animateIn = true }
        }
    }

    func loadMoods() {
        if let data = UserDefaults.standard.data(forKey: "moodHistory"),
           let saved = try? JSONDecoder().decode([MoodEntry].self, from: data) {
            moodHistory = saved
        }
    }
}

// MARK: - Mood Line Chart
struct MoodLineChart: View {
    let entries: [MoodEntry]
    @State private var animate = false

    let moodValues: [String: CGFloat] = [
        "Euphoric": 10, "Inspired": 9, "Hopeful": 8, "Grateful": 8,
        "Passionate": 7, "Calm": 7, "Nostalgic": 5, "Confused": 4,
        "Anxious": 3, "Overwhelmed": 3, "Melancholy": 2, "Numb": 1
    ]

    var recentMoods: [MoodEntry] { Array(entries.prefix(14).reversed()) }
    var points: [CGFloat] { recentMoods.map { moodValues[$0.mood] ?? 5 } }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("MOOD FLOW")
                        .font(.system(size: 11, weight: .semibold)).tracking(3)
                        .foregroundColor(Color(hex: "a78bfa"))
                    Text("Last \(recentMoods.count) entries")
                        .font(.system(size: 10, weight: .light))
                        .foregroundColor(.white.opacity(0.3))
                }
                Spacer()
                if let latest = entries.first {
                    HStack(spacing: 4) {
                        Text(latest.emoji)
                        Text(latest.mood)
                            .font(.system(size: 11, weight: .light))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }

            if points.isEmpty {
                VStack(spacing: 12) {
                    Text("☽").font(.system(size: 32)).foregroundColor(.white.opacity(0.2))
                    Text("Log moods to see your flow")
                        .font(.system(size: 13, weight: .light))
                        .foregroundColor(.white.opacity(0.3))
                }
                .frame(maxWidth: .infinity).padding(.vertical, 40)
            } else {
                GeometryReader { geo in
                    ZStack {
                        // Grid lines
                        ForEach([2, 5, 8], id: \.self) { val in
                            let y = geo.size.height - (CGFloat(val) / 10.0 * geo.size.height)
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: y))
                                path.addLine(to: CGPoint(x: geo.size.width, y: y))
                            }
                            .stroke(Color.white.opacity(0.06),
                                    style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        }

                        // Fill area
                        if points.count > 1 {
                            Path { path in
                                let w = geo.size.width / CGFloat(max(points.count - 1, 1))
                                path.move(to: CGPoint(x: 0, y: geo.size.height))
                                for (i, val) in points.enumerated() {
                                    let x = CGFloat(i) * w
                                    let y = geo.size.height - (val / 10.0 * geo.size.height)
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                                path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height))
                                path.closeSubpath()
                            }
                            .fill(LinearGradient(
                                colors: [Color(hex: "7c3aed").opacity(0.3), .clear],
                                startPoint: .top, endPoint: .bottom))
                        }

                        // Line
                        if points.count > 1 {
                            Path { path in
                                let w = geo.size.width / CGFloat(max(points.count - 1, 1))
                                for (i, val) in points.enumerated() {
                                    let x = CGFloat(i) * w
                                    let y = geo.size.height - (val / 10.0 * geo.size.height)
                                    if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                                    else { path.addLine(to: CGPoint(x: x, y: y)) }
                                }
                            }
                            .trim(from: 0, to: animate ? 1 : 0)
                            .stroke(
                                LinearGradient(
                                    colors: [Color(hex: "7c3aed"), Color(hex: "c4b5fd")],
                                    startPoint: .leading, endPoint: .trailing),
                                style: StrokeStyle(lineWidth: 2.5, lineCap: .round,
                                                   lineJoin: .round))
                            .animation(.easeInOut(duration: 1.2), value: animate)
                        }

                        // Dots
                        ForEach(Array(points.enumerated()), id: \.offset) { i, val in
                            let w = geo.size.width / CGFloat(max(points.count - 1, 1))
                            Circle()
                                .fill(Color(hex: "c4b5fd"))
                                .frame(width: 6, height: 6)
                                .position(
                                    x: CGFloat(i) * w,
                                    y: geo.size.height - (val / 10.0 * geo.size.height))
                                .opacity(animate ? 1 : 0)
                                .animation(.easeIn(duration: 0.3).delay(Double(i) * 0.08),
                                           value: animate)
                        }
                    }
                }
                .frame(height: 160)
                .onAppear { animate = true }

                // X labels
                HStack {
                    ForEach(Array(recentMoods.enumerated()), id: \.offset) { i, entry in
                        if recentMoods.count <= 7 || i % 2 == 0 {
                            Text(entry.emoji).font(.system(size: 12))
                            if i < recentMoods.count - 1 { Spacer() }
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.04)).cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20)
            .stroke(Color(hex: "7c3aed").opacity(0.2), lineWidth: 1))
    }
}

// MARK: - Activity Bar Chart
struct ActivityBarChart: View {
    let profile: UserProfile
    @State private var animate = false

    var weeklyData: [(day: String, value: CGFloat)] {
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        return days.map { day in
            let val = CGFloat(abs(day.hashValue % 8) + 2) / 10.0
            return (day, val)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("WEEKLY ACTIVITY")
                    .font(.system(size: 11, weight: .semibold)).tracking(3)
                    .foregroundColor(Color(hex: "a78bfa"))
                Text("Readings · Dreams · Moods")
                    .font(.system(size: 10, weight: .light))
                    .foregroundColor(.white.opacity(0.3))
            }

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(weeklyData.enumerated()), id: \.offset) { i, item in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(LinearGradient(
                                colors: [Color(hex: "7c3aed"), Color(hex: "c4b5fd")],
                                startPoint: .bottom, endPoint: .top))
                            .frame(height: animate ? item.value * 120 : 0)
                            .animation(
                                .spring(response: 0.6, dampingFraction: 0.7).delay(Double(i) * 0.08),
                                value: animate)
                        Text(item.day)
                            .font(.system(size: 9, weight: .light))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 140)
            .onAppear { animate = true }
        }
        .padding(20)
        .background(Color.white.opacity(0.04)).cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20)
            .stroke(Color(hex: "7c3aed").opacity(0.2), lineWidth: 1))
    }
}

// MARK: - Element Pie Chart
struct ElementPieChart: View {
    let zodiac: String
    @State private var animate = false

    let elementData: [(name: String, emoji: String, value: CGFloat, color: String)] = [
        ("Fire", "🔥", 0.25, "b45309"),
        ("Water", "🌊", 0.30, "1d4ed8"),
        ("Earth", "🌿", 0.20, "065f46"),
        ("Air", "💨", 0.25, "6d28d9"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("ELEMENTAL BALANCE")
                    .font(.system(size: 11, weight: .semibold)).tracking(3)
                    .foregroundColor(Color(hex: "a78bfa"))
                Text("Your cosmic composition")
                    .font(.system(size: 10, weight: .light))
                    .foregroundColor(.white.opacity(0.3))
            }

            HStack(spacing: 24) {
                ZStack {
                    ForEach(Array(pieSlices().enumerated()), id: \.offset) { i, slice in
                        PieSlice(startAngle: slice.start,
                                 endAngle: animate ? slice.end : slice.start)
                            .fill(Color(hex: elementData[i].color).opacity(0.8))
                            .animation(.spring(response: 0.8).delay(Double(i) * 0.15),
                                       value: animate)
                    }
                    Circle().fill(Color(hex: "060412")).frame(width: 60, height: 60)
                    Text(zodiac.components(separatedBy: " ").last ?? "✦")
                        .font(.system(size: 24))
                }
                .frame(width: 120, height: 120)
                .onAppear { animate = true }

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(elementData, id: \.name) { item in
                        HStack(spacing: 8) {
                            Circle().fill(Color(hex: item.color)).frame(width: 10, height: 10)
                            Text(item.emoji + " " + item.name)
                                .font(.system(size: 13, weight: .light))
                                .foregroundColor(.white.opacity(0.8))
                            Spacer()
                            Text("\(Int(item.value * 100))%")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(hex: item.color))
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.04)).cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20)
            .stroke(Color(hex: "7c3aed").opacity(0.2), lineWidth: 1))
    }

    func pieSlices() -> [(start: Angle, end: Angle)] {
        var slices: [(start: Angle, end: Angle)] = []
        var current: Double = -90
        for item in elementData {
            let degrees = Double(item.value) * 360
            slices.append((.degrees(current), .degrees(current + degrees)))
            current += degrees
        }
        return slices
    }
}

struct PieSlice: Shape {
    var startAngle: Angle
    var endAngle: Angle

    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(startAngle.degrees, endAngle.degrees) }
        set {
            startAngle = .degrees(newValue.first)
            endAngle = .degrees(newValue.second)
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.move(to: center)
        path.addArc(center: center, radius: radius,
                    startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()
        return path
    }
}

// MARK: - Moon Cycle Chart
struct MoonCycleChart: View {
    @State private var animate = false
    let phases = ["🌑","🌒","🌓","🌔","🌕","🌖","🌗","🌘"]

    var currentPhaseIndex: Int {
        (Calendar.current.component(.day, from: Date()) % 30) / 4
    }

    var currentDay: Int {
        Calendar.current.component(.day, from: Date()) % 30
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("LUNAR CYCLE")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(3)
                    .foregroundColor(Color(hex: "a78bfa"))
                Text("Current moon journey")
                    .font(.system(size: 10, weight: .light))
                    .foregroundColor(.white.opacity(0.3))
            }

            ZStack {
                // Orbit ring
                Circle()
                    .stroke(Color(hex: "7c3aed").opacity(0.15), lineWidth: 1)
                    .frame(width: 160, height: 160)

                // Phase items placed manually
                ForEach(0..<phases.count, id: \.self) { i in
                    MoonPhaseItem(
                        phase: phases[i],
                        index: i,
                        total: phases.count,
                        isCurrent: i == currentPhaseIndex,
                        radius: 80,
                        animate: animate
                    )
                }

                // Center label
                VStack(spacing: 2) {
                    Text("DAY")
                        .font(.system(size: 9, weight: .medium))
                        .tracking(2)
                        .foregroundColor(.white.opacity(0.3))
                    Text("\(currentDay)")
                        .font(.system(size: 26, weight: .ultraLight))
                        .foregroundColor(.white)
                    Text("OF CYCLE")
                        .font(.system(size: 9, weight: .light))
                        .tracking(1)
                        .foregroundColor(.white.opacity(0.3))
                }
            }
            .frame(height: 220)
            .frame(maxWidth: .infinity)
            .onAppear { animate = true }
        }
        .padding(20)
        .background(Color.white.opacity(0.04))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(hex: "7c3aed").opacity(0.2), lineWidth: 1)
        )
    }
}

// Separate struct to avoid type-check complexity
struct MoonPhaseItem: View {
    let phase: String
    let index: Int
    let total: Int
    let isCurrent: Bool
    let radius: CGFloat
    let animate: Bool

    var xOffset: CGFloat {
        let angle = Double(index) / Double(total) * 2 * .pi - .pi / 2
        return cos(angle) * radius
    }

    var yOffset: CGFloat {
        let angle = Double(index) / Double(total) * 2 * .pi - .pi / 2
        return sin(angle) * radius
    }

    var body: some View {
        ZStack {
            if isCurrent {
                Circle()
                    .fill(Color(hex: "7c3aed").opacity(0.3))
                    .frame(width: 40, height: 40)
                    .blur(radius: 8)
            }
            Text(phase)
                .font(.system(size: isCurrent ? 26 : 16))
                .scaleEffect(animate ? 1 : 0.3)
                .opacity(animate ? 1 : 0)
                .animation(
                    .spring(response: 0.5).delay(Double(index) * 0.1),
                    value: animate
                )
        }
        .offset(x: xOffset, y: yOffset)
    }
}
// MARK: - Stat Bubble
struct StatBubble: View {
    let value: String
    let label: String
    let color: String

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 24, weight: .ultraLight)).foregroundColor(.white)
            Text(label)
                .font(.system(size: 9, weight: .medium)).tracking(1.5)
                .foregroundColor(Color(hex: color).opacity(0.8))
        }
        .frame(maxWidth: .infinity).padding(.vertical, 18)
        .background(Color(hex: color).opacity(0.08)).cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16)
            .stroke(Color(hex: color).opacity(0.25), lineWidth: 1))
    }
}
