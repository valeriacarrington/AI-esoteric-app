import Foundation

struct AIService {

    // ─────────────────────────────────────────────
    // MARK: - OpenRouter API Key
    // Get it from: https://openrouter.ai/keys
    // ─────────────────────────────────────────────
    static let apiKey = "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"
    static let model = "google/gemma-3-4b-it:free"
    // Other good free/cheap options:
    // "google/gemma-3-27b-it:free"
    // "meta-llama/llama-4-scout:free"
    // "anthropic/claude-haiku-4-5" (paid, same model you used before)

    // MARK: - Daily Oracle Reading
    static func dailyReading(user: AppUser, mood: String, dream: String) async -> String {
        let prompt = """
        You are ASTRA, the oracle of AstralVeil — an esoteric AI of extraordinary wisdom.

        User profile:
        - Zodiac: \(user.zodiacSign)
        - Element: \(user.element)
        - Ruling planet: \(user.planet)
        - Current mood: \(mood.isEmpty ? "unspecified" : mood)
        - Last dream: \(dream.isEmpty ? "none recorded" : dream)

        Deliver a daily cosmic reading in exactly 4 parts, separated by line breaks:
        1. A one-line cosmic weather report for today (poetic, celestial)
        2. A personal message about their inner world (2 sentences, mystical)
        3. An action or intention for today (1 sentence, empowering)
        4. A closing symbol word (one word like: ILLUMINATE / TRANSMUTE / ASCEND)

        Tone: luxurious, ancient, deeply personal. Never generic horoscope language.
        Make every reading completely unique — never repeat phrases across readings.
        """
        return await callOpenRouter(prompt: prompt, maxTokens: 400)
    }

    // MARK: - Dream Interpretation
    static func interpretDream(_ dream: String, mood: String) async -> (interpretation: String, symbols: [String]) {
        let prompt = """
        You are a master of dream symbology drawing from Jungian depth psychology,
        Hermetic tradition, and ancient oneiromancy.

        Dream recorded: "\(dream)"
        Dreamer's mood: \(mood.isEmpty ? "unknown" : mood)

        Respond in JSON only, no markdown, no code blocks, exactly this structure:
        {
          "interpretation": "3-4 sentences of deep symbolic interpretation, poetic and personal",
          "symbols": ["symbol1", "symbol2", "symbol3"]
        }

        Symbols should be 2-3 word archetypal concepts found in the dream.
        Every interpretation must be unique and specific to the exact dream described.
        """
        let raw = await callOpenRouter(prompt: prompt, maxTokens: 500)
        
        // Strip markdown code fences if present
        let cleaned = raw
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let data = cleaned.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let interp = json["interpretation"] as? String,
           let syms = json["symbols"] as? [String] {
            return (interp, syms)
        }
        return (cleaned, [])
    }
    
    // MARK: - Numerology Reading
    static func numerologyReading(lifePath: Int, name: String, zodiac: String) async -> String {
        let prompt = """
        You are a master numerologist and esoteric scholar.

        Subject: \(name)
        Life Path Number: \(lifePath)
        Zodiac: \(zodiac)

        Give a 3-paragraph numerological reading:
        1. The essence of Life Path \(lifePath) — what it means cosmically
        2. How it interacts with their \(zodiac) nature
        3. Their soul's deepest purpose and hidden gift

        Use language that is elevated, mystical, and deeply affirming.
        Make this reading completely specific to \(name) and Life Path \(lifePath).
        """
        return await callOpenRouter(prompt: prompt, maxTokens: 500)
    }

    // MARK: - Mood Oracle
    static func moodOracle(mood: String, emoji: String, zodiac: String) async -> String {
        let prompt = """
        You are an emotional alchemist and cosmic counselor.

        The seeker feels: \(emoji) \(mood)
        Their zodiac: \(zodiac)

        Offer a 2-3 sentence cosmic perspective on this feeling —
        validate it astrologically, transmute it into power, and offer one
        ritual or micro-practice for today.

        Tone: warm, mystical, empowering.
        Make the advice unique to \(zodiac) and the specific feeling of \(mood).
        """
        return await callOpenRouter(prompt: prompt, maxTokens: 300)
    }

    // MARK: - Core API Call (OpenRouter)
    static func callOpenRouter(prompt: String, maxTokens: Int = 400) async -> String {
        guard let url = URL(string: "https://openrouter.ai/api/v1/chat/completions") else {
            return "URL error"
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("https://astralyeil.app", forHTTPHeaderField: "HTTP-Referer") // your app URL or bundle ID
        request.setValue("AstralVeil", forHTTPHeaderField: "X-Title")
        request.timeoutInterval = 30

        let body: [String: Any] = [
            "model": model,
            "max_tokens": maxTokens,
            "messages": [["role": "user", "content": prompt]]
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            return "Request encoding error"
        }
        request.httpBody = httpBody

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let http = response as? HTTPURLResponse {
                print("🌐 API Status: \(http.statusCode)")
                if http.statusCode == 401 {
                    return "Invalid API key — please update it in AIService.swift"
                }
                if http.statusCode != 200 {
                    let raw = String(data: data, encoding: .utf8) ?? "no body"
                    print("❌ API Error body: \(raw)")
                    return "API error \(http.statusCode)"
                }
            }

            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let message = choices.first?["message"] as? [String: Any],
               let text = message["content"] as? String {
                print("✅ API Success — received \(text.count) chars")
                return text.trimmingCharacters(in: .whitespacesAndNewlines)
            }

            let raw = String(data: data, encoding: .utf8) ?? "empty"
            print("⚠️ Unexpected response: \(raw)")
            return "Unexpected response — check console"

        } catch let error as URLError {
            print("🔌 Network error: \(error.localizedDescription)")
            if error.code == .notConnectedToInternet {
                return "No internet connection"
            } else if error.code == .timedOut {
                return "Request timed out — try again"
            }
            return "Network error: \(error.localizedDescription)"
        } catch {
            print("💥 Unknown error: \(error)")
            return "Error: \(error.localizedDescription)"
        }
    }
}
