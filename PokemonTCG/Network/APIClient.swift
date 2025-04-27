import Foundation
import Alamofire

/// API 요청을 담당하는 싱글톤 네트워크 클라이언트
final class APIClient {
    static let shared = APIClient()

    private let session: Session

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default
        self.session = Session(configuration: configuration)
    }

    /// API 요청 보내고 결과를 디코딩해서 반환
    func request<T: Decodable>(_ api: CardAPI) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            session.request(api.urlRequest)
                .validate()
                .responseDecodable(of: T.self) { response in
                    switch response.result {
                    case .success(let value):
                        continuation.resume(returning: value)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
}
