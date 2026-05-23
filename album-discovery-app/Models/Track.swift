import Foundation

// 楽曲1件を表すデータ型。
//
// - `Identifiable`: SwiftUI の List / ForEach で要素を一意に識別するために必要。
// - `Codable`: JSON との相互変換を可能にする (mock_tracks.json をデコードする用途)。
// - `Hashable`: NavigationStack の path や Set などで使えるようにしておく。
//
// プロパティ名は mock_tracks.json のキーと一致させること。
// 一致しない場合は CodingKeys で対応付けする。
struct Track: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let artistName: String
    let albumName: String
    let artworkURL: URL?
}
