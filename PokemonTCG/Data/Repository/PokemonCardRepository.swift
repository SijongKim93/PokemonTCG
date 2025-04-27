import Foundation
import Combine

final class PokemonCardRepository: PokemonCardRepositoryProtocol {
    private let store: FavoriteStoreProtocol

    init(store: FavoriteStoreProtocol = FavoriteStoreRepository()) {
        self.store = store
    }
    
    var favoriteStore: FavoriteStoreProtocol {
        store
    }

    /// 카드 데이터 Fetch (API 호출)
    func fetchCards(page: Int, query: String?, types: [String]?, supertype: String?) async throws -> [PokemonCard] {
        let response: CardListResponseDTO = try await APIClient.shared.request(
            .fetchCards(query: query, types: types, supertype: supertype, page: page)
        )
        return response.data.map { $0.toEntity() }
    }

    /// 즐겨찾기 토글
    func toggleFavorite(cardID: String) {
        favoriteStore.toggle(cardID: cardID)
    }

    /// 즐겨찾기 여부 확인
    func isFavorite(cardID: String) -> Bool {
        favoriteStore.isFavorite(cardID)
    }

    /// 저장된 즐겨찾기 리스트 가져오기
    func favorites() -> Set<String> {
        (favoriteStore as? FavoriteStoreRepository)?.subject.value ?? []
    }
}
