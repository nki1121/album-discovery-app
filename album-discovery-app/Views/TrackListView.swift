import SwiftUI

// 楽曲をカード形式で1曲ずつスワイプして閲覧する画面。(Tinder / タップル風)
struct TrackListView: View {

    @StateObject private var viewModel = TrackListViewModel()

    // 現在表示中のカードのインデックス
    @State private var currentIndex: Int = 0

    // 進行中のドラッグ移動量 (指を離すと .zero にリセット)
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        NavigationStack {
            ZStack {
                blurredBackground
                content
            }
            .navigationTitle("Albums")
        }
        .task {
            await viewModel.load()
        }
    }

    // 現在表示中の曲のジャケットを画面全体にぼかして敷く背景。
    // 曲が切り替わると id が変わり、.transition(.opacity) で滑らかにクロスフェードする。
    private var blurredBackground: some View {
        Group {
            if viewModel.tracks.indices.contains(currentIndex) {
                AsyncImage(url: viewModel.tracks[currentIndex].artworkURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.clear
                }
                .id(viewModel.tracks[currentIndex].id)
                .transition(.opacity)
            }
        }
        .blur(radius: 50)
        .ignoresSafeArea()
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView("読み込み中…")
        } else if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .foregroundStyle(.red)
                .padding()
        } else if viewModel.tracks.isEmpty {
            Text("楽曲が見つかりませんでした")
                .foregroundStyle(.secondary)
        } else if currentIndex >= viewModel.tracks.count {
            endOfStackView
        } else {
            cardStack
        }
    }

    private var endOfStackView: some View {
        VStack(spacing: 16) {
            Text("すべての曲を見ました")
                .font(.title2)
            Button("最初から見直す") {
                withAnimation {
                    currentIndex = 0
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // カードの山積み表示。
    //
    // ForEach + Track.id を使って、SwiftUI に「各カードのアイデンティティ」を伝える。
    // これにより currentIndex 変更時に「同じカードが後ろから前へ移動」と
    // 認識されるため、scaleEffect / offset の変化がスムーズに animate される。
    private var cardStack: some View {
        ZStack {
            ForEach(visibleTracks) { track in
                let depth = depthOf(track)
                TrackCardView(track: track)
                    .frame(maxWidth: 340)   // カードの最大幅を明示的に制限
                    .scaleEffect(depth == 0 ? 1.0 : 0.95)
                    .offset(depth == 0 ? dragOffset : CGSize(width: 0, height: 10))
                    .rotationEffect(depth == 0 ? .degrees(Double(dragOffset.width / 20)) : .zero)
                    .zIndex(Double(-depth))   // depth=0 が一番手前 (大きい zIndex)
                    .gesture(depth == 0 ? swipeGesture : nil)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 24)
        .padding(.vertical, 32)
    }

    // 表示中の曲リスト (現在の曲 + 次の曲、最大2枚)
    private var visibleTracks: [Track] {
        let end = min(currentIndex + 2, viewModel.tracks.count)
        guard currentIndex < end else { return [] }
        return Array(viewModel.tracks[currentIndex..<end])
    }

    // 指定された曲の「現在のカードから見た深さ」を返す
    // 0 = 現在のカード、1 = 次のカード
    private func depthOf(_ track: Track) -> Int {
        guard let index = viewModel.tracks.firstIndex(of: track) else { return 0 }
        return index - currentIndex
    }

    private var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
            }
            .onEnded { value in
                let threshold: CGFloat = 100

                if abs(value.translation.width) > threshold {
                    // スワイプ確定: カードを画面外へ飛ばすアニメーション
                    let direction: CGFloat = value.translation.width > 0 ? 1 : -1
                    withAnimation(.easeOut(duration: 0.3)) {
                        dragOffset = CGSize(
                            width: direction * 1000,
                            height: value.translation.height
                        )
                    }
                    // フライオフ完了後、currentIndex を進める。
                    // ここを withAnimation で包むことで、後ろのカードが
                    // 「後ろの位置 → 前の位置」へ滑らかに移動する。
                    Task {
                        try? await Task.sleep(for: .milliseconds(300))
                        withAnimation(.easeInOut(duration: 0.25)) {
                            currentIndex += 1
                            dragOffset = .zero
                        }
                    }
                } else {
                    // しきい値未満: 元の位置に戻す
                    withAnimation(.spring()) {
                        dragOffset = .zero
                    }
                }
            }
    }
}

#Preview {
    TrackListView()
}
