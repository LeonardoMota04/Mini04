//
//  NetworkCallsTests.swift
//  NetworkCallsTests
//
//  Created by Victor Dantas on 19/03/24.
//

import XCTest
@testable import Mini04

class NetworkCallsTests: XCTestCase {

    func testJSONDecoderDecodesAPIMessage() throws {
        let decoder = JSONDecoder()
        let response = try decoder.decode(CompletionResponse.self, from: testFeature_nc73649170)
        
        XCTAssertEqual(response.choices.first?.message.content, "Olá! Como posso ajudar você hoje?")
    }

}
