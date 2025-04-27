import Foundation

struct PokemonCard: Decodable, Identifiable, Hashable {
    let id: String
    let name: String
    let supertype: String
    let types: [String]?
    let images: ImageURLs
    let set: SetInfo
}

struct ImageURLs: Decodable, Hashable {
    let small: URL
    let large: URL
}

struct SetInfo: Decodable, Hashable {
    let images: SetImages
}

struct SetImages: Decodable, Hashable {
    let symbol: URL
    let logo: URL
}
