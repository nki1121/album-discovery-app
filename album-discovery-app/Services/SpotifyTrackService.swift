import Foundation

// Spotify Track 検索で起きうるエラー
enum SpotifyTrackServiceError: Error {
    case invalidURL
    case invalidResponse
    case httpError(status: Int)
}

// Spotify の検索 API を使って楽曲データを取得する Service。
// TrackServiceProtocol に準拠しているため、ViewModel からは
// MockTrackService と全く同じインターフェースで使える。
struct SpotifyTrackService: TrackServiceProtocol {

    private let authService: SpotifyAuthService
    private let searchQuery: String

    // 依存性注入(DI)。
    // - authService: トークン取得を委譲する Service
    // - searchQuery: 検索キーワード (Phase 3 ではハードコード)
    init(
        authService: SpotifyAuthService = SpotifyAuthService(),
        searchQuery: String = "queen"
    ) {
        self.authService = authService
        self.searchQuery = searchQuery
    }

    func fetchTracks() async throws -> [Track] {
        // ① Auth Service にトークン取得を委譲
        let token = try await authService.fetchAccessToken()

        // ② URL をクエリパラメータ付きで組み立てる
        //    完成形: https://api.spotify.com/v1/search?q=queen&type=track
        //    (limit は指定しなければ Spotify のデフォルト値が使われる)
        var components = URLComponents(string: "https://api.spotify.com/v1/search")!
        components.queryItems = [
            URLQueryItem(name: "q",    value: searchQuery),
            URLQueryItem(name: "type", value: "track")
        ]
        guard let url = components.url else {
            throw SpotifyTrackServiceError.invalidURL
        }

        // ③ リクエスト組み立て (Bearer token を Authorization ヘッダに)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // ④ 送信
        let (data, response) = try await URLSession.shared.data(for: request)

        // ⑤ ステータスコード確認
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SpotifyTrackServiceError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw SpotifyTrackServiceError.httpError(status: httpResponse.statusCode)
        }

        // ⑥ JSON をデコードして [Track] に変換
        //    SpotifySearchResponse → SpotifyTrackDTO[] → toTrack() で Track[]
        let decoded = try JSONDecoder().decode(SpotifySearchResponse.self, from: data)
        return decoded.tracks.items.map { $0.toTrack() }
    }
}
