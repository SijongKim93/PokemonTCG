import Foundation

struct PokemonCard: Decodable, Identifiable {
    let id: String
    let name: String
    let supertype: String
    let types: [String]?
    let images: ImageURLs
    let set: SetInfo
}

struct ImageURLs: Decodable {
    let small: URL
    let large: URL
}

struct SetInfo: Decodable {
    let images: SetImages
}

struct SetImages: Decodable {
    let symbol: URL
    let logo: URL
}
