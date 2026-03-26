import Foundation

// MARK: - Real File System CRUD for AstralVeil
// This demonstrates file read, write, update, delete
// Files are stored in the app's Documents directory as JSON

class AstralFileManager {

    static let shared = AstralFileManager()
    private let fileManager = FileManager.default

    private var documentsURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    // MARK: - Generic file operations

    /// WRITE — saves any Codable object to a JSON file
    func write<T: Codable>(_ object: T, to filename: String) throws {
        let url = documentsURL.appendingPathComponent(filename)
        let data = try JSONEncoder().encode(object)
        try data.write(to: url, options: .atomic)
        print("✅ Written to file: \(filename)")
    }

    /// READ — reads and decodes a JSON file
    func read<T: Codable>(_ type: T.Type, from filename: String) throws -> T {
        let url = documentsURL.appendingPathComponent(filename)
        let data = try Data(contentsOf: url)
        let object = try JSONDecoder().decode(type, from: data)
        print("📖 Read from file: \(filename)")
        return object
    }

    /// DELETE — removes a file
    func delete(filename: String) throws {
        let url = documentsURL.appendingPathComponent(filename)
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
            print("🗑️ Deleted file: \(filename)")
        }
    }

    /// LIST — lists all files in Documents
    func listFiles() -> [String] {
        let files = (try? fileManager.contentsOfDirectory(atPath: documentsURL.path)) ?? []
        print("📁 Files in Documents: \(files)")
        return files
    }

    /// FILE EXISTS check
    func fileExists(_ filename: String) -> Bool {
        let url = documentsURL.appendingPathComponent(filename)
        return fileManager.fileExists(atPath: url.path)
    }

    // MARK: - AstralVeil specific operations

    func saveDreams(_ dreams: [DreamEntry]) {
        try? write(dreams, to: "dreams.json")
    }

    func loadDreams() -> [DreamEntry] {
        (try? read([DreamEntry].self, from: "dreams.json")) ?? []
    }

    func saveReadings(_ readings: [ReadingEntry]) {
        try? write(readings, to: "readings.json")
    }

    func loadReadings() -> [ReadingEntry] {
        (try? read([ReadingEntry].self, from: "readings.json")) ?? []
    }

    func saveJournal(_ entries: [JournalEntry]) {
        try? write(entries, to: "journal.json")
    }

    func loadJournal() -> [JournalEntry] {
        (try? read([JournalEntry].self, from: "journal.json")) ?? []
    }

    func saveMoods(_ moods: [MoodEntry]) {
        try? write(moods, to: "moods.json")
    }

    func loadMoods() -> [MoodEntry] {
        (try? read([MoodEntry].self, from: "moods.json")) ?? []
    }

    func saveUser(_ user: AppUser) {
        try? write(user, to: "user.json")
    }

    func loadUser() -> AppUser? {
        try? read(AppUser.self, from: "user.json")
    }

    func deleteUser() {
        try? delete(filename: "user.json")
    }

    func deleteAllData() {
        try? delete(filename: "dreams.json")
        try? delete(filename: "readings.json")
        try? delete(filename: "journal.json")
        try? delete(filename: "moods.json")
        print("🗑️ All AstralVeil data files deleted")
    }
}
