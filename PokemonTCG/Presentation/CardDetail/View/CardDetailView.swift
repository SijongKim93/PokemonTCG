import SwiftUI

struct CardDetailView: View {
    let card: PokemonCard
    @Binding var isFavorite: Bool

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
                        isFavorite.toggle()
                    }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(.red)
                            .font(.title2)
                    }
                }
                .padding(.horizontal)
                
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

                AsyncImage(url: card.set.images.symbol) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .frame(width: 40, height: 40)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                    case .empty:
                        ProgressView()
                            .frame(width: 40, height: 40)
                    @unknown default:
                        EmptyView()
                    }
                }
                .padding()
            }
            .padding(.bottom, 40)
        }
        .navigationTitle(card.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
