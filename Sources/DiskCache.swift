import Foundation

struct DiskCache<T: Codable> {
    let url: URL
    let maxAge: TimeInterval

    init(
        directory: String = "Library/Caches/com.github.ivoronin.CoinBar",
        fileName: String,
        maxAge: TimeInterval = 86400
    ) {
        let dir = FileManager.default.homeDirectoryForCurrentUser.appending(path: directory)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        self.url = dir.appending(path: fileName)
        self.maxAge = maxAge
    }

    func load() -> T? {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: url.path()),
              let modified = attrs[.modificationDate] as? Date,
              Date().timeIntervalSince(modified) < maxAge,
              let data = try? Data(contentsOf: url),
              let value = try? JSONDecoder().decode(T.self, from: data)
        else { return nil }
        return value
    }

    func save(_ value: T) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        try? data.write(to: url)
    }
}
