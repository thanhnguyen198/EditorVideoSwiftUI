//
//  WeatherInfo.swift
//  SwiftUITemplate
//
//  Created by apple on 30/03/2023.
//

import Foundation

// MARK: - WeatherInfo

class WeatherInfo: Codable {
    var name: String
    var dt: Int
    var main: Main
    var wind: Wind
    var weather: [Weather]
}

// MARK: - Main

struct Main: Codable {
    var temp, feelsLike, tempMin, tempMax: Double
    var pressure, humidity: Double
}

// MARK: - Wind

struct Wind: Codable {
    var speed: Double
    var deg: Int
}

// MARK: - Weather

struct Weather: Codable {
    var main: String
}
