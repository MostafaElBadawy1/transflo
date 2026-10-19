import Foundation
import TransfloDomain

/// Checks public release metadata only. Installation remains an explicit user action.
public struct GitHubUpdateChecker: AppUpdateChecking {
    public static let releasesURL = URL(string: "https://github.com/Ali-Fayed/transflo/releases/latest")
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func check(currentVersion: String) async throws -> AppUpdateStatus {
        guard let endpoint = URL(string: "https://api.github.com/repos/Ali-Fayed/transflo/releases/latest") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: endpoint, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 20)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        request.setValue("Transflo-Update-Checker", forHTTPHeaderField: "User-Agent")
        let (data, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        return try Self.status(data: data, statusCode: response.statusCode, currentVersion: currentVersion)
    }

    static func status(data: Data, statusCode: Int, currentVersion: String) throws -> AppUpdateStatus {
        // GitHub returns 404 when no public stable release is accessible.
        if statusCode == 404 { return .noPublishedRelease }
        guard statusCode == 200 else { throw URLError(.badServerResponse) }
        let release = try JSONDecoder().decode(GitHubAppRelease.self, from: data)
        guard !release.draft, !release.prerelease,
              let latest = versionComponents(release.tagName),
              let current = versionComponents(currentVersion) else { throw URLError(.cannotParseResponse) }
        return current.lexicographicallyPrecedes(latest)
            ? .available(version: release.tagName) : .upToDate
    }

    /// Release builds use three numeric components; reject malformed or prerelease tags.
    private static func versionComponents(_ value: String) -> [UInt]? {
        let normalized = value.hasPrefix("v") ? String(value.dropFirst()) : value
        let parts = normalized.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count == 3,
              parts.allSatisfy({ !$0.isEmpty && $0.utf8.allSatisfy { (48...57).contains($0) } }) else { return nil }
        let numbers = parts.compactMap { UInt($0) }
        return numbers.count == 3 ? numbers : nil
    }
}

private struct GitHubAppRelease: Decodable {
    let tagName: String
    let draft: Bool
    let prerelease: Bool

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case draft, prerelease
    }
}
