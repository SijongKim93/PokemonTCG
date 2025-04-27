import Foundation
import Combine

protocol PokemonCardUseCaseProtocol {
    func fetchCards(page: Int, query: String?, types: [String]?, supertype: String?) async throws -> [PokemonCard]
    func toggleFavorite(cardID: String)
    func isFavorite(cardID: String) -> Bool
    func observeFavorites() -> AnyPublisher<Set<String>, Never>
    
    var favoriteStore: FavoriteStoreProtocol { get }
    
    func favorites() -> Set<String>
}
