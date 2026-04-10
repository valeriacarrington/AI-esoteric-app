import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedPlan: PlanType = .yearly
    @State private var animateIn = false
    @State private var glowPulse = false
    @State private var showSuccess = false

    enum PlanType: String, CaseIterable {
        case monthly = "Monthly"
        case yearly = "Yearly"
        case lifetime = "Lifetime"
    }

    let plans: [PlanType: PlanInfo] = [
        .monthly: PlanInfo(
            type: .monthly,
            title: "Premium",
            price: "$6.99",
            period: "per month",
            annualEquivalent: "$83.88 / year",
            badge: nil,
            color: "7c3aed",
            features: [
                "✦ Unlimited daily Oracle readings",
                "🌙 Full dream journal & AI interpretation",
                "☽ Mood tracker + cosmic perspective",
                "∞ Complete numerology suite",
                "🃏 Daily Tarot card readings",
                "📅 Weekly & monthly forecasts",
                "💫 Compatibility readings",
                "🔍 Full search & history",
            ]
        ),
        .yearly: PlanInfo(
            type: .yearly,
            title: "Premium",
            price: "$49.99",
            period: "per year",
            annualEquivalent: "Save 40% · Only $4.17/mo",
            badge: "BEST VALUE",
            color: "7c3aed",
            features: [
                "✦ Unlimited daily Oracle readings",
                "🌙 Full dream journal & AI interpretation",
                "☽ Mood tracker + cosmic perspective",
                "∞ Complete numerology suite",
                "🃏 Daily Tarot card readings",
                "📅 Weekly & monthly forecasts",
                "💫 Compatibility readings",
                "🔍 Full search & history",
            ]
        ),
        .lifetime: PlanInfo(
            type: .lifetime,
            title: "Pro Lifetime",
            price: "$149.99",
            period: "one-time payment",
            annualEquivalent: "Pay once · Use forever",
            badge: "PRO",
            color: "fbbf24",
            features: [
                "⚡ Everything in Premium",
                "🌟 Priority AI responses",
                "🔮 Advanced karmic analysis",
                "🪐 Full planetary retrograde suite",
                "📊 Advanced cosmic analytics",
                "🗄️ Data export & backup",
                "👑 Pro badge on profile",
                "🆕 All future features included",
            ]
        )
    ]

    var selectedPlanInfo: PlanInfo {
        plans[selectedPlan] ?? plans[.yearly]!
    }

    var body: some View {
        ZStack {
            // Background
            Color(hex: "060412").ignoresSafeArea()
            RadialGradient(
                colors: [Color(hex: "2d0a5c").opacity(0.6), .clear],
                center: .top, startRadius: 0, endRadius: 500
            ).ignoresSafeArea()
            StarFieldView()

            if showSuccess {
                successView
            } else {
                mainContent
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1)) {
                animateIn = true
            }
            glowPulse = true
        }
    }

    // MARK: - Main Content
    var mainContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // Close button
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.3))
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                }

                // Hero
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "7c3aed").opacity(0.15))
                            .frame(width: 130, height: 130)
                            .blur(radius: glowPulse ? 30 : 18)
                            .animation(
                                .easeInOut(duration: 3).repeatForever(autoreverses: true),
                                value: glowPulse
                            )
                        Text("✦")
                            .font(.system(size: 60))
                            .scaleEffect(animateIn ? 1 : 0.3)
                            .opacity(animateIn ? 1 : 0)
                    }

                    Text("UNLOCK THE COSMOS")
                        .font(.system(size: 26, weight: .ultraLight))
                        .tracking(6)
                        .foregroundColor(.white)
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 20)

                    Text("Access your full cosmic potential")
                        .font(.system(size: 13, weight: .light))
                        .tracking(2)
                        .foregroundColor(Color(hex: "a78bfa").opacity(0.8))
                        .opacity(animateIn ? 1 : 0)
                }
                .padding(.top, 8)
                .padding(.bottom, 32)

                // Plan selector tabs
                HStack(spacing: 0) {
                    ForEach(PlanType.allCases, id: \.self) { plan in
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                selectedPlan = plan
                            }
                        }) {
                            VStack(spacing: 4) {
                                if let badge = plans[plan]?.badge {
                                    Text(badge)
                                        .font(.system(size: 8, weight: .bold))
                                        .tracking(1)
                                        .foregroundColor(
                                            plan == .lifetime
                                            ? Color(hex: "fbbf24")
                                            : Color(hex: "c4b5fd")
                                        )
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(
                                            plan == .lifetime
                                            ? Color(hex: "fbbf24").opacity(0.2)
                                            : Color(hex: "7c3aed").opacity(0.3)
                                        )
                                        .cornerRadius(6)
                                } else {
                                    Text(" ")
                                        .font(.system(size: 8))
                                }
                                Text(plan.rawValue)
                                    .font(.system(size: 13,
                                                  weight: selectedPlan == plan ? .semibold : .light))
                                    .tracking(1)
                                    .foregroundColor(selectedPlan == plan
                                        ? .white : .white.opacity(0.4))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                selectedPlan == plan
                                ? (plan == .lifetime
                                   ? Color(hex: "fbbf24").opacity(0.15)
                                   : Color(hex: "7c3aed").opacity(0.3))
                                : Color.clear
                            )
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(4)
                .background(Color.white.opacity(0.06))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "7c3aed").opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .opacity(animateIn ? 1 : 0)

                // Price card
                PriceCard(info: selectedPlanInfo)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                    .opacity(animateIn ? 1 : 0)

                // Features list
                VStack(alignment: .leading, spacing: 0) {
                    Text("WHAT'S INCLUDED")
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(4)
                        .foregroundColor(Color(hex: "a78bfa").opacity(0.6))
                        .padding(.bottom, 16)

                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(selectedPlanInfo.features.enumerated()),
                                id: \.offset) { i, feature in
                            HStack(spacing: 12) {
                                Text(feature)
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundColor(.white.opacity(0.85))
                                    .lineSpacing(4)
                                Spacer()
                            }
                            .opacity(animateIn ? 1 : 0)
                            .offset(x: animateIn ? 0 : -20)
                            .animation(
                                .spring(response: 0.5).delay(0.3 + Double(i) * 0.05),
                                value: animateIn
                            )
                        }
                    }
                }
                .padding(24)
                .background(Color.white.opacity(0.04))
                .cornerRadius(22)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(
                            selectedPlan == .lifetime
                            ? Color(hex: "fbbf24").opacity(0.25)
                            : Color(hex: "7c3aed").opacity(0.2),
                            lineWidth: 1
                        )
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 28)

                // Comparison table
                ComparisonTable(selectedPlan: selectedPlan)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
                    .opacity(animateIn ? 1 : 0)

                // CTA Button
                Button(action: handlePurchase) {
                    VStack(spacing: 4) {
                        Text(ctaTitle)
                            .font(.system(size: 16, weight: .semibold))
                            .tracking(3)
                            .foregroundColor(.white)
                        Text(selectedPlanInfo.annualEquivalent)
                            .font(.system(size: 11, weight: .light))
                            .tracking(1)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        LinearGradient(
                            colors: selectedPlan == .lifetime
                            ? [Color(hex: "fbbf24"), Color(hex: "d97706")]
                            : [Color(hex: "7c3aed"), Color(hex: "4c1d95")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
                    .shadow(
                        color: selectedPlan == .lifetime
                        ? Color(hex: "fbbf24").opacity(0.4)
                        : Color(hex: "7c3aed").opacity(0.5),
                        radius: 24, y: 10
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .opacity(animateIn ? 1 : 0)

                // Restore + legal
                VStack(spacing: 10) {
                    Button(action: { }) {
                        Text("Restore Purchase")
                            .font(.system(size: 12, weight: .light))
                            .tracking(1)
                            .foregroundColor(Color(hex: "a78bfa").opacity(0.6))
                    }

                    Text("Cancel anytime · Secure payment via App Store")
                        .font(.system(size: 10, weight: .light))
                        .tracking(0.5)
                        .foregroundColor(.white.opacity(0.2))
                        .multilineTextAlignment(.center)

                    HStack(spacing: 16) {
                        Button(action: { }) {
                            Text("Privacy Policy")
                                .font(.system(size: 10, weight: .light))
                                .foregroundColor(.white.opacity(0.2))
                        }
                        Text("·").foregroundColor(.white.opacity(0.15))
                        Button(action: { }) {
                            Text("Terms of Use")
                                .font(.system(size: 10, weight: .light))
                                .foregroundColor(.white.opacity(0.2))
                        }
                    }
                }
                .padding(.bottom, 48)
            }
        }
    }

    // MARK: - Success View
    var successView: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color(hex: "7c3aed").opacity(0.2))
                    .frame(width: 160, height: 160)
                    .blur(radius: 30)
                Circle()
                    .stroke(Color(hex: "7c3aed").opacity(0.4), lineWidth: 1)
                    .frame(width: 120, height: 120)
                Image(systemName: "checkmark")
                    .font(.system(size: 52, weight: .ultraLight))
                    .foregroundColor(Color(hex: "c4b5fd"))
            }

            VStack(spacing: 12) {
                Text("WELCOME TO THE COSMOS")
                    .font(.system(size: 22, weight: .ultraLight))
                    .tracking(4)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text(selectedPlan == .lifetime
                     ? "Your Pro Lifetime access is now active"
                     : "Your Premium subscription is now active")
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(Color(hex: "a78bfa").opacity(0.8))
                    .multilineTextAlignment(.center)

                Text("✦")
                    .font(.system(size: 32))
                    .foregroundColor(Color(hex: "a78bfa"))
            }

            Button(action: { dismiss() }) {
                Text("BEGIN YOUR JOURNEY")
                    .font(.system(size: 14, weight: .semibold))
                    .tracking(3)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(LinearGradient(
                        colors: [Color(hex: "7c3aed"), Color(hex: "4c1d95")],
                        startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(18)
                    .shadow(color: Color(hex: "7c3aed").opacity(0.4), radius: 20, y: 8)
            }
            .padding(.horizontal, 40)

            Spacer()
        }
        .transition(.scale.combined(with: .opacity))
    }

    var ctaTitle: String {
        switch selectedPlan {
        case .monthly: return "START FOR \(selectedPlanInfo.price) / MO"
        case .yearly: return "GET YEARLY · \(selectedPlanInfo.price)"
        case .lifetime: return "GET LIFETIME · \(selectedPlanInfo.price)"
        }
    }

    func handlePurchase() {
        withAnimation(.spring()) {
            store.unlock()
            showSuccess = true
        }
    }
}

// MARK: - Plan Info Model
struct PlanInfo {
    let type: PaywallView.PlanType
    let title: String
    let price: String
    let period: String
    let annualEquivalent: String
    let badge: String?
    let color: String
    let features: [String]
}

// MARK: - Price Card
struct PriceCard: View {
    let info: PlanInfo
    @State private var animate = false

    var isLifetime: Bool { info.type == .lifetime }

    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    if let badge = info.badge {
                        Text(badge)
                            .font(.system(size: 10, weight: .bold)).tracking(2)
                            .foregroundColor(isLifetime
                                ? Color(hex: "fbbf24") : Color(hex: "c4b5fd"))
                            .padding(.horizontal, 10).padding(.vertical, 4)
                            .background(
                                isLifetime
                                ? Color(hex: "fbbf24").opacity(0.15)
                                : Color(hex: "7c3aed").opacity(0.3)
                            )
                            .cornerRadius(8)
                    }
                    Text(info.title.uppercased())
                        .font(.system(size: 13, weight: .semibold)).tracking(3)
                        .foregroundColor(.white)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(info.price)
                        .font(.system(size: 36, weight: .ultraLight))
                        .foregroundColor(isLifetime ? Color(hex: "fbbf24") : .white)
                        .scaleEffect(animate ? 1 : 0.8)
                        .animation(.spring(response: 0.4), value: animate)
                    Text(info.period)
                        .font(.system(size: 11, weight: .light)).tracking(1)
                        .foregroundColor(.white.opacity(0.4))
                }
            }

            Rectangle()
                .fill(Color(hex: info.color).opacity(0.2))
                .frame(height: 0.5)

            HStack {
                Image(systemName: isLifetime ? "crown.fill" : "checkmark.seal.fill")
                    .font(.system(size: 13))
                    .foregroundColor(isLifetime ? Color(hex: "fbbf24") : Color(hex: "a78bfa"))
                Text(info.annualEquivalent)
                    .font(.system(size: 12, weight: isLifetime ? .semibold : .light))
                    .tracking(1)
                    .foregroundColor(isLifetime ? Color(hex: "fbbf24") : Color(hex: "a78bfa"))
                Spacer()
            }
        }
        .padding(22)
        .background(
            LinearGradient(
                colors: isLifetime
                ? [Color(hex: "1c1400"), Color(hex: "2d1a00")]
                : [Color(hex: "1e1b4b"), Color(hex: "0d0720")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(22)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(
                    isLifetime
                    ? Color(hex: "fbbf24").opacity(0.4)
                    : Color(hex: "7c3aed").opacity(0.5),
                    lineWidth: 1.5
                )
        )
        .shadow(
            color: isLifetime
            ? Color(hex: "fbbf24").opacity(0.1)
            : Color(hex: "7c3aed").opacity(0.2),
            radius: 20, y: 8
        )
        .onAppear { animate = true }
    }
}

// MARK: - Comparison Table
struct ComparisonTable: View {
    let selectedPlan: PaywallView.PlanType

    let rows: [(feature: String, free: Bool, premium: Bool, pro: Bool)] = [
        ("Daily Oracle Reading", false, true, true),
        ("Dream Interpretation", false, true, true),
        ("Mood Tracker", true, true, true),
        ("Basic Numerology", true, true, true),
        ("Advanced Numerology", false, true, true),
        ("Tarot of the Day", false, true, true),
        ("Weekly Forecast", false, true, true),
        ("Compatibility Reading", false, true, true),
        ("Karmic Lessons", false, true, true),
        ("Planetary Energy", false, true, true),
        ("Cosmic Journal", true, true, true),
        ("Search & History", false, true, true),
        ("Charts & Analytics", false, true, true),
        ("Priority AI", false, false, true),
        ("Advanced Charts", false, false, true),
        ("Data Export", false, false, true),
        ("All Future Features", false, false, true),
        ("Pro Badge", false, false, true),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("FEATURE")
                    .font(.system(size: 9, weight: .semibold)).tracking(3)
                    .foregroundColor(.white.opacity(0.3))
                Spacer()
                Text("FREE")
                    .font(.system(size: 9, weight: .semibold)).tracking(2)
                    .foregroundColor(.white.opacity(0.3))
                    .frame(width: 50)
                Text("PREM")
                    .font(.system(size: 9, weight: .semibold)).tracking(2)
                    .foregroundColor(Color(hex: "a78bfa").opacity(0.8))
                    .frame(width: 50)
                Text("PRO")
                    .font(.system(size: 9, weight: .semibold)).tracking(2)
                    .foregroundColor(Color(hex: "fbbf24").opacity(0.8))
                    .frame(width: 50)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.06))

            ForEach(Array(rows.enumerated()), id: \.offset) { i, row in
                HStack {
                    Text(row.feature)
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(.white.opacity(0.75))
                    Spacer()

                    // Free
                    Image(systemName: row.free ? "checkmark" : "minus")
                        .font(.system(size: 11, weight: row.free ? .semibold : .light))
                        .foregroundColor(row.free ? Color(hex: "065f46") : .white.opacity(0.2))
                        .frame(width: 50)

                    // Premium
                    Image(systemName: row.premium ? "checkmark" : "minus")
                        .font(.system(size: 11, weight: row.premium ? .semibold : .light))
                        .foregroundColor(row.premium ? Color(hex: "a78bfa") : .white.opacity(0.2))
                        .frame(width: 50)

                    // Pro
                    Image(systemName: row.pro ? "checkmark" : "minus")
                        .font(.system(size: 11, weight: row.pro ? .semibold : .light))
                        .foregroundColor(row.pro ? Color(hex: "fbbf24") : .white.opacity(0.2))
                        .frame(width: 50)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(i % 2 == 0 ? Color.white.opacity(0.02) : Color.clear)
            }
        }
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(hex: "7c3aed").opacity(0.15), lineWidth: 1)
        )
    }
}
