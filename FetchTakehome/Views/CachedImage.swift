//
//  CachedImage.swift
//  FetchTakehome
//
//  Created by Min Woo Lee on 3/16/25.
//
import SwiftUI
import CryptoKit
import Observation

struct CachedImage<Content: View>: View {

    init(url: URL, @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.url = url
        self.content = content
        self.viewModel = CachedImageViewModel(url)
    }
    let url: URL
    @ViewBuilder let content: (AsyncImagePhase) -> Content

    @State private var viewModel: CachedImageViewModel

    var body: some View {
        ZStack {
            switch viewModel.state {
            case .loading:
                content(.empty)
            case .success(let image):
                content(.success(Image(uiImage: image)))
            case .failure(let error):
                content(.failure(error))
            }
        }
        .task {
            await viewModel.loadImage()
        }
    }
}

@Observable class CachedImageViewModel {

    enum CachedImageState {
        case loading
        case success(UIImage)
        case failure(LocalizedError)
    }

    enum CachedImageError: LocalizedError {
        case invalidData
    }

    init(_ url: URL) {
        self.url = url
        self.md5 = Insecure.MD5
            .hash(data: url.absoluteString.data(using: .utf8)!)
            .map { String(format: "%02hhx", $0) }
            .joined()
    }

    let url: URL
    let md5: String
    var state: CachedImageState = .loading

    static var cachePathURL: URL {
        let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("images")
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        } catch {
            print(error)
        }
        return url
    }

    func loadImage(urlSession: URLSession = .shared) async {
        // check disk
        let fileURL = Self.cachePathURL.appendingPathComponent(md5)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            if let data = try? Data(contentsOf: fileURL), let image = UIImage(data: data) {
                print("Loading \(fileURL.lastPathComponent) from disk cache")
                state = .success(image)
                return
            }
        }
        guard let (data, _) = try? await urlSession.data(from: url),
              let image = UIImage(data: data) else {
            state = .failure(CachedImageError.invalidData)
            return
        }

        state = .success(image)
        // cache to disk best effort
        try? data.write(to: fileURL)
    }

    // clear cache when user pull-to-refresh
    //
    public static func clearDiskCache() {
        do {
            print("Clearing disk cache...")
            try FileManager.default.removeItem(at: cachePathURL)
        } catch {
            print(error)
        }
    }
}
