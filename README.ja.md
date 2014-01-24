なにこれ
---
某乗り換え案内サービス（ソースコード参照）を使って、運賃計算をする奴です

Install
---
`bundle install`

Usage
---
以下の形式で csv ファイルを作成し、`main.rb` の引数に指定して実行してください。

""
出発駅1,到着駅1
出発駅2,到着駅2
""

`ruby main.rb routes.csv`
