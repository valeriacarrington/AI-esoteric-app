import Foundation
import Combine

struct DreamEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date
     var text: String
    var interpretation: String = ""
    var mood: String = ""
    var symbols: [String] = []
}

struct ReadingEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var text: String
    var zodiac: String
    var mood: String
}

struct AppUser: Codable {
    var name: String
    var email: String
    var birthDate: Date
    var zodiacSign: String
    var element: String
    var planet: String
    var joinDate: Date = Date()
    var readingsCount: Int = 0
    var streakDays: Int = 1
    var lastActiveDate: Date = Date()
}

class UserProfile: ObservableObject {
    @Published var currentUser: AppUser? = nil
    @Published var isLoggedIn: Bool = false
    @Published var todayMood: String = ""
    @Published var todayMoodEmoji: String = ""
    @Published var dreams: [DreamEntry] = []
    @Published var readings: [ReadingEntry] = []
    @Published var birthDate: Date? = nil
    @Published var dailyIntention: String = ""

    init() {
        if let data = UserDefaults.standard.data(forKey: "appUser"),
           let user = try? JSONDecoder().decode(AppUser.self, from: data) {
            self.currentUser = user
            self.birthDate = user.birthDate
            self.isLoggedIn = true
        }
        if let data = UserDefaults.standard.data(forKey: "dreams"),
           let saved = try? JSONDecoder().decode([DreamEntry].self, from: data) {
            self.dreams = saved
        }
        if let data = UserDefaults.standard.data(forKey: "readings"),
           let saved = try? JSONDecoder().decode([ReadingEntry].self, from: data) {
            self.readings = saved
        }
    }

    func signUp(name: String, email: String, birthDate: Date) {
        let sign = Self.zodiac(from: birthDate)
        let elem = Self.element(for: sign)
        let plan = Self.planet(for: sign)
        let user = AppUser(name: name, email: email, birthDate: birthDate,
                           zodiacSign: sign, element: elem, planet: plan)
        self.currentUser = user
        self.birthDate = birthDate
        self.isLoggedIn = true
        save()
    }

    func signIn(email: String) -> Bool {
        if let data = UserDefaults.standard.data(forKey: "appUser"),
           let user = try? JSONDecoder().decode(AppUser.self, from: data),
           user.email.lowercased() == email.lowercased() {
            self.currentUser = user
            self.birthDate = user.birthDate
            self.isLoggedIn = true
            return true
        }
        return false
    }

    func signOut() {
        isLoggedIn = false
        currentUser = nil
        todayMood = ""
        todayMoodEmoji = ""
    }

    func incrementReadings() {
        currentUser?.readingsCount += 1
        save()
    }

    func addReading(_ text: String) {
        let entry = ReadingEntry(date: Date(), text: text,
                                 zodiac: currentUser?.zodiacSign ?? "",
                                 mood: todayMood)
        readings.insert(entry, at: 0)
        if readings.count > 50 { readings = Array(readings.prefix(50)) }
        currentUser?.readingsCount += 1
        save()
        if let data = try? JSONEncoder().encode(readings) {
            UserDefaults.standard.set(data, forKey: "readings")
        }
    }

    func addDream(_ text: String, interpretation: String, symbols: [String]) {
        let entry = DreamEntry(date: Date(), text: text,
                               interpretation: interpretation,
                               mood: todayMood, symbols: symbols)
        dreams.insert(entry, at: 0)
        if dreams.count > 100 { dreams = Array(dreams.prefix(100)) }
        save()
        if let data = try? JSONEncoder().encode(dreams) {
            UserDefaults.standard.set(data, forKey: "dreams")
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(currentUser) {
            UserDefaults.standard.set(data, forKey: "appUser")
        }
    }

    var lifePathNumber: Int {
        guard let dob = currentUser?.birthDate else { return 1 }
        let cal = Calendar.current
        let d = cal.component(.day, from: dob)
        let m = cal.component(.month, from: dob)
        let y = cal.component(.year, from: dob)
        var sum = digitSum(d) + digitSum(m) + digitSum(y)
        while sum > 9 && sum != 11 && sum != 22 { sum = digitSum(sum) }
        return sum
    }

    private func digitSum(_ n: Int) -> Int {
        String(n).compactMap { $0.wholeNumberValue }.reduce(0, +)
    }

    static func zodiac(from date: Date) -> String {
        let cal = Calendar.current
        let month = cal.component(.month, from: date)
        let day = cal.component(.day, from: date)
        switch (month, day) {
        case (3, 21...), (4, ...19): return "Aries ♈"
        case (4, 20...), (5, ...20): return "Taurus ♉"
        case (5, 21...), (6, ...20): return "Gemini ♊"
        case (6, 21...), (7, ...22): return "Cancer ♋"
        case (7, 23...), (8, ...22): return "Leo ♌"
        case (8, 23...), (9, ...22): return "Virgo ♍"
        case (9, 23...), (10, ...22): return "Libra ♎"
        case (10, 23...), (11, ...21): return "Scorpio ♏"
        case (11, 22...), (12, ...21): return "Sagittarius ♐"
        case (12, 22...), (1, ...19): return "Capricorn ♑"
        case (1, 20...), (2, ...18): return "Aquarius ♒"
        default: return "Pisces ♓"
        }
    }

    static func element(for sign: String) -> String {
        let fire = ["Aries", "Leo", "Sagittarius"]
        let earth = ["Taurus", "Virgo", "Capricorn"]
        let air = ["Gemini", "Libra", "Aquarius"]
        let base = sign.components(separatedBy: " ").first ?? ""
        if fire.contains(base) { return "🔥 Fire" }
        if earth.contains(base) { return "🌿 Earth" }
        if air.contains(base) { return "💨 Air" }
        return "🌊 Water"
    }

    static func planet(for sign: String) -> String {
        let map = ["Aries": "♂ Mars", "Taurus": "♀ Venus", "Gemini": "☿ Mercury",
                   "Cancer": "☽ Moon", "Leo": "☀ Sun", "Virgo": "☿ Mercury",
                   "Libra": "♀ Venus", "Scorpio": "♇ Pluto", "Sagittarius": "♃ Jupiter",
                   "Capricorn": "♄ Saturn", "Aquarius": "♅ Uranus", "Pisces": "♆ Neptune"]
        let base = sign.components(separatedBy: " ").first ?? ""
        return map[base] ?? "✦ Unknown"
    }
}

// MARK: - App Store (In-App Purchase simulation)
class AppStore: ObservableObject {
    @Published var isPremium: Bool = false

    func unlock() {
        isPremium = true
        UserDefaults.standard.set(true, forKey: "isPremium")
    }

    init() {
        isPremium = UserDefaults.standard.bool(forKey: "isPremium")
    }
}
