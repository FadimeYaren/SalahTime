//
//  SalahTimeViewModel.swift
//  SalahTime
//
//  Created by yaren on 28.10.2025.
//

import Foundation
import Combine

@MainActor
final class SalahTimeViewModel: ObservableObject {
    // API verileri
    @Published var timings: Timings?
    @Published var dateText = ""
    @Published var timezone = ""
    @Published var errorMessage: String?

    // Kullanıcı girişi
    @Published var city = "Antalya"
    @Published var country = "Turkey"
    
    @Published var remainingSeconds: Int = 0

    // Sayaç / geri sayım
    @Published var nextPrayerName = ""
    @Published var timeRemaining = ""
    private var timer: Timer?
    
    init() {
            // Uygulama açılır açılmaz vakitleri getir
            Task { await fetchTimings() }
        }

    deinit { timer?.invalidate() }

    // --- API çağrısı ---
    func fetchTimings() async {
        let cityQ = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let countryQ = country.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? country
        let urlString = "https://api.aladhan.com/v1/timingsByCity?city=\(cityQ)&country=\(countryQ)&method=13"

        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL."
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(PrayerTimesResponse.self, from: data)

            self.timings = decoded.data.timings
            self.dateText = decoded.data.date.readable
            self.timezone = decoded.data.meta.timezone
            self.errorMessage = nil

            // vakitler gelince sıradaki vakti hesapla
            self.calculateNextPrayer()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // --- Yardımcı: "05:23 (+03)" -> "05:23" ---
    private func cleanHM(_ s: String) -> String {
        // Rakam ve ":" dışındakileri at
        let allowed = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: ":"))
        return String(s.unicodeScalars.filter { allowed.contains($0) })
    }

    // --- Sıradaki vakti bul ---
    func calculateNextPrayer() {
        guard let t = timings else { return }

        let list: [(String, String)] = [
            ("Fajr",     t.fajr),
            ("Dhuhr",    t.dhuhr),
            ("Asr",      t.asr),
            ("Maghrib",  t.maghrib),
            ("Isha",     t.isha)
        ]

        let now = Date()
        let cal = Calendar.current
        let today = cal.dateComponents([.year, .month, .day], from: now)

        // "HH:mm" -> bugünün tarihiyle Date
        func dateForToday(_ hm: String) -> Date? {
            let cleaned = cleanHM(hm)
            let parts = cleaned.split(separator: ":")
            guard parts.count >= 2,
                  let h = Int(parts[0]), let m = Int(parts[1]) else { return nil }
            var comps = DateComponents()
            comps.year = today.year
            comps.month = today.month
            comps.day = today.day
            comps.hour = h
            comps.minute = m
            return cal.date(from: comps)
        }

        var next: (String, Date)?

        for (name, timeStr) in list {
            if let d = dateForToday(timeStr), d > now {
                next = (name, d)
                break
            }
        }

        // Günün tüm vakitleri geçtiyse, yarınki Fajr
        if next == nil, let fajrToday = dateForToday(t.fajr),
           let fajrTomorrow = cal.date(byAdding: .day, value: 1, to: fajrToday) {
            next = ("Fajr", fajrTomorrow)
        }

        guard let nextUnwrapped = next else { return }
        nextPrayerName = nextUnwrapped.0
        startCountdown(to: nextUnwrapped.1)
    }

    // --- Geri sayım ---
    func startCountdown(to targetDate: Date) {
        // Timer'ı iptal et (ana akışta)
        timer?.invalidate()

        // Elle oluştur, sonra main run loop'a ekle
        let newTimer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let remaining = Int(targetDate.timeIntervalSinceNow)
            
            // <<< ÖNEMLİ: MainActor üzerinde state güncelle
            Task { @MainActor in
                
                self.remainingSeconds = max(0, remaining)
                
                if remaining <= 0 {
                    self.timeRemaining = "It's time!"
                    
                    self.timer?.invalidate()
                    return
                }

                let hours = remaining / 3600
                let minutes = (remaining % 3600) / 60
                let seconds = remaining % 60
                self.timeRemaining = String(format: "%02dh %02dm %02ds", hours, minutes, seconds)
            }
        }

        self.timer = newTimer
        RunLoop.main.add(newTimer, forMode: .common)
    }

}
