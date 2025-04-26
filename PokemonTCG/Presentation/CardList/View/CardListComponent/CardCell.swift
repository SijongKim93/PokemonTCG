import SwiftUI

import SwiftUI

struct CardCell: View {
    let card: PokemonCard
    @Binding var isFavorite: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 8) {
                AsyncCachedImage(url: card.images.small)
                    .frame(height: 250)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)

                Text(card.name)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 4)

                Text(card.supertype)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(height: 250)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 4)

            Button(action: {
                isFavorite.toggle()
            }) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(.red)
            }
        }
    }
}
