import Foundation

// アプリバンドルに同梱された mock_tracks.json を読み込んで [Track] を返す Service。
//
// 今は async/await のシグネチャだけ用意してあるが、中身は同期処理でも問題ない。
// 将来 SpotifyTrackService に差し替えるときに自然に async が活きてくる。
struct MockTrackService {

    func fetchTracks() async throws -> [Track] {
        // TODO: Bundle.main.url(forResource: "mock_tracks", withExtension: "json") で URL を取得
        // TODO: 取得できない場合はエラーを throw する (独自エラー型 or NSError)
        // TODO: Data(contentsOf: url) でデータを読み込む
        // TODO: JSONDecoder().decode([Track].self, from: data) でデコード
        // TODO: デコード結果を return する

        return []
    }
}
