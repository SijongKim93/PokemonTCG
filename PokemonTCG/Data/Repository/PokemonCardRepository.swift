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

    func fetchCards(page: Int, query: String?, types: [String]?, supertype: String?) async throws -> [PokemonCard] {
        let response: CardListResponseDTO = try await APIClient.shared.request(
            .fetchCards(query: query, types: types, supertype: supertype, page: page)
        )
        return response.data.map { $0.toEntity() }
    }

    func toggleFavorite(cardID: String) {
        favoriteStore.toggle(cardID: cardID)
    }

    func isFavorite(cardID: String) -> Bool {
        favoriteStore.isFavorite(cardID)
    }

    func favorites() -> Set<String> {
        (favoriteStore as? FavoriteStoreRepository)?.subject.value ?? []
    }

    func observeFavorites() -> AnyPublisher<Set<String>, Never> {
        favoriteStore.favoritesPublisher
    }
}
