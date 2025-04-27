import UIKit
import Alamofire

/// URL 이미지 캐싱 매니저 (메모리 캐시 활용)
final class ImageCacheManager {
    static let shared = ImageCacheManager()

    private let cache = NSCache<NSString, UIImage>()

    private init() {}
    
    /// URL에서 이미지를 불러오고 캐시 저장
    func loadImage(from url: URL) async throws -> UIImage {
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        if let image = UIImage(data: data) {
                            continuation.resume(returning: image)
                        } else {
                            continuation.resume(throwing: URLError(.cannotDecodeContentData))
                        }
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
}
