//
//  MockAPIClient.swift
//  FetchTakehomeTests
//
//  Created by Min Woo Lee on 3/16/25.
//

import Foundation
@testable import FetchTakehome

final class MockAPIClient: APIClientProtocol {

    var urlSession: URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }
}
