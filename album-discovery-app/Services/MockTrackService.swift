import Foundation

// このServiceで発生しうるエラー
enum MockTrackServiceError: Error {
    case fileNotFound
}

// アプリバンドルに同梱された mock_tracks.json を読み込んで [Track] を返す Service。
struct MockTrackService {

    func fetchTracks() async throws -> [Track] {
        // ① バンドル内の mock_tracks.json の場所を取得
        guard let url = Bundle.main.url(forResource: "mock_tracks", withExtension: "json") else {
            throw MockTrackServiceError.fileNotFound
        }

        // ② URL からデータを読み込む
        let data = try Data(contentsOf: url)

        // ③ JSON をデコードして [Track] にする
        let decoder = JSONDecoder()
        let tracks = try decoder.decode([Track].self, from: data)

        return tracks
    }
}
