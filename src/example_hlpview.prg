CLEAR: PNLTYPE "OFF": KEY 1,"LIST ": KEY 2,"ERL"+CHR$(13)
DEBUG = 1: KEY 3, "FOR A=0 TO FSP:?FSTACK$[A]:NEXT" + CHR$(13)
ACLS

GOSUB @STACKLIB_INIT
GOSUB @STDLIB_INIT
GOSUB @CTRLLIB_INIT
GOSUB @HLPVIEW_INIT

CLIP_CX[1] = 1
CLIP_CY[1] = 1
CLIP_CW[1] = CON_WIDTH - 2
CLIP_CH[1] = CON_HEIGHT - 2

@MAIN
  R$ = "@TST_START_JA": GOSUB @PUSH_RS
  GOSUB @HLP_VIEW

  END

@TST_START_JA
DATA "\C[B]ソンナ「バカ」ニ トウ。"
DATA "ワタシ ハ バカ？\n\n"
DATA "●\L[@TST_YES_JA]ハイ。\n\n"
DATA "●\L[@TST_NO_JA]イイエ。\n\n"
DATA ""

@TST_YES_JA
DATA "\F[B]"
DATA "バカ ッテ イウ ホウ ガ バカ。バーカ。\n\n"
DATA "\L[R:@TST_START_JA]"
DATA ""

@TST_NO_JA
DATA "ワカッテルジャーン。\n\n"
DATA "\L[R:@]"
DATA ""

@TST_START_EN
DATA "\C[B]Now, I ask you, 'stupid'. "
DATA "Am I stupid?\n\n"
DATA "●\L[@TST_YES_EN]Yes.\n\n"
DATA "●\L[@TST_NO_EN]No.\n\n"
DATA ""

@TST_YES_EN
DATA "\F[B]"
DATA "It is stupid who calls a man 'stupid'. Get it, Stuuupid?\n\n"
DATA "\L[R:@TST_START_EN]"
DATA ""

@TST_NO_EN
DATA "Oh, you are the man who knows the truth.\n\n"
DATA "\L[R:@]"
DATA ""

@THIS_HLP_INIT
HLP_START_L$ = "@TST_START_JA"
RETURN

'To 'compile'

'perl gen_qrcode.pl -N EXAMPLEH example_hlpview.prg stacklib.prg stdlib.prg ctrllib.prg hlpview.prg

'or

'perl gen_qrcode.pl -N EXAMPLEH hlpview.prg example_hlpview.prg stacklib.prg stdlib.prg ctrllib.prg
