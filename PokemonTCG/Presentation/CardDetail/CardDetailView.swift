import SwiftUI

struct CardDetailView: View {
    let card: PokemonCard
    @ObservedObject var viewModel: CardListViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                cardMainImage
                cardInfoSection
                cardTypesSection
                cardSetLogo
            }
            .padding(.bottom, 40)
        }
        .navigationTitle(card.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Components
private extension CardDetailView {
    
    var cardMainImage: some View {
        asyncImage(url: card.images.large)
            .frame(maxHeight: 300)
            .padding()
    }

    var cardInfoSection: some View {
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
    }

    var cardTypesSection: some View {
        Group {
            if let types = card.types {
                HStack {
                    ForEach(types, id: \.self) { type in
                        Text(type)
                            .font(.caption)
                            .padding(6)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    var cardSetLogo: some View {
        asyncImage(url: card.set.images.logo)
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.top, 16)
    }

    @ViewBuilder
    func asyncImage(url: URL) -> some View {
        AsyncImage(url: url) { phase in
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
                    .foregroundColor(.gray)
            case .empty:
                ProgressView()
                    .frame(height: 40)
            @unknown default:
                EmptyView()
            }
        }
    }
}
