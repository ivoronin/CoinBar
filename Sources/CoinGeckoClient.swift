import Foundation

struct CoinGeckoClient {
    struct Coin: Codable {
        let id: String
        let symbol: String
        let name: String
    }

    private static let baseURL = "https://api.coingecko.com/api/v3"

    func fetchPrice(coinId: String, currency: String) async throws(AppError) -> Double {
        let response: [String: [String: Double]] = try await fetch(
            "\(Self.baseURL)/simple/price?ids=\(coinId)&vs_currencies=\(currency)"
        )
        guard let price = response[coinId]?[currency] else {
            throw .unexpectedResponse
        }
        return price
    }

    func fetchCoins() async throws(AppError) -> [Coin] {
        try await fetch(
            "\(Self.baseURL)/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250"
        )
    }

    func fetchCurrencies() async throws(AppError) -> [String] {
        let currencies: [String] = try await fetch(
            "\(Self.baseURL)/simple/supported_vs_currencies"
        )
        return currencies.sorted()
    }

    private func fetch<T: Decodable>(_ urlString: String) async throws(AppError) -> T {
        let url = URL(string: urlString)!
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            throw AppError(error)
        }
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw .httpStatus(http.statusCode)
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw .unexpectedResponse
        }
    }
}
