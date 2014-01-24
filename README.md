なにこれ
---
某乗り換え案内サービス（ソースコード参照）を使って、運賃計算をする奴です

Install
---
`bundle install`

Usage
---
以下の形式で csv ファイルを作成し、`main.rb` の引数に指定して実行してください。

```
出発駅1,到着駅1
出発駅2,到着駅2
```

`ruby main.rb -f routes.csv -d '2013-01-01 12:00:00'`


実行時のオプションは`ruby main.rb --help`を適宜ご参照下さい。一応貼っとくけど。

```
Usage: main [options]
    -f, --file CSV_FILE              精算する駅を列挙したCSVファイルのパス
    -d, --date DATE                  乗車日時(YYYY-MM-DD HH:mm形式)
```
