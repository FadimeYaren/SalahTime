//
//  ContentView.swift
//  SalahTime
//
//  Created by yaren on 28.10.2025.
//

import SwiftUI
#if os(macOS)
import AppKit
#endif

struct ContentView: View {
    @StateObject private var vm = SalahTimeViewModel()

    // Move platform-specific colors out of the ViewBuilder
    private var bgTop: Color {
        #if os(iOS)
        return Color(.systemBackground)
        #else
        return Color(nsColor: .windowBackgroundColor)
        #endif
    }

    private var bgBottom: Color {
        #if os(iOS)
        return Color(.secondarySystemBackground)
        #else
        return Color(nsColor: .underPageBackgroundColor)
        #endif
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [bgTop, bgBottom]),
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        HStack(spacing: 10) {
                            TextField("Antalya", text: $vm.city)
                                .textFieldStyle(.roundedBorder)
                            TextField("Turkey", text: $vm.country)
                                .textFieldStyle(.roundedBorder)
                            Button("Get") {
                                Task { await vm.fetchTimings() }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.horizontal)

                        if !(vm.dateText.isEmpty && vm.timezone.isEmpty) {
                            HStack(spacing: 8) {
                                Chip(text: vm.dateText)
                                Chip(text: vm.timezone)
                                Spacer()
                            }
                            .padding(.horizontal)
                        }

                        NextPrayerCard(
                            title: vm.nextPrayerName.isEmpty ? "Next Prayer" : "Next Prayer: \(vm.nextPrayerName)",
                            countdown: vm.timeRemaining.isEmpty ? "—" : vm.timeRemaining
                        )
                        .padding(.horizontal)

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
                            .padding(14)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .strokeBorder(Color.black.opacity(0.06), lineWidth: 1)
                            )
                            .padding(.horizontal)
                        } else if let err = vm.errorMessage {
                            Text("Error: \(err)")
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        } else {
                            Text("Click the 'Get' button to see prayer times.")
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        }

                        Spacer(minLength: 20)
                    }
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("SalahTime")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Pill(text: shortBarText)
                }
            }
        }
        .task { await vm.fetchTimings() }
    }

    private var shortBarText: String {
        guard !vm.nextPrayerName.isEmpty, !vm.timeRemaining.isEmpty else { return "—" }
        return "\(vm.nextPrayerName) • \(vm.timeRemaining)"
    }
}

#Preview { ContentView() }
