import SwiftUI

struct DreamView: View {
    @EnvironmentObject var profile: UserProfile
    @State private var dreamText = ""
    @State private var interpretation = ""
    @State private var symbols: [String] = []
    @State private var isLoading = false
    @State private var showResult = false
    @State private var selectedDream: DreamEntry? = nil
    @State private var showDetail = false
    @FocusState private var editorFocused: Bool

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("🌙")
                        .font(.system(size: 44))
                    Text("DREAM JOURNAL")
                        .font(.system(size: 12, weight: .ultraLight))
                        .tracking(6)
                        .foregroundColor(Color.white.opacity(0.4))
                    Text("Decode your night visions")
                        .font(.system(size: 22, weight: .thin))
                        .tracking(1)
                        .foregroundColor(.white)
                }
                .padding(.top, 32)
                .padding(.bottom, 28)

                // Input
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color(hex: "7c3aed"))
                            .frame(width: 6, height: 6)
                        Text("RECORD YOUR DREAM")
                            .font(.system(size: 10, weight: .medium))
                            .tracking(3)
                            .foregroundColor(Color(hex: "a78bfa"))
                    }
                    .padding(.leading, 4)

                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.white.opacity(editorFocused ? 0.07 : 0.04))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(
                                        editorFocused
                                        ? Color(hex: "7c3aed").opacity(0.5)
                                        : Color(hex: "7c3aed").opacity(0.15),
                                        lineWidth: 1
                                    )
                            )

                        if dreamText.isEmpty {
                            Text("I was standing at the edge of a dark forest when suddenly...")
                                .font(.system(size: 14, weight: .light))
                                .foregroundColor(Color.white.opacity(0.2))
                                .padding(.horizontal, 18)
                                .padding(.top, 16)
                                .allowsHitTesting(false)
                        }

                        TextEditor(text: $dreamText)
                            .focused($editorFocused)
                            .font(.system(size: 15, weight: .light))
                            .foregroundColor(.white)
                            .scrollContentBackground(.hidden)
                            .tint(Color(hex: "a78bfa"))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                    }
                    .frame(minHeight: 150)
                    .animation(.easeInOut(duration: 0.2), value: editorFocused)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

                // Interpret button
                Button(action: interpretDream) {
                    ZStack {
                        if isLoading {
                            HStack(spacing: 10) {
                                ProgressView().tint(.white).scaleEffect(0.8)
                                Text("Weaving symbols...")
                                    .font(.system(size: 13, weight: .light))
                                    .tracking(2)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        } else {
                            HStack(spacing: 10) {
                                Text("🌙")
                                    .font(.system(size: 15))
                                Text("INTERPRET THIS DREAM")
                                    .font(.system(size: 12, weight: .semibold))
                                    .tracking(3)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(
                        dreamText.isEmpty
                        ? AnyShapeStyle(Color.white.opacity(0.06))
                        : AnyShapeStyle(LinearGradient(
                            colors: [Color(hex: "1e3a5f"), Color(hex: "1e1b4b")],
                            startPoint: .leading, endPoint: .trailing
                        ))
                    )
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "7c3aed").opacity(dreamText.isEmpty ? 0.1 : 0.3), lineWidth: 1)
                    )
                }
                .disabled(dreamText.isEmpty || isLoading)
                .padding(.horizontal, 24)
                .padding(.bottom, 28)

                // Interpretation result
                if showResult && !interpretation.isEmpty {
                    VStack(spacing: 16) {
                        HStack(spacing: 6) {
                            Text("✦")
                                .font(.system(size: 10))
                                .foregroundColor(Color(hex: "a78bfa"))
                            Text("INTERPRETATION")
                                .font(.system(size: 10, weight: .medium))
                                .tracking(4)
                                .foregroundColor(Color(hex: "a78bfa"))
                            Text("✦")
                                .font(.system(size: 10))
                                .foregroundColor(Color(hex: "a78bfa"))
                        }

                        Text(interpretation)
                            .font(.system(size: 15, weight: .light))
                            .foregroundColor(Color.white.opacity(0.82))
                            .multilineTextAlignment(.center)
                            .lineSpacing(8)

                        if !symbols.isEmpty {
                            VStack(spacing: 10) {
                                Text("SYMBOLS DETECTED")
                                    .font(.system(size: 9, weight: .medium))
                                    .tracking(4)
                                    .foregroundColor(Color.white.opacity(0.3))

                                FlowLayout(spacing: 8) {
                                    ForEach(symbols, id: \.self) { symbol in
                                        Text(symbol)
                                            .font(.system(size: 11, weight: .light))
                                            .tracking(0.5)
                                            .foregroundColor(Color(hex: "c4b5fd"))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color(hex: "7c3aed").opacity(0.15))
                                            .cornerRadius(20)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(Color(hex: "7c3aed").opacity(0.3), lineWidth: 1)
                                            )
                                    }
                                }
                            }
                        }
                    }
                    .padding(24)
                    .background(Color.white.opacity(0.04))
                    .cornerRadius(22)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(Color(hex: "7c3aed").opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // Dream archive
                if !profile.dreams.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "books.vertical.fill")
                                .font(.system(size: 11))
                                .foregroundColor(Color(hex: "a78bfa").opacity(0.5))
                            Text("DREAM ARCHIVE")
                                .font(.system(size: 11, weight: .medium))
                                .tracking(3)
                                .foregroundColor(Color(hex: "a78bfa").opacity(0.5))
                            Spacer()
                            Text("\(profile.dreams.count)")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Color(hex: "7c3aed"))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color(hex: "7c3aed").opacity(0.15))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal, 24)

                        ForEach(profile.dreams.prefix(10)) { entry in
                            DreamCard(entry: entry)
                                .padding(.horizontal, 24)
                        }
                    }
                }

                Spacer(minLength: 40)
            }
        }
    }

    func interpretDream() {
        editorFocused = false
        isLoading = true
        showResult = false
        Task {
            let result = await AIService.interpretDream(dreamText, mood: profile.todayMood)
            await MainActor.run {
                interpretation = result.interpretation
                symbols = result.symbols
                isLoading = false
                profile.addDream(dreamText, interpretation: result.interpretation, symbols: result.symbols)
                dreamText = ""
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    showResult = true
                }
            }
        }
    }
}

struct DreamCard: View {
    let entry: DreamEntry
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 10, weight: .medium))
                    .tracking(1)
                    .foregroundColor(Color(hex: "a78bfa").opacity(0.5))
                Spacer()
                if !entry.mood.isEmpty {
                    Text(entry.mood)
                        .font(.system(size: 10, weight: .light))
                        .foregroundColor(Color.white.opacity(0.3))
                }
                Image(systemName: expanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 10))
                    .foregroundColor(Color.white.opacity(0.2))
            }

            Text(entry.text)
                .font(.system(size: 13, weight: .light))
                .foregroundColor(Color.white.opacity(0.6))
                .lineLimit(expanded ? nil : 2)
                .lineSpacing(4)

            if expanded && !entry.interpretation.isEmpty {
                Rectangle()
                    .fill(Color(hex: "7c3aed").opacity(0.2))
                    .frame(height: 0.5)

                Text(entry.interpretation)
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(Color(hex: "c4b5fd").opacity(0.8))
                    .lineSpacing(5)
                    .italic()

                if !entry.symbols.isEmpty {
                    FlowLayout(spacing: 6) {
                        ForEach(entry.symbols, id: \.self) { sym in
                            Text(sym)
                                .font(.system(size: 9, weight: .light))
                                .foregroundColor(Color(hex: "a78bfa").opacity(0.7))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(hex: "7c3aed").opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.03))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "7c3aed").opacity(0.1), lineWidth: 1)
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                expanded.toggle()
            }
        }
    }
}

// Simple flow layout for symbol tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.map { $0.map { $0.size.height }.max() ?? 0 }.reduce(0) { $0 + $1 + spacing }
        return CGSize(width: proposal.width ?? 0, height: max(0, height - spacing))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            let rowHeight = row.map { $0.size.height }.max() ?? 0
            for item in row {
                item.view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(item.size))
                x += item.size.width + spacing
            }
            y += rowHeight + spacing
        }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[(view: LayoutSubview, size: CGSize)]] {
        var rows: [[(view: LayoutSubview, size: CGSize)]] = [[]]
        var currentX: CGFloat = 0
        let maxWidth = proposal.width ?? 0
        for subview in subviews {
            let size = subview.sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))
            if currentX + size.width > maxWidth && !rows[rows.count - 1].isEmpty {
                rows.append([])
                currentX = 0
            }
            rows[rows.count - 1].append((subview, size))
            currentX += size.width + spacing
        }
        return rows
    }
}
