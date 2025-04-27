import Foundation
import Combine

/// 즐겨찾기 저장소 (UserDefaults 기반)
final class FavoriteStoreRepository: FavoriteStoreProtocol {
    private let key = "favoriteCardIDs"
    let subject: CurrentValueSubject<Set<String>, Never>

    init() {
        let stored = UserDefaults.standard.stringArray(forKey: key) ?? []
        subject = CurrentValueSubject(Set(stored))
    }

    /// 즐겨찾기 변경사항 스트림
    var favoritesPublisher: AnyPublisher<Set<String>, Never> {
        subject.eraseToAnyPublisher()
    }

    /// 카드ID 즐겨찾기 토글
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

    /// 즐겨찾기 여부 확인
    func isFavorite(_ cardID: String) -> Bool {
        subject.value.contains(cardID)
    }
}
