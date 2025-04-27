import Foundation
import Combine

final class FavoriteStoreRepository: FavoriteStoreProtocol {
    private let key = "favoriteCardIDs"
    let subject: CurrentValueSubject<Set<String>, Never>

    init() {
        let stored = UserDefaults.standard.stringArray(forKey: key) ?? []
        subject = CurrentValueSubject(Set(stored))
    }

    var favoritesPublisher: AnyPublisher<Set<String>, Never> {
        subject.eraseToAnyPublisher()
    }

    func toggle(cardID: String) {
        var set = subject.value
        if set.contains(cardID) {
            set.remove(cardID)
        } else {
            set.insert(cardID)
        }
        subject.send(set)
        UserDefaults.standard.set(Array(set), forKey: key)
    }

    func isFavorite(_ cardID: String) -> Bool {
        subject.value.contains(cardID)
    }
}
