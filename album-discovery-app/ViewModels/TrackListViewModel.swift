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
        // ① ローディング状態に入る + 前回のエラーをクリア
        isLoading = true
        errorMessage = nil

        // ② この関数を抜けるときに、必ず isLoading を false に戻す
        defer { isLoading = false }

        // ③ Service を呼ぶ。成功すれば tracks に代入、失敗すれば errorMessage に代入。
        do {
            tracks = try await service.fetchTracks()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
