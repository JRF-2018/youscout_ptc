'== BEGIN HLPVIEW ==
CLEAR: VISIBLE 1,1,1,1,1,1: PNLTYPE "OFF": KEY 1,"LIST ": KEY 2,"ERL"+CHR$(13)
'HLPVIEW_VER$ and HLPVIEW_URI$ are below. 'Time-stamp: <2013-03-05T11:27:53Z>

DEBUG = 1
KEY 3, "FOR A=0 TO FSP:?FSTACK$[A]:NEXT" + CHR$(13)

GOSUB @STACKLIB_INIT
GOSUB @STDLIB_INIT
GOSUB @CTRLLIB_INIT
GOSUB @HLPVIEW_INIT
IF MEM$ != "" THEN GOSUB @HLP_READ_MEM
GOSUB @THIS_HLP_INIT
'@THIS_HLP_INIT must be your code to load constants.
'@THIS_HLP_INIT デ ユーザー ヨウ ノ プログラム ヲ ショキカ スル。
GOTO @HLP_MAIN

@HLPVIEW_INIT
HLPVIEW_VER$ = "0.06" 
HLPVIEW_URI$ = "http://jrf.cocolog-nifty.com/archive/ptc/hlpview.prg"
'REQUIRE "STACKLIB"
'REQUIRE "STDLIB"
'REQUIRE "CTRLLIB"

HLP_LANG$ = "EN" '"EN": English,  "JA": Japanese.
HLP_DRAW_BG_L$ = ""
HLP_BG_CMAP_L$ = ""
HLP_GRP_CMAP_L$ = ""
HLP_START_L$ = "@HLP_START_" + HLP_LANG$
HLP_BACK_PRG$ = ""
HLP_BACK_PARAM$ = ""
HLP_TEXT_COL = 0
HLP_LINK_COL = 11
HLP_OMIT_COL = 14
HLP_DEL_DBLNL = 1
HLP_SWAP_DQSQ = 0
HLP_MAX_SAVE = 8
HLP_SAVE_GRP$ = "HLP_SAVE"
HLP_RSTQ_EN$ = "Do you reset the program?"
HLP_RSTQ_JA$ = "リセット シマスカ?"
IF HLP_RSTQ$ == "" AND HLP_LANG$ == "EN" THEN HLP_RSTQ$ = HLP_RSTQ_EN$
IF HLP_RSTQ$ == "" AND HLP_LANG$ == "JA" THEN HLP_RSTQ$ = HLP_RSTQ_JA$

IF HLP_BUF_LEN == 0 THEN HLP_BUF_LEN = 256
DIM HLP_BUF$[HLP_BUF_LEN]
IF HLP_FLAG_LEN == 0 THEN HLP_FLAG_LEN = 256
DIM HLP_FLAG$[HLP_FLAG_LEN]
HLP_FLAG_N = 0
IF HLP_HISTORY_LEN == 0 THEN HLP_HISTORY_LEN = 8
DIM HLP_HISTORY$[HLP_HISTORY_LEN]

HLP_ESC_CHARS$ = "CIFLMPn0"

'PROVIDE "HLPVIEW"
RETURN


@HLP_MAIN
  R$ = "@HLP_MAIN": ARGNUM = 0: GOSUB @ENTER

  SYSBEEP = FALSE

@_MAIN_1
  R$ = HLP_LANG$: GOSUB @PUSH_RS
  GOSUB @LOAD_MSG_BASIC
  IF HLP_LANG$ == "EN" THEN HLP_RSTQ$ = HLP_RSTQ_EN$
  IF HLP_LANG$ == "JA" THEN HLP_RSTQ$ = HLP_RSTQ_JA$

  IF HLP_GRP_CMAP_L$ == "" THEN @_MAIN_2
  R = -1: GOSUB @PUSH_R
  R$ = "GRP": GOSUB @PUSH_RS
  R$ = HLP_GRP_CMAP_L$: GOSUB @PUSH_RS
  GOSUB @READ_CMAP
@_MAIN_2
  IF HLP_BG_CMAP_L$ == "" THEN @_MAIN_3
  R = -1: GOSUB @PUSH_R
  R$ = "BG": GOSUB @PUSH_RS
  R$ = HLP_BG_CMAP_L$: GOSUB @PUSH_RS
  GOSUB @READ_CMAP
@_MAIN_3

  IF HLP_DRAW_BG_L$ != "" THEN GOSUB HLP_DRAW_BG_L$

  R$ = HLP_START_L$: GOSUB @PUSH_RS
  GOSUB @HLP_VIEW
  BGMSTOP

  RN = 0
  IF RT$ != "NONE" THEN RA$[RN, 0] = "hlp_ret": RA$[RN, 1] = R$: RN = RN + 1
  IF HLP_BACK_PARAM$!="" THEN RA$[RN,0]="hlp_back_param":RA$[RN,1]=HLP_BACK_PARAM$:RN=RN+1
  GOSUB @PUSH_RA
  GOSUB @POP_RS
  MEM$ = R$

  IF HLP_BACK_PRG$ != "" THEN EXEC HLP_BACK_PRG$

  ARGNUM = 0: GOSUB @LEAVE
  END


@HLP_READ_MEM '(NONE): NONE
  R$ = "@HLP_READ_MEM": ARGNUM = 0: GOSUB @ENTER

  A = A 'Dummy Code

  R$ = MEM$: GOSUB @PUSH_RS
  GOSUB @POP_RA
  R$ = "hlp_lang": GOSUB @PUSH_RS
  GOSUB @GET_RA
  IF RT$ != "NONE" THEN HLP_LANG$ = R$
  R$ = "hlp_back": GOSUB @PUSH_RS
  GOSUB @GET_RA
  IF RT$ != "NONE" THEN HLP_BACK_PRG$ = R$
  R$ = "hlp_back_param": GOSUB @PUSH_RS
  GOSUB @GET_RA
  IF RT$ != "NONE" THEN HLP_BACK_PARAM$ = R$
  R$ = "hlp_start": GOSUB @PUSH_RS
  GOSUB @GET_RA
  IF RT$ != "NONE" THEN HLP_START_L$ = R$

  ARGNUM = 0: GOSUB @LEAVE
  RETURN


@HLP_SET_FLAG '(F$:STRING): NONE
  R$ = "@HLP_SET_FLAG": ARGNUM = 1: GOSUB @ENTER

  R$ = F$: GOSUB @PUSH_RS
  R = SETQ: GOSUB @PUSH_R

  F$ = STACK$[BP + 1]

  SETQ = (MID$(F$, 0, 1) != "!")
  IF ! SETQ THEN F$ = MID$(F$, 1, LEN(F$) - 1)

  R = 0
  A = 0
@_HLP_SET_F_1
  IF A >= HLP_FLAG_N THEN @_HLP_SET_F_1E
  IF HLP_FLAG$[A] == F$ THEN R = 1: GOTO @_HLP_SET_F_1E
  A = A + 1
  GOTO @_HLP_SET_F_1
@_HLP_SET_F_1E

  IF R AND ! SETQ THEN HLP_FLAG$[A] = ""
  IF ! SETQ THEN @_HLP_SET_F_E

  A = 0
@_HLP_SET_F_2
  IF A >= HLP_FLAG_N THEN @_HLP_SET_F_2E
  IF HLP_FLAG$[A] == "" THEN HLP_FLAG$[A] = F$: GOTO @_HLP_SET_F_E
  A = A + 1
  GOTO @_HLP_SET_F_2
@_HLP_SET_F_2E
  IF HLP_FLAG_N + 1 >= HLP_FLAG_LEN THEN PRINT "Flag Buffer Full!": STOP: RETURN
  HLP_FLAG$[HLP_FLAG_N] = F$
  HLP_FLAG_N = HLP_FLAG_N + 1
@_HLP_SET_F_E

  GOSUB @POP_R: SETQ = R
  GOSUB @POP_RS: F$ = R$

  ARGNUM = 1: GOSUB @LEAVE
  RETURN


@HLP_GET_FLAG '(F$:STRING): NUMBER
  R$ = "@HLP_GET_FLAG": ARGNUM = 1: GOSUB @ENTER

  R$ = F$: GOSUB @PUSH_RS
  R = SETQ: GOSUB @PUSH_R

  F$ = STACK$[BP + 1]
  SETQ = (MID$(F$, 0, 1) != "!")
  IF ! SETQ THEN F$ = MID$(F$, 1, LEN(F$) - 1)

  IF LEN(F$) <= 2 OR MID$(F$, 0, 2) != "G:" THEN @_HLP_GET_F_NF
  A$ = MID$(F$, 2, LEN(F$) - 2)
  LOAD "GRP" + STR$(D_GPAGE) + ":" + A$, FALSE
  IF RESULT == TRUE THEN R = 1 ELSE R = 0
  GOTO @_HLP_GET_F_E
@_HLP_GET_F_NF
  R = 0
  A = 0
@_HLP_GET_F_1
  IF A >= HLP_FLAG_N THEN @_HLP_GET_F_E
  IF HLP_FLAG$[A] == F$ THEN R = 1: GOTO @_HLP_GET_F_E
  A = A + 1
  GOTO @_HLP_GET_F_1
@_HLP_GET_F_E
  IF SETQ THEN A = R ELSE A = ! R

  GOSUB @POP_R: SETQ = R
  GOSUB @POP_RS: F$ = R$

  ARGNUM = 1: GOSUB @LEAVE
  RT$ = "NUMBER"
  R = A
  RETURN


@HLP_BRACKET_R '(S$:STRING):SARRAY
  R$ = "@HLP_BRACKET_R": ARGNUM = 1: GOSUB @ENTER

  R$ = S$: GOSUB @PUSH_RS

  S$ = STACK$[BP + 1]

  IF LEN(S$) <= 2 THEN A = 0: GOTO @_HLP_BRACKET_E
  A = INSTR(S$, "]")
  IF MID$(S$, 0, 1) != "[" OR A == -1 THEN A = 0: GOTO @_HLP_BRACKET_E
  RR$[0] = MID$(S$, 1, A - 1)
  RR$[1] = MID$(S$, A + 1, LEN(S$) - A - 1)
  RN = 2
  A = 1
@_HLP_BRACKET_E

  GOSUB @POP_RS: S$ = R$

  ARGNUM = 1: GOSUB @LEAVE
  IF A == 0 THEN RT$ = "NONE" ELSE RT$ = "ARRAY"
  RETURN


@HLP_SKIP_ESC_R '(S$:STRING):SARRAY
  R$ = "@HLP_SKIP_ESC_R": ARGNUM = 1: GOSUB @ENTER

  R$ = S$: GOSUB @PUSH_RS

  S$ = STACK$[BP + 1]

  A = 0
@_HLP_SK_ESC_1
  A = INSTR(A, S$, "\")
  IF A == -1 OR LEN(S$) <= A + 1 THEN A = -1: GOTO @_HLP_SK_ESC_1E
  IF MID$(S$, A + 1, 1) == "\" THEN A = A + 2: GOTO @_HLP_SK_ESC_1
  IF -1 != INSTR(HLP_ESC_CHARS$, MID$(S$, A + 1, 1)) THEN @_HLP_SK_ESC_1E
  A = A + 1
  GOTO @_HLP_SK_ESC_1
@_HLP_SK_ESC_1E
  IF A == -1 THEN A$ = S$: S$ = "" ELSE A$ = MID$(S$, 0, A): S$ = MID$(S$, A, LEN(S$) - A)
  RR$[0] = A$
  RR$[1] = S$
  RN = 2

  GOSUB @POP_RS: S$ = R$

  ARGNUM = 1: GOSUB @LEAVE
  RT$ = "ARRAY"
  RETURN


@HLP_LOAD_GRP_R '(FILE$:STRING):ASSOC
  R$ = "@HLP_LOAD_GRP_R": ARGNUM = 1: GOSUB @ENTER

  R$ = FILE$: GOSUB @PUSH_RS

  FILE$ = STACK$[BP + 1]

  G_PAGE = 1: GPAGE 1, D_GPAGE, L_GPAGE
  LOAD "GRP" + STR$(D_GPAGE) + ":" + FILE$, FALSE
  IF RESULT != TRUE THEN A = 0: GOTO @_HLP_LD_GRP_E

  A = GSPOIT(0, 0) * 256 + GSPOIT(1, 0)
  RN = 0
  R = 0
  RR$[RN] = ""
@_HLP_LD_GRP_1
  IF R >= A THEN A = 1: GOTO @_HLP_LD_GRP_E
  A$ = CHR$(GSPOIT((R + 2) % GRP_WIDTH, FLOOR((R + 2) / GRP_WIDTH)))
  IF A$ == "," THEN RN = RN + 1: RR$[RN] = "" ELSE RR$[RN] = RR$[RN] + A$
  R = R + 1
  GOTO @_HLP_LD_GRP_1
@_HLP_LD_GRP_E
  IF A != 0 THEN RN = RN + 1
  IF A == 0 THEN RN = 0
  FOR A = 0 TO RN - 1
    R$ = RR$[A]: GOSUB @PUSH_RS
    GOSUB @UNESCAPE
    RR$[A] = R$
  NEXT

  GOSUB @POP_RS: FILE$ = R$

  ARGNUM = 1: GOSUB @LEAVE
  RT$ = "ARRAY"
  RETURN


@HLP_SAVE_GRP_RR '(FILE$:STRING)with(ARRAY):NUMBER
  R$ = "@HLP_SAVE_GRP_RR": ARGNUM = 1: GOSUB @ENTER

  R$ = FILE$: GOSUB @PUSH_RS
  R = I: GOSUB @PUSH_R
  R = J: GOSUB @PUSH_R

  FILE$ = STACK$[BP + 1]

  G_PAGE = 1: GPAGE 1, D_GPAGE, L_GPAGE
  GCLS 0

  FOR A = 0 TO RN - 1
    R$ = RR$[A]: GOSUB @PUSH_RS
    GOSUB @ESCAPE
    RR$[A] = R$
  NEXT

  I = 0
  J = 0
@_HLP_SV_GRP_1
  IF I >= RN THEN A = 1: GOTO @_HLP_SV_GRP_E
  FOR R = 0 TO LEN(RR$[I]) - 1
    GPSET (J + 2) % GRP_WIDTH, FLOOR((J + 2) / GRP_WIDTH), ASC(MID$(RR$[I], R, 1))
    J = J + 1
  NEXT
  GPSET (J + 2) % GRP_WIDTH, FLOOR((J + 2) / GRP_WIDTH), ASC(",")
  J = J + 1
  I = I + 1
  GOTO @_HLP_SV_GRP_1
@_HLP_SV_GRP_E
  IF J > 0 THEN J = J - 1
  GPSET 0, 0, FLOOR(J / 256)
  GPSET 1, 0, J % 256

  SAVE "GRP" + STR$(D_GPAGE) + ":" + FILE$
  A = (RESULT == TRUE)

  GOSUB @POP_R: J = R
  GOSUB @POP_R: I = R
  GOSUB @POP_RS: FILE$ = R$

  ARGNUM = 1: GOSUB @LEAVE
  RT$ = "NUMBER"
  R = A
  RETURN


@HLP_SAVE '(L$:LABEL): NONE
  R$ = "@HLP_SAVE": ARGNUM = 1: GOSUB @ENTER

  R$ = L$: GOSUB @PUSH_RS
  R = I: GOSUB @PUSH_R
  R = N: GOSUB @PUSH_R

  L$ = STACK$[BP + 1]

  R$ = HLP_SAVE_GRP$: GOSUB @PUSH_RS
  GOSUB @HLP_LOAD_GRP_R
  N = RN
  FOR I = 0 TO N - 1
    HLP_BUF$[I] = RR$[I]
  NEXT

  RESTORE "@HLP_SAVEQ_" + HLP_LANG$
  READ A$
  R$ = A$: GOSUB @PUSH_RS
  R = -1: GOSUB @PUSH_R
  R = -1: GOSUB @PUSH_R
  GOSUB @OPEN_MSG_WIN

  RN = 0
  FOR I = 0 TO N - 1
    A$ = HLP_BUF$[I]
    A$ = MID$(A$, 0, INSTR(A$, "]"))
    RA$[RN, 0] = "No. " + STR$(I) + " " +A$
    RA$[RN, 1] = STR$(I)
    RN = RN + 1
  NEXT
  IF RN > HLP_MAX_SAVE THEN @_HLP_SAVE_1
  RESTORE "@HLP_NEWSV_" + HLP_LANG$
  READ A$
  RA$[RN, 0] = A$
  RA$[RN, 1] = STR$(N)
  RN = RN + 1
@_HLP_SAVE_1
  RA$[RN, 0] = "\N[B]" + MSG_CANCEL$
  RA$[RN, 1] = "@CANCEL"
  RN = RN + 1
  R = -1: GOSUB @PUSH_R
  R = -1: GOSUB @PUSH_R
  GOSUB @POPUP_MNU_RA
  IF RT$ == "NONE" OR R$ == "@CANCEL" THEN @_HLP_SAVE_E

  I = VAL(R$)
  IF I == N THEN N = N + 1
  A$ = DATE$ + " " + TIME$ + "]" + L$ + "]"
  FOR A = 0 TO HLP_FLAG_N - 1
    IF HLP_FLAG$[A] != "" THEN A$ = A$ + HLP_FLAG$[A] + "]"
  NEXT
  HLP_BUF$[I] = A$
  FOR I = 0 TO N - 1
    RR$[I] = HLP_BUF$[I]
  NEXT
  RN = N
  R$ = HLP_SAVE_GRP$: GOSUB @PUSH_RS
  GOSUB @HLP_SAVE_GRP_RR

@_HLP_SAVE_E
  GOSUB @CLOSE_MSG_WIN

  GOSUB @POP_R: N = R
  GOSUB @POP_R: I = R
  GOSUB @POP_RS: L$ = R$

  ARGNUM = 1: GOSUB @LEAVE
  RETURN


@HLP_LOAD '(L$:LABEL): STRING
  R$ = "@HLP_LOAD": ARGNUM = 1: GOSUB @ENTER

  R$ = L$: GOSUB @PUSH_RS
  R = I: GOSUB @PUSH_R
  R = N: GOSUB @PUSH_R

  L$ = STACK$[BP + 1]

  R$ = HLP_SAVE_GRP$: GOSUB @PUSH_RS
  GOSUB @HLP_LOAD_GRP_R
  N = RN
  FOR I = 0 TO N - 1
    HLP_BUF$[I] = RR$[I]
  NEXT

  RESTORE "@HLP_LOADQ_" + HLP_LANG$
  READ A$
  R = -1: GOSUB @PUSH_R
  R = -1: GOSUB @PUSH_R
  R$ = A$: GOSUB @PUSH_RS
  GOSUB @OPEN_MSG_WIN

  RN = 0
  FOR I = 0 TO N - 1
    A$ = HLP_BUF$[I]
    A$ = MID$(A$, 0, INSTR(A$, "]"))
    RA$[RN, 0] = "No. " + STR$(I) + " " +A$
    RA$[RN, 1] = STR$(I)
    RN = RN + 1
  NEXT
  RA$[RN, 0] = "\N[B]" + MSG_CANCEL$
  RA$[RN, 1] = "@CANCEL"
  RN = RN + 1
  R = -1: GOSUB @PUSH_R
  R = -1: GOSUB @PUSH_R
  GOSUB @POPUP_MNU_RA
  IF RT$ == "NONE" OR R$ == "@CANCEL" THEN @_HLP_LOAD_E

  R$ = HLP_BUF$[VAL(R$)]

  I = 0
@_HLP_LOAD_1
  IF LEN(R$) <= 0 THEN @_HLP_LOAD_1E
  A = INSTR(R$, "]")
  A$ = MID$(R$, 0, A)
  R$ = MID$(R$, A + 1, LEN(R$) - A - 1)
  IF I == 1 THEN L$ = A$
  IF I > 1 THEN HLP_FLAG$[I - 2] = A$
  I = I + 1
  GOTO @_HLP_LOAD_1
@_HLP_LOAD_1E
  HLP_FLAG_N = I - 2
@_HLP_LOAD_E
  GOSUB @CLOSE_MSG_WIN
  A$ = L$

  GOSUB @POP_R: N = R
  GOSUB @POP_R: I = R
  GOSUB @POP_RS: L$ = R$

  ARGNUM = 1: GOSUB @LEAVE
  RT$ = "STRING"
  R$ = A$
  RETURN


@HLP_SWAP_DQSQ '(S$:STRING): STRING
  R$ = "@HLP_SWAP_DQSQ": ARGNUM = 1: GOSUB @ENTER

  R$ = S$: GOSUB @PUSH_RS
  R = I :GOSUB @PUSH_R

  S$ = STACK$[BP + 1]

  A$ = S$
  I = 0
@_HLP_S_DQSQ_1
  IF I >= LEN(S$) THEN @_HLP_S_DQSQ_1E
  A = INSTR(I, S$, CHR$(39))
  IF A == -1 THEN @_HLP_S_DQSQ_1E
  A$ = SUBST$(A$, A, 1, CHR$(34))
  I = A + 1
  GOTO @_HLP_S_DQSQ_1
@_HLP_S_DQSQ_1E
  I = 0
@_HLP_S_DQSQ_2
  IF I >= LEN(S$) THEN @_HLP_S_DQSQ_2E
  A = INSTR(I, S$, CHR$(34))
  IF A == -1 THEN @_HLP_S_DQSQ_2E
  A$ = SUBST$(A$, A, 1, CHR$(39))
  I = A + 1
  GOTO @_HLP_S_DQSQ_2
@_HLP_S_DQSQ_2E

  GOSUB @POP_R: I = R
  GOSUB @POP_RS: S$ = R$

  ARGNUM = 1: GOSUB @LEAVE
  RT$ = "STRING"
  R$ = A$
  RETURN


'Escape sequences:
'\F[F1],\F[!F1]: Set or unset flag F1.
'\C[F1]: Check flag F1 and cancel the rest string if false.
'\C[!F1]: Check flag F1 and cancel the rest string if true.
'\C[G:FN1]: Check existence of GRP:FN1 by loading it.
'\L[@L1]T1: Link.
'\L[F1@L1,F2,!F3@L1,@L2]T1: Conditional Links.
'\L[@L1:F1]T1: Link with setting flag F1.
'\L[@]T1: Link for returning from @HLP_VIEW.
'\L[@:V1]T1: Link by which @HLP_VIEW returns with R$ = "V1".
'\L[B:@L1]T1: Link for B button.
'\L[R:@L1]T1: Link for R button.
'\L[L:@L1]T1: Link for L button.
'\L[@PREV]T1: Link for the previous location in history.
'\L[@SAVE]T1: Link for saving the current location and flags (and no history).
'\L[@LOAD]T1: Link for loading the saved.
'\P[@L1:S1]: (for Expert) Call the procedure @L1 with S1 as the 2nd parameter. See below.
'\M[N1]: BGMPLAY N1
'\M[@STOP]: BGMSTOP
'\I[FN1,D1]: Show image GRP:FN1 on D1 display.
'\I[FN1,D1,N1,N2,N3,N4,N5,N6]: Show image in GRP:FN1 on D1 display
'			       by GCOPY *,N1,N2,N3,N4,N5,N6,FALSE.
'Image on the lower (1) disiplay will be automatically cleared,
'but that on the upper (0) display will remain.
'
'Procedure of "\P[]" is called with the current label as the 1st parameter,
'and it must return a string:
'  "@L2:F1": to jump after call to @L2 with setting F1,
'  "#S2": to print S2 after call,
'  "": to do nothing like above, or
'  Otherwise: reserved for future.
@HLP_VIEW '(L$:LABEL): STRING
  R$ = "@HLP_VIEW": ARGNUM = 1: GOSUB @ENTER

  R$ = L$: GOSUB @PUSH_RS
  R = I: GOSUB @PUSH_R
  R = CX: GOSUB @PUSH_R
  R = CY: GOSUB @PUSH_R
  R = CW: GOSUB @PUSH_R
  R = CH: GOSUB @PUSH_R
  R = Q: GOSUB @PUSH_R
  R = N: GOSUB @PUSH_R
  R = NLQ: GOSUB @PUSH_R
  R = IMGQ: GOSUB @PUSH_R
  R = BGM: GOSUB @PUSH_R
  R$ = S$: GOSUB @PUSH_RS
  R$ = C$: GOSUB @PUSH_RS
  R$ = PREV$: GOSUB @PUSH_RS
  R$ = NEXT$: GOSUB @PUSH_RS
  R$ = BACK$: GOSUB @PUSH_RS
  R = CON_COL[1]: GOSUB @PUSH_R

  L$ = STACK$[BP + 1]

  G_PAGE = 1: GPAGE 1, R_GPAGE, L_GPAGE
  GCOPY L_GPAGE, 0, 0, GRP_WIDTH - 1, GRP_HEIGHT - 1, 0, 0, TRUE
  G_PAGE = 1: GPAGE 1, L_GPAGE, L_GPAGE
  BGM = -1
  FOR I = 0 TO HLP_HISTORY_LEN - 1
    HLP_HISTORY$[I] = ""
  NEXT
  HLP_HISTORY$[0] = "@"

@_HLP_VIEW_LP
  RESTORE L$
  N = 0
@_HLP_VIEW_1
  IF N >= HLP_BUF_LEN THEN PRINT "HLPVIEW: Buffer full!": STOP: RETURN
  READ R$
  IF R$ == "" THEN @_HLP_VIEW_1E
  IF HLP_SWAP_DQSQ THEN GOSUB @PUSH_RS: GOSUB @HLP_SWAP_DQSQ
  HLP_BUF$[N] = R$
  N = N + 1
  GOTO @_HLP_VIEW_1
@_HLP_VIEW_1E

  R = 1: GOSUB @PUSH_R
  GOSUB @CON_CLS
  CON_COL[1] = HLP_TEXT_COL

  GOSUB @MNU_CTRL_NEW
  BACK$ = ""
  PREV$ = ""
  NEXT$ = ""
  IMGQ = 0

  I = 0
  NLQ = 0
@_HLP_VIEW_2
  IF I >= N THEN @_HLP_VIEW_2E
  S$ = HLP_BUF$[I]
@_HLP_VIEW_3
  IF S$ == "" THEN @_HLP_VIEW_3E
  A = 0
@_HLP_VIEW_G1
  R$ = S$: GOSUB @PUSH_RS
  GOSUB @HLP_SKIP_ESC_R
  A$ = RR$[0]
  S$ = RR$[1]

  IF A$ == "" THEN @_HLP_VIEW_4
  CON_COL[1] = HLP_TEXT_COL
  R = 1: GOSUB @PUSH_R
  R = LAST_CX[1]: GOSUB @PUSH_R
  R = LAST_CY[1]: GOSUB @PUSH_R
  R$ = A$: GOSUB @PUSH_RS
  R$ = "": GOSUB @PUSH_RS
  GOSUB @CON_PRINT
  NLQ = 0
@_HLP_VIEW_4
  IF LEN(S$) < 2 THEN @_HLP_VIEW_3
  A$ = MID$(S$, 0, 2)
  IF A$ == "\0" THEN S$ = MID$(S$, 2, LEN(S$) - 2): GOTO @_HLP_VIEW_3
  IF A$ == "\n" THEN @_HLP_VIEW_NL
  IF A$ == "\L" THEN @_HLP_VIEW_L
  IF A$ == "\I" THEN @_HLP_VIEW_I
  IF A$ == "\M" THEN @_HLP_VIEW_M
  IF A$ == "\F" THEN @_HLP_VIEW_F
  IF A$ == "\C" THEN @_HLP_VIEW_C
  IF A$ == "\P" THEN @_HLP_VIEW_P
  GOTO @_HLP_VIEW_3
@_HLP_VIEW_NL
  S$ = MID$(S$, 2, LEN(S$) - 2)
  IF LAST_CX[1] != CLIP_CX[1] THEN @_HLP_VIEW_NL1
  IF HLP_DEL_DBLNL AND NLQ THEN GOTO @_HLP_VIEW_3
  NLQ = 1
@_HLP_VIEW_NL1
  LAST_CY[1] = LAST_CY[1] + 1
  LAST_CX[1] = CLIP_CX[1]
  GOTO @_HLP_VIEW_3
@_HLP_VIEW_L
  S$ = MID$(S$, 2, LEN(S$) - 2)
  R$ = S$: GOSUB @PUSH_RS
  GOSUB @HLP_BRACKET_R
  IF RT$ == "NONE" THEN S$ = "\x5CL" + S$: GOTO @_HLP_VIEW_3
  C$ = RR$[0]
  S$ = RR$[1]
  A$ = ""
  IF LEN(C$) >= 2 AND MID$(C$, 0, 1) != "@" AND MID$(C$, 1, 1) == ":" THEN A$ = MID$(C$, 0, 1)
  IF LEN(A$) > 0 THEN C$ = MID$(C$, 2, LEN(C$) - 2)
  IF A$ == "B" THEN BACK$ = C$
  IF A$ == "L" THEN PREV$ = C$
  IF A$ == "R" THEN NEXT$ = C$
  IF A$ == "" THEN @_HLP_VIEW_L1
  R$ = A$: GOSUB @PUSH_RS
  R$ = C$: GOSUB @PUSH_RS
  GOSUB @MNU_CTRL_BUTTON
@_HLP_VIEW_L1
  R$ = S$: GOSUB @PUSH_RS
  GOSUB @HLP_SKIP_ESC_R
  A$ = RR$[0]
  S$ = RR$[1]
  IF A$ == "" THEN @_HLP_VIEW_3
  CX = LAST_CX[1]
  CY = LAST_CY[1]
  CON_COL[1] = HLP_LINK_COL
  R = 1: GOSUB @PUSH_R
  R = CX: GOSUB @PUSH_R
  R = CY: GOSUB @PUSH_R
  R$ = A$: GOSUB @PUSH_RS
  R$ = "": GOSUB @PUSH_RS
  GOSUB @CON_PRINT
  NLQ = 0
  IF LAST_CY[1] == CY THEN CW = LAST_CX[1] - CX
  IF LAST_CY[1] != CY THEN CW = CLIP_CX[1] + CLIP_CW[1] - CX
  IF CW <= 0 AND LAST_CY[1] == CY THEN @_HLP_VIEW_3
  IF CW <= 0 THEN @_HLP_VIEW_L2
  R = CX: GOSUB @PUSH_R
  R = CY: GOSUB @PUSH_R
  R = CW: GOSUB @PUSH_R
  R = 1: GOSUB @PUSH_R
  R$ = C$: GOSUB @PUSH_RS
  GOSUB @MNU_CTRL_ADD
  IF LAST_CY[1] == CY THEN @_HLP_VIEW_3
@_HLP_VIEW_L2
  CH = LAST_CY[1] - CY - 1
  IF CH <= 0 THEN @_HLP_VIEW_L3
  R = CLIP_CX[1]: GOSUB @PUSH_R
  R = CY + 1: GOSUB @PUSH_R
  R = CLIP_CW[1]: GOSUB @PUSH_R
  R = CH: GOSUB @PUSH_R
  R$ = C$: GOSUB @PUSH_RS
  GOSUB @MNU_CTRL_ADD
@_HLP_VIEW_L3
  CW = LAST_CX[1] - CLIP_CX[1]
  IF CW <= 0 THEN @_HLP_VIEW_3
  R = CLIP_CX[1]: GOSUB @PUSH_R
  R = LAST_CY[1]: GOSUB @PUSH_R
  R = CW: GOSUB @PUSH_R
  R = 1: GOSUB @PUSH_R
  R$ = C$: GOSUB @PUSH_RS
  GOSUB @MNU_CTRL_ADD
  GOTO @_HLP_VIEW_3

@_HLP_VIEW_F
  S$ = MID$(S$, 2, LEN(S$) - 2)
  R$ = S$: GOSUB @PUSH_RS
  GOSUB @HLP_BRACKET_R
  IF RT$ == "NONE" THEN S$ = "\x5CF" + S$: GOTO @_HLP_VIEW_3
  C$ = RR$[0]
  S$ = RR$[1]
  R$ = C$: GOSUB @PUSH_RS
  GOSUB @HLP_SET_FLAG
  GOTO @_HLP_VIEW_3

@_HLP_VIEW_C
  S$ = MID$(S$, 2, LEN(S$) - 2)
  R$ = S$: GOSUB @PUSH_RS
  GOSUB @HLP_BRACKET_R
  IF RT$ == "NONE" THEN S$ = "\x5CC" + S$: GOTO @_HLP_VIEW_3
  C$ = RR$[0]
  S$ = RR$[1]
  R$ = C$: GOSUB @PUSH_RS
  GOSUB @HLP_GET_FLAG
  IF ! R THEN S$ = ""
  GOTO @_HLP_VIEW_3

@_HLP_VIEW_P
  S$ = MID$(S$, 2, LEN(S$) - 2)
  R$ = S$: GOSUB @PUSH_RS
  GOSUB @HLP_BRACKET_R
  IF RT$ == "NONE" THEN S$ = "\x5CP" + S$: GOTO @_HLP_VIEW_3
  C$ = RR$[0]
  S$ = RR$[1]
  A = INSTR(C$, ":")
  IF A == -1 THEN A$ = "" ELSE A$ = MID$(C$, A + 1, LEN(C$) - A - 1): C$ = MID$(C$, 0, A)
  R$ = L$: GOSUB @PUSH_RS
  R$ = A$: GOSUB @PUSH_RS
  GOSUB C$
  IF R$ == "" THEN @_HLP_VIEW_3
  IF MID$(R$, 0, 1) == "@" THEN @_HLP_VIEW_CK
  IF MID$(R$, 0, 1) == "#" THEN S$ = MID$(R$, 1, LEN(R$) - 1) + S$: GOTO @_HLP_VIEW_3
  GOTO @_HLP_VIEW_3

@_HLP_VIEW_M
  S$ = MID$(S$, 2, LEN(S$) - 2)
  R$ = S$: GOSUB @PUSH_RS
  GOSUB @HLP_BRACKET_R
  IF RT$ == "NONE" THEN S$ = "\x5CM" + S$: GOTO @_HLP_VIEW_3
  C$ = RR$[0]
  S$ = RR$[1]
  IF C$ == "@STOP" THEN BGMSTOP: BGM = -1
  IF C$ != "@STOP" AND VAL(C$) != BGM THEN BGM = VAL(C$): BGMPLAY BGM
  GOTO @_HLP_VIEW_3

@_HLP_VIEW_I
  S$ = MID$(S$, 2, LEN(S$) - 2)
  R$ = S$: GOSUB @PUSH_RS
  GOSUB @HLP_BRACKET_R
  IF RT$ == "NONE" THEN S$ = "\x5CF" + S$: GOTO @_HLP_VIEW_3
  C$ = RR$[0]
  S$ = RR$[1]
  R$ = C$: GOSUB @PUSH_RS
  GOSUB @POP_RR
  IF RN!=1 AND RN!=2 AND RN!=7 AND RN!=8 THEN S$ = "\x5CI["+C$+"]"+S$: GOTO @_HLP_VIEW_3
  LOAD "GRP" + STR$(D_GPAGE) + ":" + RR$[0], FALSE
  IF RESULT != TRUE THEN S$ = "\x5CI[" + C$ + "]" + S$: GOTO @_HLP_VIEW_3
  Q = 1
  IF RN == 2 OR RN == 8 THEN Q = VAL(RR$[0])
  IF Q == 0 THEN GOSUB @GPAGE_U ELSE GOSUB @GPAGE_L
  IF RN == 1 OR RN == 2 THEN GCOPY D_GPAGE, 0, 0, GRP_WIDTH -1, GRP_HEIGHT - 1, 0, 0, FALSE
  IF RN == 7 THEN A = VAL(RR$[1]): R = VAL(RR$[2])
  IF RN == 7 THEN GCOPY D_GPAGE,A,R,VAL(RR$[3]),VAL(RR$[4]),VAL(RR$[5]),VAL(RR$[6]),FALSE
  IF RN == 8 THEN A = VAL(RR$[2]): R = VAL(RR$[3])
  IF RN == 8 THEN GCOPY D_GPAGE,A,R,VAL(RR$[4]),VAL(RR$[5]),VAL(RR$[6]),VAL(RR$[7]),FALSE
  IF Q == 1 THEN IMGQ = 1
  GOTO @_HLP_VIEW_3
@_HLP_VIEW_3E
  I = I + 1
  GOTO @_HLP_VIEW_2
@_HLP_VIEW_2E

  LAST_CX[1] = CLIP_CX[1]
  LAST_CY[1] = CLIP_CY[1] + CLIP_CH[1] - 1

  CX = LAST_CX[1] + 1
  IF PREV$ != "" THEN CON_COL[1] = HLP_LINK_COL ELSE CON_COL[1] = HLP_OMIT_COL
  R = 1: GOSUB @PUSH_R
  R = CX: GOSUB @PUSH_R
  R = LAST_CY[1]: GOSUB @PUSH_R
  R$ = "[\N[L]" + MSG_PREV$ + "]": GOSUB @PUSH_RS
  R$ = "": GOSUB @PUSH_RS
  GOSUB @CON_PRINT
  IF PREV$ == "" THEN @_HLP_VIEW_BL
  R = CX: GOSUB @PUSH_R
  R = LAST_CY[1]: GOSUB @PUSH_R
  R = LAST_CX[1] - CX: GOSUB @PUSH_R
  R = 1: GOSUB @PUSH_R
  R$ = PREV$: GOSUB @PUSH_RS
  GOSUB @MNU_CTRL_ADD
@_HLP_VIEW_BL

  CX = LAST_CX[1] + 1
  IF BACK$ != "" THEN CON_COL[1] = HLP_LINK_COL ELSE CON_COL[1] = HLP_OMIT_COL
  R = 1: GOSUB @PUSH_R
  R = CX: GOSUB @PUSH_R
  R = LAST_CY[1]: GOSUB @PUSH_R
  R$ = "[\N[B]" + MSG_BACK$ + "]": GOSUB @PUSH_RS
  R$ = "": GOSUB @PUSH_RS
  GOSUB @CON_PRINT
  IF BACK$ == "" THEN @_HLP_VIEW_BB
  R = CX: GOSUB @PUSH_R
  R = LAST_CY[1]: GOSUB @PUSH_R
  R = LAST_CX[1] - CX: GOSUB @PUSH_R
  R = 1: GOSUB @PUSH_R
  R$ = BACK$: GOSUB @PUSH_RS
  GOSUB @MNU_CTRL_ADD
@_HLP_VIEW_BB

  CX = LAST_CX[1] + 1
  IF NEXT$ != "" THEN CON_COL[1] = HLP_LINK_COL ELSE CON_COL[1] = HLP_OMIT_COL
  R = 1: GOSUB @PUSH_R
  R = CX: GOSUB @PUSH_R
  R = LAST_CY[1]: GOSUB @PUSH_R
  R$ = "[" + MSG_NEXT$ + "\N[R]]": GOSUB @PUSH_RS
  R$ = "": GOSUB @PUSH_RS
  GOSUB @CON_PRINT
  IF NEXT$ == "" THEN @_HLP_VIEW_BR
  R = CX: GOSUB @PUSH_R
  R = LAST_CY[1]: GOSUB @PUSH_R
  R = LAST_CX[1] - CX: GOSUB @PUSH_R
  R = 1: GOSUB @PUSH_R
  R$ = NEXT$: GOSUB @PUSH_RS
  GOSUB @MNU_CTRL_ADD
@_HLP_VIEW_BR

  R$ = "START": GOSUB @PUSH_RS
  R$ = "@RSTQ": GOSUB @PUSH_RS
  GOSUB @MNU_CTRL_BUTTON

  IF BACK$ != "" THEN @_HLP_VIEW_ML
  R$ = "B": GOSUB @PUSH_RS
  R$ = "": GOSUB @PUSH_RS
  GOSUB @MNU_CTRL_BUTTON
  
@_HLP_VIEW_ML
  GOSUB @MNU_CTRL_LOOP
  IF R$ != "@RSTQ" THEN @_HLP_VIEW_CK

  R = -1: GOSUB @PUSH_R
  R = -1: GOSUB @PUSH_R
  R$ = HLP_RSTQ$: GOSUB @PUSH_RS
  GOSUB @OPEN_MSG_WIN

  RA$[0, 0] = "\N[Y]" + MSG_YES$
  RA$[0, 1] = "Y"
  RA$[1, 0] = "\N[X]" + MSG_NO$
  RA$[1, 1] = "N"
  RA$[2, 0] = "\B[Y]"
  RA$[2, 1] = "Y"
  RA$[3, 0] = "\B[X]"
  RA$[3, 1] = "N"
  RN = 4
  R = -1: GOSUB @PUSH_R
  R = -1: GOSUB @PUSH_R
  GOSUB @POPUP_MNU_RA
  IF RT$ == "NONE" THEN C$ = "" ELSE C$ = R$

  GOSUB @CLOSE_MSG_WIN

  IF C$ == "Y" THEN A = 0: GOTO @_HLP_VIEW_E
  GOTO @_HLP_VIEW_ML

@_HLP_VIEW_CK
  S$ = R$

  IF ! IMGQ THEN  @_HLP_VIEW_NI
  G_PAGE = 1: GPAGE 1, D_GPAGE, L_GPAGE
  GCOPY R_GPAGE, 0, 0, GRP_WIDTH - 1, GRP_HEIGHT - 1, 0, 0, TRUE
  GOSUB @SHIPOUT_L_GPAGE
@_HLP_VIEW_NI

  R$ = S$: GOSUB @PUSH_RS
  GOSUB @POP_RR
  N = RN
  FOR I = 0 TO RN - 1
    HLP_BUF$[I] = RR$[I]
  NEXT
  Q = 1
  I = 0
@_HLP_VIEW_A1
  IF I >= N THEN @_HLP_VIEW_A1E
  A$ = HLP_BUF$[I]
  R = INSTR(A$, "@")
  IF A$ == "" OR MID$(A$, 0, 1) == ":" THEN R = 0
  IF R == 0 AND Q THEN R$ = A$: GOTO @_HLP_VIEW_A1E
  IF R == -1 THEN C$ = A$: S$ = ""
  IF R != -1 THEN C$ = MID$(A$, 0, R): S$ = MID$(A$, R, LEN(A$) - R)
  R$ = C$: GOSUB @PUSH_RS
  GOSUB @HLP_GET_FLAG
  Q = Q AND R
  IF Q AND S$ != "" THEN R$ = S$: GOTO @_HLP_VIEW_A1E
  IF S$ != "" THEN Q = 1
@_HLP_VIEW_A1L
  I = I + 1
  GOTO @_HLP_VIEW_A1
@_HLP_VIEW_A1E
  S$ = R$
  C$ = ""
  A = INSTR(S$, ":")
  IF A != -1 THEN C$ = MID$(S$, A, LEN(S$) - A): S$ = MID$(S$, 0, A)
  IF S$ == "@SAVE" THEN R$ = L$: GOSUB @PUSH_RS: GOSUB @HLP_SAVE
  IF S$ == "@LOAD" THEN R$ = L$: GOSUB @PUSH_RS: GOSUB @HLP_LOAD: L$ = R$
  IF S$ == "" OR S$ == "@SAVE" OR S$ == "@LOAD" THEN @_HLP_VIEW_HE
  IF S$ == "@PREV" THEN @_HLP_VIEW_HB
  L$ = S$
  FOR I = HLP_HISTORY_LEN - 1 TO 0 STEP -1
    IF I == 0 THEN A$ = L$ ELSE A$ = HLP_HISTORY$[I - 1]
    HLP_HISTORY$[I] = A$
  NEXT
  GOTO @_HLP_VIEW_HE
@_HLP_VIEW_HB
  IF HLP_HISTORY$[1] == "" THEN @_HLP_VIEW_HE
  FOR I = 0 TO HLP_HISTORY_LEN - 1
    IF I == HLP_HISTORY_LEN - 1 THEN A$ = "" ELSE A$ = HLP_HISTORY$[I + 1]
    HLP_HISTORY$[I] = A$
  NEXT
  L$ = HLP_HISTORY$[0]
@_HLP_VIEW_HE
  IF LEN(C$) > 2 THEN R$ = MID$(C$,1,LEN(C$)-1): GOSUB @PUSH_RS: GOSUB @HLP_SET_FLAG
  IF C$ != "" THEN A$ = MID$(C$,1,LEN(C$)-1): A = 1 ELSE A = 0
  IF L$ != "@" THEN @_HLP_VIEW_LP

@_HLP_VIEW_E
  GOSUB @POP_R: CON_COL[1] = R
  GOSUB @POP_RS: BACK$ = R$
  GOSUB @POP_RS: NEXT$ = R$
  GOSUB @POP_RS: PREV$ = R$
  GOSUB @POP_RS: C$ = R$
  GOSUB @POP_RS: S$ = R$
  GOSUB @POP_R: BGM = R
  GOSUB @POP_R: IMGQ = R
  GOSUB @POP_R: NLQ = R
  GOSUB @POP_R: N = R
  GOSUB @POP_R: Q = R
  GOSUB @POP_R: CH = R
  GOSUB @POP_R: CW = R
  GOSUB @POP_R: CY = R
  GOSUB @POP_R: CX = R
  GOSUB @POP_R: I = R
  GOSUB @POP_RS: L$ = R$

  ARGNUM = 1: GOSUB @LEAVE
  IF A == 0 THEN RT$ = "NONE" ELSE RT$ = "STRING": R$ = A$
  RETURN


@HLP_SAVEQ_EN
DATA "Which number do you save to?"
@HLP_SAVEQ_JA
DATA "ナンバン ニ セーブ シマスカ?"
@HLP_NEWSV_EN
DATA "NEW FILE"
@HLP_NEWSV_JA
DATA "アタラシイ ファイル"
@HLP_LOADQ_EN
DATA "Which number do you load from?"
@HLP_LOADQ_JA
DATA "ナンバン カラ ロード シマスカ?"

'== END HLPVIEW ==
