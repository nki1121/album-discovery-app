import Foundation

// Spotify の /api/token エンドポイントが返す JSON の形を表す型。
//
// Spotify は JSON のキーを snake_case で返す (access_token, token_type, expires_in) が、
// Swift の慣習は camelCase。CodingKeys で対応を取る。
struct SpotifyTokenResponse: Decodable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType   = "token_type"
        case expiresIn   = "expires_in"
    }
}

// Spotify 認証で起きうるエラー
enum SpotifyAuthError: Error {
    case missingCredentials       // Client ID/Secret が空文字
    case invalidResponse          // HTTPURLResponse にキャストできない
    case httpError(status: Int)   // 4xx, 5xx 等
}

// Spotify からアクセストークンを取得する Service。
//
// 認証だけが責務。トラック検索など別の API 呼び出しは別の Service が担当する。
struct SpotifyAuthService {

    private let tokenURL = URL(string: "https://accounts.spotify.com/api/token")!

    func fetchAccessToken() async throws -> String {
        // ① 環境変数から読んだ値が入っているか確認（認証チェック）
        let clientID = Secrets.spotifyClientID
        let clientSecret = Secrets.spotifyClientSecret
        guard !clientID.isEmpty, !clientSecret.isEmpty else {
            throw SpotifyAuthError.missingCredentials
        }

        // ② "ID:Secret" を Base64 エンコードして Authorization ヘッダの値を作る（Base64エンコード）
        //    (Basic 認証はこの形式)
        let credentials = "\(clientID):\(clientSecret)"
        let base64Credentials = Data(credentials.utf8).base64EncodedString()

        // ③ リクエストを組み立てる
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=client_credentials".data(using: .utf8)

        // ④ 実際に送信する。async/await でレスポンス到着まで一行で待てる（送信）
        let (data, response) = try await URLSession.shared.data(for: request)

        // ⑤ ステータスコードを確認 (200番台でなければエラー)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SpotifyAuthError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw SpotifyAuthError.httpError(status: httpResponse.statusCode)
        }

        // ⑥ JSON をデコードして、access_token を返す
        let tokenResponse = try JSONDecoder().decode(SpotifyTokenResponse.self, from: data)
        return tokenResponse.accessToken
    }
}
