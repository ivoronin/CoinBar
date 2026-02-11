import Foundation

@Observable
final class Settings {
    var coinId: String {
        didSet { UserDefaults.standard.set(coinId, forKey: "coinId") }
    }
    var currency: String {
        didSet { UserDefaults.standard.set(currency, forKey: "currency") }
    }
    var showPair: Bool {
        didSet { UserDefaults.standard.set(showPair, forKey: "showPair") }
    }

    init() {
        coinId = UserDefaults.standard.string(forKey: "coinId") ?? "bitcoin"
        currency = UserDefaults.standard.string(forKey: "currency") ?? "usd"
        showPair = UserDefaults.standard.object(forKey: "showPair") == nil
            ? true
            : UserDefaults.standard.bool(forKey: "showPair")
    }
}
