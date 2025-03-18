//
//  RecipeView.swift
//  FetchTakehome
//
//  Created by Min Woo Lee on 3/16/25.
//
import SwiftUI

struct RecipeView: View {
    @Environment(\.openURL) private var openURL

    var recipe: Recipe
    var body: some View {
        HStack(alignment: .center) {

            VStack(alignment: .leading) {
                if let urlString = recipe.photoUrlSmall,
                   let imageUrl = URL(string: urlString)  {
                    CachedImage(url: imageUrl) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                        case .empty:
                            ProgressView()
                        case .failure(_):
                            Image(systemName: "photo.badge.exclamationmark")
                                .resizable()
                                .scaledToFit()
                        @unknown default:
                            Image(systemName: "photo.badge.exclamationmark")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                } else {
                    Image(systemName: "frying.pan")
                        .resizable()
                        .scaledToFit()
                }
            }
            .cornerRadius(15)
            .frame(maxWidth: 100, alignment: .leading)

            VStack(alignment: .leading) {
                Text(recipe.name)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .font(.headline)
                Text(recipe.cuisine)
                    .font(.caption)
                Divider()
                HStack {
                    if let sourceUrl = recipe.sourceUrl {
                        Button {
                            openURL(URL(string: sourceUrl)!)
                        } label: {
                            VStack {
                                Image(systemName: "globe")
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 5).fill(Color.white))
                        }
                    }
                    if let youtubeUrl = recipe.youtubeUrl {
                        Button {
                            openURL(URL(string: youtubeUrl)!)
                        } label: {
                            VStack {
                                Image(systemName: "film")
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 5).fill(Color.white))
                        }
                    }
                }
                // required to make individual buttons tappable
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

        }
        .padding()
        .background(.mint.opacity(0.1))
        .cornerRadius(15)
    }
}

#Preview {
    RecipeView(recipe: Recipe(
        uuid: "1",
        cuisine: "Malaysian",
        name: "Apam Balik",
        photoUrlLarge: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg",
        photoUrlSmall: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg",
        //        photoUrlSmall: nil,
        sourceUrl: "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ",
        youtubeUrl: "https://www.youtube.com/watch?v=6R8ffRRJcrg"
    ))
}
