//
//  CalendarParsingTest.swift
//  CalendarWidgetTests
//
//  Created by Valentine Eyiubolu on 12.04.21.
//

import XCTest

class CalendarParsingTest: XCTestCase {

    let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    let api = APIClient()
    
    func testRemoteJSONMapping() throws {
        let expectation = XCTestExpectation(description: "response")
        
        api.load(builder: APIEndpoint.calendars) { (results) in
            switch results {
            case .success(let data):
                self.parse(data: data, expectation: expectation)
            case .failure(let error):
                XCTFail(error.localizedDescription)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 30)
    }
    
    func parse(data: Data, expectation: XCTestExpectation? = nil) {
        do {
            let result = try self.decoder.decode(CalendarResponse.self, from: data)
            
            XCTAssertNotNil(result.data)
            XCTAssertTrue(result.data.calendars.count > 0)
            
            expectation?.fulfill()
        } catch let DecodingError.dataCorrupted(context) {
            XCTFail("Data corrupted: \(context.debugDescription)")
            expectation?.fulfill()
        } catch let DecodingError.keyNotFound(key, _) {
            let message = "Key '\(key.stringValue)' not found"
            XCTFail(message)
            expectation?.fulfill()
        } catch let DecodingError.valueNotFound(value, context) {
            let message = "Value '\(value)' not found: \(context.debugDescription)"
            XCTFail(message)
            expectation?.fulfill()
        } catch let DecodingError.typeMismatch(type, context)  {
            let message = "Type '\(type)' mismatch: \(context.debugDescription)"
            XCTFail(message)
            expectation?.fulfill()
        } catch {
            XCTFail(error.localizedDescription)
            expectation?.fulfill()
        }
    }
    
}
