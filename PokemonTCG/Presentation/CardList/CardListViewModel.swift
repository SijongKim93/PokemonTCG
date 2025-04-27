import SwiftUI
import Combine

@MainActor
final class CardListViewModel: ObservableObject {
    // MARK: - Published Properties (View Binding용)
    @Published var allCards: [PokemonCard] = []   // 전체 캐싱된 카드 리스트
    @Published var cards: [PokemonCard] = []       // 현재 화면에 보여줄 카드 리스트
    @Published var favoriteIDs: Set<String> = []   // 즐겨찾기한 카드 ID 목록
    @Published var selectedTypes: [String] = []    // 선택된 타입 필터
    @Published var selectedSupertype: String? = nil { // 선택된 슈퍼타입 필터
        didSet {
            if selectedSupertype == "Trainer" {
                selectedTypes = []
            }
            fetchCards(reset: true, query: query.isEmpty ? nil : query)
        }
    }
    @Published var searchText: String = ""         // 검색바 입력 텍스트
    @Published var query: String = ""              // 실제 검색 API에 보내는 쿼리
    @Published var hasLoaded: Bool = false         // 초기 데이터 로딩 여부
    @Published var isFavoritesOnly: Bool = false { // 즐겨찾기 보기 토글
        didSet {
            updateDisplayedCards()
        }
    }
    @Published var isLoading: Bool = false         // 현재 로딩 중 여부
    @Published var isFetchingNextPage: Bool = false // 페이징 추가 로딩 여부

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

    // MARK: - Computed Properties
    var filteredCards: [PokemonCard] {
        if query.isEmpty {
            return cards
        } else {
            return cards.filter { $0.name.localizedCaseInsensitiveContains(query) }
        }
    }

    // MARK: - API Fetch
    /// 전체 카드 목록 가져오기 (필터/검색 적용)
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
                    allCards.append(contentsOf: fetched)
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

    /// 즐겨찾기한 카드만 가져오기
    private func fetchFavoriteCards() {
        guard !favoriteIDs.isEmpty else {
            self.cards = []
            return
        }

        let favoriteQuery = favoriteIDs.map { "id:\($0)" }.joined(separator: " OR ")

        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                let fetched = try await useCase.fetchCards(
                    page: 1,
                    query: favoriteQuery,
                    types: nil,
                    supertype: nil
                )
                await MainActor.run {
                    cards = fetched
                    isLastPage = true
                }
            } catch {
                print("[fetchFavoriteCards] error: \(error)")
            }
        }
    }

    // MARK: - Favorite
    /// 즐겨찾기 토글
    func toggleFavorite(cardID: String) {
        useCase.toggleFavorite(cardID: cardID)
        favoriteIDs = useCase.favorites()

        if isFavoritesOnly {
            fetchFavoriteCards()
        }
    }

    /// 해당 카드가 즐겨찾기인지 확인
    func isFavorite(cardID: String) -> Bool {
        favoriteIDs.contains(cardID)
    }

    // MARK: - Paging (Infinite Scroll)
    /// 현재 아이템이 끝에 가까워질 경우 다음 페이지 호출
    func fetchNextPageIfNeeded(currentItem: PokemonCard) {
        guard !isLoading, !isFetchingNextPage, !isLastPage else { return }
        guard !isFavoritesOnly else { return }

        let thresholdIndex = cards.index(cards.endIndex, offsetBy: -5)
        if cards.firstIndex(where: { $0.id == currentItem.id }) == thresholdIndex {
            fetchNextPage()
        }
    }

    /// 다음 페이지 가져오기
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
                    allCards.append(contentsOf: fetched)
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

    // MARK: - Navigation
    /// 카드 디테일 화면으로 이동
    func pushToDetail(card: PokemonCard) {
        router.push(.cardDetail(card))
    }

    // MARK: - Search & Filter
    /// 모든 필터 초기화
    func resetFilters() {
        query = ""
        searchText = ""
        selectedTypes = []
        selectedSupertype = nil
        isFavoritesOnly = false
        fetchCards(reset: true, query: nil)
    }

    /// 검색어 적용 (검색 버튼 클릭 시)
    func applySearch() {
        query = searchText
        fetchCards(reset: true, query: query.isEmpty ? nil : query)
    }

    // MARK: - Helper
    /// 즐겨찾기 토글 시 화면 업데이트
    private func updateDisplayedCards() {
        if isFavoritesOnly {
            fetchFavoriteCards()
        } else {
            cards = allCards
        }
    }
}
