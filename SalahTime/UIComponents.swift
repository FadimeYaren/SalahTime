//
//  UIComponents.swift
//  SalahTime
//
//  Created by yaren on 28.10.2025.
//
import SwiftUI

public struct Chip: View {
    public let text: String
    public init(text: String) { self.text = text }
    public var body: some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.secondary.opacity(0.12), in: Capsule())
    }
}

public struct Pill: View {
    public let text: String
    public init(text: String) { self.text = text }
    public var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "clock.badge.checkmark")
                .imageScale(.small)
            Text(text)
                .font(.footnote)
                .monospacedDigit()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(Color.secondary.opacity(0.15)))
        .overlay(Capsule().stroke(Color.secondary.opacity(0.25), lineWidth: 1))
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }
}

public struct NextPrayerCard: View {
    public let title: String
    public let countdown: String
    public init(title: String, countdown: String) {
        self.title = title; self.countdown = countdown
    }
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(title, systemImage: "bell.badge.fill")
                    .labelStyle(.titleAndIcon)
                    .font(.headline)
                Spacer()
            }
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text(countdown)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .minimumScaleFactor(0.6)
                Spacer()
            }
            HStack {
                Image(systemName: "waveform.path.ecg")
                Text("Updated live every second")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.18), Color.indigo.opacity(0.14)]),
                startPoint: .topLeading, endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.blue.opacity(0.15), lineWidth: 1)
        )
    }
}

public struct PrayerRow: View {
    public let name: String
    public let time: String
    public let icon: String
    public init(name: String, time: String, icon: String) {
        self.name = name; self.time = time; self.icon = icon
    }
    public var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.primary.opacity(0.06))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .imageScale(.medium)
                    .foregroundStyle(.primary)
            }
            Text(name)
                .font(.system(.body, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer(minLength: 8)
            Text(time)
                .font(.system(.callout, design: .monospaced))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 8)
    }
}

