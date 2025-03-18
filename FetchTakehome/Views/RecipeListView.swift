//
//  ContentView.swift
//  FetchTakehome
//
//  Created by Min Woo Lee on 3/16/25.
//

import SwiftUI

struct RecipeListView: View {

    @State var viewModel = RecipeListViewModel()

    var body: some View {
        NavigationStack {
            switch viewModel.state {
            case .empty:
                ProgressView()
            case .success(let array) where array.isEmpty:
                ContentUnavailableView {
                    Label("Not found", systemImage: "questionmark.folder")
                } description: {
                    Text("No recipes found")
                }
            case .success(_):
                listView()
            case .failure(let localizedError):
                ContentUnavailableView {
                    Label("Error", systemImage: "exclamationmark.triangle.fill")
                } description: {
                    Text(localizedError.localizedDescription)
                }
            }
        }
        .task {
            await viewModel.fetchRecipes()
        }
    }

    private func listView() -> some View {
        return List {
            if case .empty = viewModel.state {
                ProgressView()
            } else {
                ForEach(viewModel.recipes, id: \.uuid) { recipe in
                    RecipeView(recipe: recipe)
                        .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Recipes")
        .refreshable {
            CachedImageViewModel.clearDiskCache()
            await viewModel.fetchRecipes()
        }
    }
}

#Preview("Normal") {
    RecipeListView()
}

#Preview("Empty") {
    let emptyViewModel = RecipeListViewModel(path: "recipes-empty.json")
    RecipeListView(viewModel: emptyViewModel)
}

#Preview("Error") {
    let errorViewModel = RecipeListViewModel(path: "recipes-malformed.json")
    RecipeListView(viewModel: errorViewModel)
}
