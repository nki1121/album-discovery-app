# AlbumDiscoveryApp

Spotify Web API から取得した楽曲を、マッチングアプリ風のカードスワイプ UI で1曲ずつ発見できる iOS アプリ。
SwiftUI / Swift Concurrency / MVVM を基礎から学び直しながら個人開発した、インターン応募ポートフォリオです。

## スクリーンショット

<!-- ここに Simulator のスクリーンショットを 2〜3 枚貼ってください -->
<!-- 例: 一覧画面、スワイプ中、エラー画面 -->

| 一覧画面 | スワイプ中 |
|---|---|
| (画像) | (画像) |

## プロジェクトの背景

過去に研究の一環で類似機能のアプリを生成 AI に大部分を委ねて開発した経験から、「**動くこと**」と「**理解していること**」は別物だと痛感しました。インターン応募を機に、設計判断ごとに「なぜそうするのか」を言語化しながら、一から再設計・再実装したのが本プロジェクトです。

## 主な機能

- **Spotify Web API 連携** — Client Credentials Flow でアクセストークンを取得し、検索 API を呼び出す
- **カードスワイプ UI** — 1曲ずつアルバムジャケットをカード表示。左右ドラッグで次の曲へ
- **ぼかし背景** — 現在表示中のジャケットを背景にぼかして敷き、曲の切り替えと連動してクロスフェード
- **モックデータ ⇄ 実 API の切り替え** — プロトコル抽象化により、ViewModel に手を加えずデータ源を差し替え可能
- **段階的なローディング / エラー状態の表示**

## 使用技術

| カテゴリ | 技術 |
|---|---|
| 言語 | Swift 5 |
| UI | SwiftUI |
| 非同期処理 | Swift Concurrency (`async`/`await`, `@MainActor`) |
| HTTP通信 | URLSession |
| アーキテクチャ | MVVM + プロトコル指向 |
| 開発環境 | Xcode 26+ |
| CI | GitHub Actions |
| バージョン管理 | Git |

## アーキテクチャ

```
┌────────────────────────────────────────────────────┐
│                       View                          │
│  TrackListView (カードスタック + スワイプジェスチャ)   │
│  TrackCardView (カード1枚の見た目)                    │
└────────────────────────────────────────────────────┘
                       ↑ 状態を読む
                       ↓ ロード要求
┌────────────────────────────────────────────────────┐
│                    ViewModel                        │
│  TrackListViewModel                                 │
│  - @Published tracks/isLoading/errorMessage         │
│  - load() で Service を呼ぶ                          │
└────────────────────────────────────────────────────┘
                       ↑ Track 配列を返す
                       ↓ fetchTracks()
┌────────────────────────────────────────────────────┐
│                  TrackServiceProtocol                │
│   ┌──────────────────┐  ┌────────────────────────┐  │
│   │ MockTrackService │  │ SpotifyTrackService    │  │
│   │ (ローカルJSON)    │  │  ├ SpotifyAuthService  │  │
│   │                  │  │  └ SpotifySearchDTO    │  │
│   └──────────────────┘  └────────────────────────┘  │
└────────────────────────────────────────────────────┘
                              ↓ HTTPS
                       [Spotify Web API]
```

ViewModel は具体的な実装ではなく `TrackServiceProtocol` に依存しているため、
モックデータと実 API を **コード1単語の変更で切り替え可能** な設計になっています。

## ディレクトリ構成

```
album-discovery-app/
├── README.md
├── .github/workflows/ci.yml              # GitHub Actions CI
├── album-discovery-app.xcodeproj/
└── album-discovery-app/
    ├── App/
    │   └── AlbumDiscoveryAppApp.swift    # @main エントリーポイント
    ├── Models/
    │   └── Track.swift                   # ドメインモデル (Codable + Identifiable)
    ├── Services/
    │   ├── TrackServiceProtocol.swift    # 抽象インターフェース
    │   ├── MockTrackService.swift        # ローカルJSON実装
    │   ├── SpotifyAuthService.swift      # OAuth トークン取得
    │   ├── SpotifySearchDTO.swift        # Spotify レスポンスDTOとTrackへの変換
    │   └── SpotifyTrackService.swift     # Spotify検索API実装
    ├── ViewModels/
    │   └── TrackListViewModel.swift      # 画面状態管理 (@MainActor)
    ├── Views/
    │   ├── TrackListView.swift           # カードスタック + スワイプジェスチャ
    │   ├── TrackCardView.swift           # カード1枚分の見た目
    │   └── TrackRowView.swift            # (旧List表示用、将来の拡張用に保持)
    ├── Config/
    │   ├── Secrets.swift                 # 環境変数読み込み (gitignored)
    │   └── Secrets.swift.example         # セットアップ用テンプレート
    ├── Resources/
    │   └── mock_tracks.json              # オフライン開発用データ
    └── Assets.xcassets/
```

## セットアップ

### 必要環境

- macOS 15 以降
- Xcode 26 以降
- [Spotify Developer](https://developer.spotify.com/dashboard) アカウント

### 手順

#### 1. リポジトリをクローン

```bash
git clone <repository-url>
cd album-discovery-app
```

#### 2. Spotify Developer Dashboard でアプリ登録

1. https://developer.spotify.com/dashboard にログイン
2. 「Create app」をクリックし、必要事項を入力(Redirect URI は使用しないため `http://localhost:8080` 等で可)
3. 「Web API」にチェックを入れて Save
4. 作成したアプリの Settings から **Client ID** と **Client Secret** を控える

#### 3. Xcode で開く

```bash
open album-discovery-app.xcodeproj
```

#### 4. ローカル開発用スキームを作成

秘密情報を含むスキームを git 管理対象外にするため、ユーザー専用スキームを作成します:

1. Xcode メニュー: **Product → Scheme → Manage Schemes...**
2. `album-discovery-app` を選択し、**Duplicate** をクリック
3. 複製されたスキームの名前を `album-discovery-app-Local` に変更
4. **「Shared」のチェックを必ず外す**(これが xcuserdata 配下に保存される条件)
5. Close

#### 5. 環境変数を登録

1. Xcode 上部のスキーム選択メニューで `album-discovery-app-Local` を選択
2. **Product → Scheme → Edit Scheme...** を開く
3. 左で **Run** を選択 → 上部タブで **Arguments** を選択
4. **Environment Variables** に以下を追加:

| Name | Value |
|---|---|
| `SPOTIFY_CLIENT_ID` | Spotify から取得した Client ID |
| `SPOTIFY_CLIENT_SECRET` | Spotify から取得した Client Secret |

#### 6. ビルド & 実行

- スキームを `album-discovery-app-Local` に設定したまま ⌘R で実行
- "queen" の検索結果が表示されれば成功

### モックデータで動かしたい場合

Spotify Developer の登録なしで動作確認したい場合、`TrackListViewModel.swift` で Service を切り替えるだけで OK です:

```swift
// album-discovery-app/ViewModels/TrackListViewModel.swift
init(service: TrackServiceProtocol = MockTrackService()) {  // ← SpotifyTrackService → MockTrackService
    self.service = service
}
```

これだけで `mock_tracks.json` から固定の5曲が表示されます。
**ViewModel / View のコードを一切変更しない**ことが、プロトコル抽象化のご利益です。

## 設計上のこだわりポイント

### 1. プロトコル指向による依存性逆転 (DIP)

`TrackListViewModel` は具体的な実装(`MockTrackService` や `SpotifyTrackService`)を知らず、
`TrackServiceProtocol` という抽象にのみ依存しています。

```swift
final class TrackListViewModel: ObservableObject {
    private let service: TrackServiceProtocol   // ← 抽象に依存
    
    init(service: TrackServiceProtocol = MockTrackService()) {  // ← DI
        self.service = service
    }
}
```

本番では `SpotifyTrackService`、テスト時はスタブ、開発時はモック、と用途に応じて
**ViewModel に手を入れずに** 切り替えられます。

### 2. DTO による外部 API 構造とドメインモデルの分離

Spotify が返す JSON 構造は深くネストしており、そのまま View で使うと変更に弱くなります。
`SpotifySearchDTO` で受け取った後、`toTrack()` メソッドで内部の `Track` 型へ変換することで、
**Spotify の仕様変更が ViewModel / View に波及しない** 構造にしています。

```swift
SpotifyTrackDTO (外部APIの形)  →  toTrack()  →  Track (内部の形)
```

### 3. Secret 管理を Xcode Scheme の Environment Variables で実現

API キーを Swift のソースコードに直書きせず、Xcode の Scheme 環境変数に保存しています。

- スキームは **xcuserdata 配下**(`.gitignore` 済み)に保存されるため、コミットされない
- ソースコードには値が含まれないため、誤コミットや外部ツールへの露出を防げる

Secret を **Single Source of Truth** で管理する設計判断です。

### 4. 段階的なコミット履歴

`git log` で実装の道筋を追えるよう、Phase 1(モック表示)→ Phase 2(リファクタリング)→ Phase 3(実 API 連携)と段階的にコミットしています。設計判断のタイミングを履歴で示せる構成です。

## CI/CD

GitHub Actions により、main ブランチへの push および PR 作成時に自動でビルド・テストが実行されます。

設定ファイル: `.github/workflows/ci.yml`

- macOS ランナーで Xcode によるビルドとテストを実行
- 並列実行の重複を `concurrency` で抑制
- テスト結果(`.xcresult`)をアーティファクトとしてアップロード

## 今後の展望

### コア体験の発展(目指す姿)

本アプリのコンセプトは **「ジャケットの第一印象で音楽と出会い、気に入った曲をすぐ Spotify で聴く」** という体験のデザインです。今後は以下の方向に発展させたいと考えています。

- **「好み / 好みでない」のスワイプ判定**
  - 右スワイプで「好み」、左スワイプで「好みでない(スキップ)」と意思表示できるよう変更
  - 現在は方向に関係なく次の曲に進むだけだが、ジェスチャに意味を持たせる
- **好みの楽曲の永続化**
  - SwiftData または UserDefaults を用い、端末ローカルに保存
  - アプリ再起動後も保持される
- **「好み」一覧画面の追加**
  - 保存した楽曲を一覧で確認できる別画面を追加
  - タブ切り替えで「Discover(発見)」と「Library(好みリスト)」を行き来
- **Spotify アプリ連携**
  - 一覧の楽曲をタップすると、`spotify:track:<id>` の URL スキームで Spotify アプリを起動
  - 「気に入った曲をすぐ実環境で聴ける」導線を完成させる

これらの実装により、本アプリは単なる「楽曲表示アプリ」から **「音楽との出会いを設計する体験」** へと進化します。

### その他の改善

- [ ] 検索バー追加(現在はクエリ文字列 "queen" ハードコード)
- [ ] 詳細画面への遷移
- [ ] Spotify の `preview_url` を用いた30秒試聴機能
- [ ] テストの拡充(`TrackListViewModelTests` でスタブ注入による検証)
- [ ] ダーク/ライトモード対応の確認

## 振り返り

### 「動く」と「理解している」を区別する学習姿勢

本プロジェクトの最大の目的は、**コードを自分の言葉で説明できる範囲を広げる**ことでした。
特に意識したのは以下の3点です。

- **設計判断の言語化**: 「なぜ MVVM か」「なぜプロトコルを噛ますか」「なぜ Secret をスキームで管理するか」など、選択の理由を明文化しながら進める
- **段階的な実装**: モックで完成 → リファクタリング → 実 API 連携 と少しずつ進め、各ステップで動作を確認
- **意図したコミット履歴**: 各設計判断のタイミングを `git log` に残し、後から読んで道筋が追える形に

### インシデント対応の経験

開発中、Xcode の共有スキームに API Secret を誤って書き込んでしまうインシデントが発生しました。
`git status` での即時検知 → `git restore` での復旧 → Spotify Dashboard での Secret rotate → ユーザー専用スキームへの設定移行、という対応を行い、リポジトリへの秘密情報流出を未然に防ぎました。
失敗経験を通じて、**問題発生時に冷静に状況を把握し、根本構造まで遡って作り直す姿勢**を実体験で学ぶことができました。

### 課題

- テストコードが未整備。`TrackListViewModelTests` でスタブを注入したユニットテストを今後追加したい
- 検索クエリがハードコードのため、ユーザー入力対応にしたい
- エラー表示は文字列のみ。リトライボタンや具体的なメッセージで改善余地あり

## ライセンス

MIT
