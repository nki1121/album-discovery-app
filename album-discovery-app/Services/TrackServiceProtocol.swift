import Foundation

// Service層が満たすべき「約束ごと」を定義するプロトコル。
//
// このプロトコルに準拠した型(MockTrackService, 将来のSpotifyTrackServiceなど)は、
// すべて同じインターフェースで楽曲データを返せることを保証する。
//
// ViewModelは具体的な型ではなくこのプロトコルに依存するため、
// 実装を差し替えてもViewModelに変更を加える必要がない。
protocol TrackServiceProtocol {
    // TODO: 楽曲データを取得するメソッドのシグネチャを宣言する
    // ヒント: 戻り値は [Track]、非同期で、失敗の可能性あり
    // 形式: func メソッド名() async throws -> 戻り値型
    
    func fetchTracks() async throws -> [Track]
}
