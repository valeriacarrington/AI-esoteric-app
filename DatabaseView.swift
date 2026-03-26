import SwiftUI

struct DatabaseView: View {
    @EnvironmentObject var profile: UserProfile
    @State private var selectedTable = "dreams"
    @State private var records: [[String: String]] = []
    @State private var searchQuery = ""
    @State private var newKey = ""
    @State private var newValue = ""
    @State private var statusMessage = ""
    @State private var showAddForm = false
    @State private var filesList: [String] = []
    @State private var showFiles = false

    let tables = ["dreams", "readings", "moods", "journal", "users"]
    let db = AstralDatabase.shared
    let fm = AstralFileManager.shared

    var filteredRecords: [[String: String]] {
        if searchQuery.isEmpty { return records }
        return records.filter { row in
            row.values.contains { $0.lowercased().contains(searchQuery.lowercased()) }
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // Header
                VStack(spacing: 8) {
                    Text("🗄️").font(.system(size: 36))
                    Text("DATA MANAGER")
                        .font(.system(size: 11, weight: .ultraLight)).tracking(6)
                        .foregroundColor(.white.opacity(0.4))
                    Text("Database & Files")
                        .font(.system(size: 22, weight: .thin)).foregroundColor(.white)
                }
                .padding(.top, 24).padding(.bottom, 24)

                // Status message
                if !statusMessage.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: "065f46"))
                        Text(statusMessage)
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(12)
                    .background(Color(hex: "065f46").opacity(0.15))
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }

                // ── DATABASE SECTION ──
                VStack(alignment: .leading, spacing: 14) {
                    SectionHeader(icon: "cylinder.fill", title: "DATABASE (CRUD)")
                        .padding(.horizontal, 20)

                    // Table selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(tables, id: \.self) { table in
                                Button(action: {
                                    selectedTable = table
                                    loadRecords()
                                }) {
                                    VStack(spacing: 3) {
                                        Text(table.uppercased())
                                            .font(.system(size: 10, weight: .medium)).tracking(1)
                                            .foregroundColor(selectedTable == table
                                                ? .white : .white.opacity(0.4))
                                        Text("\(db.count(table: table))")
                                            .font(.system(size: 14, weight: .ultraLight))
                                            .foregroundColor(selectedTable == table
                                                ? Color(hex: "a78bfa") : .white.opacity(0.3))
                                    }
                                    .padding(.horizontal, 16).padding(.vertical, 10)
                                    .background(selectedTable == table
                                        ? Color(hex: "7c3aed").opacity(0.4)
                                        : Color.white.opacity(0.05))
                                    .cornerRadius(12)
                                    .overlay(RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(hex: "7c3aed").opacity(
                                            selectedTable == table ? 0.8 : 0.15), lineWidth: 1))
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // Search within DB
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.3))
                        TextField("", text: $searchQuery,
                                  prompt: Text("Search in \(selectedTable)...")
                            .foregroundColor(.white.opacity(0.25)))
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(.white)
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                            .tint(Color(hex: "a78bfa"))
                            .onChange(of: searchQuery) { _ in
                                if !searchQuery.isEmpty {
                                    records = db.search(table: selectedTable, query: searchQuery)
                                } else {
                                    loadRecords()
                                }
                            }
                        if !searchQuery.isEmpty {
                            Button(action: { searchQuery = ""; loadRecords() }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white.opacity(0.3))
                            }
                        }
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.06)).cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(hex: "7c3aed").opacity(0.2), lineWidth: 1))
                    .padding(.horizontal, 20)

                    // CRUD action buttons
                    HStack(spacing: 10) {
                        // CREATE
                        Button(action: { withAnimation { showAddForm.toggle() } }) {
                            Label("INSERT", systemImage: "plus.circle.fill")
                                .font(.system(size: 11, weight: .semibold)).tracking(1)
                                .foregroundColor(.white)
                                .padding(.horizontal, 14).padding(.vertical, 9)
                                .background(Color(hex: "065f46").opacity(0.5)).cornerRadius(10)
                        }

                        // READ
                        Button(action: { loadRecords(); status("READ: \(records.count) records loaded") }) {
                            Label("SELECT", systemImage: "arrow.down.circle.fill")
                                .font(.system(size: 11, weight: .semibold)).tracking(1)
                                .foregroundColor(.white)
                                .padding(.horizontal, 14).padding(.vertical, 9)
                                .background(Color(hex: "1d4ed8").opacity(0.5)).cornerRadius(10)
                        }

                        // DELETE ALL
                        Button(action: {
                            db.deleteAll(table: selectedTable)
                            loadRecords()
                            status("DELETE ALL: \(selectedTable) cleared")
                        }) {
                            Label("DELETE ALL", systemImage: "trash.fill")
                                .font(.system(size: 11, weight: .semibold)).tracking(1)
                                .foregroundColor(.white)
                                .padding(.horizontal, 14).padding(.vertical, 9)
                                .background(Color(hex: "b45309").opacity(0.5)).cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 20)

                    // Add form
                    if showAddForm {
                        VStack(spacing: 10) {
                            Text("INSERT NEW RECORD INTO \(selectedTable.uppercased())")
                                .font(.system(size: 10, weight: .medium)).tracking(2)
                                .foregroundColor(Color(hex: "a78bfa"))

                            HStack(spacing: 10) {
                                TextField("", text: $newKey,
                                          prompt: Text("Field name")
                                    .foregroundColor(.white.opacity(0.3)))
                                    .font(.system(size: 13)).foregroundColor(.white)
                                    .padding(10).background(Color.white.opacity(0.06))
                                    .cornerRadius(10).autocapitalization(.none)
                                    .autocorrectionDisabled()

                                TextField("", text: $newValue,
                                          prompt: Text("Value")
                                    .foregroundColor(.white.opacity(0.3)))
                                    .font(.system(size: 13)).foregroundColor(.white)
                                    .padding(10).background(Color.white.opacity(0.06))
                                    .cornerRadius(10).autocapitalization(.none)
                                    .autocorrectionDisabled()
                            }

                            Button(action: insertRecord) {
                                Text("INSERT RECORD")
                                    .font(.system(size: 12, weight: .semibold)).tracking(2)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity).padding(.vertical, 12)
                                    .background(LinearGradient(
                                        colors: [Color(hex: "7c3aed"), Color(hex: "4c1d95")],
                                        startPoint: .leading, endPoint: .trailing))
                                    .cornerRadius(12)
                            }
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.04)).cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(hex: "7c3aed").opacity(0.3), lineWidth: 1))
                        .padding(.horizontal, 20)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // Records list
                    if filteredRecords.isEmpty {
                        VStack(spacing: 10) {
                            Text("📭").font(.system(size: 28))
                            Text("No records in \(selectedTable)")
                                .font(.system(size: 13, weight: .light))
                                .foregroundColor(.white.opacity(0.3))
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 32)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(Array(filteredRecords.enumerated()), id: \.offset) { i, record in
                                DBRecordCard(
                                    record: record,
                                    table: selectedTable,
                                    onDelete: {
                                        if let id = record["id"] {
                                            db.delete(table: selectedTable, id: id)
                                            loadRecords()
                                            status("DELETED record id: \(id.prefix(8))...")
                                        }
                                    },
                                    onUpdate: {
                                        if let id = record["id"] {
                                            db.update(table: selectedTable, id: id,
                                                      set: "updatedAt",
                                                      to: ISO8601DateFormatter().string(from: Date()))
                                            loadRecords()
                                            status("UPDATED record id: \(id.prefix(8))...")
                                        }
                                    }
                                )
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                }
                .padding(.bottom, 24)

                // ── FILE SYSTEM SECTION ──
                VStack(alignment: .leading, spacing: 14) {
                    SectionHeader(icon: "doc.fill", title: "FILE SYSTEM (READ/WRITE/DELETE)")
                        .padding(.horizontal, 20)

                    // File action buttons
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {

                        FileActionButton(icon: "arrow.down.doc.fill", label: "EXPORT ALL",
                                         color: "065f46") {
                            exportAllToFiles()
                        }

                        FileActionButton(icon: "arrow.up.doc.fill", label: "IMPORT FILES",
                                         color: "1d4ed8") {
                            importFromFiles()
                        }

                        FileActionButton(icon: "doc.text.fill", label: "LIST FILES",
                                         color: "7c3aed") {
                            filesList = fm.listFiles()
                            showFiles = true
                            status("Found \(filesList.count) files in Documents")
                        }

                        FileActionButton(icon: "trash.fill", label: "DELETE FILES",
                                         color: "b45309") {
                            fm.deleteAllData()
                            filesList = fm.listFiles()
                            status("All data files deleted from filesystem")
                        }
                    }
                    .padding(.horizontal, 20)

                    // Files list
                    if showFiles {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("FILES IN DOCUMENTS DIRECTORY")
                                .font(.system(size: 10, weight: .medium)).tracking(3)
                                .foregroundColor(Color(hex: "a78bfa"))
                                .padding(.horizontal, 20)

                            if filesList.isEmpty {
                                Text("No files yet — tap EXPORT ALL first")
                                    .font(.system(size: 12, weight: .light))
                                    .foregroundColor(.white.opacity(0.35))
                                    .padding(.horizontal, 20)
                            } else {
                                ForEach(filesList, id: \.self) { file in
                                    HStack(spacing: 12) {
                                        Image(systemName: "doc.text.fill")
                                            .font(.system(size: 13))
                                            .foregroundColor(Color(hex: "a78bfa"))
                                        Text(file)
                                            .font(.system(size: 13, weight: .light))
                                            .foregroundColor(.white.opacity(0.8))
                                        Spacer()
                                        Button(action: {
                                            try? fm.delete(filename: file)
                                            filesList = fm.listFiles()
                                            status("Deleted: \(file)")
                                        }) {
                                            Image(systemName: "trash")
                                                .font(.system(size: 12))
                                                .foregroundColor(Color(hex: "f87171").opacity(0.7))
                                        }
                                    }
                                    .padding(12)
                                    .background(Color.white.opacity(0.04)).cornerRadius(12)
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .padding(.bottom, 24)

                // ── SYNC APP DATA TO DB ──
                VStack(alignment: .leading, spacing: 14) {
                    SectionHeader(icon: "arrow.triangle.2.circlepath", title: "SYNC APP → DATABASE")
                        .padding(.horizontal, 20)

                    Button(action: syncAppDataToDB) {
                        HStack(spacing: 10) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 14))
                            Text("SYNC ALL APP DATA TO DB")
                                .font(.system(size: 13, weight: .semibold)).tracking(2)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(LinearGradient(
                            colors: [Color(hex: "7c3aed"), Color(hex: "4c1d95")],
                            startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(16)
                        .shadow(color: Color(hex: "7c3aed").opacity(0.3), radius: 12, y: 6)
                    }
                    .padding(.horizontal, 20)
                }

                Spacer(minLength: 48)
            }
        }
        .onAppear { loadRecords() }
    }

    // MARK: - Actions
    func loadRecords() {
        records = db.selectAll(table: selectedTable)
    }

    func insertRecord() {
        guard !newKey.isEmpty, !newValue.isEmpty else { return }
        db.insert(table: selectedTable, record: [newKey: newValue])
        loadRecords()
        status("INSERTED: \(newKey) = \(newValue) into \(selectedTable)")
        newKey = ""; newValue = ""
        withAnimation { showAddForm = false }
    }

    func exportAllToFiles() {
        fm.saveDreams(profile.dreams)
        fm.saveReadings(profile.readings)
        if let user = profile.currentUser { fm.saveUser(user) }
        if let data = UserDefaults.standard.data(forKey: "moodHistory"),
           let moods = try? JSONDecoder().decode([MoodEntry].self, from: data) {
            fm.saveMoods(moods)
        }
        if let data = UserDefaults.standard.data(forKey: "journalEntries"),
           let journal = try? JSONDecoder().decode([JournalEntry].self, from: data) {
            fm.saveJournal(journal)
        }
        filesList = fm.listFiles()
        showFiles = true
        status("Exported \(filesList.count) files to Documents")
    }

    func importFromFiles() {
        let dreams = fm.loadDreams()
        if !dreams.isEmpty { profile.dreams = dreams }
        let readings = fm.loadReadings()
        if !readings.isEmpty { profile.readings = readings }
        status("Imported \(dreams.count) dreams, \(readings.count) readings from files")
    }

    func syncAppDataToDB() {
        db.deleteAll(table: "dreams")
        for dream in profile.dreams {
            db.insert(table: "dreams", record: [
                "text": String(dream.text.prefix(100)),
                "interpretation": String(dream.interpretation.prefix(100)),
                "mood": dream.mood,
                "symbols": dream.symbols.joined(separator: ",")
            ])
        }
        db.deleteAll(table: "readings")
        for reading in profile.readings {
            db.insert(table: "readings", record: [
                "zodiac": reading.zodiac,
                "mood": reading.mood,
                "text": String(reading.text.prefix(100))
            ])
        }
        if let user = profile.currentUser {
            db.deleteAll(table: "users")
            db.insert(table: "users", record: [
                "name": user.name,
                "email": user.email,
                "zodiac": user.zodiacSign,
                "element": user.element,
                "planet": user.planet
            ])
        }
        loadRecords()
        status("Synced \(profile.dreams.count) dreams + \(profile.readings.count) readings + user to DB")
    }

    func status(_ msg: String) {
        withAnimation { statusMessage = msg }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation { statusMessage = "" }
        }
    }
}

// MARK: - DB Record Card
struct DBRecordCard: View {
    let record: [String: String]
    let table: String
    let onDelete: () -> Void
    let onUpdate: () -> Void
    @State private var expanded = false

    var displayFields: [(String, String)] {
        record.filter { $0.key != "id" && $0.key != "createdAt" }
            .sorted { $0.key < $1.key }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("ID: \(record["id"]?.prefix(8) ?? "?")...")
                    .font(.system(size: 10, weight: .medium)).tracking(1)
                    .foregroundColor(Color(hex: "a78bfa").opacity(0.6))
                Spacer()

                // UPDATE button
                Button(action: onUpdate) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "1d4ed8").opacity(0.8))
                }

                // DELETE button
                Button(action: onDelete) {
                    Image(systemName: "trash.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "f87171").opacity(0.8))
                }

                Image(systemName: expanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 10)).foregroundColor(.white.opacity(0.2))
            }

            if expanded {
                ForEach(displayFields, id: \.0) { key, value in
                    HStack(alignment: .top, spacing: 8) {
                        Text(key + ":")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(hex: "a78bfa").opacity(0.7))
                            .frame(width: 80, alignment: .leading)
                        Text(value)
                            .font(.system(size: 11, weight: .light))
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(2)
                    }
                }
                if let created = record["createdAt"] {
                    Text("Created: \(created)")
                        .font(.system(size: 9)).foregroundColor(.white.opacity(0.25))
                }
            } else {
                if let firstField = displayFields.first {
                    Text(firstField.1)
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(1)
                }
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.04)).cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14)
            .stroke(Color(hex: "7c3aed").opacity(0.1), lineWidth: 1))
        .onTapGesture {
            withAnimation(.spring(response: 0.3)) { expanded.toggle() }
        }
    }
}

// MARK: - File Action Button
struct FileActionButton: View {
    let icon: String
    let label: String
    let color: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(Color(hex: color))
                Text(label)
                    .font(.system(size: 10, weight: .semibold)).tracking(1)
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity).padding(.vertical, 18)
            .background(Color(hex: color).opacity(0.1)).cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: color).opacity(0.3), lineWidth: 1))
        }
    }
}
