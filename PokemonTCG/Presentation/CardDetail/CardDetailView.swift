import SwiftUI

struct CardDetailView: View {
    let card: PokemonCard
    @ObservedObject var viewModel: CardListViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AsyncImage(url: card.images.large) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .foregroundColor(.gray)
                    case .empty:
                        ProgressView()
                            .frame(height: 200)
                    @unknown default:
                        EmptyView()
                    }
                }
                .padding()

                HStack {
                    Text(card.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: {
                        viewModel.toggleFavorite(cardID: card.id)
                    }) {
                        Image(systemName: viewModel.isFavorite(cardID: card.id) ? "heart.fill" : "heart")
                            .foregroundColor(.red)
                            .font(.title2)
                    }
                }
                .padding(.horizontal)

                if let types = card.types {
                    HStack {
                        ForEach(types, id: \ .self) { type in
                            Text(type)
                                .font(.caption)
                                .padding(6)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }

                AsyncImage(url: card.set.images.logo) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    case .empty:
                        ProgressView()
                            .frame(height: 40)
                    @unknown default:
                        EmptyView()
                    }
                }
                .padding(.top, 16)

                
            }
            .padding(.bottom, 40)
        }
        .navigationTitle(card.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
