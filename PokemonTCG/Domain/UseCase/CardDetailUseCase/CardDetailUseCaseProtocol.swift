import Foundation
import Combine

protocol CardDetailUseCaseProtocol {
    func toggleFavorite(cardID: String)
    func observeFavorites() -> AnyPublisher<Set<String>, Never>
}
