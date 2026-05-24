import SwiftUI

// アプリのエントリーポイント。
// `@main` が付いた型がアプリ起動時に最初に評価される。
// ここでは最初に表示する画面 (TrackListView) を WindowGroup に渡すだけにしておく。
@main
struct AlbumDiscoveryAppApp: App {
    
    var body: some Scene {
        WindowGroup {
            TrackListView()
        }
    }
}
