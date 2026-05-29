import Foundation

enum ServiceErrror: Error {
    case invalidUrl
    case invalidResponse
    case noData
    case decodingError
}

class GitHubService {
    static let shared = GitHubService()
    private init() {}

    func searchUsers(query: String) async throws -> GithubModel {
        let urlString = "https://api.github.com/search/users?q=\(query)"
        guard let url = URL(string: urlString) else {
            throw ServiceErrror.invalidUrl
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw ServiceErrror.invalidResponse
        }

        do {
            return try JSONDecoder().decode(GithubModel.self, from: data)
        } catch {
            throw ServiceErrror.decodingError
        }
    }
}

