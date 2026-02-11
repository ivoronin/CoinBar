import SwiftUI

@main
struct CoinBarApp: App {
    @State private var settings: Settings
    @State private var coinList: CoinList
    @State private var priceService: PriceService

    init() {
        let settings = Settings()
        _settings = State(initialValue: settings)
        _coinList = State(initialValue: CoinList())
        _priceService = State(initialValue: PriceService(settings: settings))
    }

    private var menuBarTitle: String {
        if settings.showPair {
            let symbol = coinList.symbolFor(settings.coinId)
            let currency = settings.currency.uppercased()
            return "\(symbol)/\(currency) \(priceService.formattedPrice)"
        }
        return priceService.formattedPrice
    }

    var body: some Scene {
        MenuBarExtra {
            PopoverView(
                settings: settings,
                priceService: priceService,
                coinList: coinList
            )
        } label: {
            Text(menuBarTitle)
                .onAppear {
                    NSApp.setActivationPolicy(.accessory)
                }
        }
        .menuBarExtraStyle(.window)
    }
}

// MARK: - Launch at Login

private struct LaunchAtLogin {
    private static let plistURL: URL = {
        FileManager.default.homeDirectoryForCurrentUser
            .appending(path: "Library/LaunchAgents/com.github.ivoronin.CoinBar.plist")
    }()

    static var isEnabled: Bool {
        FileManager.default.fileExists(atPath: plistURL.path())
    }

    static func toggle() {
        if isEnabled {
            try? FileManager.default.removeItem(at: plistURL)
        } else {
            let executablePath = URL(fileURLWithPath: CommandLine.arguments[0])
                .standardizedFileURL.path()
            let plist: [String: Any] = [
                "Label": "com.github.ivoronin.CoinBar",
                "ProgramArguments": [executablePath],
                "RunAtLoad": true,
                "KeepAlive": false
            ]
            let dir = plistURL.deletingLastPathComponent()
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            (plist as NSDictionary).write(to: plistURL, atomically: true)
        }
    }
}

// MARK: - Popover View

private struct PopoverView: View {
    var settings: Settings
    var priceService: PriceService
    var coinList: CoinList

    @State private var launchAtLogin = LaunchAtLogin.isEnabled

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SearchPicker(
                title: "Coin",
                items: coinList.coinItems,
                selection: Binding(
                    get: { settings.coinId },
                    set: {
                        settings.coinId = $0
                        Task { await priceService.refresh() }
                    }
                )
            )
            .padding(.bottom, 4)

            Divider()
                .padding(.vertical, 4)

            SearchPicker(
                title: "Currency",
                items: coinList.currencyItems,
                selection: Binding(
                    get: { settings.currency },
                    set: {
                        settings.currency = $0
                        Task { await priceService.refresh() }
                    }
                )
            )

            Divider()
                .padding(.vertical, 8)

            HStack {
                Text("Show Pair")
                Spacer()
                Toggle("", isOn: Binding(
                    get: { settings.showPair },
                    set: { settings.showPair = $0 }
                ))
                .labelsHidden()
                .toggleStyle(.switch)
                .controlSize(.mini)
            }
            .padding(.bottom, 4)

            HStack {
                Text("Launch at Login")
                Spacer()
                Toggle("", isOn: $launchAtLogin)
                    .labelsHidden()
                    .toggleStyle(.switch)
                    .controlSize(.mini)
                    .onChange(of: launchAtLogin) { LaunchAtLogin.toggle() }
            }

            Divider()
                .padding(.vertical, 8)

            HStack {
                let errorMessage = priceService.error?.userMessage
                    ?? coinList.error?.userMessage
                Button(errorMessage ?? "Refresh") {
                    Task { await priceService.refresh() }
                }
                .keyboardShortcut("r")
                .foregroundStyle(errorMessage != nil ? .red : .secondary)
                Spacer()
                Text(appVersion)
                    .foregroundStyle(.tertiary)
                Spacer()
                Button("Quit") {
                    NSApp.terminate(nil)
                }
                .keyboardShortcut("q")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(width: 240)
    }
}
