//
//  NetworkTest.swift
//  CalendarWidgetTests
//
//  Created by Valentine Eyiubolu on 7.04.21.
//

import XCTest
@testable import CalendarWidgetExtension

class NetworkTest: XCTestCase {
    
    let request: APIClient = APIClient()
   
    func testWeatherRequest() throws {
        let urlRequest = APIEndpoint.weather.urlRequest
        XCTAssertTrue(urlRequest.url?.scheme == "https")
        XCTAssertTrue(urlRequest.url?.host == "ad.mail.ru")
        XCTAssertTrue(urlRequest.url?.path == "/adi/223382")
    }
 
    func testTokenRequest() throws {
        let urlRequest = APIEndpoint.accessToken(.refreshToken("")).urlRequest
        XCTAssertTrue(urlRequest.url?.scheme == "https")
        XCTAssertTrue(urlRequest.url?.host == "o2.mail.ru")
        XCTAssertTrue(urlRequest.url?.path == "/token")
    }
    
}
