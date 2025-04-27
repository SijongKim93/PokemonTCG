import SwiftUI
import Combine

@MainActor
final class CardListViewModel: ObservableObject {
    @Published var cards: [PokemonCard] = []
    @Published var favoriteIDs: Set<String> = []
    @Published var selectedTypes: [String] = []
    @Published var selectedSupertype: String? = nil {
        didSet {
            if selectedSupertype == "Trainer" {
                selectedTypes = []
            }
        }
    }
    @Published var query: String = ""
    @Published var hasLoaded: Bool = false
    @Published var isFavoritesOnly: Bool = false
    @Published var isLoading: Bool = false
    @Published var isFetchingNextPage: Bool = false

    private var currentPage = 1
    private var isLastPage = false
    private let useCase: PokemonCardUseCaseProtocol

    var router: NavigationRouter

    init(useCase: PokemonCardUseCaseProtocol, router: NavigationRouter) {
        self.useCase = useCase
        self.router = router
        self.favoriteIDs = useCase.favorites()
    }
    
    var filteredCards: [PokemonCard] {
        var filtered = cards
        
        if isFavoritesOnly {
            filtered = filtered.filter { favoriteIDs.contains($0.id) }
        }
        
        if !query.isEmpty {
            filtered = filtered.filter { $0.name.localizedCaseInsensitiveContains(query) }
        }
        
        return filtered
    }

    func fetchCards(reset: Bool = false, query: String?) {
        if reset {
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
                    cards.append(contentsOf: fetched)
                    if fetched.count < 20 {
                        isLastPage = true
                    }
                }
            } catch {
                print("[fetchCards] error: \(error)")
            }
        }
    }

    func resetFilters() {
        query = ""
        selectedTypes = []
        selectedSupertype = nil
        isFavoritesOnly = false
        fetchCards(reset: true, query: nil)
    }

    func toggleFavorite(cardID: String) {
        useCase.toggleFavorite(cardID: cardID)
        favoriteIDs = useCase.favorites()
    }

    func isFavorite(cardID: String) -> Bool {
        favoriteIDs.contains(cardID)
    }

    func fetchNextPageIfNeeded(currentItem: PokemonCard) {
        guard !isLoading, !isFetchingNextPage, !isLastPage else { return }

        let thresholdIndex = cards.index(cards.endIndex, offsetBy: -5)
        if cards.firstIndex(where: { $0.id == currentItem.id }) == thresholdIndex {
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
                    cards.append(contentsOf: fetched)
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

    func pushToDetail(card: PokemonCard) {
        router.push(card)
    }
}
