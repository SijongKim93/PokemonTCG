# PokemonTCG -과제 기술문서 정리

<img src="https://github.com/user-attachments/assets/bffc607e-ba21-469e-a50e-a1f4a18d2763" width="200" height="430"> 
<img src="https://github.com/user-attachments/assets/34882827-f7f0-44db-b183-25e589a74592" width="200" height="430">
<img src="https://github.com/user-attachments/assets/5ca1091e-6bf1-4607-88fe-27c8c640da03" width="200" height="430"> 

## 주요기능

- 포켓몬 카드 리스트 조회
- 검색 및 필터 기능
- 즐겨찾기 추가/삭제 및 즐겨찾기 전용 View
- Paging 기능
- 네트워크 최적화 및 이미지 캐싱 적용

![PokemonTCG](https://github.com/user-attachments/assets/b490ca76-decc-413e-b176-7591094b0211)


## 사용 기술 스택


| 기술 | 사용 목적 |
| --- | --- |
| SwiftUI | UI 및 화면 전환 |
| Combine | 상태 관리 |
| Alamofire | API 통신  |
| async/await | 비동기 네트워크 통신 |
| UserDefaults | 즐겨찾기 누른 데이터 저장 |
| NSCache | 이미지 메모리 캐싱 |

## 아키텍처 설계


### App/

- **NavigationRouter**
    - enum 기반 화면 이동 관리 (`NavigationDestination`)
    - `NavigationPath`를 직접 제어하여 ViewModel이 화면 이동 제어 가능

### Data/

- **Repository/**
    - API 요청 및 즐겨찾기 데이터(UserDefaults) 관리
- **Manager/**
    - `ImageCacheManager`를 통해 URL 이미지 캐싱
- **Network/**
    - `APIClient`: Alamofire 기반 API 요청 담당
    - `Endpoint`: 서버 API 경로 관리 (`CardAPI`)

### Domain/

- **Entity/**
    - 앱 내부에서 사용하는 데이터 모델 (`PokemonCard`, `PokemonCardDTO`)
- **UseCase/**
    - 도메인 비즈니스 로직 구현 (`CardListUseCase`)

### Presentation/

- **CardList/**
    - 카드 목록 화면 (ListView, ViewModel, Cell 포함)
- **CardDetail/**
    - 카드 상세화면
- **Component/**
    - 공통 UI 컴포넌트 (`SearchBar`, `FilterBar`, `AsyncCachedImage`)

### Protocol/

- **RepositoryProtocol/**
    - Repository 추상화
- **UseCaseProtocol/**
    - UseCase 추상화

## 데이터 흐름

```swift
[ View (SwiftUI) ]
        ↓ (이벤트)
[ ViewModel (CardListViewModel) ]
        ↓ (요청)
[ UseCase (CardListUseCase) ]
        ↓ (데이터 요청)
[ Repository (PokemonCardRepository) ]
        ↓ (네트워크 / 로컬 호출)
[ APIClient / FavoriteStoreRepository ]
```

- **단방향 흐름(One-Way-Data-Flow)** 을 유지
- **View ↔ ViewModel** 간 양방향 바인딩 (SwiftUI @StateObject)
- **ViewModel → UseCase → Repository** 명확하게 역할 분리


## 프로토콜 추상화 한 이유

클래스 간 강한 결합 발생 우려

단일 구현체에 의존하는 형태로 설계하여 테스트 및 유지보수 , 기능 확장이 어려워짐

- 느슨한 결합을 통해 구현체 교체 시 다른 레이어 수정 필요 없도록 설계
- 테스트 용이성을 위해 Mock 객체를 주입하여 Unit Test 가능 하도록 설계
- 현재 구현해둔 UserDefaults를 다른 저장소로 쉽게 전환할 수 있도록 설계
- 각 레이어가 단일 책임 원칙을 준수 하도록 설계

위 내용을 바탕으로 실제 구현에서 의존성을 주입하였습니다.

```swift
CardListViewModel
    ↓ (PokemonCardUseCaseProtocol)
PokemonCardUseCase
    ↓ (PokemonCardRepositoryProtocol)
PokemonCardRepository
    ↓ (FavoriteStoreProtocol)
FavoriteStoreRepository
```

### ViewModel → UseCase

```swift
final class CardListViewModel: ObservableObject {
	private let useCase: PokemonCardUseCaseProtocol
}
```

- **CardListViewModel**은 실제 구현체(`PokemonCardUseCase`)를 알지 못하고
- PokemonCardUseCaseProtocol에만 의존하도록 설계
- 추후 MockUseCase를 주입하거나 다른 UseCase 교체가능

### UseCase → Repository

```swift
final class PokemonCardUseCase: PokemonCardUseCaseProtocol {
    private let repository: PokemonCardRepositoryProtocol
}
```

- UseCase도 실제 Repository를 알 수 없는 상태로 구현한 뒤 오직 Protocol에만 의존하도록 구현하여 추후 Repository가 변경되어도 UseCase 수정할 필요 없어짐

### Repository → Store

```swift
final class PokemonCardRepository: PokemonCardRepositoryProtocol {
    private let store: FavoriteStoreProtocol
}
```

- 동일하게 Repository도 FavoriteStore 구현체를 알 수 없도록 구현되어 UserDefaults 대신 CoreData 로 수정하고 싶을때 별도 Repository 수정 필요 하지 않도록 구현

이와 같은 POP 를 기반으로 느슨한 결합과 높은 테스트 용이성을 갖추고 확장 가능한 구조를 가진 아키텍처로 구현하였습니다.

## API 통신 설계

네트워크 통신 구현 시 용청 및 응답 구조가 바뀔 때 최소한의 변경으로 대응할 수 있도록 확장성 및 안정성을 고려하여 구조 설계

1. 재사용성 - 공통 API 요청 코드 작성하여 중복 제거
2. 확장성 - 새로운 API 추가 시 최소한의 코드 작성
3. 타입 안전성 - 모든 API 요청과 응답을 제네릭으로 처리

### Alamofire를 활용한 API요청 구조

```swift
enum CardAPI {
    case fetchCards(query: String?, types: [String]?, supertype: String?, page: Int)
    case fetchTypes
    case fetchSupertypes
}
```

API Endpoint는 enum 으로 타입 안전하도록 관리

```swift
final class APIClient {
    static let shared = APIClient()

    func request<T: Decodable>(_ api: CardAPI) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            session.request(api.urlRequest)
                .validate()
                .responseDecodable(of: T.self) { response in
                    switch response.result {
                    case .success(let value):
                        continuation.resume(returning: value)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
}

```

새로운 API 가 추가되면 enum case만 추가하면 된다.

request<T>() 함수는 항상 일관되게 사용가능하도록 구성

타입 안전성을 확보하여 서버 응답 구조 변경 시 빠르게 에러 감지 가능

이와 같은 내용을 토대로 API 통신은 Endpoint 관리, APIClient 공통 요청으로 추상화 하여 확장성, 안전성, 유지보수성을 갖춘 구조로 설계

## 트러블 슈팅

### 1. Filter 적용 시 즐겨찾기 상태 무시

### 문제

`isFavoritesOnly == true` 인 상황에서 type, supertype 필터를 변경 하면 해당하는 필터의 모든 카드가 나오는 문제, 즐겨 찾기 + 필터 조합이 깨지는 문제 발생

 

### 원인

```swift
.onChange(of: viewModel.selectedSupertype) { _, _ in
    viewModel.fetchCards(reset: true, query: viewModel.query.isEmpty ? nil : viewModel.query)
}
.onChange(of: viewModel.selectedTypes) { _, _ in
    viewModel.fetchCards(reset: true, query: viewModel.query.isEmpty ? nil : viewModel.query)
}
```

필터 변경 시 단순히 `fetchCards(reset:query:)` 만 호출 했기 때문에, 현재 즐겨찾기 모드인지 여부를 고려하지 않고 전체 카드 리스트를 새로 불러오는 문제 발생

### 수정 방향

```swift
func fetchFilteredCards() {
    if isFavoritesOnly {
        fetchFavoriteCards()
        return
    }
    fetchCards(reset: true, query: query.isEmpty ? nil : query)
}
```

- **`isFavoritesOnly`가 true**인 경우에는 → **즐겨찾기 카드만 필터링**해서 다시 가져온다.
- 아니면 → 일반 카드 리스트를 조건에 맞춰 다시 요청.

```swift
@Published var selectedSupertype: String? = nil {
    didSet {
        if selectedSupertype == "Trainer" {
            selectedTypes = []
        }
        fetchFilteredCards()
    }
}
```

- supertype이 바뀔 때도 **`fetchFilteredCards()`** 호출.

```swift
.onChange(of: viewModel.selectedTypes) { _, _ in
    viewModel.fetchFilteredCards()
}
```

- 타입 변경될 때도 **`fetchFilteredCards()`** 호출 하도록 수정하면 문제 해결

### 문제 해결 후 느낀점

필터 변경 시에도 즐겨찾기 상태를 유지하고 반영할 수 있도록 수정하여야 한다.

데이터를 필터링하는 책임을 fetch와 filter를 명확하게 나눠 사용자 상태를 항상 고려해야한다.

---

### 2. 즐겨찾기 토글 시 불필요한 API 호출

### 문제

즐겨찾기 버튼을 눌렀을 때, 무조건 `fetchCards()` 이 호출되도록 구현 되어있었고 결과적으로 즐겨찾기 상태를 바꿀 때 마다 API 재요청하여 네트워크 리소스 낭비가 발생

### 원인

```swift
func toggleFavorite(cardID: String) {
    useCase.toggleFavorite(cardID: cardID)
    favoriteIDs = useCase.favorites()
    fetchCards(reset: true, query: nil) // 항상 전체 다시 요청
}
```

즐겨찾기를 누를 때 마다 fetchCards를 강제로 호출하는 구조였고 심지어 현재 보고 있는 화면이 전체 카드인지, 즐겨찾기 카드인지 구분되어 있지 않은 상태

### 수정 방향

```swift
func toggleFavorite(cardID: String) {
    useCase.toggleFavorite(cardID: cardID)
    favoriteIDs = useCase.favorites()

    if isFavoritesOnly {
        Task {
            await fetchFavoriteCardsWithFilter()
        }
    } else {
        applyFilter()
    }
}
```

즐겨찾기 모드면 → API 호출하여 최신 즐겨찾 된 카드 가져오도록 구현

전체 카드 모드면 → 그냥 `applyFilter()` 로 메모리 내 필터만 갱신하였고 이를 바탕으로 불필요한 네트워크 요청 제거 후 최적화 완료

### 문제 해결 후 느낀점

- 최소한의 네트워크 요청을 위해 항상 상태를 기준으로 처리 흐름을 달리해야한다는 점을 느낄 수 있었고 이를 바탕으로 상태 관리가 매우 중요함
- 캐시를 적극 활용하여 사용자 경험을 높힐 뿐 아니라 네트워크 불필요 요청을 줄일 수 있음
