import SwiftUI

// 楽曲1曲分をカードとして大きく表示するView。
// ジェスチャは持たず、見た目だけが責務。
struct TrackCardView: View {
    let track: Track

    var body: some View {
        VStack(spacing: 0) {
            // アルバムジャケット (常に正方形)
            //
            // Color.clear をサイズ枠として使うパターン。
            // - Color.clear: 透明だが、レイアウト上の「枠」として機能する
            // - .aspectRatio(1, contentMode: .fit): 親の幅に応じた正方形を強制
            // - .overlay: その上に AsyncImage を重ねる
            // - .clipped: はみ出した部分を切り取る
            //
            // AsyncImage に直接 aspectRatio を付けると、画像の自然サイズと
            // 競合して意図したサイズにならないことがあるための回避策。
            Color.clear
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    AsyncImage(url: track.artworkURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                }
                .clipped()

            // 楽曲情報
            VStack(alignment: .leading, spacing: 6) {
                Text(track.title)
                    .font(.headline)
                    .lineLimit(2)

                Text(track.artistName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Text(track.albumName)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 8)
    }
}

#Preview {
    TrackCardView(
        track: Track(
            id: "preview",
            title: "Bohemian Rhapsody",
            artistName: "Queen",
            albumName: "A Night at the Opera",
            artworkURL: URL(string: "https://picsum.photos/seed/queen/600/600")
        )
    )
    .padding()
}
