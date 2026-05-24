import Foundation

// API 認証情報を取得するための窓口。
//
// このファイルには「値」は一切書かれておらず、環境変数を読むコードだけ。
// したがってリポジトリにコミットしても秘密情報の漏洩リスクはない。
//
// 実際の値の管理場所:
//   - ローカル開発: Xcode Scheme の Environment Variables (Run > Arguments)
//                   ※ スキームは xcuserdata 配下に保存されコミットされない
//   - CI/CD:        GitHub Actions の Secrets を env 経由で渡す
//
// セットアップ手順は README.md を参照。

enum Secrets {
    static var spotifyClientID: String {
        ProcessInfo.processInfo.environment["SPOTIFY_CLIENT_ID"] ?? ""
    }

    static var spotifyClientSecret: String {
        ProcessInfo.processInfo.environment["SPOTIFY_CLIENT_SECRET"] ?? ""
    }
}
