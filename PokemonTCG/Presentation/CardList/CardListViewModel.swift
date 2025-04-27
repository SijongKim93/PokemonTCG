import SwiftUI

@MainActor
final class CardListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var allCards: [PokemonCard] = []   // 캐싱된 모든 카드
    @Published var cards: [PokemonCard] = []      // 현재 표시되는 카드
    @Published var favoriteIDs: Set<String> = []  // 즐겨찾기 ID
    @Published var selectedTypes: [String] = []   // 선택된 타입 필터
    @Published var selectedSupertype: String? = nil { // 선택된 슈퍼타입 필터
        didSet {
            if selectedSupertype == "Trainer" {
                selectedTypes = []
            }
            // API 호출로 변경 - 필터가 변경될 때마다 새로운 데이터 요청
            fetchFilteredCards()
        }
    }
    @Published var searchText: String = ""        // 검색창 텍스트
    @Published var query: String = ""             // 실제 검색 쿼리
    @Published var hasLoaded: Bool = false        // 초기 로딩 여부
    @Published var isFavoritesOnly: Bool = false { // 즐겨찾기 모드 토글
        didSet {
            // 즐겨찾기 모드 변경 시 필터링된 카드 다시 가져오기
            fetchFilteredCards()
        }
    }
    @Published var isLoading: Bool = false        // 로딩 상태
    @Published var isFetchingNextPage: Bool = false // 페이지 로딩 상태

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
    /// 필터링된 카드 가져오기 - 모든 필터 조건 적용
    func fetchFilteredCards() {
        // 즐겨찾기 모드인 경우 즐겨찾기 카드만 가져오기
        if isFavoritesOnly {
            fetchFavoriteCards()
            return
        }
        
        // 일반 모드인 경우 현재 필터 조건으로 API 호출
        fetchCards(reset: true, query: query.isEmpty ? nil : query)
    }
    
    /// 모든 카드 가져오기 (페이징 포함)
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
                    // 중복 카드 필터링
                    let newUniqueCards = fetched.filter { fetchedCard in
                        !allCards.contains(where: { $0.id == fetchedCard.id })
                    }
                    allCards.append(contentsOf: newUniqueCards)
                    cards = allCards
                    
                    if fetched.count < 20 {
                        isLastPage = true
                    }
                }
            } catch {
                print("[fetchCards] error: \(error)")
            }
        }
    }

    /// 즐겨찾기 카드만 가져오기
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
                    types: selectedTypes.isEmpty ? nil : selectedTypes,
                    supertype: selectedSupertype
                )
                await MainActor.run {
                    // 즐겨찾기에서는 전체 결과를 바로 cards에 할당
                    allCards = fetched
                    cards = fetched
                    isLastPage = true  // 즐겨찾기는 페이징 없음
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

        // 즐겨찾기 모드일 때 즐겨찾기 해제하면 해당 카드 제거
        if isFavoritesOnly {
            cards = cards.filter { favoriteIDs.contains($0.id) }
        }
    }

    /// 해당 카드가 즐겨찾기인지 확인
    func isFavorite(cardID: String) -> Bool {
        favoriteIDs.contains(cardID)
    }

    // MARK: - Paging
    /// 무한 스크롤을 위한 다음 페이지 필요 여부 체크
    func fetchNextPageIfNeeded(currentItem: PokemonCard) {
        guard !isLoading, !isFetchingNextPage, !isLastPage else { return }
        guard !isFavoritesOnly else { return }  // 즐겨찾기 모드에서는 페이징 비활성화

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
                    // 중복 카드 필터링
                    let newUniqueCards = fetched.filter { fetchedCard in
                        !allCards.contains(where: { $0.id == fetchedCard.id })
                    }
                    allCards.append(contentsOf: newUniqueCards)
                    cards = allCards
                    
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
        fetchFilteredCards()  // API 호출로 변경
    }
}
