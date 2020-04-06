

    README file of Youscout for PTC

    (Created: 2013-02-19 +0900, Time-stamp: <2013-04-13T06:32:17Z>)


■ About "Youscout for PTC"

See "index.html".


■ About this distribution

This distribution includes the sources of YOUSCOUT, MKJRFTRT and
YSCHELP and some development accessories for SMILE BASIC of the Petit
Computer in Perl-runnable PCs.

This includes also the file named "URI.txt".  This may be pseudo URL
of the distribution because the provider of my site doesn't allow over
1M bytes per file.  It is only an indicator.

To re-'compile', simply 'make all' if you can use Unix-like commands
(on Linux or on Cygwin of Windows, etc.) and already have installed
the "Data::Petitcom" Perl-module from CPAN.  If you don't know some of
these words, this leads you a difficult way, you know.


■ LOG

Only in Japanese (with Kanji) below.



    README ファイル - ヨウスコウ PTC


■ 「ヨウスコウ PTC」ニ カンシテ

「index.html」ヲ ミヨ。


■ ハイフブツ ニ カンシテ

コノ ハイフブツ ニハ YOUSCOUT, MKJRFTRT, YSCHELP ノ ソース ガ フクマレ
テイル。マタ、Perl ノアル PC ジョウ デノ プチコンmkII ノ SMILE BASIC ヨ
ウ ノ カイハツ=キット モフクマレテイル。

コレ ニハ "URI.txt" トイウ ファイル モ フクマレテイル。タダシ、カカレ
タ URL ハ ダミー デアル カノウセイ ガアル。ナゼナラ、プロバイダ ノ 1M
バイト セイゲン ニヨリ ファイル ヲ ソコニ オケイコト ガ アルカラ。ソノ
バアイ、タダ ノ シキベツシ デシカナイ。

ハイフブツ ヲ「コンパイル」シナオス ニハ、"make all" スレバ イイ。Unix
フウ ノ コマンド ガ ツカエ(タトエバ Linux ヤ Cygwin ジョウ)、スデニ
"Data::Petitcom" トイウ Perl モジュール ヲ CPAN カラ インストールシテイ
レバ、ソレダケデイイ。モシ、イッテルコト ガ ヨクワカラナイ バアイ、ココ
カラ サキ、ナンジ ノ ミチ ハ ケワシイ ト シレ。


■ LOG

  2013-01-05 -- 購入した 3DS LL が届く。はじめから、易双六の DS 版を作
                るつもりで、プチコンmkII をまず購入。

  2013-01-07 -- JRF Tarot の tiny 版への変換スクリプトを書く。

  2013-01-08 -- Data::Petitcom の存在を知り gen_qrcode.pl を作りはじめ
                る。

  2013-01-1? -- このころ、プチコンの制限の多いプログラミングに苦戦して
                いた。

  2013-01-21 -- 一つのファイルでテストをしてきたが行数が9999行を超えた
                ため、MKJRFTRT を作る。

  2013-01-30 -- つい、gen_qrcode.pl に parse ルーチン まで書いてしまう。
  	     	分割管理のプログラムが大きくなりすぎ、Web にある文法
  	     	チェッカを使うのは面倒になっていた。

  2013-02-11 -- これまでテスト集の状態だったものをゲームのかたちに書き
  	        上げる。YOUSCOUT のかたちができる。どうにも行数が足りな
  	        いので YSCHELP も分ける。

  2013-02-14 -- 診療医にちょっとだけゲームに触ってもらう。はじめて私以
	        外の人に見てもらった。このために、とにかく動くところま
	        で持ってきた。

  2013-02-18 -- 配布準備をしながら YSCHELP の文を書き上げる。マニュア
  	        ルのトップページの「。」から入る「テスト ノ メイキュウ」
  	        も含めて。

  2013-02-21 -- バージョン 0.01。PTC 版、初公開。

  2013-02-23 -- バージョン 0.02。@CON_PRINT や @HLP_VIEW の記事を書いて
                いて気付た部分や、固式の判定ミスなどバグの修正。

  2013-02-25 -- バージョン 0.03。アニメーション時の位置決めや内部ルー
                チンの改良。「テスト ノ メイキュウ」のバグ取りなど。

  2013-03-01 -- バージョン 0.04。MOVE or STAY 選択のときタイトルに戻ろ
  	        うとするとエラー終了他、バグ取り。CON_PRINT の改良。そ
  	        して、大きいところでは、「大アルカナの影響」を 1.5 倍
  	        などにすると出る端数を切り上げる処理を足した。

  2013-03-05 -- バージョン 0.05。HLP_VIEW に \P を追加。[7][8] のカー
                ド表示位置を中央寄りに改める。

  2013-04-13 -- バージョン 0.06。「テスト ノ メイキュウ」のバグ取りを
                含む小さな改良のみ。


(This file was written in Japanese/UTF8.)
