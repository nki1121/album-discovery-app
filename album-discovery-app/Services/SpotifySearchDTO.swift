import Foundation

// Spotify の /v1/search エンドポイントが返す JSON 構造を Swift で表す DTO 群。
//
// 目的:
//   - Spotify の生 JSON 形式をそのまま受け止めるための型
//   - アプリ内部で使う Track 型とは別に切り出し、外部との境界を作る
//
// この型は「外から来るデータを受け取る」だけが責務なので、Decodable のみに準拠する。

// 一番外側の構造: { "tracks": { "items": [...] } }
struct SpotifySearchResponse: Decodable {
    let tracks: SpotifyTracksContainer
}

// tracks の中身: { "items": [...] }
struct SpotifyTracksContainer: Decodable {
    let items: [SpotifyTrackDTO]
}

// 1曲分の情報
struct SpotifyTrackDTO: Decodable {
    let id: String
    let name: String
    let artists: [SpotifyArtistDTO]
    let album: SpotifyAlbumDTO
}

// アーティスト1人分の情報
struct SpotifyArtistDTO: Decodable {
    let id: String
    let name: String
}

// アルバム1枚分の情報
struct SpotifyAlbumDTO: Decodable {
    let id: String
    let name: String
    let images: [SpotifyImageDTO]
}

// アルバムジャケット画像1枚分の情報 (Spotify はサイズ違いを複数返す)
struct SpotifyImageDTO: Decodable {
    let url: String
    let height: Int?  // 画像によっては取れないケースがあるためオプショナル
    let width: Int?
}

// MARK: - ドメインモデル (Track) への変換
//
// extension を使って SpotifyTrackDTO に「Track に変換する能力」を後付けする。
// こうすることで、変換ロジックを DTO の定義と切り離しつつ、関連付けて読める。

extension SpotifyTrackDTO {

    // SpotifyTrackDTO 1件を、アプリで使う Track 型に変換する
    func toTrack() -> Track {
        // アーティストが複数いる場合があるので、カンマ区切りで連結
        // 例: [Queen, David Bowie] → "Queen, David Bowie"
        let artistNamesJoined = artists
            .map { $0.name }
            .joined(separator: ", ")

        // 画像は複数あるので、最初のもの(通常一番大きい)を使う
        // images が空の場合や URL 不正の場合は nil
        let artworkURL = album.images.first.flatMap { URL(string: $0.url) }

        return Track(
            id: id,
            title: name,
            artistName: artistNamesJoined,
            albumName: album.name,
            artworkURL: artworkURL
        )
    }
}
