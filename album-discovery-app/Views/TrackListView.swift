import SwiftUI

// 楽曲一覧画面 (Phase 1 のメイン画面)。
//
// この View は「ViewModel が持つ状態を描画するだけ」のシンプルな責務に留める。
// データ取得や状態の組み立てロジックは TrackListViewModel 側で行う。
//
// - `@StateObject`: この View がライフサイクルを所有する ViewModel に使う。
//   親から渡されるだけなら @ObservedObject だが、ここでは生成も自分で行うため @StateObject。
struct TrackListView: View {

    @StateObject private var viewModel = TrackListViewModel()

    var body: some View {
        NavigationStack {
            // ViewModel の状態に応じて、表示するViewを切り替える
            Group {
                if viewModel.isLoading {
                    // ローディング中: くるくる回るインジケータ
                    ProgressView("読み込み中…")
                } else if let errorMessage = viewModel.errorMessage {
                    // エラー時: メッセージを赤字で表示
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .padding()
                } else {
                    // 通常時: 楽曲一覧
                    List(viewModel.tracks) { track in
                        HStack {
                            // アルバムジャケット画像 (URLから非同期で取得)
                            AsyncImage(url: track.artworkURL) { image in
                                image.resizable()
                            } placeholder: {
                                Color.gray
                            }
                            .frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 6))

                            // 曲名 + アーティスト名
                            VStack(alignment: .leading) {
                                Text(track.title)
                                    .font(.headline)
                                Text(track.artistName)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Albums")
        }
        // 画面表示時に1回だけロードを実行
        .task {
            await viewModel.load()
        }
    }
}

#Preview {
    TrackListView()
}
