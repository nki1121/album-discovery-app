import Foundation
import Combine

// 一覧画面の状態 (state) を保持し、Service を呼び出す責任を持つクラス。
//
// - `@MainActor`: @Published プロパティの更新は必ずメインスレッドで行う必要があるため、
//   クラス全体をメインアクター上で動かす。これにより `await` から戻った後の代入も安全。
// - `ObservableObject` + `@Published`: SwiftUI の View が変更を検知して再描画できるようにする。
// - `service` はイニシャライザで受け取る (依存性注入)。
//   これにより、テスト時にダミーの Service を差し込むことができる。
@MainActor
final class TrackListViewModel: ObservableObject {

    @Published private(set) var tracks: [Track] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil

    private let service: MockTrackService

    init(service: MockTrackService = MockTrackService()) {
        self.service = service
    }

    // View の .task から呼ばれる、データ読み込みのエントリーポイント。
    func load() async {
        // TODO: isLoading を true にする
        // TODO: errorMessage を nil にリセットする
        // TODO: do { tracks = try await service.fetchTracks() }
        //       catch { errorMessage = error.localizedDescription }
        // TODO: defer もしくは catch/成功 両方で isLoading = false に戻す
    }
}
