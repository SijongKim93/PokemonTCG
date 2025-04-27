import SwiftUI
import Combine

@MainActor
final class NavigationRouter: ObservableObject {
    @Published var path = NavigationPath()
    
    func push<T: Hashable>(_ value: T) {
        path.append(value)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
}
