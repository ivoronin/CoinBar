import Foundation

enum AppError: Error {
    case httpStatus(Int)
    case networkUnavailable
    case unexpectedResponse
    case unknown

    init(_ error: any Error) {
        if let appError = error as? AppError {
            self = appError
            return
        }
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .timedOut,
                 .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed:
                self = .networkUnavailable
            default:
                self = .unexpectedResponse
            }
            return
        }
        if error is DecodingError {
            self = .unexpectedResponse
            return
        }
        self = .unknown
    }

    var userMessage: String {
        switch self {
        case .httpStatus(429): "Rate limited"
        case .httpStatus(let code): "API error (\(code))"
        case .networkUnavailable: "No connection"
        case .unexpectedResponse: "Unexpected response"
        case .unknown: "Unknown error"
        }
    }
}
