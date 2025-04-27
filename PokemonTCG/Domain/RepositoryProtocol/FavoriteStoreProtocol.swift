import Combine

public protocol FavoriteStoreProtocol: AnyObject {
    var favoritesPublisher: AnyPublisher<Set<String>, Never> { get }
    func toggle(cardID: String)
    func isFavorite(_ cardID: String) -> Bool
}
