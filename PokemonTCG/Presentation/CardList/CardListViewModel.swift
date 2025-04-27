import SwiftUI
import Combine

@MainActor
final class CardListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var allCards: [PokemonCard] = []   // 전체 캐싱된 카드
    @Published var cards: [PokemonCard] = []       // 현재 보여줄 카드
    @Published var favoriteIDs: Set<String> = []
    @Published var selectedTypes: [String] = []
    @Published var selectedSupertype: String? = nil {
        didSet {
            if selectedSupertype == "Trainer" {
                selectedTypes = []
            }
            fetchCards(reset: true, query: query.isEmpty ? nil : query)
        }
    }
    @Published var searchText: String = ""
    @Published var query: String = ""
    @Published var hasLoaded: Bool = false
    @Published var isFavoritesOnly: Bool = false {
        didSet {
            updateDisplayedCards()
        }
    }
    @Published var isLoading: Bool = false
    @Published var isFetchingNextPage: Bool = false

    // MARK: - Private Properties
    private var currentPage = 1
    private var isLastPage = false
    private let useCase: PokemonCardUseCaseProtocol

    var router: NavigationRouter

    // MARK: - Init
    init(useCase: PokemonCardUseCaseProtocol, router: NavigationRouter) {
        self.useCase = useCase
        self.router = router
        self.favoriteIDs = useCase.favorites()
    }

    // MARK: - Computed
    var filteredCards: [PokemonCard] {
        if query.isEmpty {
            return cards
        } else {
            return cards.filter { $0.name.localizedCaseInsensitiveContains(query) }
        }
    }

    // MARK: - Fetch Functions
    func fetchCards(reset: Bool = false, query: String?) {
        if reset {
            allCards = []
            cards = []
            currentPage = 1
            isLastPage = false
        }

        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                let fetched = try await useCase.fetchCards(
                    page: currentPage,
                    query: query,
                    types: selectedTypes.isEmpty ? nil : selectedTypes,
                    supertype: selectedSupertype
                )
                await MainActor.run {
                    let newUniqueCards = fetched.filter { fetchedCard in
                        !allCards.contains(where: { $0.id == fetchedCard.id })
                    }
                    allCards.append(contentsOf: newUniqueCards)
                    updateDisplayedCards()
                    if fetched.count < 20 {
                        isLastPage = true
                    }
                }
            } catch {
                print("[fetchCards] error: \(error)")
            }
        }
    }

    // MARK: - Favorite
    func toggleFavorite(cardID: String) {
        useCase.toggleFavorite(cardID: cardID)
        favoriteIDs = useCase.favorites()
        updateDisplayedCards()
    }

    func isFavorite(cardID: String) -> Bool {
        favoriteIDs.contains(cardID)
    }

    // MARK: - Paging
    func fetchNextPageIfNeeded(currentItem: PokemonCard) {
        guard !isLoading, !isFetchingNextPage, !isLastPage else { return }

        let thresholdIndex = allCards.index(allCards.endIndex, offsetBy: -5)
        if allCards.firstIndex(where: { $0.id == currentItem.id }) == thresholdIndex {
            fetchNextPage()
        }
    }

    private func fetchNextPage() {
        isFetchingNextPage = true
        currentPage += 1

        Task {
            do {
                let fetched = try await useCase.fetchCards(
                    page: currentPage,
                    query: query.isEmpty ? nil : query,
                    types: selectedTypes.isEmpty ? nil : selectedTypes,
                    supertype: selectedSupertype
                )
                
                await MainActor.run {
                    let newUniqueCards = fetched.filter { fetchedCard in
                        !allCards.contains(where: { $0.id == fetchedCard.id })
                    }
                    allCards.append(contentsOf: newUniqueCards)
                    updateDisplayedCards()
                    isFetchingNextPage = false
                    if fetched.count < 20 {
                        isLastPage = true
                    }
                }
            } catch {
                print("[fetchNextPage] error: \(error)")
                await MainActor.run {
                    isFetchingNextPage = false
                }
            }
        }
    }

    // MARK: - Helper
    func pushToDetail(card: PokemonCard) {
        router.push(.cardDetail(card))
    }

    func resetFilters() {
        query = ""
        searchText = ""
        selectedTypes = []
        selectedSupertype = nil
        isFavoritesOnly = false
        fetchCards(reset: true, query: nil)
    }

    func applySearch() {
        query = searchText
        fetchCards(reset: true, query: query.isEmpty ? nil : query)
    }

    private func updateDisplayedCards() {
        if isFavoritesOnly {
            cards = allCards.filter { favoriteIDs.contains($0.id) }
        } else {
            cards = allCards
        }
    }
}
