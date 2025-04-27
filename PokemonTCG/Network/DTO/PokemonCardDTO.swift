import Foundation

struct CardListResponseDTO: Decodable {
    let data: [PokemonCardDTO]
}

struct PokemonCardDTO: Decodable {
    let id: String
    let name: String
    let supertype: String
    let types: [String]?
    let images: ImageURLsDTO
    let set: SetInfoDTO
}

struct ImageURLsDTO: Decodable {
    let small: URL
    let large: URL
}

struct SetInfoDTO: Decodable {
    let images: SetImagesDTO
}

struct SetImagesDTO: Decodable {
    let symbol: URL
    let logo: URL
}

extension PokemonCardDTO {
    func toEntity() -> PokemonCard {
        return PokemonCard(
            id: id,
            name: name,
            supertype: supertype,
            types: types,
            images: ImageURLs(
                small: images.small,
                large: images.large
            ),
            set: SetInfo(
                images: SetImages(
                    symbol: set.images.symbol,
                    logo: set.images.logo
                )
            )
        )
    }
}
