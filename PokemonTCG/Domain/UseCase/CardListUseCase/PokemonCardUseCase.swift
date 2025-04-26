import Foundation
import Combine

final class PokemonCardUseCase: PokemonCardUseCaseProtocol {
    private let repository: PokemonCardRepositoryProtocol
    
    var favoriteStore: FavoriteStoreProtocol {
        repository.favoriteStore
    }
    
    init(repository: PokemonCardRepositoryProtocol) {
        self.repository = repository
    }

    func fetchCards(page: Int, query: String?, types: [String]?, supertype: String?) async throws -> [PokemonCard] {
        try await repository.fetchCards(page: page, query: query, types: types, supertype: supertype)
    }

    func toggleFavorite(cardID: String) {
        repository.toggleFavorite(cardID: cardID)
    }

    func isFavorite(cardID: String) -> Bool {
        repository.isFavorite(cardID: cardID)
    }

    func observeFavorites() -> AnyPublisher<Set<String>, Never> {
        repository.observeFavorites()
    }
    
    func favorites() -> Set<String> {
        repository.favorites()
    }
}
