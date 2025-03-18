//
//  RecipeListViewModel.swift
//  FetchTakehome
//
//  Created by Min Woo Lee on 3/16/25.
//

import Foundation
import Observation

@Observable final class RecipeListViewModel {

    enum AppState {
        case empty
        case success([Recipe])
        case failure(LocalizedError)
    }

    init(apiClient: APIClientProtocol = APIClient.shared, path: String = "recipes.json") {
        self.path = path
        self.apiClient = apiClient
    }

    @ObservationIgnored private var apiClient: APIClientProtocol
    @ObservationIgnored private var path: String

    var state: AppState = .empty
    var recipes: [Recipe] {
        if case let .success(recipes) = state {
            return recipes
        }
        return []
    }

    func fetchRecipes() async {
        do {
            let recipes = try await apiClient.fetch(from: self.path)
            state = .success(recipes)
        } catch {
            if let localizedError = error as? LocalizedError {
                state = .failure(localizedError)
            } else {
                print(error)
            }
        }
    }
}


