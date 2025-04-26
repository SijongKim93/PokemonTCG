import Foundation
import Combine

final class CardDetailUseCase: CardDetailUseCaseProtocol {
    private let repository: PokemonCardRepositoryProtocol

    init(repository: PokemonCardRepositoryProtocol) {
        self.repository = repository
    }

    func toggleFavorite(cardID: String) {
        repository.toggleFavorite(cardID: cardID)
    }

    func observeFavorites() -> AnyPublisher<Set<String>, Never> {
        repository.observeFavorites()
    }
}
