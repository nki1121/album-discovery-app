import SwiftUI

// アプリのエントリーポイント。
// `@main` が付いた型がアプリ起動時に最初に評価される。
// ここでは最初に表示する画面 (TrackListView) を WindowGroup に渡すだけにしておく。
@main
struct AlbumDiscoveryAppApp: App {
    
    init() {
        Task {
            do {
                let tracks = try await MockTrackService().fetchTracks()
                print("成功: \(tracks.count)件")
                for track in tracks {
                    print("- \(track.title) / \(track.artistName)")
                }
            } catch {
                print("エラー: \(error)")
            }
        }
        
        
    }
    
    var body: some Scene {
        WindowGroup {
            TrackListView()
        }
    }
}
