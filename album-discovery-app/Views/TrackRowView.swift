import SwiftUI

// 楽曲一覧の「1行ぶん」の見た目を担当するView。
//
// - 親から `track: Track` を受け取り、それを描画するだけ。
// - 自分で状態を持たない (ViewModelも持たない) 純粋な表示部品。
// - こうしておくことで、Previewでダミーデータを渡して見た目だけ確認できる。
struct TrackRowView: View {

    // 表示する楽曲データ。親から渡される。
    let track: Track

    var body: some View {
        // TODO: TrackListView の HStack { ... } の中身をここに移動する
        //   - AsyncImage (アルバムジャケット)
        //   - VStack
        //       - Text(track.title)
        //       - Text(track.artistName)
        HStack {
            AsyncImage(url: track.artworkURL) { image in
                image.resizable()
            } placeholder: {
                Color.gray
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 6))

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

#Preview {
    // ダミーのTrackを1件用意して、行の見た目を確認できるようにする
    TrackRowView(
        track: Track(
            id: "preview",
            title: "Bohemian Rhapsody",
            artistName: "Queen",
            albumName: "A Night at the Opera",
            artworkURL: URL(string: "https://picsum.photos/seed/queen/300/300")
        )
    )
}
