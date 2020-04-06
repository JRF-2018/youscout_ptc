'== BEGIN YSCMSG ==
@YSCMSG_INIT
YSCMSG_VER$ = "0.04" 'Time-stamp: <2013-02-26T23:43:53Z>
YSCMSG_URI$ = "http://jrf.cocolog-nifty.com/archive/youscout/ptc/yscmsg.prg"


MSG_MOVE$ = "": MSG_STAY$ = "": MSG_OBLIGED$ = "": MSG_CHOSE$ = "": MSG_NONE$ = ""
MSG_CARDS$ = "": MSG_MJTRT$ = "": MSG_INV$ = "": MSG_UTRG$ = "": MSG_LTRG$ = ""
MSG_SWORD$ = "": MSG_COIN$ = "": MSG_CUP$ = "": MSG_WAND$ = ""
MSG_ACE$ = "": MSG_JACK$ = "": MSG_CABALLERO$ = "": MSG_QUEEN$ = "": MSG_KING$ = ""

DIM MSG_TRTMJ$[22], MSG_HXG$[64 + 4]

'PROVIDE "YSCMSG"
RETURN

'You may not write "\\" in messages, but "\x5C",
'because it simplifies decoration of strings.

'メッセージ デハ "\\" ヲ ツカッテ ハ ナラナイ。"\x5C" ヲ ツカウ。
'ブン ノ シュウショク ヲ ヨウイ ニ スル タメ。

'Load messaging words for youscout.
@LOAD_MSG_YSCWDS '(LANG$:STRING): NONE
  R$ = "@LOAD_MSG_YSCWDS": ARGNUM = 1: GOSUB @ENTER

  R$ = LANG$
  GOSUB @PUSH_RS
  R = I
  GOSUB @PUSH_R

  LANG$ = STACK$[BP + 1]

  RESTORE "@MSG_YSCWDS_" + LANG$
  READ MSG_MOVE$, MSG_STAY$, MSG_OBLIGED$, MSG_CHOSE$, MSG_NONE$
  READ MSG_CARDS$, MSG_MJTRT$, MSG_INV$, MSG_UTRG$, MSG_LTRG$
  READ MSG_SWORD$, MSG_COIN$, MSG_CUP$, MSG_WAND$
  READ MSG_ACE$, MSG_JACK$, MSG_CABALLERO$, MSG_QUEEN$, MSG_KING$

  RESTORE "@MSG_TRTMJ_" + LANG$
  FOR I = 0 TO 22 -1
   READ MSG_TRTMJ$[I]
  NEXT

  RESTORE "@MSG_HXG_" + LANG$
  FOR I = 0 TO 64 + 4 -1
   READ MSG_HXG$[I]
  NEXT

  GOSUB @POP_R
  I = R
  GOSUB @POP_RS
  LANG$ = R$

  ARGNUM = 1: GOSUB @LEAVE
  RETURN


@MSG_YSCWDS_EN
DATA "Move", "Stay", "obliged", "chose", "none"
DATA "Cards", "Major arcanum", "Inv.", "upper trigram", "lower trigram"
DATA "Sword", "Coin", "Cup", "Wand", "Ace", "Page", "Knight", "Queen", "King"
@MSG_YSCWDS_JA
DATA "ウゴク", "トドマル", "シカナイ", "エランダ", "ナシ"
DATA "カード", "ダイ アルカナ", "ギャク", "ジョウカ", "シモカ"
DATA "ツルギ", "カネ", "ハイ", "シャクジョウ", "ハジメ", "ワラシ", "モノノフ", "ヒメ", "オオキミ"


@MSG_TRTMJ_EN
DATA "The Fool"
DATA "The Magician", "The High Priestess", "The Empress", "The Emperor", "The Hierophant"
DATA "The Lovers", "The Chariot", "Strength", "The Hermit", "Wheel of Fortune"
DATA "Justice", "The Hanged Man", "Death", "Temperance", "The Devil"
DATA "The Tower", "The Star", "The Moon", "The Sun", "Judgement", "The World"

@MSG_TRTMJ_JA
DATA "オロカモノ"
DATA "マジナイシ", "ミコ", "スメラミ", "スメラギ", "ホッス"
DATA "コイビト ドモ", "シチョウ", "チカラ", "インジャ", "メグリアワセ"
DATA "ギ", "ツルシ オトド", "シ", "セツ", "マ"
DATA "ウテナ", "ホシ", "ツキ", "ヒ", "ミ サバキ", "ヨ"


@MSG_HXG_EN
@MSG_HXG_JA
DATA "コン Field", "ハク Stripping", "ヒ Grouping", "カン Viewing"
DATA "ヨ Providing-For", "シン Prospering", "スイ Clustering", "ヒ Obstruction"
DATA "ケン Humbling", "ゴン Bound", "ケン Limping", "ゼン Infiltrating"
DATA "ショウカ Small Exceeding", "リョ Sojourning", "カン Conjoining", "トン Retiring"
DATA "シ Leading", "モウ Enveloping", "カン Gorge", "カン Dispersing"
DATA "カイ Taking-Apart", "ビセイ Not-Yet Fording", "コン Confining", "ショウ Arguing"
DATA "ショウ Ascending", "コ Corrupting", "セイ Welling", "ソン Ground"
DATA "コウ Persevering", "テイ Holding", "タイカ Great Exceeding", "コウ Coupling"
DATA "フク Returning", "イ Swallowing", "チュン Sprouting", "エキ Augmenting"
DATA "シン Shake", "ゼイゴウ Gnawing Bite", "ズイ Following", "ムボウ Without Embroiling"
DATA "メイイ Brightness Hiding", "ヒ Adorning", "キセイ Already Fording", "カジン Dwelling People"
DATA "ホウ Abounding", "リ Radiance", "カク Skinning", "ドウジン Concording People"
DATA "リン Nearing", "ソン Diminishing", "セツ Articulating", "チュウフ Centre Confirming"
DATA "キマイ Converting The Maiden", "ケイ Polarising", "ダ Open", "リ Treading"
DATA "タイ Pervading", "ダイチク Great Accumulating", "ジュ Attending", "ショウチク Small Accumulating"
DATA "タイソウ Great Invigorating", "タイユウ Great Possessing", "カイ Parting", "ケン Force"
DATA "セン ケン Force Whirl", "セン コン Field Whirl", "ジュウ ケン Force Eclipse", "ジュウ コン Field Eclipse"


@MSG_MAINMNU_EN
DATA "Start", "@MODE_START", "\c4English\cR/ニホンゴ", "@MODE_SET_LANG,JA"
DATA "Options", "@MODE_OPT", "Help", "@MODE_HELP", "End", "@END", "", ""
@MSG_MAINMNU_JA
DATA "ハジメル", "@MODE_START", "\c4ニホンゴ\cR/English", "@MODE_SET_LANG,EN"
DATA "セッテイ", "@MODE_OPT", "セツメイ", "@MODE_HELP", "シュウリョウ", "@END", "", ""

@MSG_OPTMNU_EN
DATA "Terminal Card Appears", "@MSG_OPTTERM_EN,terminals"
DATA "Values of Court Cards", "@MSG_OPTCCD_EN,court_cd"
DATA "Influence of Major Arcana", "@MSG_OPTMAI_EN,ma_inf"
DATA "Exchange of 8 and 11", "@MSG_OPTSWAP_EN,swap_8_11"
DATA "Upper Display", "@MSG_OPTUREV_EN,urev"
DATA "Language", "@MSG_OPTLANG_EN,lang"
DATA "", ""
@MSG_OPTMNU_JA
DATA "シュウリョウ カード ノ クリカエシ", "@MSG_OPTTERM_JA,terminals"
DATA "コートカード ノ スコア", "@MSG_OPTCCD_JA,court_cd"
DATA "ダイ アルカナ ノ エイキョウ", "@MSG_OPTMAI_JA,ma_inf"
DATA "8 ト 11 ノ イレカエ", "@MSG_OPTSWAP_JA,swap_8_11"
DATA "ウエガメン", "@MSG_OPTUREV_JA,urev"
DATA "コトバ", "@MSG_OPTLANG_JA,lang"
DATA "", ""

@MSG_OPTTERM_EN
DATA "0", "No Game", "1", "Once", "3", "3 times", "5", "5 times", "10", "10 times", "", ""
@MSG_OPTTERM_JA
DATA "0", "ゲーム ナシ", "1", "1 カイ", "3", "3 カイ", "5", "5 カイ", "10", "10 カイ", "", ""
@MSG_OPTCCD_EN
@MSG_OPTCCD_JA
DATA "K14", "K=14,Q=13,C=12,J=11", "K13a", "K=13,Q=12,C=12,J=11"
DATA "K13b", "K=13,Q=12,C=11,J=11", "K10", "K=10,Q=10,C=10,J=10", "", ""
@MSG_OPTMAI_EN
@MSG_OPTMAI_JA
DATA "3", "3", "2.5", "2.5", "2", "2", "1.5", "1.5", "1", "1", "", ""
@MSG_OPTSWAP_EN
DATA "memorial","Memorial Method","expansive","Expansive Method","solid","Solid Method","",""
@MSG_OPTSWAP_JA
DATA "memorial", "キネン シキ", "expansive", "カイ シキ", "solid", "コ シキ", "", ""
@MSG_OPTUREV_EN
DATA "0", "Upright", "1", "Reversal", "", ""
@MSG_OPTUREV_JA
DATA "0", "セイ イチ", "1", "タイメン", "", ""
@MSG_OPTLANG_EN
DATA "EN", "English", "JA", "Japanese", "", ""
@MSG_OPTLANG_JA
DATA "JA", "ニホンゴ", "EN", "エイゴ", "", ""


@MSG_RSTQ_EN
DATA "Do you go back to the title?", ""
@MSG_RSTQ_JA
DATA "タイトル ニ モドリマスカ?", ""

@MSG_RSTQYN_EN
DATA "Go back to the title.", "No, continue."
@MSG_RSTQYN_JA
DATA "タイトル ニ モドル。", "イイエ。ツヅケル。"

@MSG_THISHXG_EN
DATA "The hexagram is '\[0]'.", ""
@MSG_THISHXG_JA
DATA "エキ ノ カ ハ 「\[0]」 デス。", ""

@MSG_NOPLSL_EN
DATA "This place cannot be selected.", ""
@MSG_NOPLSL_JA
DATA "ココ ハ センタク デキマセン。", ""

@MSG_MOVEQ_EN
DATA "Choose stay or move.", ""
@MSG_MOVEQ_JA
DATA "ウゴク カ トドマル カ エランデ クダサイ。", ""

@MSG_CLKTLN_EN
DATA "Click the talon or push \N[A].\n", ""
@MSG_CLKTLN_JA
DATA "カード ヤマ ヲ クリック スル カ、\N[A] ヲ オシテ クダサイ。\n", ""

@MSG_CHSPLS_EN
DATA "Choose the first place of the token.\n", ""
@MSG_CHSPLS_JA
DATA "トークン ノ ハジメ ノ バショ ヲ エランデ クダサイ。\n", ""

@MSG_CHSPLSS_EN
DATA "But '\[0]' restricts you onto the \[1].", ""
@MSG_CHSPLSS_JA
DATA "タダシ 「\[0]」 ノ タメ、\[1] ニ シカ オケマセン。", ""

@MSG_START_EN
DATA "Sort out 8 and 11 from the major arcana.\n"
DATA  "Shuffle the rest and make a board by 6 cards of them.", ""
@MSG_START_JA
DATA "ダイ アルカナ カラ 8 ト 11 ヲ ノゾキ、ノコリ ヲ シャッフル。\n6 マイ ヒイテ バン ヲ ツクリマス。", ""

@MSG_SWAPMEM_EN
DATA "Swap 8 and 11 after memory of the history of Tarot.\n \[0]", ""
@MSG_SWAPMEM_JA
DATA "タロット ノ レキシ ヲ キネン シ、8 ト 11 ガ アレバ イレカエマス。\n \[0]", ""

@MSG_SWAPEXP_EN
DATA "Swap 8 and 11 by the Expansive Method, after memory of the history of Tarot.\n \[0]", ""
@MSG_SWAPEXP_JA
DATA "タロット ノ レキシ ヲ キネン シ、8 ト 11 ガ アレバ カイシキ ニ シタガッテ イレカエマス。\n \[0]", ""

@MSG_SWAPSOL_EN
DATA "Swap 8 and 11 by the Solid Method, after memory of the history of Tarot.\n \[0]", ""
@MSG_SWAPSOL_JA
DATA "タロット ノ レキシ ヲ キネン シ、8 ト 11 ガ アレバ コシキ ニ シタガッテ イレカエマス。\n \[0]", ""

@MSG_SWAPNO_EN
DATA "No need for the swap.", ""
@MSG_SWAPNO_JA
DATA "イレカエ ノ ヒツヨウ ハ アリマセン。", ""

@MSG_CHSTKN_EN
DATA "Determine the first place of the token.\n", ""
@MSG_CHSTKN_JA
DATA "ハジメ ニ トークン ヲ オク バショ ヲ キメテクダサイ。\n", ""

@MSG_TERM0_EN
DATA "Go back to the title, because you chose 'No Game'.", ""
@MSG_TERM0_JA
DATA "「ゲーム ナシ」ニ セッテイ サレテイルタメ ココデ シュウリョウ デス。", ""

@MSG_TERMN_EN
DATA "Drew the terminal card.(\[0]/\[1])\nShuffle the cards except for those on the board.", ""
@MSG_TERMN_JA
DATA "シュウリョウ カード ヲ ヒキマシタ。(\[0]/\[1])\nバン ニ アルモノ イガイ ノ カード ヲ シャッフル シマス。", ""

@MSG_TERME_EN
DATA "Drew the termainal card.(\[0]/\[0])\nThe game is over.", ""
@MSG_TERME_JA
DATA "\[0]ドメ ノ シュウリョウ カード ヲ ヒキマシタ。\nゲーム シュウリョウ デス。", ""

@MSG_TERMU_EN
DATA "You must win at the end if the token places in the senior or in the fifth.", ""
@MSG_TERMU_JA
DATA "ジョウ コウ カ 5 コウ ニ トークン ガ アレバ、アナタ ノ「カチ」デシタ。", ""

@MSG_TERML_EN
DATA "You must win at the end if the token places in the second or in the fifth.", ""
@MSG_TERML_JA
DATA "2 コウ カ 5 コウ ニ トークン ガ アレバ、アナタ ノ「カチ」デシタ。", ""

@MSG_CONDU_EN
DATA "You win at the end if the token places in the senior or in the fifth.", ""
@MSG_CONDU_JA
DATA "サイゴ ニ ジョウ コウ カ 5 コウ ニ トークン ガ アレバ、アナタ ノ「カチ」デス。", ""

@MSG_CONDL_EN
DATA "You win at the end if the token places in the second or in the fifth.", ""
@MSG_CONDL_JA
DATA "サイゴ ニ 2 コウ カ 5 コウ ニ トークン ガ アレバ、アナタ ノ「カチ」デス。", ""

@MSG_YWIN_EN
DATA "The board shows that YOU WIN.", ""
@MSG_YWIN_JA
DATA "アナタ ノ「カチ」ノ ヨウデス。", ""

@MSG_YLOSE_EN
DATA "The board shows that YOU LOSE.", ""
@MSG_YLOSE_JA
DATA "アナタ ノ「マケ」ノ ヨウデス。", ""

@MSG_DREW_EN
DATA "You drew the card '\[2] of \[1]s' in the \[0].\n", ""
@MSG_DREW_JA
DATA "\[0] デ「\[1] ノ \[2]」ノ カード ヲ ヒキマシタ。\n", ""

@MSG_OSTAY_EN
DATA "You must stay.", ""
@MSG_OSTAY_JA
DATA "トドマル シカ アリマセン。", ""

@MSG_OMOVE_EN
DATA "You must move.", ""
@MSG_OMOVE_JA
DATA "ウゴク シカ アリマセン。", ""

@MSG_CRULE_EN
DATA "Changing rule of this time:\n", ""
@MSG_CRULE_JA
DATA "コンカイ ノ コウカン ルール:\n", ""

@MSG_GMOVE_EN
DATA "\[0] > \[1]?\n → Yes, MOVE.", ""
@MSG_GMOVE_JA
DATA "\[0] > \[1]?\n → ダイ ナリ。ウゴク。", ""

@MSG_GCHSE_EN
DATA "\[0] > \[1]?\n → Yes, CHOOSE.", ""
@MSG_GCHSE_JA
DATA "\[0] > \[1]?\n → ダイ ナリ。エラブ。", ""

@MSG_LSTAY_EN
DATA "\[0] > \[1]?\n → No, STAY.", ""
@MSG_LSTAY_JA
DATA "\[0] > \[1]?\n → ショウ ナリ。トドマル。", ""

@MSG_CDNEED_EN
DATA "No necessary card.\n → STAY.", ""
@MSG_CDNEED_JA
DATA "ヒツヨウ ナ カード ガ アリマセン。\n → トドマル。", ""

@MSG_CDNSUT_EN
DATA "No suitable card.\n → STAY.", ""
@MSG_CDNSUT_JA
DATA "テイトウ ナ カード ガ アリマセン。\n → トドマル。", ""

@MSG_CDNONE_EN
DATA "No card = 0", ""
@MSG_CDNONE_JA
DATA "カード ナシ = 0", ""

'== END YSCMSG ==
