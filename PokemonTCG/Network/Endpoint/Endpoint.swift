import Foundation

enum CardAPI {
    case fetchCards(
        query: String?,
        types: [String]?,
        supertype: String?,
        page: Int
    )
    case fetchTypes
    case fetchSupertypes
}

extension CardAPI {
    var baseURL: URL {
        URL(string: "https://api.pokemontcg.io/v2")!
    }
    
    var path: String {
        switch self {
        case .fetchCards: return "/cards"
        case .fetchTypes: return "/types"
        case .fetchSupertypes: return "/supertypes"
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case let .fetchCards(query, types, supertype, page):
            var items: [URLQueryItem] = [
                .init(name: "page", value: "\(page)"),
                .init(name: "pageSize", value: "20"),
                .init(name: "select", value: "id,name,supertype,types,images,set")
            ]

            var lucene: [String] = []

            if let query = query, !query.isEmpty {
                if query.contains("id:") {
                    lucene.append(query)
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
