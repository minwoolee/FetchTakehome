//
//  FetchTakehomeTests.swift
//  FetchTakehomeTests
//
//  Created by Min Woo Lee on 3/16/25.
//

import Foundation
import Testing
import CryptoKit
import UIKit
@testable import FetchTakehome

@Suite(.serialized)
struct FetchTakehomeTests {

    @Test func fetchSuccess() async throws {
        let data =
            """
              {
                  "recipes": [
                      {
                          "cuisine": "Malaysian",
                          "name": "Apam Balik",
                          "photo_url_large": "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg",
                          "photo_url_small": "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg",
                          "source_url": "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ",
                          "uuid": "0c6ca6e7-e32a-4053-b824-1dbf749910d8",
                          "youtube_url": "https://www.youtube.com/watch?v=6R8ffRRJcrg"
                      },
                      {
                          "cuisine": "British",
                          "name": "Apple & Blackberry Crumble",
                          "photo_url_large": "https://d3jbb8n5wk0qxi.cloudfront.net/photos/535dfe4e-5d61-4db6-ba8f-7a27b1214f5d/large.jpg",
                          "photo_url_small": "https://d3jbb8n5wk0qxi.cloudfront.net/photos/535dfe4e-5d61-4db6-ba8f-7a27b1214f5d/small.jpg",
                          "source_url": "https://www.bbcgoodfood.com/recipes/778642/apple-and-blackberry-crumble",
                          "uuid": "599344f4-3c5c-4cca-b914-2210e3b3312f",
                          "youtube_url": "https://www.youtube.com/watch?v=4vhcOwVBDO4"
                      }
                ]
              }
              """.data(using: .utf8)!
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: ["Content-Type": "application/json"])!
            return (response, data)
        }

        let recipeListViewModel = RecipeListViewModel(apiClient: MockAPIClient())
        await recipeListViewModel.fetchRecipes()
        #expect(recipeListViewModel.recipes.count == 2)
    }

    @Test func fetchFailBadData() async throws {
        let data = """
              {
                  "recipes": [
                      {
                          "name": "Apam Balik",
                          "photo_url_large": "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg",
                          "photo_url_small": "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg",
                          "source_url": "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ",
                          "uuid": "0c6ca6e7-e32a-4053-b824-1dbf749910d8",
                          "youtube_url": "https://www.youtube.com/watch?v=6R8ffRRJcrg"
                      }
                    ]
                }
        """.data(using: .utf8)!
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: ["Content-Type": "application/json"])!
            return (response, data)
        }
        let recipeListViewModel = RecipeListViewModel(apiClient: MockAPIClient())
        await recipeListViewModel.fetchRecipes()
        if case let .failure(error) = recipeListViewModel.state {
            guard let testError = error as? APIError else {
                Issue.record("Unexpected error type: \(error)")
                return
            }
            if case let .invalidData(error) = testError {
                #expect(error is DecodingError)
            } else {
                Issue.record("Unexpected error \(testError)")
            }
        } else {
            Issue.record("Expected fetch to fail, but succeeded")
        }
    }

    @Test func fetchFailBadStatusCode() async throws {
        let data = "".data(using: .utf8)!
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")!,
                                           statusCode: 500,
                                           httpVersion: nil,
                                           headerFields: ["Content-Type": "application/json"])!
            return (response, data)
        }
        let recipeListViewModel = RecipeListViewModel(apiClient: MockAPIClient())
        await recipeListViewModel.fetchRecipes()
        if case let .failure(error) = recipeListViewModel.state {
            guard let testError = error as? APIError else {
                Issue.record("Unexpected error type: \(error)")
                return
            }
            if case let .badStatus(code) = testError {
                #expect(code == 500)
            } else {
                Issue.record("Unexpected error")
            }
        } else {
            Issue.record("Expected fetch to fail, but succeeded")
        }
    }

    @Test func imageCacheCreateAndClear() async throws {
        #expect(CachedImageViewModel.cachePathURL.lastPathComponent == "images")
        CachedImageViewModel.clearDiskCache()
        let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("images")
        #expect(!FileManager.default.fileExists(atPath: url.path))
    }

    @Test func imageCachePersistence() async throws {
        let urlString = "https://dummyimage.com/homer.png"
        let sourceImage = UIImage(named: "homer")!
        let pngData = sourceImage.pngData()!
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: URL(string: urlString)!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: ["Content-Type": "application/json"])!
            return (response, pngData)
        }
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: config)

        let viewModel = CachedImageViewModel(URL(string: urlString)!)
        await viewModel.loadImage(urlSession: urlSession)

        if case let .success(image) = viewModel.state {
            #expect(image.pngData() == pngData)
        } else {
            Issue.record("Failed to load image")
        }

        // check disk cache exists
        let md5 = Insecure.MD5.hash(data: urlString.data(using: .utf8)!).map { String(format: "%02hhx", $0) }.joined()
        let fileUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            .appendingPathComponent("images")
            .appendingPathComponent(md5)
        #expect(FileManager.default.fileExists(atPath: fileUrl.path))

        // clean up
        CachedImageViewModel.clearDiskCache()
    }

    @Test func imageLoadFail() async throws {
        let urlString = "https://dummyimage.com/homer.png"
        MockURLProtocol.requestHandler = nil
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: config)

        let viewModel = CachedImageViewModel(URL(string: urlString)!)
        await viewModel.loadImage(urlSession: urlSession)

        if case .failure(_) = viewModel.state {
            #expect(true)
        } else {
            Issue.record("Expected load to fail, but succeeded")
        }
    }
}
