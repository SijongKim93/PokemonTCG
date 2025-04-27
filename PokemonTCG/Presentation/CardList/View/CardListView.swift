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
                    text: $viewModel.query,
                    onSearch: {
                        viewModel.fetchCards(reset: true, query: viewModel.query.isEmpty ? nil : viewModel.query)
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
            .navigationTitle("Pokémon Cards")
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
            .navigationDestination(for: PokemonCard.self) { card in
                CardDetailView(
                    card: card,
                    viewModel: viewModel
                )
            }
            .onAppear {
                if !viewModel.hasLoaded {
                    viewModel.fetchCards(query: viewModel.query.isEmpty ? nil : viewModel.query)
                    viewModel.hasLoaded = true
                }
            }
            .onChange(of: viewModel.selectedSupertype) { _, _ in
                viewModel.fetchCards(reset: true, query: viewModel.query.isEmpty ? nil : viewModel.query)
            }
            .onChange(of: viewModel.selectedTypes) { _, _ in
                viewModel.fetchCards(reset: true, query: viewModel.query.isEmpty ? nil : viewModel.query)
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
                ForEach(viewModel.filteredCards) { card in
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
