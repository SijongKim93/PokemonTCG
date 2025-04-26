import SwiftUI

@main
struct PokemonTCGApp: App {
    var body: some Scene {
        WindowGroup {
            CardListView(
                viewModel: CardListViewModel(
                    useCase: PokemonCardUseCase(
                        repository: PokemonCardRepository()
                    )
                )
            )
        }
    }
}
