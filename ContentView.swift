import SwiftUI

struct ContentView: View {
    @EnvironmentObject var profile: UserProfile
    @EnvironmentObject var store: AppStore
    @State private var selectedTab: AppTab = .home
    @State private var showMenu = false
    @State private var menuDragOffset: CGFloat = 0

    var body: some View {
        ZStack {
            if !profile.isLoggedIn {
                AuthView()
                    .environmentObject(profile)
                    .transition(.asymmetric(
                        insertion: .opacity,
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                ZStack(alignment: .leading) {
                    CosmicBackground()

                    VStack(spacing: 0) {
                        TopNavBar(showMenu: $showMenu, selectedTab: $selectedTab)
                            .environmentObject(profile)

                        ZStack {
                            switch selectedTab {
                            case .home:
                                HomeView()
                                    .environmentObject(profile)
                                    .transition(.opacity)
                            case .mood:
                                MoodView()
                                    .environmentObject(profile)
                                    .transition(.opacity)
                            case .dreams:
                                DreamView()
                                    .environmentObject(profile)
                                    .transition(.opacity)
                            case .insights:
                                InsightsView()
                                    .environmentObject(profile)
                                    .transition(.opacity)
                            case .numerology:
                                NumerologyView()
                                    .environmentObject(profile)
                                    .transition(.opacity)
                            case .search:
                                SearchView()
                                    .environmentObject(profile)
                                    .transition(.opacity)
                            case .charts:
                                ChartsView()
                                    .environmentObject(profile)
                                    .transition(.opacity)
                            case .profile:
                                ProfileView()
                                    .environmentObject(profile)
                                    .environmentObject(store)
                                    .transition(.opacity)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .animation(.easeInOut(duration: 0.25), value: selectedTab)

                        BottomTabBar(selectedTab: $selectedTab)
                    }

                    if showMenu {
                        Color.black.opacity(0.6)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                    showMenu = false
                                }
                            }

                        SideMenuView(showMenu: $showMenu, selectedTab: $selectedTab)
                            .environmentObject(profile)
                            .environmentObject(store)
                            .offset(x: menuDragOffset)
                            .transition(.move(edge: .leading))
                            .gesture(
                                DragGesture()
                                    .onChanged { v in
                                        if v.translation.width < 0 {
                                            menuDragOffset = v.translation.width
                                        }
                                    }
                                    .onEnded { v in
                                        if v.translation.width < -80 {
                                            withAnimation(.spring()) { showMenu = false }
                                        }
                                        menuDragOffset = 0
                                    }
                            )
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .opacity
                ))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: profile.isLoggedIn)
        .preferredColorScheme(.dark)
    }
}

// MARK: - App Tabs
enum AppTab: String, CaseIterable {
    case home = "Oracle"
    case mood = "Mood"
    case dreams = "Dreams"
    case insights = "Insights"
    case numerology = "Numbers"
    case search = "Search"
    case charts = "Charts"
    case profile = "Profile"

    var icon: String {
        switch self {
        case .home: return "sparkles"
        case .mood: return "moon.stars.fill"
        case .dreams: return "cloud.moon.fill"
        case .insights: return "circle.hexagongrid.fill"
        case .numerology: return "infinity"
        case .search: return "magnifyingglass"
        case .charts: return "chart.xyaxis.line"
        case .profile: return "person.crop.circle.fill"
        }
    }
}

// MARK: - Cosmic Background
struct CosmicBackground: View {
    @State private var shimmer = false

    var body: some View {
        ZStack {
            Color(hex: "060412").ignoresSafeArea()
            RadialGradient(
                colors: [Color(hex: "2d0a5c").opacity(0.5), .clear],
                center: .init(x: 0.15, y: 0.1),
                startRadius: 0, endRadius: 400
            ).ignoresSafeArea()
            RadialGradient(
                colors: [Color(hex: "0a1a5c").opacity(0.4), .clear],
                center: .init(x: 0.85, y: 0.85),
                startRadius: 0, endRadius: 350
            ).ignoresSafeArea()
            RadialGradient(
                colors: [Color(hex: "1a0a3c").opacity(0.3), .clear],
                center: .init(x: 0.5, y: 0.5),
                startRadius: 0, endRadius: 500
            ).ignoresSafeArea()
            Circle()
                .fill(Color(hex: "5b21b6").opacity(0.08))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: shimmer ? 30 : -30, y: shimmer ? -20 : 20)
                .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: shimmer)
                .ignoresSafeArea()
            StarFieldView()
        }
        .onAppear { shimmer = true }
    }
}

// MARK: - Star Field
struct StarFieldView: View {
    struct Star {
        let x, y, size: CGFloat
        let opacity: Double
        let twinkleSpeed: Double
    }

    let stars: [Star] = (0..<120).map { _ in
        Star(
            x: CGFloat.random(in: 0...1),
            y: CGFloat.random(in: 0...1),
            size: CGFloat.random(in: 0.8...2.5),
            opacity: Double.random(in: 0.15...0.8),
            twinkleSpeed: Double.random(in: 2...6)
        )
    }

    @State private var twinkle = false

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<stars.count, id: \.self) { i in
                Circle()
                    .fill(Color.white)
                    .frame(width: stars[i].size, height: stars[i].size)
                    .opacity(twinkle ? stars[i].opacity : stars[i].opacity * 0.4)
                    .animation(
                        .easeInOut(duration: stars[i].twinkleSpeed)
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.05),
                        value: twinkle
                    )
                    .position(
                        x: stars[i].x * geo.size.width,
                        y: stars[i].y * geo.size.height
                    )
            }
        }
        .ignoresSafeArea()
        .onAppear { twinkle = true }
    }
}

// MARK: - Top Nav Bar
struct TopNavBar: View {
    @Binding var showMenu: Bool
    @Binding var selectedTab: AppTab
    @EnvironmentObject var profile: UserProfile
    @State private var pulse = false

    var body: some View {
        HStack(spacing: 0) {
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showMenu.toggle()
                }
            }) {
                VStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white.opacity(0.8))
                            .frame(width: i == 1 ? 16 : 22, height: 1.5)
                    }
                }
                .frame(width: 44, height: 44)
            }

            Spacer()

            HStack(spacing: 6) {
                Text("✦")
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: "a78bfa"))
                    .opacity(pulse ? 1 : 0.4)
                    .animation(.easeInOut(duration: 2).repeatForever(), value: pulse)
                Text("ASTRALVEIL")
                    .font(.system(size: 16, weight: .ultraLight))
                    .tracking(6).foregroundColor(.white)
                Text("✦")
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: "a78bfa"))
                    .opacity(pulse ? 0.4 : 1)
                    .animation(.easeInOut(duration: 2).repeatForever(), value: pulse)
            }

            Spacer()

            Button(action: { selectedTab = .profile }) {
                ZStack {
                    Circle()
                        .stroke(Color(hex: "7c3aed").opacity(0.6), lineWidth: 1)
                        .frame(width: 36, height: 36)
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color(hex: "6d28d9"), Color(hex: "1e1b4b")],
                            startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 32, height: 32)
                    Text(String(profile.currentUser?.name.prefix(1).uppercased() ?? "✦"))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 16).padding(.vertical, 8)
        .background(Color.white.opacity(0.02).background(.ultraThinMaterial.opacity(0.3)))
        .overlay(
            Rectangle().frame(height: 0.5)
                .foregroundColor(Color(hex: "7c3aed").opacity(0.2)),
            alignment: .bottom
        )
        .onAppear { pulse = true }
    }
}

// MARK: - Bottom Tab Bar
struct BottomTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab
                        }
                    }) {
                        VStack(spacing: 4) {
                            ZStack {
                                if selectedTab == tab {
                                    Circle()
                                        .fill(Color(hex: "7c3aed").opacity(0.2))
                                        .frame(width: 34, height: 34)
                                        .blur(radius: 4)
                                }
                                Image(systemName: tab.icon)
                                    .font(.system(size: selectedTab == tab ? 19 : 16))
                                    .foregroundColor(selectedTab == tab
                                        ? Color(hex: "c4b5fd") : Color.white.opacity(0.3))
                                    .scaleEffect(selectedTab == tab ? 1.1 : 1.0)
                            }
                            .frame(height: 26)

                            Text(tab.rawValue)
                                .font(.system(size: 8, weight: .medium))
                                .tracking(0.3)
                                .foregroundColor(selectedTab == tab
                                    ? Color(hex: "c4b5fd") : Color.white.opacity(0.25))
                        }
                        .frame(width: 64)
                        .padding(.vertical, 8)
                    }
                }
            }
            .padding(.horizontal, 8)
        }
        .background(ZStack {
            Color(hex: "0a0618")
            Color.white.opacity(0.03)
        })
        .overlay(
            Rectangle().frame(height: 0.5)
                .foregroundColor(Color(hex: "7c3aed").opacity(0.25)),
            alignment: .top
        )
    }
}

// MARK: - Side Menu
struct SideMenuView: View {
    @Binding var showMenu: Bool
    @Binding var selectedTab: AppTab
    @EnvironmentObject var profile: UserProfile
    @EnvironmentObject var store: AppStore

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(hex: "080514")
                .overlay(LinearGradient(
                    colors: [Color(hex: "2d0a5c").opacity(0.25), .clear],
                    startPoint: .top, endPoint: .bottom))

            VStack(alignment: .leading, spacing: 0) {
                // Profile header
                VStack(alignment: .leading, spacing: 12) {
                    ZStack {
                        Circle()
                            .stroke(LinearGradient(
                                colors: [Color(hex: "7c3aed"), Color(hex: "3b0764")],
                                startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
                            .frame(width: 72, height: 72)
                        Circle()
                            .fill(LinearGradient(
                                colors: [Color(hex: "4c1d95"), Color(hex: "1e1b4b")],
                                startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 66, height: 66)
                        Text(String(profile.currentUser?.name.prefix(1).uppercased() ?? "✦"))
                            .font(.system(size: 28, weight: .thin)).foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(profile.currentUser?.name ?? "")
                            .font(.system(size: 20, weight: .light))
                            .tracking(1).foregroundColor(.white)
                        Text(profile.currentUser?.zodiacSign ?? "")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "a78bfa"))
                        Text(profile.currentUser?.planet ?? "")
                            .font(.system(size: 11, weight: .light)).tracking(1)
                            .foregroundColor(.white.opacity(0.35))
                    }

                    if !store.isPremium {
                        Button(action: { store.unlock(); showMenu = false }) {
                            HStack(spacing: 6) {
                                Image(systemName: "crown.fill").font(.system(size: 10))
                                Text("Unlock Premium")
                                    .font(.system(size: 11, weight: .medium)).tracking(1)
                            }
                            .foregroundColor(Color(hex: "fbbf24"))
                            .padding(.horizontal, 14).padding(.vertical, 7)
                            .background(Color(hex: "fbbf24").opacity(0.1)).cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(hex: "fbbf24").opacity(0.3), lineWidth: 1))
                        }
                    } else {
                        HStack(spacing: 6) {
                            Image(systemName: "crown.fill").font(.system(size: 10))
                            Text("Premium Member")
                                .font(.system(size: 11, weight: .medium)).tracking(1)
                        }
                        .foregroundColor(Color(hex: "fbbf24"))
                    }
                }
                .padding(.horizontal, 28).padding(.top, 72).padding(.bottom, 32)

                Rectangle().fill(Color(hex: "7c3aed").opacity(0.2))
                    .frame(height: 0.5).padding(.horizontal, 28).padding(.bottom, 20)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(AppTab.allCases, id: \.self) { tab in
                            menuRow(tab: tab)
                        }

                        Rectangle().fill(Color(hex: "7c3aed").opacity(0.2))
                            .frame(height: 0.5).padding(.horizontal, 28).padding(.vertical, 20)

                        extraRow(icon: "gearshape.fill", label: "Settings")
                        extraRow(icon: "questionmark.circle.fill", label: "Help & FAQ")

                        Button(action: {
                            withAnimation { profile.signOut(); showMenu = false }
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.3))
                                Text("Sign Out")
                                    .font(.system(size: 13, weight: .light)).tracking(2)
                                    .foregroundColor(.white.opacity(0.3))
                            }
                            .padding(.horizontal, 28).padding(.vertical, 16)
                        }
                    }
                }
            }
        }
        .frame(width: 290).ignoresSafeArea()
        .shadow(color: .black.opacity(0.5), radius: 30, x: 10, y: 0)
    }

    func menuRow(tab: AppTab) -> some View {
        Button(action: {
            withAnimation(.spring()) { selectedTab = tab; showMenu = false }
        }) {
            HStack(spacing: 16) {
                ZStack {
                    if selectedTab == tab {
                        Circle().fill(Color(hex: "7c3aed").opacity(0.2))
                            .frame(width: 32, height: 32)
                    }
                    Image(systemName: tab.icon).font(.system(size: 14))
                        .foregroundColor(selectedTab == tab
                            ? Color(hex: "c4b5fd") : .white.opacity(0.4))
                }
                .frame(width: 32)

                Text(tab.rawValue)
                    .font(.system(size: 15, weight: selectedTab == tab ? .regular : .light))
                    .tracking(1)
                    .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.55))

                Spacer()

                if selectedTab == tab {
                    Capsule().fill(Color(hex: "7c3aed"))
                        .frame(width: 3, height: 18)
                }
            }
            .padding(.horizontal, 28).padding(.vertical, 13)
            .background(selectedTab == tab
                ? Color(hex: "7c3aed").opacity(0.07) : .clear)
        }
    }

    func extraRow(icon: String, label: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon).font(.system(size: 13))
                .foregroundColor(.white.opacity(0.3)).frame(width: 32)
            Text(label).font(.system(size: 14, weight: .light)).tracking(1)
                .foregroundColor(.white.opacity(0.35))
            Spacer()
        }
        .padding(.horizontal, 28).padding(.vertical, 12)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
