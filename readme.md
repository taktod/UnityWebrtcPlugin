# 概要

unityからwebrtcをcallする動作をつくっていくサンプルプロジェクト

# いそがしい人向け

gclientでソースコードをコンパイルするのがめんどうな人は
lib*.aをいれてあるので、それをつかえばいいのですが、
headerファイルがなくコンパイルが通らないので
~/Documents/gn/webrtcというディレクトリをつくり
そこで

```
$ git clone https://webrtc.googlesource.com/src.git
$ cd src
$ git checkout a102f0f112df
```

を実行してheaderファイルを準備してもらえればとおもいます。

とおもったらlibwebrtc.aがおおきすぎてgithubにあげれませんでした。
どこかにおいとくところがあればいいんですが・・・
