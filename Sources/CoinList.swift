import Foundation

@Observable
final class CoinList {
    private var coins: [CoinGeckoClient.Coin] = []
    private var currencies: [String] = []
    private(set) var error: AppError?

    private let client = CoinGeckoClient()
    private let coinsCache = DiskCache<[CoinGeckoClient.Coin]>(fileName: "coins.json")
    private let currenciesCache = DiskCache<[String]>(fileName: "currencies.json")

    private static let pinnedCurrencies = ["usd", "eur", "gbp"]

    init() {
        coins = coinsCache.load() ?? []
        currencies = currenciesCache.load() ?? []
        Task { await fetchFromAPI() }
    }

    func symbolFor(_ coinId: String) -> String {
        coins.first { $0.id == coinId }?.symbol.uppercased() ?? coinId.uppercased()
    }

    var coinItems: [PickerItem] {
        coins.map { PickerItem(id: $0.id, label: "\($0.name) (\($0.symbol.uppercased()))") }
    }

    var currencyItems: [PickerItem] {
        let pinned = Self.pinnedCurrencies
        let sorted = currencies.sorted { lhs, rhs in
            let lhsIndex = pinned.firstIndex(of: lhs)
            let rhsIndex = pinned.firstIndex(of: rhs)
            switch (lhsIndex, rhsIndex) {
            case let (lhsIndex?, rhsIndex?): return lhsIndex < rhsIndex
            case (_?, nil): return true
            case (nil, _?): return false
            default: return lhs < rhs
            }
        }
        return sorted.map { PickerItem(id: $0, label: $0.uppercased()) }
    }

    private func fetchFromAPI() async {
        var fetchError: AppError?

        do {
            let fetched = try await client.fetchCoins()
            coins = fetched
            coinsCache.save(fetched)
        } catch {
            fetchError = error
        }

        do {
            let fetched = try await client.fetchCurrencies()
            currencies = fetched
            currenciesCache.save(fetched)
        } catch {
            fetchError = error
        }

        if fetchError != nil, coins.isEmpty || currencies.isEmpty {
            self.error = fetchError
        } else {
            self.error = nil
        }
    }
}
