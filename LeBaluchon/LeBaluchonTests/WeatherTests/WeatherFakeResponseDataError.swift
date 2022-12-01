//
//  WeatherFakeResponseDataError.swift
//  LeBaluchonTests
//
//  Created by Mickaël Horn on 24/11/2022.
//

import Foundation

class WeatherFakeResponseDataError {
    // Data - getTraduction()
    static var weatherCorrectData: Data {
        let bundle = Bundle(for: WeatherFakeResponseDataError.self)
        let url = bundle.url(forResource: "Weather", withExtension: "json")
        let data = try! Data(contentsOf: url!)
        return data
    }
    
    static let incorrectData = "erreur".data(using: .utf8)!
    
    // Response
    static let responseOK = HTTPURLResponse(url: URL(string: "https://openclassrooms.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
    static let responseKO = HTTPURLResponse(url: URL(string: "https://openclassrooms.com")!, statusCode: 500, httpVersion: nil, headerFields: nil)!
    
    // Error
    class WeatherError: Error {}
    static let error = WeatherError()
}
