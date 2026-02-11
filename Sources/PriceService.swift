import Foundation

@Observable
final class PriceService {
    private(set) var formattedPrice = "..."
    private(set) var error: AppError?

    private let settings: Settings
    private let client = CoinGeckoClient()

    init(settings: Settings) {
        self.settings = settings
        startPolling()
    }

    func refresh() async {
        do {
            let price = try await client.fetchPrice(
                coinId: settings.coinId, currency: settings.currency
            )
            formattedPrice = Self.format(price)
            error = nil
        } catch {
            formattedPrice = "--"
            self.error = error
        }
    }

    private func startPolling() {
        Task {
            while !Task.isCancelled {
                await refresh()
                try? await Task.sleep(for: .seconds(60))
            }
        }
    }

    private static func format(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        if price >= 1.0 {
            formatter.maximumFractionDigits = 0
        } else {
            formatter.maximumFractionDigits = 6
        }
        return formatter.string(from: price as NSNumber) ?? "--"
    }
}
