import UIKit

final class ImageCacheManager {
    static let shared = ImageCacheManager()

    private let cache = NSCache<NSString, UIImage>()

    private init() {}

    func loadImage(from url: URL) async throws -> UIImage {
        let key = url.absoluteString as NSString

        if let cachedImage = cache.object(forKey: key) {
            return cachedImage
        } else {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else {
                throw URLError(.cannotDecodeContentData)
            }
            cache.setObject(image, forKey: key)
            return image
        }
    }
}
