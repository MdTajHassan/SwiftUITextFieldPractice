import Foundation

// MARK: - Models
struct GithubModel: Codable {
    let items: [Login]
}

struct Login: Codable {
    let id: Int
    let login: String
}

// MARK: - Service Error
enum ServiceError: Error {
    case invalidUrl
    case invalidResponse
    case noData
    case decodingError
}
