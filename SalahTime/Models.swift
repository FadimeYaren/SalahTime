//
//  Models.swift
//  SalahTime
//
//  Created by yaren on 28.10.2025.
//
import Foundation

struct PrayerTimesResponse: Decodable {
    let data: PrayerData
}

struct PrayerData: Decodable {
    let timings: Timings
    let date: DateInfo
    let meta: MetaInfo
}

struct Timings: Decodable {
    let fajr, sunrise, dhuhr, asr, sunset, maghrib, isha, imsak, midnight: String

    enum CodingKeys: String, CodingKey {
        case fajr = "Fajr"
        case sunrise = "Sunrise"
        case dhuhr = "Dhuhr"
        case asr = "Asr"
        case sunset = "Sunset"
        case maghrib = "Maghrib"
        case isha = "Isha"
        case imsak = "Imsak"
        case midnight = "Midnight"
    }
}

struct DateInfo: Decodable {
    let readable: String
}

struct MetaInfo: Decodable {
    let timezone: String
}

