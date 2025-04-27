import SwiftUI

struct CardListView: View {
    @StateObject private var viewModel: CardListViewModel

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    init(viewModel: CardListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack(path: $viewModel.router.path) {
            VStack {
                searchBarSection
                filterBarSection
                cardGridSection
            }
            .navigationTitle("Pokemon Cards")
            .toolbar { favoritesToggleButton }
            .onAppear(perform: onAppear)
            .onChange(of: viewModel.selectedSupertype) { _, _ in /* 메소드 내부에서 처리 */ }
            .onChange(of: viewModel.selectedTypes) { _, _ in onFilterChange() }
            .navigationDestination(for: NavigationDestination.self, destination: navigationDestinationView)
        }
    }
}

// MARK: - Components
private extension CardListView {
    
    var searchBarSection: some View {
        SearchBar(
            text: $viewModel.searchText,
            onSearch: { viewModel.applySearch() },
            onClear: { viewModel.resetFilters() }
        )
        .padding(.top)
    }
    
    var filterBarSection: some View {
        FilterBar(
            selectedSupertype: $viewModel.selectedSupertype,
            selectedTypes: $viewModel.selectedTypes
        )
    }
    
    var cardGridSection: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else if viewModel.filteredCards.isEmpty {
                emptyStateView
            } else {
                cardGrid
            }
        }
    }
    
    var favoritesToggleButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: {
                viewModel.isFavoritesOnly.toggle()
                // didSet에서 fetchFilteredCards()가 호출되므로 여기서는 추가 작업 필요 없음
            }) {
                Image(systemName: viewModel.isFavoritesOnly ? "heart.fill" : "heart")
                    .foregroundColor(.red)
            }
        }
    }
    
    var emptyStateView: some View {
        VStack(spacing: 16) {
            Text("해당 내용이 없습니다.")
                .font(.headline)
                .foregroundColor(.gray)

            Button(action: {
                viewModel.resetFilters()
            }) {
                Text("필터 초기화")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var cardGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(viewModel.filteredCards, id: \.id) { card in
                Button {
                    viewModel.pushToDetail(card: card)
                } label: {
                    CardCell(
                        card: card,
                        isFavorite: Binding(
                            get: { viewModel.isFavorite(cardID: card.id) },
                            set: { _ in viewModel.toggleFavorite(cardID: card.id) }
                        )
                    )
                }
                .buttonStyle(.plain)
                .onAppear {
                    viewModel.fetchNextPageIfNeeded(currentItem: card)
                }
            }
        }
        .padding(.horizontal)
    }
    
    func navigationDestinationView(_ destination: NavigationDestination) -> some View {
        switch destination {
        case .cardDetail(let card):
            CardDetailView(
                card: card,
                viewModel: viewModel
            )
        }
    }
    
    func onAppear() {
        if !viewModel.hasLoaded {
            viewModel.hasLoaded = true
            viewModel.fetchCards(query: viewModel.query.isEmpty ? nil : viewModel.query)
        }
    }
    
    func onFilterChange() {
        // 타입 필터 변경 시에만 호출됨 (supertype은 didSet에서 처리)
        viewModel.fetchFilteredCards()
    }
}
