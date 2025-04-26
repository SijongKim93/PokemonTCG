import SwiftUI

struct CardListView: View {
    @StateObject private var viewModel: CardListViewModel
    @State private var favoriteIDs: Set<String> = []
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    init(viewModel: CardListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
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
            .onAppear {
                favoriteIDs = viewModel.favoriteIDs
                viewModel.fetchCards(query: viewModel.query.isEmpty ? nil : viewModel.query)
            }
            .onChange(of: viewModel.favoriteIDs) { _, newValue in
                favoriteIDs = newValue
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
        } else {
            let filteredCards = viewModel.isFavoritesOnly
            ? viewModel.cards.filter { favoriteIDs.contains($0.id) }
            : viewModel.cards
            
            if filteredCards.isEmpty {
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
                    ForEach(filteredCards, id: \.id) { card in
                        NavigationLink(destination: {
                            CardDetailView(
                                card: card,
                                isFavorite: Binding(
                                    get: { favoriteIDs.contains(card.id) },
                                    set: { isFav in
                                        viewModel.toggleFavorite(cardID: card.id)
                                    }
                                )
                            )
                        }) {
                            CardCell(
                                card: card,
                                isFavorite: Binding(
                                    get: { favoriteIDs.contains(card.id) },
                                    set: { isFav in
                                        viewModel.toggleFavorite(cardID: card.id)
                                    }
                                )
                            )
                        }
                        .onAppear {
                            if !viewModel.isFavoritesOnly {
                                viewModel.fetchNextPageIfNeeded(currentItem: card)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
