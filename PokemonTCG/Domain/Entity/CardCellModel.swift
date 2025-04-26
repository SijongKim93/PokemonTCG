import Foundation
import Combine

final class CardCellModel: ObservableObject, Identifiable {
    let id: String
    let card: PokemonCard

    @Published var isFavorite: Bool

    init(card: PokemonCard, isFavorite: Bool) {
        self.id = card.id
        self.card = card
        self.isFavorite = isFavorite
    }

    func updateFavorite(_ isFavorite: Bool) {
        self.isFavorite = isFavorite
    }
}
