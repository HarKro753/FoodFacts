//
//  CachedAsyncImage.swift
//  YukaMock
//
//  Created by Harro Krog on 09.11.25.
//

import SwiftUI

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    private let url: URL
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder

    @State private var image: UIImage?
    @State private var isLoading = false
    @State private var hasFailed = false

    init(
        url: URL,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if let image = image {
                content(Image(uiImage: image))
            } else if hasFailed {
                placeholder()
            } else {
                placeholder()
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }

    private func loadImage() {
        let cacheKey = url.absoluteString

        // Check cache first
        if let cachedImage = ImageCache.shared.get(forKey: cacheKey) {
            self.image = cachedImage
            return
        }

        // Download image
        isLoading = true
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false

                if let data = data, let downloadedImage = UIImage(data: data) {
                    // Cache the image
                    ImageCache.shared.set(downloadedImage, forKey: cacheKey)
                    self.image = downloadedImage
                } else {
                    hasFailed = true
                }
            }
        }.resume()
    }
}
