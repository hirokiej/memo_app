# メモアプリ
フィヨルドブートキャンプの課題で作成した、Sinatraを使った簡単なメモアプリケーションです。

## 環境

* Ruby 3.2.0
* psql (PostgreSQL) 14.13

## 使い方

1. インストール
 PostgreSQLをインストール
 ```
 brew install postgresql
 ```
 データベースを作成します
 ```
 createdb my_memo_db
 ```
 PostgreSQLを起動し、`my_memo_db`に接続します
 ```
 psql my_memo_db
 ```
 テーブルを作成します
 ```
 CREATE TABLE memos (id SERIAL PRIMARY KEY, title text NOT NULL, content text NOT NULL);
 ```
`\q`でpsqlを終了

2. 実行方法
 `git clone`をします
 ```
 git clone https://github.com/hirokiej/memo_app.git

 ```
 必要なgemをインストールします
 ```
 bundle install
 ```
 アプリケーションを起動します
 ```
 bundle exec ruby app.rb
 ```
3. アクセス
 以下のURLをブラウザでアクセスします
 http://localhost:4567/
