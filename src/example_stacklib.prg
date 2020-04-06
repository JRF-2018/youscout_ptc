'This file is an example for STACKLIB.PRG .
CLEAR: VISIBLE 1,1,1,1,1,1: PNLTYPE "OFF": KEY 1,"LIST ": KEY 2,"ERL"+CHR$(13)
KEY 3, "FOR A=0 TO FSP:?FSTACK$[A]:NEXT" + CHR$(13)

'A "magic" above.
'ウエ ハ 「オマジナイ」。

GOSUB @STACKLIB_INIT

'DEBUG mode.
'DEBUG モード。
DEBUG = 1

@EXAMPLE_MAIN

'Discriminate the following variables as 'registers' against normal ones:
'ツギ ノ ヘンスウ ヲ レジスタ ト イイ、クベツ=スル:
'A, A$, R, R$, RR$[], RA$[], RN, RT$, RE$, TMP, TMP$, TMP$[], (ARGNUM)

  A$ = "TEST OK"

  'Callee must preserve variables, but caller must reserve registers in use. 
  'ヨビダシ サキ ハ ヘンスウ ハ ホゾン=セヨ。
  'デモ レジスタ ハ ヨビダシ モト ガ タイヒ=セヨ。
  R$ = A$
  GOSUB @PUSH_RS

  'The 1st argument is "E1". The 2nd argument is "E2".
  'ダイ 1 ヒキスウ ハ "E1"。ダイ 2 ヒキスウ ハ "E2"。
  R$ = "E1": GOSUB @PUSH_RS
  R$ = "E2": GOSUB @PUSH_RS
  GOSUB @EXAMPLE_1

  PRINT R$

  GOSUB @POP_RS
  A$ = R$
  PRINT A$

  END


@EXAMPLE_1 '(ARG1$:STRING, ARG2$:STRING)
  ARGNUM = 2: R$ = "@EXAMPLE_1": GOSUB @ENTER
  'By @ENTER, set BP for accessing the arguments.
  '@ENTER デ、ヒキスウ ノ サンショウ ノ タメ BP ヲ セッテイ。

  'Preserve variables as local allocation.
  'ローカル ヘンスウ ニ ツカウタメ ホゾン。
  R$ = ARG1$
  GOSUB @PUSH_RS
  R$ = ARG2$
  GOSUB @PUSH_RS

  ARG1$ = STACK$[BP + 1]
  ARG2$ = STACK$[BP + 2]

  A$ = "OK " + ARG1$ + " & " + ARG2$

  'Pop preserved variable.
  'ホゾン=シタ ヘンスウ ヲ モト ニ モドス。
  GOSUB @POP_RS
  ARG1$ = R$
  GOSUB @POP_RS
  ARG2$ = R$

  'By @LEAVE, reset BP and consume stack for the arguments.
  '@LEAVE デ、BP ヲ モノ ニ モドシ、ヒキスウ=ヨウ ノ STACK$ ヲ ヨミトバス。
  ARGNUM = 2: GOSUB @LEAVE

  RT$ = "STRING"
  R$ = A$
  RETURN


'To generate QR code:
'QR コード ヲ ツクル ニハ:

'perl gen_qrcode.pl -N EXAMPLE0 example_stacklib.prg stacklib.prg
