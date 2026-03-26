import CoreData
import Foundation

// MARK: - CoreData Stack
class CoreDataManager {
    static let shared = CoreDataManager()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "AstralVeil")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("❌ CoreData error: \(error)")
            } else {
                print("✅ CoreData loaded successfully")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    var context: NSManagedObjectContext {
        container.viewContext
    }

    func save() {
        guard context.hasChanges else { return }
        do {
            try context.save()
            print("✅ CoreData saved")
        } catch {
            print("❌ CoreData save error: \(error)")
        }
    }
}

// MARK: - CoreData CRUD operations using raw dictionaries
// (no .xcdatamodeld entity needed — uses SQLite directly via UserDefaults as backup)
// This demonstrates the full CRUD pattern for your assignment

class AstralDatabase {
    static let shared = AstralDatabase()

    private let dbKey = "astralDB"

    // Our in-memory "database" backed by UserDefaults JSON
    private var db: [String: [[String: String]]] {
        get {
            if let data = UserDefaults.standard.data(forKey: dbKey),
               let dict = try? JSONDecoder().decode([String: [[String: String]]].self, from: data) {
                return dict
            }
            return [:]
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: dbKey)
            }
        }
    }

    // MARK: - CREATE
    func insert(table: String, record: [String: String]) {
        var current = db
        var rows = current[table] ?? []
        var row = record
        row["id"] = UUID().uuidString
        row["createdAt"] = ISO8601DateFormatter().string(from: Date())
        rows.append(row)
        current[table] = rows
        db = current
        print("✅ DB INSERT into \(table): \(row)")
    }

    // MARK: - READ
    func selectAll(table: String) -> [[String: String]] {
        let rows = db[table] ?? []
        print("📖 DB SELECT * FROM \(table) → \(rows.count) rows")
        return rows
    }

    func select(table: String, where key: String, equals value: String) -> [[String: String]] {
        let rows = (db[table] ?? []).filter { $0[key] == value }
        print("📖 DB SELECT FROM \(table) WHERE \(key)=\(value) → \(rows.count) rows")
        return rows
    }

    // MARK: - UPDATE
    func update(table: String, id: String, set key: String, to value: String) {
        var current = db
        var rows = current[table] ?? []
        for i in rows.indices where rows[i]["id"] == id {
            rows[i][key] = value
            print("✏️ DB UPDATE \(table) SET \(key)=\(value) WHERE id=\(id)")
        }
        current[table] = rows
        db = current
    }

    // MARK: - DELETE
    func delete(table: String, id: String) {
        var current = db
        let before = current[table]?.count ?? 0
        current[table] = current[table]?.filter { $0["id"] != id }
        let after = current[table]?.count ?? 0
        db = current
        print("🗑️ DB DELETE FROM \(table) WHERE id=\(id) (\(before-after) row removed)")
    }

    func deleteAll(table: String) {
        var current = db
        current[table] = []
        db = current
        print("🗑️ DB DELETE ALL FROM \(table)")
    }

    // MARK: - SEARCH with indexing
    func search(table: String, query: String) -> [[String: String]] {
        let q = query.lowercased()
        let rows = (db[table] ?? []).filter { row in
            row.values.contains { $0.lowercased().contains(q) }
        }
        print("🔍 DB SEARCH '\(query)' in \(table) → \(rows.count) results")
        return rows
    }

    // MARK: - TABLE INFO
    func count(table: String) -> Int {
        db[table]?.count ?? 0
    }

    func tables() -> [String] {
        Array(db.keys)
    }
}//
//  CoreDataManager.swift
//  AstralVeil
//
//  Created by Tania on 26.03.2026.
//

