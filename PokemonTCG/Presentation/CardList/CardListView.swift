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
                SearchBar(
                    text: $viewModel.searchText,
                    onSearch: {
                        viewModel.applySearch()
                    },
                    onClear: {
                        viewModel.resetFilters()
                    }
                )
                .padding(.top)

                FilterBar(
                    selectedSupertype: $viewModel.selectedSupertype,
                    selectedTypes: $viewModel.selectedTypes
                )

                ScrollView {
                    contentView
                }
            }
            .navigationTitle("Pokemon Cards")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.isFavoritesOnly.toggle()
                    }) {
                        Image(systemName: viewModel.isFavoritesOnly ? "heart.fill" : "heart")
                            .foregroundColor(.red)
                    }
                }
            }
            .onAppear {
                if !viewModel.hasLoaded {
                    viewModel.hasLoaded = true
                    viewModel.fetchCards(query: viewModel.query.isEmpty ? nil : viewModel.query)
                }
            }
            .onChange(of: viewModel.selectedSupertype) { _, _ in
                viewModel.fetchCards(reset: true, query: viewModel.query.isEmpty ? nil : viewModel.query)
            }
            .onChange(of: viewModel.selectedTypes) { _, _ in
                viewModel.fetchCards(reset: true, query: viewModel.query.isEmpty ? nil : viewModel.query)
            }
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .cardDetail(let card):
                    CardDetailView(
                        card: card,
                        viewModel: viewModel
                    )
                }
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
        } else if viewModel.filteredCards.isEmpty {
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
        } else {
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
    }
}
