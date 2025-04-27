import Foundation
import Alamofire

final class APIClient {
    static let shared = APIClient()

    private let session: Session

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default
        self.session = Session(configuration: configuration)
    }

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
