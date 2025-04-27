import Foundation
import Combine

protocol PokemonCardRepositoryProtocol {
    func fetchCards(page: Int, query: String?, types: [String]?, supertype: String?) async throws -> [PokemonCard]
    func toggleFavorite(cardID: String)
    func isFavorite(cardID: String) -> Bool
    func favorites() -> Set<String>
    
    var favoriteStore: FavoriteStoreProtocol { get }
}
