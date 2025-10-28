import SwiftUI

@main
struct SalahTimeMacApp: App {
    @StateObject private var vm = SalahTimeViewModel()

    var body: some Scene {
        // Menü çubuğunda sürekli görünen öğe
        MenuBarExtra {
            // Tıklayınca açılan popup
            PopupView(vm: vm)
                .frame(width: 420, height: 620)
                .task { await vm.fetchTimings() }   // açılışta veriyi çek
        } label: {
            // Menü çubuğu etiketi (ikon + kalan süre)
            HStack(spacing: 6) {
                Image(systemName: "moon.stars.fill")
                Text(shortLabel)
                    .monospacedDigit()
            }
        }
        .menuBarExtraStyle(.window) // tıklayınca pencere gibi açılsın
    }

    private var shortLabel: String {
        // Örn: "Asr • 17m" veya "1h 05m"
        let name = vm.nextPrayerName.isEmpty ? "—" : vm.nextPrayerName
        let s = vm.remainingSeconds
        if s <= 0 { return "\(name) • 0m" }
        let h = s / 3600, m = (s % 3600) / 60
        return h > 0 ? "\(name) • \(h)h \(m)m" : "\(name) • \(m)m"
    }
}

