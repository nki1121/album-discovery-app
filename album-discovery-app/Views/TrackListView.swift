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
        // TODO: NavigationStack { ... } で包み、 .navigationTitle("Albums") を付ける
        //
        // TODO: 表示の出し分けを実装する
        //   - viewModel.isLoading が true → ProgressView()
        //   - viewModel.errorMessage が非 nil → エラーメッセージを Text で表示
        //   - それ以外 → List(viewModel.tracks) { track in 行ビュー }
        //
        // TODO: 行ビュー (とりあえずこの中にインラインで書いてもOK)
        //   HStack {
        //       AsyncImage(url: track.artworkURL) { image in image.resizable() }
        //                  placeholder: { Color.gray }
        //           .frame(width: 56, height: 56)
        //           .clipShape(RoundedRectangle(cornerRadius: 6))
        //       VStack(alignment: .leading) {
        //           Text(track.title).font(.headline)
        //           Text(track.artistName).font(.subheadline).foregroundStyle(.secondary)
        //       }
        //   }
        //
        // TODO: View に .task { await viewModel.load() } を付け、初回表示時にロードを走らせる

        Text("TODO: TrackListView を実装する")
    }
}

#Preview {
    TrackListView()
}
