import UIKit

/// URL 이미지 캐싱 매니저 (메모리 캐시 활용)
final class ImageCacheManager {
    static let shared = ImageCacheManager()

    private let cache = NSCache<NSString, UIImage>()

    private init() {}

    /// URL에서 이미지를 불러오고 캐시 저장
    func loadImage(from url: URL) async throws -> UIImage {
        let key = url.absoluteString as NSString

        // 캐시 hit
        if let cachedImage = cache.object(forKey: key) {
            return cachedImage
        } else {
            // 캐시 miss -> 네트워크 요청
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else {
                throw URLError(.cannotDecodeContentData)
            }
            cache.setObject(image, forKey: key)
            return image
        }
    }
}
