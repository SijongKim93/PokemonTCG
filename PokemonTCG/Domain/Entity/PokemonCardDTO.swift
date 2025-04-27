import Foundation

/// API 응답 데이터 모델 (DTO)
struct CardListResponseDTO: Decodable {
    let data: [PokemonCardDTO]
}

/// 카드 DTO
struct PokemonCardDTO: Decodable {
    let id: String
    let name: String
    let supertype: String
    let types: [String]?
    let images: ImageURLsDTO
    let set: SetInfoDTO
}

/// 카드 이미지 DTO
struct ImageURLsDTO: Decodable {
    let small: URL
    let large: URL
}

/// 카드 세트 DTO
struct SetInfoDTO: Decodable {
    let images: SetImagesDTO
}

/// 세트 로고/심볼 이미지 DTO
struct SetImagesDTO: Decodable {
    let symbol: URL
    let logo: URL
}

/// DTO -> Entity 변환
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
