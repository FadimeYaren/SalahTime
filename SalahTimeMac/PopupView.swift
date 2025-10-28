//
//  PopupView.swift
//  SalahTime
//
//  Created by yaren on 28.10.2025.
//
import SwiftUI
struct PopupView: View {
    @ObservedObject var vm: SalahTimeViewModel

    var body: some View {
        ScrollView {                       // ⬅️ eklendi
            VStack(spacing: 16) {          // spacing biraz artırıldı
                // Başlık + Yenile
                HStack {
                    Text("SalahTime")
                        .font(.title2).bold()
                    Spacer(minLength: 0)
                    Text("v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—")")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    Button {
                        Task { await vm.fetchTimings() }
                    } label: { Image(systemName: "arrow.clockwise") }
                    .help("Refresh")
                }

                // Şehir / Ülke
                HStack(spacing: 10) {
                    TextField("Antalya", text: $vm.city)
                        .textFieldStyle(.roundedBorder)
                        .controlSize(.large)                 // ⬅️ macOS için daha okunaklı
                    TextField("Turkey", text: $vm.country)
                        .textFieldStyle(.roundedBorder)
                        .controlSize(.large)
                    Button("Get") {
                        Task { await vm.fetchTimings() }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }

                if !(vm.dateText.isEmpty && vm.timezone.isEmpty) {
                    HStack(spacing: 8) {
                        Chip(text: vm.dateText)
                        Chip(text: vm.timezone)
                        Spacer()
                    }
                }

                // Sayaç kartı
                NextPrayerCard(
                    title: vm.nextPrayerName.isEmpty ? "Next Prayer" : "Next Prayer: \(vm.nextPrayerName)",
                    countdown: vm.timeRemaining.isEmpty ? "—" : vm.timeRemaining
                )
                .fixedSize(horizontal: false, vertical: true) // ⬅️ yükseklikte taşma olmasın

                // Günün vakitleri
                if let t = vm.timings {
                    VStack(spacing: 0) {
                        PrayerRow(name: "Fajr",     time: t.fajr,     icon: "moon.stars.fill")
                        Divider()
                        PrayerRow(name: "Sunrise",  time: t.sunrise,  icon: "sunrise.fill")
                        Divider()
                        PrayerRow(name: "Dhuhr",    time: t.dhuhr,    icon: "sun.max.fill")
                        Divider()
                        PrayerRow(name: "Asr",      time: t.asr,      icon: "sun.max.trianglebadge.exclamationmark.fill")
                        Divider()
                        PrayerRow(name: "Maghrib",  time: t.maghrib,  icon: "sunset.fill")
                        Divider()
                        PrayerRow(name: "Isha",     time: t.isha,     icon: "moonphase.first.quarter.inverse")
                    }
                    .padding(12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                } else if let err = vm.errorMessage {
                    Text("Hata: \(err)").foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text("Veriler yükleniyor…").foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
