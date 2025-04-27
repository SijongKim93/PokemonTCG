import Foundation

/// 카드 Entity
struct PokemonCard: Decodable, Identifiable, Hashable {
    let id: String
    let name: String
    let supertype: String
    let types: [String]?
    let images: ImageURLs
    let set: SetInfo
}

/// 카드 이미지 Entity
struct ImageURLs: Decodable, Hashable {
    let small: URL
    let large: URL
}

/// 카드 세트 정보 Entity
struct SetInfo: Decodable, Hashable {
    let images: SetImages
}

/// 세트 이미지 Entity
struct SetImages: Decodable, Hashable {
    let symbol: URL
    let logo: URL
}
