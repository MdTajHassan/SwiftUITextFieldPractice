import Foundation

final class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var users: [Login] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var debounceTask: Task<Void, Never>? = nil
    
    func searchTextDidChange() {
        // Cancel any pending debounce task
        debounceTask?.cancel()

        // If the query is empty, clear results and stop loading state
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            Task { @MainActor in
                self.users = []
                self.errorMessage = "Please enter text..."
                self.isLoading = false
            }
            return
        }

        // Start a new debounced task
        debounceTask = Task { [weak self] in
            // Wait 400ms; cancel if a new character arrives
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard let self = self, !Task.isCancelled else { return }
            await self.searchUsers()
        }
    }

    func searchUsers() async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        do {
            let response = try await GitHubService.shared.searchUsers(query: searchText)
            await MainActor.run {
                self.users = response.items
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.users = []
                if let svcError = error as? ServiceErrror {
                    switch svcError {
                    case .invalidUrl: self.errorMessage = "Invalid URL"
                    case .invalidResponse: self.errorMessage = "Invalid server response"
                    case .noData: self.errorMessage = "No data received"
                    case .decodingError: self.errorMessage = "Failed to decode data"
                    }
                } else {
                    self.errorMessage = error.localizedDescription
                }
                self.isLoading = false
            }
        }
    }
}
