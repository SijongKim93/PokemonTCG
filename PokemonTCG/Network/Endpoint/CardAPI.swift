import Foundation

/// API 엔드포인트 종류 정의
enum CardAPI {
    case fetchCards(query: String?, types: [String]?, supertype: String?, page: Int)
    case fetchTypes
    case fetchSupertypes
}

extension CardAPI {
    /// 기본 도메인
    var baseURL: URL {
        URL(string: "https://api.pokemontcg.io/v2")!
    }
    
    /// 각 케이스에 따른 path
    var path: String {
        switch self {
        case .fetchCards: return "/cards"
        case .fetchTypes: return "/types"
        case .fetchSupertypes: return "/supertypes"
        }
    }
    
    /// API 요청에 필요한 Query 파라미터
    var queryItems: [URLQueryItem]? {
        switch self {
        case let .fetchCards(query, types, supertype, page):
            var items: [URLQueryItem] = [
                .init(name: "page", value: "\(page)"),
                .init(name: "pageSize", value: "20"),
                .init(name: "select", value: "id,name,supertype,types,images,set") // 필요한 필드만 요청
            ]

            var lucene: [String] = []

            if let query = query, !query.isEmpty {
                if query.contains("id:") {
                    lucene.append("(\(query))") // 전체를 괄호로 묶어야 제대로 동작
                } else {
                    lucene.append("name:\"*\(query)*\"")
                }
            }

            if let types = types, !types.isEmpty {
                lucene.append(contentsOf: types.map { "types:\($0)" })
            }

            if let supertype = supertype {
                lucene.append("supertype:\(supertype)")
            }

            if !lucene.isEmpty {
                items.append(
                    .init(name: "q", value: lucene.joined(separator: " "))
                )
            }

            return items

        case .fetchTypes, .fetchSupertypes:
            return nil
        }
    }
    
    /// 최종 URLRequest 생성
    var urlRequest: URLRequest {
        var components = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = queryItems
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        return request
    }
}
