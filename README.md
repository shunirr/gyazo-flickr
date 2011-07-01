# Gyazo To Flickr
## これは何？

Gyazo アプリから Flickr にアップロードできるサーバアプリです。

## セットアップ

以下のソフトウェアに依存しています。

* Ruby 1.9.2 (1.8.x でも動くかもしれませんが未検証です)
* Bundler

Bunlder で、必要なライブラリを自動的にインストールします。

    bundle install

次にセットアップスクリプトを動かします。

    bundle exec ruby setup.rb

セットアップスクリプトに従って操作をしてください。基本的には Enter を押してクリックするだけで終了します。

## 実行

ここまでくれば実行するだけです。

    bundle exec rackup

rackup を行なうと、 9292 番ポートで待ち受けをはじめます。デーモン化したり、 nginx で繋いだりしましょう。


## Gyazo の設定

アップロードは /upload というパスで行なえます。あなたが gyazowin を使っているのならば、以下のような ini ファイルを書くことで利用できるでしょう。

    [gyazowin+]
    upload_server=gyazo-upload.example.com
    upload_path=upload

    use_ssl=no
    ssl_check_cert=no

    use_auth=no
    auth_id=
    auth_pw=

    up_dialog=no
    copy_url=no
    copy_dialog=no
    open_browser=yes

