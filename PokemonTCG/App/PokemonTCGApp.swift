import SwiftUI

@main
struct PokemonTCGApp: App {
    @StateObject private var router = NavigationRouter()

    var body: some Scene {
        WindowGroup {
            CardListView(
                viewModel: CardListViewModel(
                    useCase: PokemonCardUseCase(
                        repository: PokemonCardRepository()
                    ),
                    router: router
                )
            )
        }
    }
}
