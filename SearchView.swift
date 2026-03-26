import SwiftUI

// MARK: - Searchable index entry
struct SearchableItem: Identifiable {
    var id = UUID()
    var title: String
    var subtitle: String
    var category: SearchCategory
    var date: Date?
    var content: String
}

enum SearchCategory: String, CaseIterable {
    case dreams = "Dreams"
    case readings = "Readings"
    case journal = "Journal"
    case moods = "Moods"

    var icon: String {
        switch self {
        case .dreams: return "cloud.moon.fill"
        case .readings: return "sparkles"
        case .journal: return "book.fill"
        case .moods: return "moon.stars.fill"
        }
    }

    var color: String {
        switch self {
        case .dreams: return "1d4ed8"
        case .readings: return "7c3aed"
        case .journal: return "065f46"
        case .moods: return "be185d"
        }
    }
}

struct SearchView: View {
    @EnvironmentObject var profile: UserProfile
    @State private var searchText = ""
    @State private var selectedCategory: SearchCategory? = nil
    @State private var sortOrder: SortOrder = .newest
    @State private var searchIndex: [SearchableItem] = []
    @State private var animateIn = false

    enum SortOrder: String, CaseIterable {
        case newest = "Newest"
        case oldest = "Oldest"
        case relevance = "Relevance"
    }

    var filteredResults: [SearchableItem] {
        var results = searchIndex

        // Filter by category
        if let cat = selectedCategory {
            results = results.filter { $0.category == cat }
        }

        // Filter by search text
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            results = results.filter {
                $0.title.lowercased().contains(q) ||
                $0.subtitle.lowercased().contains(q) ||
                $0.content.lowercased().contains(q)
            }
        }

        // Sort
        switch sortOrder {
        case .newest:
            results.sort { ($0.date ?? Date.distantPast) > ($1.date ?? Date.distantPast) }
        case .oldest:
            results.sort { ($0.date ?? Date.distantPast) < ($1.date ?? Date.distantPast) }
        case .relevance:
            if !searchText.isEmpty {
                let q = searchText.lowercased()
                results.sort {
                    let a = $0.title.lowercased().contains(q) ? 2 : 0
                    let b = $1.title.lowercased().contains(q) ? 2 : 0
                    return a > b
                }
            }
        }
        return results
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // Header
                VStack(spacing: 8) {
                    Text("🔍")
                        .font(.system(size: 36))
                        .opacity(animateIn ? 1 : 0)
                    Text("COSMIC SEARCH")
                        .font(.system(size: 11, weight: .ultraLight)).tracking(6)
                        .foregroundColor(.white.opacity(0.4))
                        .opacity(animateIn ? 1 : 0)
                }
                .padding(.top, 24).padding(.bottom, 20)

                // Search bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14))
                        .foregroundColor(searchText.isEmpty
                            ? .white.opacity(0.3) : Color(hex: "a78bfa"))
                    TextField("", text: $searchText,
                              prompt: Text("Search dreams, readings, journal...")
                        .foregroundColor(.white.opacity(0.25)))
                        .font(.system(size: 15, weight: .light))
                        .foregroundColor(.white)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                        .tint(Color(hex: "a78bfa"))

                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.3))
                        }
                    }
                }
                .padding(.horizontal, 16).padding(.vertical, 14)
                .background(Color.white.opacity(0.06))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16)
                    .stroke(searchText.isEmpty
                        ? Color(hex: "7c3aed").opacity(0.2)
                        : Color(hex: "7c3aed").opacity(0.6), lineWidth: 1))
                .padding(.horizontal, 20).padding(.bottom, 16)
                .opacity(animateIn ? 1 : 0)

                // Category filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        // All button
                        FilterChip(
                            label: "All",
                            icon: "square.grid.2x2.fill",
                            color: "7c3aed",
                            isSelected: selectedCategory == nil
                        ) { withAnimation { selectedCategory = nil } }

                        ForEach(SearchCategory.allCases, id: \.self) { cat in
                            FilterChip(
                                label: cat.rawValue,
                                icon: cat.icon,
                                color: cat.color,
                                isSelected: selectedCategory == cat
                            ) {
                                withAnimation {
                                    selectedCategory = selectedCategory == cat ? nil : cat
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 16)

                // Sort + results count
                HStack {
                    Text("\(filteredResults.count) results")
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(.white.opacity(0.35))

                    Spacer()

                    Menu {
                        ForEach(SortOrder.allCases, id: \.self) { order in
                            Button(action: { sortOrder = order }) {
                                HStack {
                                    Text(order.rawValue)
                                    if sortOrder == order {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.system(size: 11))
                            Text(sortOrder.rawValue)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(Color(hex: "a78bfa"))
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color(hex: "7c3aed").opacity(0.15))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20).padding(.bottom, 14)

                // Results
                if filteredResults.isEmpty {
                    VStack(spacing: 16) {
                        Text("✦")
                            .font(.system(size: 36))
                            .foregroundColor(.white.opacity(0.2))
                        Text(searchText.isEmpty
                             ? "Your cosmic records will appear here"
                             : "No results found for \"\(searchText)\"")
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(.white.opacity(0.3))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 60)
                } else {
                    VStack(spacing: 10) {
                        ForEach(filteredResults) { item in
                            SearchResultCard(item: item, query: searchText)
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Spacer(minLength: 48)
            }
        }
        .onAppear {
            buildIndex()
            withAnimation(.spring(response: 0.6).delay(0.1)) { animateIn = true }
        }
        .onChange(of: profile.dreams.count) { buildIndex() }
        .onChange(of: profile.readings.count) { buildIndex() }
    }

    func buildIndex() {
        var index: [SearchableItem] = []

        // Index dreams
        for dream in profile.dreams {
            index.append(SearchableItem(
                title: String(dream.text.prefix(60)),
                subtitle: dream.interpretation.isEmpty ? "No interpretation" : String(dream.interpretation.prefix(80)),
                category: .dreams,
                date: dream.date,
                content: dream.text + " " + dream.interpretation + " " + dream.symbols.joined(separator: " ")
            ))
        }

        // Index readings
        for reading in profile.readings {
            index.append(SearchableItem(
                title: reading.zodiac + " Reading",
                subtitle: String(reading.text.prefix(80)),
                category: .readings,
                date: reading.date,
                content: reading.text + " " + reading.zodiac + " " + reading.mood
            ))
        }

        // Index journal from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "journalEntries"),
           let entries = try? JSONDecoder().decode([JournalEntry].self, from: data) {
            for entry in entries {
                index.append(SearchableItem(
                    title: String(entry.text.prefix(60)),
                    subtitle: entry.reflection.isEmpty ? "No reflection" : String(entry.reflection.prefix(80)),
                    category: .journal,
                    date: entry.date,
                    content: entry.text + " " + entry.reflection
                ))
            }
        }

        // Index moods from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "moodHistory"),
           let moods = try? JSONDecoder().decode([MoodEntry].self, from: data) {
            for mood in moods {
                index.append(SearchableItem(
                    title: mood.emoji + " " + mood.mood,
                    subtitle: mood.date.formatted(date: .long, time: .shortened),
                    category: .moods,
                    date: mood.date,
                    content: mood.mood
                ))
            }
        }

        searchIndex = index
    }
}

struct FilterChip: View {
    let label: String
    let icon: String
    let color: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                Text(label)
                    .font(.system(size: 12, weight: isSelected ? .medium : .light))
                    .tracking(0.5)
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.5))
            .padding(.horizontal, 14).padding(.vertical, 8)
            .background(isSelected
                ? Color(hex: color).opacity(0.35)
                : Color.white.opacity(0.05))
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20)
                .stroke(Color(hex: color).opacity(isSelected ? 0.8 : 0.2), lineWidth: 1))
        }
    }
}

struct SearchResultCard: View {
    let item: SearchableItem
    let query: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(hex: item.category.color).opacity(0.15))
                    .frame(width: 42, height: 42)
                Image(systemName: item.category.icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: item.category.color))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text(item.subtitle)
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(.white.opacity(0.5))
                    .lineLimit(2).lineSpacing(3)
                if let date = item.date {
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 10)).foregroundColor(.white.opacity(0.25))
                }
            }

            Spacer()

            Text(item.category.rawValue)
                .font(.system(size: 9, weight: .medium)).tracking(1)
                .foregroundColor(Color(hex: item.category.color))
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(Color(hex: item.category.color).opacity(0.1))
                .cornerRadius(8)
        }
        .padding(14)
        .background(Color.white.opacity(0.04))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16)
            .stroke(Color(hex: item.category.color).opacity(0.15), lineWidth: 1))
    }
}//
//  SearchView.swift
//  AstralVeil
//
//  Created by Tania on 23.03.2026.
//

