import SwiftUI

struct FilterBar: View {
    @Binding var selectedSupertype: String?
    @Binding var selectedTypes: [String]

    private let supertypes = ["Energy", "Pokémon", "Trainer"]
    private let types = [
        "Colorless", "Darkness", "Dragon", "Fairy",
        "Fighting", "Fire", "Grass", "Lightning",
        "Metal", "Psychic", "Water"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(supertypes, id: \.self) { supertype in
                        Button(action: {
                            if selectedSupertype == supertype {
                                selectedSupertype = nil
                            } else {
                                selectedSupertype = supertype
                            }
                        }) {
                            Text(supertype)
                                .padding(8)
                                .background(selectedSupertype == supertype ? Color.blue.opacity(0.7) : Color.gray.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(types, id: \.self) { type in
                        Button(action: {
                            if selectedTypes.contains(type) {
                                selectedTypes.removeAll { $0 == type }
                            } else {
                                selectedTypes.append(type)
                            }
                        }) {
                            Text(type)
                                .padding(8)
                                .background(selectedTypes.contains(type) ? Color.green.opacity(0.7) : Color.gray.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .disabled(selectedSupertype == "Trainer")
                        .opacity(selectedSupertype == "Trainer" ? 0.5 : 1.0)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
