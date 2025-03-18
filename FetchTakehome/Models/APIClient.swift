//
//  APIClient.swift
//  FetchTakehome
//
//  Created by Min Woo Lee on 3/16/25.
//

import Foundation

protocol APIClientProtocol {
    var urlSession: URLSession { get }
    func fetch(from path: String) async throws -> [Recipe]
}

extension APIClientProtocol {
    func fetch(from path: String) async throws -> [Recipe] {
        let url = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net")!.appendingPathComponent(path)
        let (data, response) = try await urlSession.data(from: url)
        guard let response = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard response.statusCode == 200 else {
            throw APIError.badStatus(response.statusCode)
        }
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let payload = try decoder.decode(Payload.self, from: data)
            return payload.recipes
        } catch {
            throw APIError.invalidData(error)
        }
    }
}

class APIClient: APIClientProtocol {

    var urlSession: URLSession {
        return .shared
    }

    static let shared = APIClient()

    private init() {}
}

enum APIError: LocalizedError {
    case invalidResponse
    case badStatus(Int)
    case invalidData(Error)

    public var errorDescription: String? {
        switch self {
            case .invalidResponse:
            return "Invalid HTTP response"
        case .badStatus(let code):
            return "HTTP status code: \(code)"
        case .invalidData(let error):
            return "Invalid data: \(error.localizedDescription)"
        }
    }
}
