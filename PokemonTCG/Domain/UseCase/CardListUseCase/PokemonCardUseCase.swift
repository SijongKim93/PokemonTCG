import Foundation
import Combine

final class PokemonCardUseCase: PokemonCardUseCaseProtocol {
    private let repository: PokemonCardRepositoryProtocol
    
    /// 즐겨찾기 저장소 접근
    var favoriteStore: FavoriteStoreProtocol {
        repository.favoriteStore
    }
    
    init(repository: PokemonCardRepositoryProtocol) {
        self.repository = repository
    }
    
    /// 카드 목록 조회
    func fetchCards(page: Int, query: String?, types: [String]?, supertype: String?) async throws -> [PokemonCard] {
        try await repository.fetchCards(page: page, query: query, types: types, supertype: supertype)
    }
    
    /// 카드 즐겨찾기 토글
    func toggleFavorite(cardID: String) {
        repository.toggleFavorite(cardID: cardID)
    }
    
    /// 카드 즐겨찾기 여부 조회
    func isFavorite(cardID: String) -> Bool {
        repository.isFavorite(cardID: cardID)
    }
    
    /// 모든 즐겨찾기 ID 조회
    func favorites() -> Set<String> {
        repository.favorites()
    }
}
