import SwiftUI

struct AsyncCachedImage: View {
    let url: URL

    @State private var image: UIImage?
    @State private var isLoading = false

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else if isLoading {
                ProgressView()
            } else {
                Color.gray.opacity(0.2)
                    .overlay(
                        ProgressView()
                    )
            }
        }
        .onAppear {
            loadImage()
        }
    }

    private func loadImage() {
        guard !isLoading else { return }
        isLoading = true
        Task {
            do {
                let loadedImage = try await ImageCacheManager.shared.loadImage(from: url)
                await MainActor.run {
                    self.image = loadedImage
                }
            } catch {
                print("Failed to load image: \(error)")
            }
        }
    }
}
