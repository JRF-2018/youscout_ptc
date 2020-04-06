'== BEGIN YSCHLP ==
@THIS_HLP_INIT
'YSCHLP_VER$ and YSCHLP_URI$ are below. 'Time-stamp: <2013-04-05T03:32:20Z>
GOSUB @YSCHLP_P_INIT
GOSUB @YSCHLP_INIT
'REQUIRE "YSCHELP_P"
'REQUIRE "YSCHELP"
THIS_HLP_VER$ = YSCHLP_VER$
THIS_HLP_URI$ = YSCHLP_URI$
RETURN

@YSCHLP_INIT
YSCHLP_VER$ = "0.06"
YSCHLP_URI$ = "http://jrf.cocolog-nifty.com/archive/youscout/ptc/yschlp.prg"

'REQUIRE "STDLIB"
'REQUIRE "CTRLLIB"
'REQUIRE "YSCHLP_P"

YOUSCOUT_VER$ = ""
IF MEM$ != "" THEN GOSUB @YSC_READ_MEM

HLP_GRP_CMAP_L$ = "@" + TAROT_NAME$ + "_CMAP"
HLP_BG_CMAP_L$ = ""
HLP_DRAW_BG_L$ = "@YSC_DRAW_BG"
HLP_TEXT_COL = COL_BLACK
HLP_LINK_COL = COL_C
HLP_OMIT_COL = COL_GREY
HLP_DEL_DBLNL = 1
HLP_SWAP_DQSQ = 1
IF YOUSCOUT_VER$ != "" THEN HLP_RSTQ_EN$ = "Do you go back to the title?"
IF YOUSCOUT_VER$ != "" THEN HLP_RSTQ_JA$ = "タイトル ニ モドリマスカ?"
HLP_SAVE_GRP$ = "YSCHLP_S"

'PROVIDE "YSCHLP"
RETURN


@YSC_READ_MEM '(NONE): NONE
  R$ = "@YSC_READ_MEM": ARGNUM = 0: GOSUB @ENTER

  A = A 'Dummy Code.

  R$ = MEM$: GOSUB @PUSH_RS
  GOSUB @POP_RA
  R$ = "ysc_ver": GOSUB @PUSH_RS
  GOSUB @GET_RA
  IF RT$ != "NONE" THEN YOUSCOUT_VER$ = R$

  ARGNUM = 0: GOSUB @LEAVE
  RETURN


@YSC_DRAW_BG '(NONE): NONE
  R$ = "@YSC_DRAW_BG": ARGNUM = 0: GOSUB @ENTER

  R = I: GOSUB @PUSH_R
  R$ = W$: GOSUB @PUSH_RS
  R$ = G$: GOSUB @PUSH_RS

  W$ = HEX$(COL_WHITE, 1)
  G$ = HEX$(COL_GREY, 1)

  R = BG_PAGE: GOSUB @PUSH_R

  GOSUB @GPAGE_U
  COLSET "GRP", COL_BOARD, BOARD_RGB$
  GOSUB @GPAGE_L
  COLSET "GRP", COL_BOARD, BOARD_RGB$
  FOR I = 1 TO 16 - 1
    GOSUB @GPAGE_U
    GOSUB @BGPAGE_U
    COLSET "BG", I, CMAP$[I]
    IF (I > 0 AND I <= 7) OR I == 14 THEN COLSET "BG", I * 16 + 15, CMAP$[I]
    GOSUB @GPAGE_L
    GOSUB @BGPAGE_L
    COLSET "BG", I, CMAP$[I]
    IF (I > 0 AND I <= 7) OR I == 14 THEN COLSET "BG", I * 16 + 15, CMAP$[I]
  NEXT

  GOSUB @BGPAGE_L
  CHRSET "BGU1", 0, "0" + G$ * 7 + (G$ + W$ * 7) * 7
  CHRSET "BGU1", 1,  G$ * 8 + (W$ * 8) * 7
  CHRSET "BGU1", 2,  (G$ + W$ * 7) * 8
  CHRSET "BGU1", 3, W$ * 8 * 8
  GOSUB @BGPAGE_U
  CHRSET "BGU1", 0, "0" + G$ * 7 + (G$ + W$ * 7) * 7
  CHRSET "BGU1", 1,  G$ * 8 + (W$ * 8) * 7
  CHRSET "BGU1", 2,  (G$ + W$ * 7) * 8
  CHRSET "BGU1", 3, W$ * 8 * 8
  CWIN_CHR_BG_TL = 256 + 0
  CWIN_CHR_BG_T = 256 + 1
  CWIN_CHR_BG_L = 256 + 2
  CWIN_CHR_BG_C = 256 + 3
  DRAW_CWIN_NOINIT = TRUE

  GOSUB @GPAGE_L
  GCLS COL_BOARD
  A = 4 + GRP_WIDTH - 8 - 1
  R = 4 + GRP_HEIGHT - 8 - 1
  GFILL 4, 4, A, R, COL_WHITE
  GBOX 4, 4, A, R, COL_GREY
  GPSET 4, 4, COL_BOARD
  GPSET 4, R, COL_BOARD
  GPSET A, R, COL_BOARD
  GPSET A, 4, COL_BOARD
  GPSET 4 + 1, 4 + 1, COL_GREY
  GPSET 4 + 1, R - 1, COL_GREY
  GPSET A - 1, R - 1, COL_GREY
  GPSET A - 1, 4 + 1, COL_GREY
  G_PAGE = 0: GPAGE 0, D_GPAGE, U_GPAGE

  R = 0: GOSUB @PUSH_R
  GOSUB @CON_CLS
  R = 1: GOSUB @PUSH_R
  GOSUB @CON_CLS
  GOSUB @YSC_DRAW_LOGO

  CLIP_CX[1] = 1
  CLIP_CY[1] = 1
  CLIP_CW[1] = CON_WIDTH - 2
  CLIP_CH[1] = CON_HEIGHT - 2

  GOSUB @POP_R: BG_PAGE = R: BGPAGE BG_PAGE

  GOSUB @POP_RS: G$ = R$
  GOSUB @POP_RS: W$ = R$
  GOSUB @POP_R: I = R

  ARGNUM = 0: GOSUB @LEAVE
  RETURN


@YSC_DRAW_LOGO
  R$ = "@YSC_DRAW_LOGO": ARGNUM = 0 :GOSUB @ENTER

  GOSUB @GPAGE_U
  GOSUB @YSC_DRAW_LOGO1
  GOSUB @YSC_DRAW_LOGO2

  ARGNUM = 0: GOSUB @LEAVE
  RETURN

'YSC_DRAW_LOGO1 is the same function of @DRAW_LOGO_GRP of MKJRFTRT
@YSC_DRAW_LOGO1 '(NONE): NONE
  ARGNUM = 0: R$ = "@YSC_DRAW_LOGO1": GOSUB @ENTER

  R = I: GOSUB @PUSH_R
  R = W: GOSUB @PUSH_R
  R = H: GOSUB @PUSH_R

  GCLS COL_BOARD

  RESTORE CHAR_LOGO$[0]
  READ W, H
  W = W 'Dummy code.

  FOR I = 0 TO CHAR_LOGO_LEN - 1
    R = 32: GOSUB @PUSH_R
    R = 16 + I * (H + 32): GOSUB @PUSH_R
    R = COL_WHITE: GOSUB @PUSH_R
    R$ = CHAR_LOGO$[I]: GOSUB @PUSH_RS
    R = 0: GOSUB @PUSH_R
    R = 0: GOSUB @PUSH_R
    GOSUB @G_PUT_BM
  NEXT

  GOSUB @POP_R: H = R
  GOSUB @POP_R: W = R
  GOSUB @POP_R: I = R

  ARGNUM = 0: GOSUB @LEAVE
  RETURN


'YSC_DRAW_LOGO2 is almost the same function of @DRAW_LOGO of YOUSCOUT
@YSC_DRAW_LOGO2 '(NONE): NONE
  R$ = "@YSC_DRAW_LOGO2": ARGNUM = 0: GOSUB @ENTER

  R = I: GOSUB @PUSH_R
  R = W: GOSUB @PUSH_R

  CON_COL[0] = 0

  W = 32
'  A$ = GRP_FILE_T$
'  LOAD "GRP" + STR$(D_GPAGE) + ":" + A$, FALSE
'  IF RESULT != TRUE THEN @LOAD_ERROR_FST

  FOR I = 0 TO LEN(LOGO_STR_JA$) - 1
    R = 0: GOSUB @PUSH_R
    R =  5 + FLOOR(W / FONT_WIDTH): GOSUB @PUSH_R
    R = 2 + I * 2: GOSUB @PUSH_R
    R$ = MID$(LOGO_STR_JA$, I, 1): GOSUB @PUSH_RS
    R$ = "": GOSUB @PUSH_RS
    GOSUB @CON_PRINT
  NEXT

  R = 0: GOSUB @PUSH_R
  R = 5 + FLOOR(W / FONT_WIDTH): GOSUB @PUSH_R
  R = CON_HEIGHT - 9 + 1: GOSUB @PUSH_R
  R$ = LOGO_STR_EN$: GOSUB @PUSH_RS
  R$ = "": GOSUB @PUSH_RS
  GOSUB @CON_PRINT

  R = 0: GOSUB @PUSH_R
  R = 5 + FLOOR(W / FONT_WIDTH): GOSUB @PUSH_R
  R = CON_HEIGHT - 9 + 3: GOSUB @PUSH_R
  R$ = " " + LOGO_SUB_STR$: GOSUB @PUSH_RS
  R$ = "": GOSUB @PUSH_RS
  GOSUB @CON_PRINT

  IF YOUSCOUT_VER$ == "" THEN A$ = "PTC" ELSE A$ = "PTC Ver." + YOUSCOUT_VER$
  R = 0: GOSUB @PUSH_R
  R = 5 + FLOOR(W / FONT_WIDTH): GOSUB @PUSH_R
  R = CON_HEIGHT - 9 + 5: GOSUB @PUSH_R
  R$ = "  " + A$: GOSUB @PUSH_RS
  R$ = "": GOSUB @PUSH_RS
  GOSUB @CON_PRINT

  CON_COL[0] = COL_BLACK

  GOSUB @POP_R: W = R
  GOSUB @POP_R: I = R

  ARGNUM = 0: GOSUB @LEAVE
  RETURN


@TST_TRAP '(L$:LABEL, PARAM$:STRING): STRING
  R$ = "@TST_TRAP": ARGNUM = 2: GOSUB @ENTER

  R$ = L$: GOSUB @PUSH_RS
  R$ = PARAM$: GOSUB @PUSH_RS

  L$ = STACK$[BP + 1]
  PARAM$ = STACK$[BP + 2]

  R$ = PARAM$: GOSUB @PUSH_RS
  GOSUB @POP_RR

  R = RND(100) / 100.0
  IF R < VAL(RR$[0]) THEN @_TST_TRAP_1
  IF R < VAL(RR$[0]) + VAL(RR$[1]) THEN @_TST_TRAP_2
  A$ = ""
  GOTO @_TST_TRAP_E

@_TST_TRAP_1
  A$ = "@TST_ROOM1T_" + MID$(L$, LEN(L$) - 2, 2)
  GOTO @_TST_TRAP_E

@_TST_TRAP_2
  RESTORE "@TST_TRMSG_" + MID$(L$, LEN(L$) - 2, 2)
  READ A$
  A$ = "#" + A$
  GOTO @_TST_TRAP_E

@_TST_TRAP_E
  GOSUB @POP_RS: PARAM$ = R$
  GOSUB @POP_RS: L$ = R$

  ARGNUM = 2: GOSUB @LEAVE
  R$ = A$: RT$ = "STRING"
  RETURN


@TST_RND '(L$:LABEL, PARAM$:STRING): STRING
  R$ = "@TST_RND": ARGNUM = 2: GOSUB @ENTER

'  R$ = L$: GOSUB @PUSH_RS
  R$ = PARAM$: GOSUB @PUSH_RS

'  L$ = STACK$[BP + 1]
  PARAM$ = STACK$[BP + 2]

  R$ = "TMP_" + STR$(RND(VAL(PARAM$))): GOSUB @PUSH_RS
  GOSUB @HLP_SET_FLAG

  GOSUB @POP_RS: PARAM$ = R$
'  GOSUB @POP_RS: L$ = R$

  ARGNUM = 2: GOSUB @LEAVE
  R$ = "": RT$ = "STRING"
  RETURN


@TST_CLEAR_TMP '(L$:LABEL, PARAM$:STRING): STRING
  R$ = "@TST_CLEAR_TMP": ARGNUM = 2: GOSUB @ENTER

  R = I: GOSUB @PUSH_R
  R = J: GOSUB @PUSH_R

  FOR I = 0 TO HLP_FLAG_N - 1
    A$ = HLP_FLAG$[I]
    IF INSTR(A$, "TMP_") == 0 THEN HLP_FLAG$[I] = ""
  NEXT

  J = 0
  FOR I = 0 TO HLP_FLAG_N - 1
    IF HLP_FLAG$[I] != "" THEN HLP_FLAG$[J] = HLP_FLAG$[I]: J = J + 1
  NEXT
  HLP_FLAG_N = J

  GOSUB @POP_R: J = R
  GOSUB @POP_R: I = R

  ARGNUM = 2: GOSUB @LEAVE
  R$ = "": RT$ = "STRING"
  RETURN


@HLP_START_EN
@YSC_START_EN
DATA "\F[!MK]\F[!CMK]"
DATA "\M[@STOP]"
DATA "■ YOUSCOUT MANUAL\n\n"
DATA "'Youscout' is a sort of solitaire games playing with tarot cards, "
DATA "inspired by arguments about Yi-Ching divination.\n\n"
DATA "This document includes these chapters:\n\n"
DATA "●\L[@YSC_MANUP_EN]Manipulation at this console,\n\n"
DATA "●\L[@YSC_RMAIN_EN]Rule of 'Youscout',\n\n"
DATA "●\L[@YSC_ABOUT_EN]About distribution,\n\n"
DATA "●\L[@YSC_START_JA]Japanese (ニホンゴ) manual"
DATA "\L[@TST_START_EN].\n\n"
DATA "\L[B:@]"
DATA ""

@HLP_START_JA
@YSC_START_JA
DATA "\F[!MK]\F[!CMK]"
DATA "\M[@STOP]"
DATA "■ ヨウスコウ マニュアル\n\n"
DATA "「ヨウスコウ」ハ タロット=カード ヲ ツカッタ ソリティア=ゲーム ノ イッシュ デ、エキ=キョウ ノ リロン ニ ヒント ヲ エテイル。\n\n"
DATA "コノ セツメイショ ニ フクマレル ダイ=コウモク ハ ツギ ノ トオリ:\n\n"
DATA "●\L[@YSC_MANUP_JA]ゲーム ノ ソウサ、\n\n"
DATA "●\L[@YSC_RMAIN_JA]「ヨウスコウ」ノ ルール、\n\n"
DATA "●\L[@YSC_ABOUT_JA]ハイフブツ ニ カンシテ,\n\n"
DATA "●\L[@YSC_START_EN]エイゴ (English) マニュアル"
DATA "\L[@TST_START_JA]。\n\n"
DATA "\L[B:@]"
DATA ""


@TST_START_EN
DATA "\M[@STOP]"
DATA "\C[!CMK]\F[!MK]"
DATA "\C[!CMK]\C[G:JRFTRT_A]\C[G:JRFTRT_D]\F[MK]"
DATA "\C[!CMK]\F[CMK]"
DATA "\C[MK]\I[JRFTRT_A,0,72,112,107,167,140,32]"
DATA "[\L[@SAVE]Save\0][\L[@LOAD]Load\0][\L[@TST_ITEMS_EN]Item\0]\n\n"
DATA "You have strayed into a 'Dungeon of Test'.\n\n"
DATA "A hermit tells you.:\n\n"
DATA "'\C[R1]No need to come back. "
DATA "\F[!R1]Proceed to the next.'"
DATA "\C[K0]\L[B:@HLP_START_EN]"
DATA "\L[R:@TST_ROAD1_EN]"
DATA ""

@TST_ITEMS_EN
DATA "■ Items\n\n"
DATA "\C[K1]●Mysterious Knot\n\n"
DATA "\C[!K1]●????\n\n"
DATA "\C[K2]●Strange Knot\n\n"
DATA "\C[!K2]●????\n\n"
DATA "\C[K3]●Master Key\n\n"
DATA "\C[!K3]●????\n\n"
DATA "\C[K0]●Map of Returning\n\n"
DATA "\C[!K0]●????\n\n"
DATA "\L[B:@PREV]"
DATA ""

@TST_ROAD1_EN
DATA "\M[21]"
DATA "[\L[@SAVE]Save\0][\L[@LOAD]Load\0][\L[@TST_ITEMS_EN]Item\0]\n\n"
DATA "Straight way to the north. A room on the left.\n\n"
DATA "●\L[@TST_ROOM1_EN]Enter in the room.\n\n"
DATA "●\L[@TST_ROAD2_EN]Go forward.\n\n"
DATA "\C[K0]\L[B:@HLP_START_EN]"
DATA "\L[L:@TST_START_EN:R1]"
DATA "\L[R:@TST_ROAD2_EN]"
DATA ""

@TST_ROAD2_EN
DATA "\M[21]"
DATA "[\L[@SAVE]Save\0][\L[@LOAD]Load\0][\L[@TST_ITEMS_EN]Item\0]\n\n"
DATA "A corner. You must turn right.\n\n"
DATA "●\L[@TST_ROAD3_EN]Go forward.\n\n"
DATA "●\L[@TST_ROAD1_EN]Go back.\n\n"
DATA "\C[K0]\L[B:@HLP_START_EN]"
DATA "\L[L:@TST_ROAD1_EN]"
DATA "\L[R:@TST_ROAD3_EN]"
DATA ""

@TST_ROAD3_EN
DATA "\M[21]"
DATA "[\L[@SAVE]Save\0][\L[@LOAD]Load\0][\L[@TST_ITEMS_EN]Item\0]\n\n"
DATA "Straight way to the east. A room on the left.\n\n"
DATA "●\L[@TST_ROOM3_EN]Enter the room.\n\n"
DATA "●\L[@TST_ROAD4_EN]Go forward.\n\n"
DATA "●\L[@TST_ROAD2_EN]Go back.\n\n"
DATA "\C[K0]\L[B:@HLP_START_EN]"
DATA "\L[L:@TST_ROAD2_EN]"
DATA "\L[R:@TST_ROAD4_EN]"
DATA ""

@TST_ROAD4_EN
DATA "\M[21]"
DATA "[\L[@SAVE]Save\0][\L[@LOAD]Load\0][\L[@TST_ITEMS_EN]Item\0]\n\n"
DATA "A corner. You must turn right.\n\n"
DATA "●\L[@TST_ROAD5_EN]Go forward.\n\n"
DATA "●\L[@TST_ROAD3_EN]Go back\n\n"
DATA "\C[K0]\L[B:@HLP_START_EN]"
DATA "\L[L:@TST_ROAD3_EN]"
DATA "\L[R:@TST_ROAD5_EN]"
DATA ""

@TST_ROAD5_EN
DATA "\M[@STOP]"
DATA "\C[K3]\C[MK]\I[JRFTRT_A,0,144,0,179,55,140,32]"
DATA "\C[!K3]\C[MK]\I[JRFTRT_A,0,36,112,71,167,140,32]"
DATA "[\L[@SAVE]Save\0][\L[@LOAD]Load\0][\L[@TST_ITEMS_EN]Item\0]\n\n"
DATA "A locked door shuts you the way."
DATA "\C[K3]You have the key.\n\n"
DATA "\C[!K3]You don\N[SQ]t have the key.\n\n"
DATA "\C[K3]●\L[@TST_ROAD6_EN]Go forward.\n\n"
DATA "●\L[@TST_ROAD4_EN]Go back.\n\n"
DATA "\C[K0]\L[B:@HLP_START_EN]"
DATA "\L[L:@TST_ROAD4_EN]"
DATA "\C[K3]\L[R:@TST_ROAD6_EN]"
DATA ""

@TST_ROAD6_EN
DATA "\M[21]"
DATA "[\L[@SAVE]Save\0][\L[@LOAD]Load\0][\L[@TST_ITEMS_EN]Item\0]\n\n"
DATA "Straight way to the south. A room on the left.\n\n"
DATA "●\L[@TST_ROOM6_EN]Enter the room.\n\n"
DATA "●\L[@TST_ROAD7_EN]Go forward.\n\n"
DATA "●\L[@TST_ROAD5_EN]Go back.\n\n"
DATA "\C[K0]\L[B:@HLP_START_EN]"
DATA "\L[L:@TST_ROAD5_EN]"
DATA "\L[R:@TST_ROAD7_EN]"
DATA ""

@TST_ROAD7_EN
DATA "\M[21]"
DATA "[\L[@SAVE]Save\0][\L[@LOAD]Load\0][\L[@TST_ITEMS_EN]Item\0]\n\n"
DATA "A corner. You must turn right.\n\n"
DATA "●\L[@TST_ROAD8_EN]Go forward.\n\n"
DATA "●\L[@TST_ROAD6_EN]Go back.\n\n"
DATA "\C[K0]\L[B:@HLP_START_EN]"
DATA "\L[L:@TST_ROAD6_EN]"
DATA "\L[R:@TST_ROAD8_EN]"
DATA ""

@TST_ROAD8_EN
DATA "\M[21]"
DATA "[\L[@SAVE]Save\0][\L[@LOAD]Load\0][\L[@TST_ITEMS_EN]Item\0]\n\n"
DATA "Straight way to the west. A room on the left.\n\n"
DATA "●\L[@TST_ROOM8_EN]Enter the room.\n\n"
DATA "●\L[@TST_ROAD9_EN]Go forward.\n\n"
DATA "●\L[@TST_ROAD7_EN]Go back.\n\n"
DATA "\C[K0]\L[B:@HLP_START_EN]"
DATA "\L[L:@TST_ROAD7_EN]"
DATA "\L[R:@TST_ROAD9_EN]"
DATA ""

@TST_ROAD9_EN
DATA "\M[21]"
DATA "[\L[@SAVE]Save\0][\L[@LOAD]Load\0][\L[@TST_ITEMS_EN]Item\0]\n\n"
DATA "A corner. You must turn right.\n\n"
DATA "●\L[@TST_ROADA_EN]Go forward.\n\n"
DATA "●\L[@TST_ROAD8_EN]Go back.\n\n"
DATA "\C[K0]\L[B:@HLP_START_EN]"
DATA "\L[L:@TST_ROAD8_EN]"
DATA "\L[R:@TST_ROADA_EN]"
DATA ""

@TST_ROADA_EN
DATA "\M[21]"
DATA "[\L[@SAVE]Save\0][\L[@LOAD]Load\0][\L[@TST_ITEMS_EN]Item\0]\n\n"
DATA "Straight way to the north. A man on the way.\n\n"
DATA "●\L[@TST_ROADB_EN]Go forward.\n\n"
DATA "●\L[@TST_ROAD9_EN]Go back.\n\n"
DATA "\C[K0]\L[B:@HLP_START_EN]"
DATA "\L[L:@TST_ROAD9_EN]"
DATA "\L[R:@TST_ROADB_EN]"
DATA ""

@TST_ROADB_EN
DATA "\M[@STOP]"
DATA "\C[!K2]\C[MK]\I[JRFTRT_A,0,108,112,143,167,140,32]"
DATA "\C[K2]\C[MK]\I[JRFTRT_A,0,144,112,179,167,140,32]"
DATA "[\L[@SAVE]Save\0][\L[@LOAD]Load\0][\L[@TST_ITEMS_EN]Item\0]\n\n"
DATA "There is a guard. He inquires you.:\n\n"
DATA "'Did you get permission?'\n\n"
DATA "\C[K1]●\L[@TST_TEST1_EN]Show the Mysterious Knot.\n\n"
DATA "\C[K2]●\L[@TST_TEST2_EN]Show the Strange Knot.\n\n"
DATA "●\L[@TST_TESTN_EN]Answer 'No, I didn\N[SQ]t'.\n\n"
DATA "\C[K0]\L[B:@HLP_START_EN]"
DATA ""

@TST_ROOM1_EN
DATA "\M[@STOP]"
DATA "\C[MK]\I[JRFTRT_A,0,108,0,143,55,140,32]"
DATA "[\L[@SAVE]Save\0][\L[@LOAD]Load\0][\L[@TST_ITEMS_EN]Item\0]\n\n"
DATA "You entered the room. You show a treasure chest. "
DATA "\C[K3]You can open it by the 'Master Key'.\n\n"
DATA "\C[!K3]But you cannot open it.\n\n"
DATA "\C[K3]●\L[@TST_ROOM1A_EN]Open the chest.\n\n"
DATA "●\L[@TST_ROAD1_EN]Leave the room.\n\n"
DATA "\C[K0]\L[B:@HLP_START_EN]"
DATA "\L[L:@TST_ROAD1_EN]"
DATA ""

@TST_ROOM1A_EN
DATA "[\L[@SAVE]Save\0][\L[@LOAD]Load\0][\L[@TST_ITEMS_EN]Item\0]\n\n"
DATA "Nothing but garbage. "
DATA "\C[K1]\C[K2]\n\n"
DATA "\C[!K1]\C[!K2]Two ropes with a knot are there.\n\n"
DATA "\C[K1]\C[!K2]A rope with a knot is there.\n\n"
DATA "\C[!K1]\C[K2]A rope with a knot is there.\n\n"
DATA "\C[TR]\P[@TST_TRAP:0.25,0.25]"
DATA "\P[@TST_RND:2]"
DATA "\C[TMP_0]\C[!K1]●\L[@TST_ROOM1B_EN]Get a Mysterious Knot.\n\n"
DATA "\C[TMP_0]\C[!K2]●\L[@TST_ROOM1C_EN]Get a Strange Knot.\n\n"
DATA "\C[TMP_1]\C[!K2]●\L[@TST_ROOM1C_EN]Get a Strange Knot.\n\n"
DATA "\C[TMP_1]\C[!K1]●\L[@TST_ROOM1B_EN]Get a Mysterious Knot.\n\n"
DATA "●\L[@TST_ROAD1_EN]Leave the room.\n\n"
DATA "\C[K0]\L[B:@HLP_START_EN]"
DATA "\L[L:@TST_ROAD1_EN]"
DATA "\P[@TST_CLEAR_TMP]"
DATA "\F[TR]"
DATA ""

@TST_ROOM1B_EN
DATA "\F[K1]"
DATA "\C[MK]\I[JRFTRT_A,0,180,56,215,111,140,32]"
DATA "[\L[@SAVE]Save\0][\L[@LOAD]Load\0][\L[@TST_ITEMS_EN]Item\0]\n\n"
DATA "You got the Mysterious Knot."
DATA "\C[K0]\L[B:@HLP_START_EN]"
DATA "\L[R:@TST_ROOM1A_EN]"
DATA ""

@TST_ROOM1C_EN
DATA "\F[K2]"
DATA "\C[MK]\I[JRFTRT_A,0,72,0,107,55,140,32]"
DATA "[\L[@SAVE]Save\0][\L[@LOAD]Load\0][\L[@TST_ITEMS_EN]Item\0]\n\n"
DATA "You got the Strange Knot."
DATA "\C[K0]\L[B:@HLP_START_EN]"
DATA "\L[R:@TST_ROOM1A_EN]"
DATA ""

@TST_TRMSG_EN
DATA "You found a trap, but escaped.\n\n", ""

@TST_ROOM1T_EN
DATA "\C[MK]\I[JRFTRT_A,0,108,56,143,111,140,32]"
DATA "[\L[@SAVE]Save\0][\L[@LOAD]Load\0][\L[@TST_ITEMS_EN]Item\0]\n\n"
DATA "Trap! You find yourself at somewhere else."
DATA "\C[K0]\L[B:@HLP_START_EN]"
DATA "\L[R:@TST_ROAD8_EN]"
DATA ""

@TST_ROOM3_EN
DATA "\M[@STOP]"
DATA "\C[MK]\I[JRFTRT_A,0,0,0,35,55,140,32]"
DATA "[\L[@SAVE]Save\0][\L[@LOAD]Load\0][\L[@TST_ITEMS_EN]Item\0]\n\n"
DATA "There are some pieces of furniture.\n\n"
DATA "●\L[@TST_ROOM3A_EN]Search the chair.\n\n"
DATA "●\L[K3@TST_ROOM3A_EN,R3@TST_ROOM3C_EN,@TST_ROOM3B_EN]Search the desk.\n\n"
DATA "●\L[@TST_ROOM3A_EN]Search the shelf.\n\n"
DATA "●\L[@TST_ROAD3_EN]Leave the room.\n\n"
DATA "\C[K0]\L[B:@HLP_START_EN]"
DATA "\L[L:@TST_ROAD3_EN]"
DATA ""

@TST_ROOM3A_EN
DATA "[\L[@SAVE]Save\0][\L[@LOAD]Load\0][\L[@TST_ITEMS_EN]Item\0]\n\n"
DATA "Nothing could be found.\n\n"
DATA "\C[K0]\L[B:@HLP_START_EN]"
DATA "\L[L:@TST_ROOM3_EN]"
DATA ""

@TST_ROOM3B_EN
DATA "\F[R3]"
DATA "[\L[@SAVE]Save\0][\L[@LOAD]Load\0][\L[@TST_ITEMS_EN]Item\0]\n\n"
DATA "Nothing could be found, but...\n\n"
DATA "\C[K0]\L[B:@HLP_START_EN]"
DATA "\L[L:@TST_ROOM3_EN]"
DATA ""

@TST_ROOM3C_EN
DATA "[\L[@SAVE]Save\0][\L[@LOAD]Load\0][\L[@TST_ITEMS_EN]Item\0]\n\n"
DATA "You investigated a drawer. You found the 'Master Key'.\n\n"
DATA "●\L[@TST_ROOM3D_EN]Get the Master Key.\n\n"
DATA "●\L[@TST_ROAD3_EN]Leave the room.\n\n"
DATA "\C[K0]\L[B:@HLP_START_EN]"
DATA "\L[L:@TST_ROOM3_EN]"
DATA ""

@TST_ROOM3D_EN
DATA "\F[K3]"
DATA "\C[MK]\I[JRFTRT_A,0,180,0,215,55,140,32]"
DATA "[\L[@SAVE]Save\0][\L[@LOAD]Load\0][\L[@TST_ITEMS_EN]Item\0]\n\n"
DATA "You got the Master Key.\n\n"
DATA "\C[K0]\L[B:@HLP_START_EN]"
DATA "\L[R:@TST_ROOM3_EN]"
DATA ""

@TST_ROOM6_EN
DATA "\M[@STOP]"
DATA "\C[MK]\I[JRFTRT_D,0,180,0,215,55,140,32]"
DATA "[\L[@SAVE]Save\0][\L[@LOAD]Load\0][\L[@TST_ITEMS_EN]Item\0]\n\n"
DATA "There are some pieces of furniture and a man. He tells you.:\n\n"
DATA "'Nothing is here.'\n\n"
DATA "●\L[@TST_ROOM6A_EN]Search the chair.\n\n"
DATA "●\L[@TST_ROOM6A_EN]Search the desk.\n\n"
DATA "●\L[@TST_ROOM6A_EN]Search the shelf.\n\n"
DATA "●\L[@TST_ROAD6_EN]Leave the room.\n\n"
DATA "\C[K0]\L[B:@HLP_START_EN]"
DATA "\L[L:@TST_ROAD6_EN]"
DATA ""

@TST_ROOM6A_EN
DATA "[\L[@SAVE]Save\0][\L[@LOAD]Load\0][\L[@TST_ITEMS_EN]Item\0]\n\n"
DATA "Nothing could be found.\n\n"
DATA "\C[K0]\L[B:@HLP_START_EN]"
DATA "\L[L:@TST_ROOM6_EN]"
DATA ""

@TST_ROOM8_EN
DATA "\M[5]"
DATA "\F[!K1]\F[!K2]\F[!K3]"
DATA "\C[!K0]\C[MK]\I[JRFTRT_A,0,72,56,107,111,140,32]"
DATA "\C[K0]\C[MK]\I[JRFTRT_A,0,0,56,35,111,140,32]"
DATA "[\L[@SAVE]Save\0][\L[@LOAD]Load\0][\L[@TST_ITEMS_EN]Item\0]\n\n"
DATA "You entered the room. You encounter a 'Goddess of Seasons'.:\n\n"
DATA "\C[!K0]'You have no experience to have such things.'\n\n"
DATA "\C[K0]'You have no meaning to have such things.'\n\n"
DATA "You have lost all items"
DATA "\C[K0] except for the Map"
DATA "!\n\n"
DATA "●\L[@TST_ROAD8_EN]Leave the room.\n\n"
DATA "\C[K0]\L[B:@HLP_START_EN]"
DATA "\L[L:@TST_ROAD8_EN]"
DATA ""

@TST_TESTN_EN
DATA "[\L[@SAVE]Save\0][\L[@LOAD]Load\0][\L[@TST_ITEMS_EN]Item\0]\n\n"
DATA "'Then, you cannot go forward.'\n\n"
DATA "●\L[@TST_ROADA_EN]Go back.\n\n"
DATA "\C[K0]\L[B:@HLP_START_EN]"
DATA "\L[L:@TST_ROADA_EN]"
DATA ""

@TST_TEST1_EN
DATA "\C[!K2]\C[MK]\I[JRFTRT_A,0,216,56,251,111,140,32]"
DATA "\C[K2]\C[MK]\I[JRFTRT_A,0,144,56,179,111,140,32]"
DATA "[\L[@SAVE]Save\0][\L[@LOAD]Load\0][\L[@TST_ITEMS_EN]Item\0]\n\n"
DATA "'Well, you have permission. You can go forward.'\n\n"
DATA "●\L[K2@TST_TESTE_EN,@TST_FINAL_EN]Go forward.\n\n"
DATA "\C[K0]\L[B:@HLP_START_EN]"
DATA "\L[R:K2@TST_TESTE_EN,@TST_FINAL_EN]"
DATA ""

@TST_TESTE_EN
DATA "\M[2]"
DATA "[\L[@SAVE]Save\0][\L[@LOAD]Load\0][\L[@TST_ITEMS_EN]Item\0]\n\n"
DATA "'Wait a moment, boy. "
DATA "Your pocket glimpses another knot. "
DATA "What is it?'\n\n"
DATA "●\L[@TST_TEST2_EN]Show the Strange Knot.\n\n"
DATA "\C[K0]\L[B:@HLP_START_EN]"
DATA ""

@TST_TEST2_EN
DATA "\M[2]"
DATA "[\L[@SAVE]Save\0][\L[@LOAD]Load\0][\L[@TST_ITEMS_EN]Item\0]\n\n"
DATA "'It is YOU who have the symbol that I killed the father."
DATA "Now, I avenge the father\N[SQ]s enemy!'\n\n"
DATA "The guard slashed you into the bodies."
DATA "\C[K0]\L[B:@HLP_START_EN]"
DATA "\L[R:@TST_GOVER_EN]"
DATA ""

@TST_GOVER_EN
DATA "\M[6]"
DATA "\C[MK]\I[JRFTRT_D,0,180,56,215,111,140,32]"
DATA "\F[!K0]\F[!K1]\F[!K2]\F[!K3]\F[!TR]\F[!R3]"
DATA "[\L[@SAVE]Save\0][\L[@LOAD]Load\0][\L[@TST_ITEMS_EN]Item\0]\n\n"
DATA "GAME OVER."
DATA "\C[K0]\L[B:@HLP_START_EN]"
DATA "\L[R:@TST_START_EN]"
DATA ""

@TST_FINAL_EN
DATA "\M[10]"
DATA "\C[MK]\I[JRFTRT_A,0,216,0,251,55,140,32]"
DATA "[\L[@SAVE]Save\0][\L[@LOAD]Load\0][\L[@TST_ITEMS_EN]Item\0]\n\n"
DATA "Suddenly, you slipped your step.\n\n"
DATA "You are falling down in a gaping hole...\n\n"
DATA "\C[K0]\L[B:@HLP_START_EN]"
DATA "\L[R:@TST_CONGL_EN]"
DATA ""

@TST_CONGL_EN
DATA "\M[9]"
DATA "\F[K0]\F[!TR]\F[!R3]"
DATA "\C[MK]\I[JRFTRT_A,0,180,112,215,167,140,32]"
DATA "■ Congratulations\n\n"
DATA "Awaking shows you forward or a ray of light.\n\n"
DATA "Congratulations. You have reached the exit.\n\n"
DATA "...and like this, you can program an adventure game "
DATA "by using 'hlpview.prg'.\n\n"
DATA "●\L[@SAVE]Save.\n\n"
DATA "●\L[@HLP_START_EN]Go back to the manual.\n\n"
DATA "\C[K0]\L[B:@HLP_START_EN]"
DATA "\L[R:@HLP_START_EN]"
DATA ""


@TST_START_JA
DATA "\M[@STOP]"
DATA "\C[!CMK]\F[!MK]"
DATA "\C[!CMK]\C[G:JRFTRT_A]\C[G:JRFTRT_D]\F[MK]"
DATA "\C[!CMK]\F[CMK]"
DATA "\C[MK]\I[JRFTRT_A,0,72,112,107,167,140,32]"
DATA "[\L[@SAVE]セーブ\0][\L[@LOAD]ロード\0][\L[@TST_ITEMS_JA]モチモノ\0]\n\n"
DATA "アナタ ハ「テスト ノ メイキュウ」ニ マヨイコンダ。\n\n"
DATA "インジャ ガ アナタ ニ カタリ カケル。:\n\n"
DATA "「\C[R1]モドッテ コンデ ヨイ。"
DATA "\F[!R1]ツギ ヘ ススミ ナサイ。」"
DATA "\C[K0]\L[B:@HLP_START_JA]"
DATA "\L[R:@TST_ROAD1_JA]"
DATA ""

@TST_ITEMS_JA
DATA "■ モチモノ\n\n"
DATA "\C[K1]●フシギ ナ ムスビ メ\n\n"
DATA "\C[!K1]●????\n\n"
DATA "\C[K2]●キミョウ ナ ムスビ メ\n\n"
DATA "\C[!K2]●????\n\n"
DATA "\C[K3]●マスター キー\n\n"
DATA "\C[!K3]●????\n\n"
DATA "\C[K0]●カエリ ミチ ノ チズ\n\n"
DATA "\C[!K0]●????\n\n"
DATA "\L[B:@PREV]"
DATA ""

@TST_ROAD1_JA
DATA "\M[21]"
DATA "[\L[@SAVE]セーブ\0][\L[@LOAD]ロード\0][\L[@TST_ITEMS_JA]モチモノ\0]\n\n"
DATA "キタ ヘ ミチ ガ ノビテイル。ヒダリ ガワ ニ ヘヤ ガアル。\n\n"
DATA "●\L[@TST_ROOM1_JA]ヘヤ ヘ ハイル。\n\n"
DATA "●\L[@TST_ROAD2_JA]サキ ヘ ススム。\n\n"
DATA "\C[K0]\L[B:@HLP_START_JA]"
DATA "\L[L:@TST_START_JA:R1]"
DATA "\L[R:@TST_ROAD2_JA]"
DATA ""

@TST_ROAD2_JA
DATA "\M[21]"
DATA "[\L[@SAVE]セーブ\0][\L[@LOAD]ロード\0][\L[@TST_ITEMS_JA]モチモノ\0]\n\n"
DATA "マガリ カド ノ ヨウダ。ミギ ニ マガル シカナイ。\n\n"
DATA "●\L[@TST_ROAD3_JA]サキ ヘ ススム。\n\n"
DATA "●\L[@TST_ROAD1_JA]ウシロ ニ モドル。\n\n"
DATA "\C[K0]\L[B:@HLP_START_JA]"
DATA "\L[L:@TST_ROAD1_JA]"
DATA "\L[R:@TST_ROAD3_JA]"
DATA ""

@TST_ROAD3_JA
DATA "\M[21]"
DATA "[\L[@SAVE]セーブ\0][\L[@LOAD]ロード\0][\L[@TST_ITEMS_JA]モチモノ\0]\n\n"
DATA "ヒガシ ヘ ミチ ガ ノビテイル。ヒダリ ガワ ニ ヘヤ ガアル。\n\n"
DATA "●\L[@TST_ROOM3_JA]ヘヤ ヘ ハイル。\n\n"
DATA "●\L[@TST_ROAD4_JA]サキ ヘ ススム。\n\n"
DATA "●\L[@TST_ROAD2_JA]ウシロ ニ モドル。\n\n"
DATA "\C[K0]\L[B:@HLP_START_JA]"
DATA "\L[L:@TST_ROAD2_JA]"
DATA "\L[R:@TST_ROAD4_JA]"
DATA ""

@TST_ROAD4_JA
DATA "\M[21]"
DATA "[\L[@SAVE]セーブ\0][\L[@LOAD]ロード\0][\L[@TST_ITEMS_JA]モチモノ\0]\n\n"
DATA "マガリ カド ノ ヨウダ。ミギ ニ マガル シカナイ。\n\n"
DATA "●\L[@TST_ROAD5_JA]サキ ヘ ススム。\n\n"
DATA "●\L[@TST_ROAD3_JA]ウシロ ニ モドル。\n\n"
DATA "\C[K0]\L[B:@HLP_START_JA]"
DATA "\L[L:@TST_ROAD3_JA]"
DATA "\L[R:@TST_ROAD5_JA]"
DATA ""

@TST_ROAD5_JA
DATA "\M[@STOP]"
DATA "\C[!K3]\C[MK]\I[JRFTRT_A,0,144,0,179,55,140,32]"
DATA "\C[K3]\C[MK]\I[JRFTRT_A,0,36,112,71,167,140,32]"
DATA "[\L[@SAVE]セーブ\0][\L[@LOAD]ロード\0][\L[@TST_ITEMS_JA]モチモノ\0]\n\n"
DATA "カギ ノ アル トビラ ガ アリ ミチ ヲ フサイデイル。"
DATA "\C[K3]アナタ ハ カギ ヲ モッテイル。\n\n"
DATA "\C[!K3]アナタ ハ カギ ヲ モッテイナイ。\n\n"
DATA "\C[K3]●\L[@TST_ROAD6_JA]サキ ヘ ススム。\n\n"
DATA "●\L[@TST_ROAD4_JA]ウシロ ニ モドル。\n\n"
DATA "\C[K0]\L[B:@HLP_START_JA]"
DATA "\L[L:@TST_ROAD4_JA]"
DATA "\C[K3]\L[R:@TST_ROAD6_JA]"
DATA ""

@TST_ROAD6_JA
DATA "\M[21]"
DATA "[\L[@SAVE]セーブ\0][\L[@LOAD]ロード\0][\L[@TST_ITEMS_JA]モチモノ\0]\n\n"
DATA "ミナミ ヘ ミチ ガ ノビテイル。ヒダリ ガワ ニ ヘヤ ガアル。\n\n"
DATA "●\L[@TST_ROOM6_JA]ヘヤ ヘ ハイル。\n\n"
DATA "●\L[@TST_ROAD7_JA]サキ ヘ ススム。\n\n"
DATA "●\L[@TST_ROAD5_JA]ウシロ ニ モドル。\n\n"
DATA "\C[K0]\L[B:@HLP_START_JA]"
DATA "\L[L:@TST_ROAD5_JA]"
DATA "\L[R:@TST_ROAD7_JA]"
DATA ""

@TST_ROAD7_JA
DATA "\M[21]"
DATA "[\L[@SAVE]セーブ\0][\L[@LOAD]ロード\0][\L[@TST_ITEMS_JA]モチモノ\0]\n\n"
DATA "マガリ カド ノ ヨウダ。ミギ ニ マガル シカナイ。\n\n"
DATA "●\L[@TST_ROAD8_JA]サキ ヘ ススム。\n\n"
DATA "●\L[@TST_ROAD6_JA]ウシロ ニ モドル。\n\n"
DATA "\C[K0]\L[B:@HLP_START_JA]"
DATA "\L[L:@TST_ROAD6_JA]"
DATA "\L[R:@TST_ROAD8_JA]"
DATA ""

@TST_ROAD8_JA
DATA "\M[21]"
DATA "[\L[@SAVE]セーブ\0][\L[@LOAD]ロード\0][\L[@TST_ITEMS_JA]モチモノ\0]\n\n"
DATA "ニシ ヘ ミチ ガ ノビテイル。ヒダリ ガワ ニ ヘヤ ガアル。\n\n"
DATA "●\L[@TST_ROOM8_JA]ヘヤ ヘ ハイル。\n\n"
DATA "●\L[@TST_ROAD9_JA]サキ ヘ ススム。\n\n"
DATA "●\L[@TST_ROAD7_JA]ウシロ ニ モドル。\n\n"
DATA "\C[K0]\L[B:@HLP_START_JA]"
DATA "\L[L:@TST_ROAD7_JA]"
DATA "\L[R:@TST_ROAD9_JA]"
DATA ""

@TST_ROAD9_JA
DATA "\M[21]"
DATA "[\L[@SAVE]セーブ\0][\L[@LOAD]ロード\0][\L[@TST_ITEMS_JA]モチモノ\0]\n\n"
DATA "マガリ カド ノ ヨウダ。ミギ ニ マガル シカナイ。\n\n"
DATA "●\L[@TST_ROADA_JA]サキ ヘ ススム。\n\n"
DATA "●\L[@TST_ROAD8_JA]ウシロ ニ モドル。\n\n"
DATA "\C[K0]\L[B:@HLP_START_JA]"
DATA "\L[L:@TST_ROAD8_JA]"
DATA "\L[R:@TST_ROADA_JA]"
DATA ""

@TST_ROADA_JA
DATA "\M[21]"
DATA "[\L[@SAVE]セーブ\0][\L[@LOAD]ロード\0][\L[@TST_ITEMS_JA]モチモノ\0]\n\n"
DATA "キタ ヘ ミチ ガ ノビテイル。マエ ニ ヒト ガイル。\n\n"
DATA "●\L[@TST_ROADB_JA]サキ ヘ ススム。\n\n"
DATA "●\L[@TST_ROAD9_JA]ウシロ ニ モドル。\n\n"
DATA "\C[K0]\L[B:@HLP_START_JA]"
DATA "\L[L:@TST_ROAD9_JA]"
DATA "\L[R:@TST_ROADB_JA]"
DATA ""

@TST_ROADB_JA
DATA "\M[@STOP]"
DATA "\C[!K2]\C[MK]\I[JRFTRT_A,0,108,112,143,167,140,32]"
DATA "\C[K2]\C[MK]\I[JRFTRT_A,0,144,112,179,167,140,32]"
DATA "[\L[@SAVE]セーブ\0][\L[@LOAD]ロード\0][\L[@TST_ITEMS_JA]モチモノ\0]\n\n"
DATA "モンバン ガ イル。カレ ガ トウ。:\n\n"
DATA "「オマエ ハ ユルシ ヲ エテイルカ。」\n\n"
DATA "\C[K1]●\L[@TST_TEST1_JA]フシギ ナ ムスビ メ ヲ ミセル。\n\n"
DATA "\C[K2]●\L[@TST_TEST2_JA]キミョウ ナ ムスビ メ ヲ ミセル。\n\n"
DATA "●\L[@TST_TESTN_JA]「エテ イナイ」ト コタエル。\n\n"
DATA "\C[K0]\L[B:@HLP_START_JA]"
DATA ""

@TST_ROOM1_JA
DATA "\M[@STOP]"
DATA "\C[MK]\I[JRFTRT_A,0,108,0,143,55,140,32]"
DATA "[\L[@SAVE]セーブ\0][\L[@LOAD]ロード\0][\L[@TST_ITEMS_JA]モチモノ\0]\n\n"
DATA "ヘヤ ニ ハイル ト、マエ ニ タカラバコ ガ アル。"
DATA "\C[K3]「マスターキー」ガ ツカエル ヨウダ。\n\n"
DATA "\C[!K3]シカシ、アケラレソウ ニ ナイ。\n\n"
DATA "\C[K3]●\L[@TST_ROOM1A_JA]タカラバコ ヲ アケル。\n\n"
DATA "●\L[@TST_ROAD1_JA]ヘヤ ヲ デル。\n\n"
DATA "\C[K0]\L[B:@HLP_START_JA]"
DATA "\L[L:@TST_ROAD1_JA]"
DATA ""

@TST_ROOM1A_JA
DATA "[\L[@SAVE]セーブ\0][\L[@LOAD]ロード\0][\L[@TST_ITEMS_JA]モチモノ\0]\n\n"
DATA "ロク ナ モノ ガ ハイッテイナイ。"
DATA "\C[K1]\C[K2]\n\n"
DATA "\C[!K1]\C[!K2]ムスビ メ ノ アル ヒモ ガ 2ホン アル。\n\n"
DATA "\C[K1]\C[!K2]ムスビ メ ノ アル ヒモ ガ 1ポン アル。\n\n"
DATA "\C[!K1]\C[K2]ムスビ メ ノ アル ヒモ ガ 1ポン アル。\n\n"
DATA "\C[TR]\P[@TST_TRAP:0.25,0.25]"
DATA "\P[@TST_RND:2]"
DATA "\C[TMP_0]\C[!K1]●\L[@TST_ROOM1B_JA]フシギ ナ ムスビ メ ヲ ヒロウ。\n\n"
DATA "\C[TMP_0]\C[!K2]●\L[@TST_ROOM1C_JA]キミョウ ナ ムスビ メ ヲ ヒロウ。\n\n"
DATA "\C[TMP_1]\C[!K2]●\L[@TST_ROOM1C_JA]キミョウ ナ ムスビ メ ヲ ヒロウ。\n\n"
DATA "\C[TMP_1]\C[!K1]●\L[@TST_ROOM1B_JA]フシギ ナ ムスビ メ ヲ ヒロウ。\n\n"
DATA "●\L[@TST_ROAD1_JA]ヘヤ ヲ デル。\n\n"
DATA "\C[K0]\L[B:@HLP_START_JA]"
DATA "\L[L:@TST_ROAD1_JA]"
DATA "\P[@TST_CLEAR_TMP]"
DATA "\F[TR]"
DATA ""

@TST_ROOM1B_JA
DATA "\F[K1]"
DATA "\C[MK]\I[JRFTRT_A,0,180,56,215,111,140,32]"
DATA "[\L[@SAVE]セーブ\0][\L[@LOAD]ロード\0][\L[@TST_ITEMS_JA]モチモノ\0]\n\n"
DATA "フシギ ナ ムスビ メ ヲ ヒロッタ。"
DATA "\C[K0]\L[B:@HLP_START_JA]"
DATA "\L[R:@TST_ROOM1A_JA]"
DATA ""

@TST_ROOM1C_JA
DATA "\F[K2]"
DATA "\C[MK]\I[JRFTRT_A,0,72,0,107,55,140,32]"
DATA "[\L[@SAVE]セーブ\0][\L[@LOAD]ロード\0][\L[@TST_ITEMS_JA]モチモノ\0]\n\n"
DATA "キミョウ ナ ムスビ メ ヲ ヒロッタ。"
DATA "\C[K0]\L[B:@HLP_START_JA]"
DATA "\L[R:@TST_ROOM1A_JA]"
DATA ""

@TST_TRMSG_JA
DATA "ワナ ガ アッタガ、ヒッカカラ ナカッタ。\n\n", ""

@TST_ROOM1T_JA
DATA "\C[MK]\I[JRFTRT_A,0,108,56,143,111,140,32]"
DATA "[\L[@SAVE]セーブ\0][\L[@LOAD]ロード\0][\L[@TST_ITEMS_JA]モチモノ\0]\n\n"
DATA "ワナ ダ!ドコカ ベツ ノ バショ ニ トバサレタ ヨウダ。"
DATA "\C[K0]\L[B:@HLP_START_JA]"
DATA "\L[R:@TST_ROAD8_JA]"
DATA ""

@TST_ROOM3_JA
DATA "\M[@STOP]"
DATA "\C[MK]\I[JRFTRT_A,0,36,56,71,111,140,32]"
DATA "[\L[@SAVE]セーブ\0][\L[@LOAD]ロード\0][\L[@TST_ITEMS_JA]モチモノ\0]\n\n"
DATA "ヘヤ ニハ カグ ガ イクツカアル。\n\n"
DATA "●\L[@TST_ROOM3A_JA]イス ヲ シラベル。\n\n"
DATA "●\L[K3@TST_ROOM3A_JA,R3@TST_ROOM3C_JA,@TST_ROOM3B_JA]ツクエ ヲ シラベル。\n\n"
DATA "●\L[@TST_ROOM3A_JA]タナ ヲ シラベル。\n\n"
DATA "●\L[@TST_ROAD3_JA]ヘヤ ヲ デル。\n\n"
DATA "\C[K0]\L[B:@HLP_START_JA]"
DATA "\L[L:@TST_ROAD3_JA]"
DATA ""

@TST_ROOM3A_JA
DATA "[\L[@SAVE]セーブ\0][\L[@LOAD]ロード\0][\L[@TST_ITEMS_JA]モチモノ\0]\n\n"
DATA "ナニ モ ナイ ヨウダ。\n\n"
DATA "\C[K0]\L[B:@HLP_START_JA]"
DATA "\L[L:@TST_ROOM3_JA]"
DATA ""

@TST_ROOM3B_JA
DATA "\F[R3]"
DATA "[\L[@SAVE]セーブ\0][\L[@LOAD]ロード\0][\L[@TST_ITEMS_JA]モチモノ\0]\n\n"
DATA "ナニ モ ナイ ヨウダ ガ...\n\n"
DATA "\C[K0]\L[B:@HLP_START_JA]"
DATA "\L[L:@TST_ROOM3_JA]"
DATA ""

@TST_ROOM3C_JA
DATA "[\L[@SAVE]セーブ\0][\L[@LOAD]ロード\0][\L[@TST_ITEMS_JA]モチモノ\0]\n\n"
DATA "ヒキダシ ヲ ヨク シラベルト、「マスターキー」ヲ ミツケタ。\n\n"
DATA "●\L[@TST_ROOM3D_JA]マスター キー ヲ ヒロウ。\n\n"
DATA "●\L[@TST_ROAD3_JA]ヘヤ ヲ デル。\n\n"
DATA "\C[K0]\L[B:@HLP_START_JA]"
DATA "\L[L:@TST_ROOM3_JA]"
DATA ""

@TST_ROOM3D_JA
DATA "\F[K3]"
DATA "\C[MK]\I[JRFTRT_A,0,180,0,215,55,140,32]"
DATA "[\L[@SAVE]セーブ\0][\L[@LOAD]ロード\0][\L[@TST_ITEMS_JA]モチモノ\0]\n\n"
DATA "マスター キー ヲ ヒロッタ。\n\n"
DATA "\C[K0]\L[B:@HLP_START_JA]"
DATA "\L[R:@TST_ROOM3_JA]"
DATA ""

@TST_ROOM6_JA
DATA "\M[@STOP]"
DATA "\C[MK]\I[JRFTRT_D,0,180,0,215,55,140,32]"
DATA "[\L[@SAVE]セーブ\0][\L[@LOAD]ロード\0][\L[@TST_ITEMS_JA]モチモノ\0]\n\n"
DATA "ヘヤ ニハ カグ ガ アリ、ヒト ガ イル。カレ ガ イウ。:\n\n"
DATA "「ココ ニハ ナニ モ ナイゾ。」\n\n"
DATA "●\L[@TST_ROOM6A_JA]イス ヲ シラベル。\n\n"
DATA "●\L[@TST_ROOM6A_JA]ツクエ ヲ シラベル。\n\n"
DATA "●\L[@TST_ROOM6A_JA]タナ ヲ シラベル。\n\n"
DATA "●\L[@TST_ROAD6_JA]ヘヤ ヲ デル。\n\n"
DATA "\C[K0]\L[B:@HLP_START_JA]"
DATA "\L[L:@TST_ROAD6_JA]"
DATA ""

@TST_ROOM6A_JA
DATA "[\L[@SAVE]セーブ\0][\L[@LOAD]ロード\0][\L[@TST_ITEMS_JA]モチモノ\0]\n\n"
DATA "ナニ モ ナイ ヨウダ。\n\n"
DATA "\C[K0]\L[B:@HLP_START_JA]"
DATA "\L[L:@TST_ROOM6_JA]"
DATA ""

@TST_ROOM8_JA
DATA "\M[5]"
DATA "\F[!K1]\F[!K2]\F[!K3]"
DATA "\C[!K0]\C[MK]\I[JRFTRT_A,0,0,112,35,167,140,32]"
DATA "\C[K0]\C[MK]\I[JRFTRT_A,0,0,56,35,111,140,32]"
DATA "[\L[@SAVE]セーブ\0][\L[@LOAD]ロード\0][\L[@TST_ITEMS_JA]モチモノ\0]\n\n"
DATA "ヘヤ ニ ハイル ト、「トキ ノ メガミ」ガ アラワレタ。:\n\n"
DATA "\C[!K0]「アナタ ガ コンナ モノ ヲ モツ ノ ハ ハヤイ。」\n\n"
DATA "\C[K0]「アナタ ガ コンナ モノ ヲ モツ イミ ハ ナイ。」\n\n"
DATA "\C[K0]チズ イガイ ノ "
DATA "モチモノ ヲ スベテ ウバワレテ シマッタ!\n\n"
DATA "●\L[@TST_ROAD8_JA]ヘヤ ヲ デル。\n\n"
DATA "\C[K0]\L[B:@HLP_START_JA]"
DATA "\L[L:@TST_ROAD8_JA]"
DATA ""

@TST_TESTN_JA
DATA "[\L[@SAVE]セーブ\0][\L[@LOAD]ロード\0][\L[@TST_ITEMS_JA]モチモノ\0]\n\n"
DATA "「ナラバ ココ ハ トウセン。」\n\n"
DATA "●\L[@TST_ROADA_JA]ウシロ ニ モドル。\n\n"
DATA "\C[K0]\L[B:@HLP_START_JA]"
DATA "\L[L:@TST_ROADA_JA]"
DATA ""

@TST_TEST1_JA
DATA "\C[!K2]\C[MK]\I[JRFTRT_A,0,216,56,251,111,140,32]"
DATA "\C[K2]\C[MK]\I[JRFTRT_A,0,144,56,179,111,140,32]"
DATA "[\L[@SAVE]セーブ\0][\L[@LOAD]ロード\0][\L[@TST_ITEMS_JA]モチモノ\0]\n\n"
DATA "「ウム、ユルシ ヲ エテイルナ。トオッテ ヨシ。」\n\n"
DATA "●\L[K2@TST_TESTE_JA,@TST_FINAL_JA]サキ ヘ ススム。\n\n"
DATA "\C[K0]\L[B:@HLP_START_JA]"
DATA "\L[R:K2@TST_TESTE_JA,@TST_FINAL_JA]"
DATA ""

@TST_TESTE_JA
DATA "\M[2]"
DATA "[\L[@SAVE]セーブ\0][\L[@LOAD]ロード\0][\L[@TST_ITEMS_JA]モチモノ\0]\n\n"
DATA "「チョット マテ。"
DATA "ポケット カラ モウヒトツ ムスビ メ ガ ミエテイル。"
DATA "ソレハ ナンダ。 」\n\n"
DATA "●\L[@TST_TEST2_JA]キミョウ ナ ムスビ メ ヲ ミセル。\n\n"
DATA "\C[K0]\L[B:@HLP_START_JA]"
DATA ""

@TST_TEST2_JA
DATA "\M[2]"
DATA "[\L[@SAVE]セーブ\0][\L[@LOAD]ロード\0][\L[@TST_ITEMS_JA]モチモノ\0]\n\n"
DATA "「オノレ、コレ ハ チチ ヲ コロシタ ノハ ワタシ ト イウ シルシ。"
DATA "チチ ノ カタキ メ!」\n\n"
DATA "モンバン ハ アナタ ヲ イットウリョウダン ニ シタ。"
DATA "\C[K0]\L[B:@HLP_START_JA]"
DATA "\L[R:@TST_GOVER_JA]"
DATA ""

@TST_GOVER_JA
DATA "\M[6]"
DATA "\C[MK]\I[JRFTRT_D,0,180,56,215,111,140,32]"
DATA "\F[!K0]\F[!K1]\F[!K2]\F[!K3]\F[!TR]\F[!R3]"
DATA "[\L[@SAVE]セーブ\0][\L[@LOAD]ロード\0][\L[@TST_ITEMS_JA]モチモノ\0]\n\n"
DATA "ゲーム オーバー。"
DATA "\C[K0]\L[B:@HLP_START_JA]"
DATA "\L[R:@TST_START_JA]"
DATA ""

@TST_FINAL_JA
DATA "\M[10]"
DATA "\C[MK]\I[JRFTRT_A,0,216,0,251,55,140,32]"
DATA "[\L[@SAVE]セーブ\0][\L[@LOAD]ロード\0][\L[@TST_ITEMS_JA]モチモノ\0]\n\n"
DATA "トツゼン、アナタ ハ アシ ヲ スベラセタ。\n\n"
DATA "アナタ ハ フカイ アナ ヲ オチテイク...\n\n"
DATA "\C[K0]\L[B:@HLP_START_JA]"
DATA "\L[R:@TST_CONGL_JA]"
DATA ""

@TST_CONGL_JA
DATA "\M[9]"
DATA "\F[K0]\F[!TR]\F[!R3]"
DATA "\C[MK]\I[JRFTRT_A,0,180,112,215,167,140,32]"
DATA "■ オメデトウ\n\n"
DATA "キヅク ト マエ ニ ヒカリ ガ ミエル。\n\n"
DATA "オメデトウ。キミ ハ デグチ ニ タドリツイタ。\n\n"
DATA "...ト イッタヨウニ、hlpview.prg ヲ ツカウ ト "
DATA "アドヴェンチャー=ゲーム モ ツクレマス。\n\n"
DATA "●\L[@SAVE]セーブ スル。\n\n"
DATA "●\L[@HLP_START_JA]マニュアル ニ モドル。\n\n"
DATA "\C[K0]\L[B:@HLP_START_JA]"
DATA "\L[R:@HLP_START_JA]"
DATA ""


@YSC_MANUP_EN
DATA "■ Manipulation (1/5)\n\n"
DATA "In selection menu, at the first time you touch, you place '⇒'. "
DATA "When you touch the place of '⇒' once more, you select it. "
DATA "You can push \N[CROSS] button to place '⇒'. "
DATA "You can select by \N[A] button, if '⇒' was placed. "
DATA "\L[B:@YSC_START_EN]"
DATA "\L[R:@YSC_MANUP2_EN]"
DATA ""

@YSC_MANUP2_EN
DATA "■ Manipulation (2/5)\n\n"
DATA "At the beginning of a game, you select a place "
DATA "by the tiny card of the lower display. "
DATA "Long touch of it can display a selection menu.\n\n"
DATA "\L[B:@YSC_START_EN]"
DATA "\L[L:@YSC_MANUP_EN]"
DATA "\L[R:@YSC_MANUP3_EN]"
DATA ""

@YSC_MANUP3_EN
DATA "■ Manipulation (3/5)\n\n"
DATA "Progress game by touching the talon, or by pushing \N[A] button. "
DATA "('Talon' means a stack of cards to draw.)\n\n"
DATA "Sometimes, you are prompted to choose 'MOVE' or 'STAY'. "
DATA "You can choose it by \N[Y] button or \N[X] button."
DATA "\L[B:@YSC_START_EN]"
DATA "\L[L:@YSC_MANUP2_EN]"
DATA "\L[R:@YSC_MANUP4_EN]"
DATA ""

@YSC_MANUP4_EN
DATA "■ Manipulation (4/5)\n\n"
DATA "In game, you can manupulate 'Soroban' calculator "
DATA "of the lower display by touch.\n\n"
DATA "Touching '↑♠'-likes below 'Soroban' shows the rule.\n\n"
DATA "\L[B:@YSC_START_EN]"
DATA "\L[L:@YSC_MANUP3_EN]"
DATA "\L[R:@YSC_MANUP5_EN]"
DATA ""

@YSC_MANUP5_EN
DATA "■ Manipulation (5/5)\n\n"
DATA "You can cancel animations by touching the talon, "
DATA  "or by pushing \N[A] button.\n\n"
DATA  "START button prompts you choose to go back to the title or not."
DATA "\L[B:@YSC_START_EN]"
DATA "\L[L:@YSC_MANUP4_EN]"
DATA ""


@YSC_MANUP_JA
DATA "■ ソウサ ホウホウ (1/3)\n\n"
DATA "センタク ガメン デハ 1ドメ ノ タッチ デ「⇒」ノ イチ ガ カワリ、"
DATA "「⇒」ガ ツイタ モノ ヲ モウイチド タッチ スルト センタク サレル。"
DATA "\N[CROSS]ボタン デ イチ ヲ カエル コト モ デキル。"
DATA  "「⇒」ガ デテイレバ、\N[A]ボタン デ センタク デキル。"
DATA "\L[B:@YSC_START_JA]"
DATA "\L[R:@YSC_MANUP2_JA]"
DATA ""

@YSC_MANUP2_JA
DATA "■ ソウサ ホウホウ (2/3)\n\n"
DATA "ゲーム ノ ハジマリ デハ、シタ ガメン ノ チイサナ カード デ、"
DATA "イチ ヲ センタク スル。ナガイ タッチ デ センタク ガメン モ デル。\n\n"
DATA "ゲーム チュウ ハ シタ ガメン ノ カード=ヤマ ニ タッチ スルカ、"
DATA "\N[A]ボタン ヲ オシテ ゲーム ヲ ススメル。\n\n"
DATA "トチュウ「ウゴク」カ「トドマル」カ キカレル コトガアル。"
DATA  "ソノ バアイ ハ、タッチ ヲ スルカ、"
DATA  "\N[Y]ボタン カ \N[X] ボタン デ センタク スル。"
DATA "\L[B:@YSC_START_JA]"
DATA "\L[L:@YSC_MANUP_JA]"
DATA "\L[R:@YSC_MANUP3_JA]"
DATA ""

@YSC_MANUP3_JA
DATA "■ ソウサ ホウホウ (3/3)\n\n"
DATA "ゲーム チュウ、ソロバン ハ タッチ デ ソウサ デキル。\n\n"
DATA "ソロバン ノ シタ ノ、「↑♠」 ナド ヲ タッチ スルト、"
DATA "ルール ガ ヒョウジサレル。\n\n"
DATA "アニメーション チュウ ニ、カード=ヤマ ヲ タッチ スルカ、"
DATA "\N[A]ボタン ヲ オスト、アニメーション ハ オワル。\n\n"
DATA "START ボタン ヲ オスト タイトル ガメン ニ モドル カ キカレル。"
DATA "\L[B:@YSC_START_JA]"
DATA "\L[L:@YSC_MANUP2_JA]"
DATA ""

@YSC_ABOUT_EN
DATA "■ About Dist. (1/4)\n\n"
DATA "The distribution of 'Youscout' consists of the 3 files: \n\n"
DATA "●YOUSCOUT (Main),\n"
DATA "●MKJRFTRT (show below),\n"
DATA "●YSCHELP (now, you show).\n\n"
DATA "To install, you must invoke MKJRFTRT only once. "
DATA "It prepares graphic files for YOUSCOUT.\n\n"
DATA "Then, invoke YOUSCOUT."
DATA "\L[B:@YSC_START_EN]"
DATA "\L[R:@YSC_ABOUT2_EN]"
DATA ""

@YSC_ABOUT2_EN
DATA "■ About Dist. (2/4)\n\n"
DATA "The game 'Youscout' was made by JRF "
DATA "after traditional ideas and arguments about "
DATA "Tarot and Yi-King, and some modern card/board-games.\n\n"
DATA "In the same time of making the rules, the web-programed game was made."
DATA "\L[B:@YSC_START_EN]"
DATA "\L[L:@YSC_ABOUT1_EN]"
DATA "\L[R:@YSC_ABOUT3_EN]"
DATA ""

@YSC_ABOUT3_EN
DATA "■ About Dist. (3/4)\n\n"
DATA "Youscout for PTC is a BASIC program for PetitComputer of DSi-ware.\n\n"
DATA "It is also authored by JRF, and is originally distributed by him. "
DATA "He intends this program to be Public-Dmain.\n\n"
DATA "\L[B:@YSC_START_EN]"
DATA "\L[L:@YSC_ABOUT2_EN]"
DATA "\L[R:@YSC_ABOUT4_EN]"
DATA ""

@YSC_ABOUT4_EN
DATA "■ About Dist. (4/4)\n\n"
DATA "You can download the sources or QR-codes from JRF\N[SQ]s web-site:\n\n"
DATA "● http://jrf.cocolog-nifty.com/archive/youscout/ptc/index.html"
DATA "\L[B:@YSC_START_EN]"
DATA "\L[L:@YSC_ABOUT3_EN]"
DATA "\L[R:@YSC_THANKS_EN]"
DATA ""


@YSC_ABOUT_JA
DATA "■ ハイフブツ ニ カンシテ (1/4)\n\n"
DATA "「ヨウスコウ」ノ ハイフブツ ハ 3ツ ノ ファイル カラナル:\n\n"
DATA "●YOUSCOUT (メイン),\n"
DATA "●MKJRFTRT (シタ ニ カク),\n"
DATA "●YSCHELP (イマ ミテル モノ).\n\n"
DATA "インストール ノ タメ、サイショ ニ 1ド ダケ、"
DATA "MKJRFTRT ヲ ジッコウ セネバナラナイ。"
DATA "コレハ YOUSCOUT ヨウ ノ ガゾウ ヲ サクセイ スル。\n\n"
DATA "アト ハ、YOUSCOUT ヲ ジッコウ スルダケ。"
DATA "\L[B:@YSC_START_JA]"
DATA "\L[R:@YSC_ABOUT2_JA]"
DATA ""

@YSC_ABOUT2_JA
DATA "■ ハイフブツ ニ カンシテ (2/4)\n\n"
DATA "「ヨウスコウ」ハ JRF ニ ヨッテ ツクラレタ。"
DATA "タロット ヤ エキキョウ ノ カコ ノ アイデア ト ギロン、"
DATA "マタ サイキン ノ カード/ボード ゲーム ヲ サンコウ ニ ツクラレタ。\n\n"
DATA "ルール ヲ キメル トキ、"
DATA "ドウジ ニ ウェブ=プログラム=ゲーム モ ツクッテイタ。"
DATA "\L[B:@YSC_START_JA]"
DATA "\L[L:@YSC_ABOUT_JA]"
DATA "\L[R:@YSC_ABOUT3_JA]"
DATA ""

@YSC_ABOUT3_JA
DATA "■ ハイフブツ ニ カンシテ (3/4)\n\n"
DATA "「ヨウスコウ PTC」ハ DSiウェア「プチコンmkII」ヨウ ノ "
DATA "BASIC プログラム デアル。\n\n"
DATA "コレ モ JRF ガ シルシ、ハイフ ヲ ハジメタ。"
DATA "JRF ハ コレ ヲ「パブリック=ドメイン」 ニ スル イシ ヲ モツ。\n\n"
DATA "\L[B:@YSC_START_JA]"
DATA "\L[L:@YSC_ABOUT2_JA]"
DATA "\L[R:@YSC_ABOUT4_JA]"
DATA ""

@YSC_ABOUT4_JA
DATA "■ ハイフブツ ニ カンシテ (4/4)\n\n"
DATA "「ヨウスコウ PTC」ノ ソース ファイル ヤ QRコード ハ、"
DATA "ツギ ノ JRF ノ ウェブ=サイト カラ ダウンロード デキルハズ:\n\n"
DATA "● http://jrf.cocolog-nifty.com/archive/youscout/ptc/index.html"
DATA "\L[B:@YSC_START_JA]"
DATA "\L[L:@YSC_ABOUT3_JA]"
DATA "\L[R:@YSC_THANKS_JA]"
DATA ""


@YSC_RMAIN_EN
DATA "■ Rule\n\n"
DATA "●\L[@YSC_RABST_EN]Flow of the Game.\n\n"
DATA "●\L[@YSC_RMKBD_EN]Make a Board.\n\n"
DATA "●\L[@YSC_RSUIT_EN]Read Rules.\n\n"
DATA "●\L[@YSC_RWORL_EN]Win or Lose.\n\n"
DATA "●\L[@YSC_RSWAP_EN]Swap of (8),(11)\n\n"
DATA "●\L[@YSC_RMJTB_EN]Scores of Major Arcana.\n\n"
DATA "\L[B:@YSC_START_EN]"
DATA "\L[R:@YSC_RABST_EN]"
DATA ""

@YSC_RMAIN_JA
DATA "■ ルール\n\n"
DATA "●\L[@YSC_RABST_JA]ゲーム ノ ナガレ。\n\n"
DATA "●\L[@YSC_RMKBD_JA]バン ヲ ツクル。\n\n"
DATA "●\L[@YSC_RSUIT_JA]ルール ノ ヨミカタ。\n\n"
DATA "●\L[@YSC_RWORL_JA]ゲーム ノ カチ マケ。\n\n"
DATA "●\L[@YSC_RSWAP_JA](8)ト(11)ノ イレカエ。\n\n"
DATA "●\L[@YSC_RMJTB_JA]ダイ=アルカナ スウヒョウ。\n\n"
DATA "\L[B:@YSC_START_JA]"
DATA "\L[R:@YSC_RABST_JA]"
DATA ""


@YSC_RABST_EN
DATA "■ Flow of Game (1/3)\n\n"
DATA "Shuffle the 22(-2) major arcana of Tarot. "
DATA "Draw 6 cards and make a 'board' by them.\n\n"
DATA "Place the token there."
DATA "\L[B:@YSC_RMAIN_EN]"
DATA "\L[L:@YSC_RMAIN_EN]"
DATA "\L[R:@YSC_RABST2_EN]"
DATA ""

@YSC_RABST2_EN
DATA "■ Flow of Game (2/3)\n\n"
DATA "Shuffle the 56 minor arcana inserted with 1 major arcanum to make a talon.\n\n"
DATA "Draw a card from the talon. "
DATA "Move the token following to the rules "
DATA "by the suit (♠♦♥♣) of the drawn card and the token place (↑↓).\n\n"
DATA "\L[B:@YSC_RMAIN_EN]"
DATA "\L[L:@YSC_RABST_EN]"
DATA "\L[R:@YSC_RABST3_EN]"
DATA ""

@YSC_RABST3_EN
DATA "■ Flow of Game (3/3)\n\n"
DATA "The game is finished when the inserted major arcana appears the pre-defined times.\n\n"
DATA "The current token place decides you win or you lose."
DATA "\L[B:@YSC_RMAIN_EN]"
DATA "\L[L:@YSC_RABST2_EN]"
DATA "\L[R:@YSC_RMKBD_EN]"
DATA ""


@YSC_RMKBD_EN
DATA "■ Make a Board (1/6)\n\n"
DATA "Sort out (0) and (13) of 22 major arcana. "
DATA "Shuffle the rest and put drawn 6 of them to make a 'board' as follows:\n\n"
DATA "    [6]   [4]  \n"
DATA "[0]    [5]     \n"
DATA "       [2]     \n"
DATA "  [3]       [1]\n\n"
DATA "On [0], put (0) and (13)."
DATA "\L[B:@YSC_RMAIN_EN]"
DATA "\L[L:@YSC_RABST3_EN]"
DATA "\L[R:@YSC_RMKBD2_EN]"
DATA ""

@YSC_RMKBD2_EN
DATA "■ Make a Board (2/6)\n\n"
DATA "We call them as a 'hexagram'.\n\n"
DATA "In a hexagram, we call [1]  as the 'base place', "
DATA "[6] as the 'senior place', "
DATA "and others as 2nd place, 3rd place, 4th place and 5th place.\n\n"
DATA "We call [1][2][3] as the 'lower trigram' and "
DATA "[4][5][6] as the 'upper trigram'.\n\n"
DATA "\L[B:@YSC_RMAIN_EN]"
DATA "\L[L:@YSC_RMKBD_EN]"
DATA "\L[R:@YSC_RMKBD3_EN]"
DATA ""

@YSC_RMKBD3_EN
DATA "■ Make a Board (3/6)\n\n"
DATA "After the history of Tarot, "
DATA "you must swap (8) and (11) if one of which exists on the board."
DATA "If one of which does\N[SQ]t exist on the board, "
DATA "you must swap them by retrieving the other from the stack.\n\n"
DATA "There are some manners of swap, "
DATA "but at first you should always swap them."
DATA "\L[B:@YSC_RMAIN_EN]"
DATA "\L[L:@YSC_RMKBD2_EN]"
DATA "\L[R:@YSC_RMKBD4_EN]"
DATA ""

@YSC_RMKBD4_EN
DATA "■ Make a Board (4/6)\n\n"
DATA "You place the token on one of the places [1]-[6] as you like."
DATA "That is the start place of the token.\n\n"
DATA "●When you placed it on [1][2][3], then it is (13),\n\n"
DATA "●When you placed it on [4][5][6], then it is (0),\n\n"
DATA "insert it into the stack of 56 minor arcana and shuffle them to make a talon.\n\n"
DATA "(0) or (13) rest on the board is called as the purpose card."
DATA "\L[B:@YSC_RMAIN_EN]"
DATA "\L[L:@YSC_RMKBD3_EN]"
DATA "\L[R:@YSC_RMKBD5_EN]"
DATA ""

@YSC_RMKBD5_EN
DATA "■ Make a Board (5/6)\n\n"
DATA "Game is started.\n\n"
DATA "Draw a card. Read the rule by the suit(♠♦♥♣) of the drawn card, "
DATA "by the place(↑↓) of the token and "
DATA "by the score table of the major arcana. "
DATA "Following it, you are directed to move the token or stay.\n\n"
DATA "The drawn (0) or (13) is called as the terminal card.\n\n"
DATA "\L[B:@YSC_RMAIN_EN]"
DATA "\L[L:@YSC_RMKBD4_EN]"
DATA "\L[R:@YSC_RMKBD6_EN]"
DATA ""

@YSC_RMKBD6_EN
DATA "■ Make a Board (6/6)\n\n"
DATA "When the terminal card appears first time or 2nd time, "
DATA "gather the terminal, the discarded and the rest of the talon "
DATA "and shuffle them to make a new talon.\n\n"
DATA "When the terminal card appears 3rd time, the game reaches finish. "
DATA "Look win or lose.\n\n"
DATA "(You can pre-define the number of times other than 3.)"
DATA "\L[B:@YSC_RMAIN_EN]"
DATA "\L[L:@YSC_RMKBD5_EN]"
DATA "\L[R:@YSC_RSUIT_EN]"
DATA ""

@YSC_RSUIT_EN
DATA "■ Read the Rules (1/13)\n\n"
DATA "Generally, correspondence of the suit of the minor arcana of Tarot "
DATA "and that of Trump is not definite.\n\n"
DATA "However, in this game, we treat them as corresponded by:\n\n"
DATA "♠:Swords,\n"
DATA "♦:Coins,\n"
DATA "♥:Cups,\n"
DATA "♣:Wands.\n\n"
DATA "\L[B:@YSC_RMAIN_EN]"
DATA "\L[L:@YSC_RMKBD6_EN]"
DATA "\L[R:@YSC_RSUIT2_EN]"
DATA ""

@YSC_RSUIT2_EN
DATA "■ Read the Rules (2/13)\n\n"
DATA "You put the cards as follows.:\n\n"
DATA "       [8]     \n"
DATA "    [6]   [4]  \n"
DATA "[0]    [5]     \n"
DATA "       [2]     \n"
DATA "  [3]       [1]\n"
DATA "       [7]     \n\n"
DATA "You put minor arcana beside the major arcana of [1]-[6] "
DATA "or on the spaces of [7] or [8]."
DATA "\L[B:@YSC_RMAIN_EN]"
DATA "\L[L:@YSC_RSUIT_EN]"
DATA "\L[R:@YSC_RSUIT3_EN]"
DATA ""

@YSC_RSUIT3_EN
DATA "■ Read the Rules (3/13)\n\n"
DATA "Coins on [1][2][3][7], Cups on [4][5][6] and Swords on [8].\n\n"
DATA "In rules, we write [7] as '↓♦' and [8] as '↑♠'.\n\n"
DATA "'$' means the drawn card. "
DATA "For example, '$♥' means the drawn card of cups."
DATA "\L[B:@YSC_RMAIN_EN]"
DATA "\L[L:@YSC_RSUIT2_EN]"
DATA "\L[R:@YSC_RSUIT4_EN]"
DATA ""

@YSC_RSUIT4_EN
DATA "■ Read the Rules (4/13)\n\n"
DATA "Take '♥' as example. It means the whole cups of :\n\n"
DATA "the current place by '@♥',\n\n"
DATA "the right place by '→♥',\n\n"
DATA "the left place by '←♥',\n\n"
DATA "the upper place by '↑♥',\n\n"
DATA "the lower place by '↓♥'.\n\n"
DATA "\L[B:@YSC_RMAIN_EN]"
DATA "\L[L:@YSC_RSUIT3_EN]"
DATA "\L[R:@YSC_RSUIT5_EN]"
DATA ""

@YSC_RSUIT5_EN
DATA "■ Read the Rules (5/13)\n\n"
DATA "The ← of [3] is [4]. The → of [4] is [3].\n\n"
DATA "The ← of [6] is [1]. The → of [1] is [6].\n\n"
DATA "The ↑ of [3][2][1] are [6][5][4] respectively.\n\n"
DATA "The ↓ of [6][5][4] are [3][2][1] respectively.\n\n"
DATA "At [6], '←♦' is '↓♦' i.e. [7].\n\n"
DATA "\L[B:@YSC_RMAIN_EN]"
DATA "\L[L:@YSC_RSUIT4_EN]"
DATA "\L[R:@YSC_RSUIT6_EN]"
DATA ""

@YSC_RSUIT6_EN
DATA "■ Read the Rules (6/13)\n\n"
DATA "Rules are Compare-Rules and Change-Rules.\n\n"
DATA "A Compare-Rule forms like '○ > □'."
DATA "Comparing 'score's of ○ and □ directs to move the token if greater.\n\n"
DATA "(There are rules which direct only to stay.)\n\n"
DATA "(There is a rule that you can choose stay even after directed to move.)\n\n"
DATA "\L[B:@YSC_RMAIN_EN]"
DATA "\L[L:@YSC_RSUIT5_EN]"
DATA "\L[R:@YSC_RSUIT7_EN]"
DATA ""

@YSC_RSUIT7_EN
DATA "■ Read the Rules (7/13)\n\n"
DATA "A Change-Rule varies by move or stay.\n\n"
DATA "There must be distincted rules for stay "
DATA "if stay can be chosen after directed to move.\n\n"
DATA "A Change-Rule forms like a sequence of '○⇒□'s.\n"
DATA "If □  is '×' then you discard ○. Otherwise, change the cards.\n\n"
DATA "\L[B:@YSC_RMAIN_EN]"
DATA "\L[L:@YSC_RSUIT6_EN]"
DATA "\L[R:@YSC_RSUIT8_EN]"
DATA ""

@YSC_RSUIT8_EN
DATA "■ Read the Rules (8/13)\n\n"
DATA "The 'score' of a card is the number of the card.\n\n"
DATA "That of '♥2'is 2. That of '♥A' is 1.\n\n"
DATA "Those of '♥J','♥C','♥Q','♥K' are "
DATA "11,12,13,14 respectively.\n\n"
DATA "(In a manner, The score of '♥J','♥C','♥Q','♥K' is all 10.)"
DATA "\L[B:@YSC_RMAIN_EN]"
DATA "\L[L:@YSC_RSUIT7_EN]"
DATA "\L[R:@YSC_RSUIT9_EN]"
DATA ""

@YSC_RSUIT9_EN
DATA "■ Read the Rules (9/13)\n\n"
DATA "'Max' means maximum. Max(@♥) is "
DATA "(one of) the maximum scored card of the cups of the current place.\n\n"
DATA "'Sum' means summation. Sum(@♦) is "
DATA "the summation of the scores of the coins of the current place.\n\n"
DATA "\L[B:@YSC_RMAIN_EN]"
DATA "\L[L:@YSC_RSUIT8_EN]"
DATA "\L[R:@YSC_RSUITA_EN]"
DATA ""

@YSC_RSUITA_EN
DATA "■ Read the Rules (10/13)\n\n"
DATA "The score of Max or Sum is calculated as 0 with no corresponded card.\n\n"
DATA "However, with the necessary mark '!', you must stay the token if none.\n\n"
DATA "For example, with no corresponded card, Max(@♦) is 0 but "
DATA "Max(↓♥!) interrupts your calculation and you must stay the token.\n\n"
DATA "\L[B:@YSC_RMAIN_EN]"
DATA "\L[L:@YSC_RSUIT9_EN]"
DATA "\L[R:@YSC_RSUITB_EN]"
DATA ""

@YSC_RSUITB_EN
DATA "■ Read the Rules (11/13)\n\n"
DATA "Suitable means 'at least one suitable card'. Suitable(@♥!) is necessary "
DATA "one of the cups of the current place which can make the Compare-Rule "
DATA "greater.\n\n"
DATA "Min(Suitable(@♥)) is the minimum scored card of such cups.\n\n"
DATA "If it appears in the right of the Compare-Rule, "
DATA "What you must check is only the minimum scored card of @♥."
DATA "\L[B:@YSC_RMAIN_EN]"
DATA "\L[L:@YSC_RSUITA_EN]"
DATA "\L[R:@YSC_RSUITC_EN]"
DATA ""

@YSC_RSUITC_EN
DATA "■ Read the Rules (12/13)\n\n"
DATA "The 'score' of major arcana is written as '(→A)[/♠]' for example.\n\n"
DATA "With it, you look the 'score table of major arcana' "
DATA "about the major arcanum of the right place.\n\n"
DATA "In the table, when you read '♠○/□', "
DATA "because of '[/♠]', □ must be the score.\n\n"
DATA "\L[B:@YSC_RMAIN_EN]"
DATA "\L[L:@YSC_RSUITB_EN]"
DATA "\L[R:@YSC_RSUITD_EN]"
DATA ""

@YSC_RSUITD_EN
DATA "■ Read the Rules (13/13)\n\n"
DATA "However, when the major arcanum is reversal, "
DATA "you must read the table reversally right to left.\n\n"
DATA "With the reversal major arcanum, "
DATA "when you read'♠○/□' in the table, "
DATA "because of '[/♠]', ○ must be the score.\n\n"
DATA "There are manners to multiply the score by 2 or 3 to read."
DATA "Usually, multiply it by 2."
DATA "\L[B:@YSC_RMAIN_EN]"
DATA "\L[L:@YSC_RSUITC_EN]"
DATA "\L[R:@YSC_RWORL_EN]"
DATA ""

@YSC_RWORL_EN
DATA "■ Win or Lose\n\n"
DATA "If you started in the upper trigram [6][5][4] and namely "
DATA "the terminal card is (0), then "
DATA "you win with the token placed on [6] or [5] at finish.\n\n"
DATA "If you started in the lower trigram [3][2][1] and namely "
DATA "the terminal card is (13), then "
DATA "you win with the token placed on [2] or [5] at finish.\n\n"
DATA "Otherwise, you lose.\n\n"
DATA "\L[B:@YSC_RMAIN_EN]"
DATA "\L[L:@YSC_RSUITC_EN]"
DATA ""


@YSC_RABST_JA
DATA "■ ゲーム ノ ナガレ (1/3)\n\n"
DATA "タロット カード ノ ダイ=アルカナ 22(-2)マイ ヲ シャッフル シテ、"
DATA "6マイ カード ヲ ヒキ、「バン」ヲ ツクル。\n\n"
DATA "ソコ ニ トークン ヲ オク。"
DATA "(「トークン」トハ ゲーム ノ コマ ノ コト。)\n\n"
DATA "\L[B:@YSC_RMAIN_JA]"
DATA "\L[L:@YSC_RMAIN_JA]"
DATA "\L[R:@YSC_RABST2_JA]"
DATA ""

@YSC_RABST2_JA
DATA "■ ゲーム ノ ナガレ (2/3)\n\n"
DATA "ショウ＝アルカナ 56マイ ニ ダイ=アルカナ 1マイ ヲ クワエ、シャッフル。"
DATA "ソレヲ ヒキ、デタ スート(♠♦♥♣) ト、トークン ノ イチ(↑↓) ニ "
DATA "オウジタ ルール ニ シタガッテ、トークン ヲ ウゴカス。\n\n"
DATA "\L[B:@YSC_RMAIN_JA]"
DATA "\L[L:@YSC_RABST_JA]"
DATA "\L[R:@YSC_RABST3_JA]"
DATA ""

@YSC_RABST3_JA
DATA "■ ゲーム ノ ナガレ (3/3)\n\n"
DATA "ダイ=アルカナ ヲ キメタ カイスウ ヒイタ トキ、ゲーム シュウリョウ。\n\n"
DATA "トークン ノ アル イチ デ カチ マケ ガ キマル。"
DATA "\L[B:@YSC_RMAIN_JA]"
DATA "\L[L:@YSC_RABST2_JA]"
DATA "\L[R:@YSC_RMKBD_JA]"
DATA ""


@YSC_RMKBD_JA
DATA "■ バン ヲ ツクル (1/6)\n\n"
DATA "ダイ=アルカナ 22マイ カラ(0)ト(13)ノ カード ヲ トリノゾク。"
DATA "ノコリ 20マイ ヲ シャッフル シ、ツギ ノ ヨウ ニ ナラベ、"
DATA "「バン」ト スル。\n\n"
DATA "    [6]   [4]  \n"
DATA "[0]    [5]     \n"
DATA "       [2]     \n"
DATA "  [3]       [1]\n\n"
DATA "ナオ、[0]ニハ(0)ト(13)ノ カード ヲ オイテオク。"
DATA "\L[B:@YSC_RMAIN_JA]"
DATA "\L[L:@YSC_RABST3_JA]"
DATA "\L[R:@YSC_RMKBD2_JA]"
DATA ""

@YSC_RMKBD2_JA
DATA "■ バン ヲ ツクル (2/6)\n\n"
DATA "サキ ノ[1]ヲ「ショコウ」、[6]ヲ「ジョウコウ」、"
DATA "ソレイガイ ハ 2コウ、3コウ、4コウ、5コウ ト ヨブ。\n\n"
DATA "[1][2][3]ヲ「シモカ」、[4][5][6]ヲ「ジョウカ」ト ヨブ。\n\n"
DATA "(ナオ「シモカ」ハ ユトウ=ヨミ ダガ、コノ ゲーム デハ、"
DATA "エキ=キョウ ノ ホカ ノ ヨウゴ ト クベツ スルタメ、コウ ヨブ。)"
DATA "\L[B:@YSC_RMAIN_JA]"
DATA "\L[L:@YSC_RMKBD_JA]"
DATA "\L[R:@YSC_RMKBD3_JA]"
DATA ""

@YSC_RMKBD3_JA
DATA "■ バン ヲ ツクル (3/6)\n\n"
DATA "タロット ノ レキシ ヲ キネン シ、"
DATA "バン ニ(8)カ(11)ノ カード ガ デテイレバ イレカエル。"
DATA "イッポウ ガ デテイナケレバ、ヤマ カラ トッテ デモ イレカエル。\n\n"
DATA "イレカエ ノ リュウギ ハ イクツカ アルガ、"
DATA "マズ ハ カナラズ イレカエル ヨウ ニ スレバ イイ。"
DATA "\L[B:@YSC_RMAIN_JA]"
DATA "\L[L:@YSC_RMKBD2_JA]"
DATA "\L[R:@YSC_RMKBD4_JA]"
DATA ""

@YSC_RMKBD4_JA
DATA "■ バン ヲ ツクル (4/6)\n\n"
DATA "[1]カラ[6]ノ スキナ トコロ ニ トークン ヲ オク。"
DATA "ココガ ゲーム カイシ イチ トナル。\n\n"
DATA "●[1][2][3]ニ トークン ヲ オイタラ(13)ノ カード ヲ、\n\n"
DATA "●[4][5][6]ニ トークン ヲ オイタラ(0)ノ カード ヲ、\n\n"
DATA "ショウ=アルカナ ノ カード ニ マゼ、シャッフル。\n\n"
DATA "バン ニ ノコッタ(0)カ(13)ヲ モクテキ カード ト ヨブ。"
DATA "\L[B:@YSC_RMAIN_JA]"
DATA "\L[L:@YSC_RMKBD3_JA]"
DATA "\L[R:@YSC_RMKBD5_JA]"
DATA ""

@YSC_RMKBD5_JA
DATA "■ バン ヲ ツクル (5/6)\n\n"
DATA "ゲーム カイシ デアル。\n\n"
DATA "カード ヲ イチ マイ ヒキ、デタ スート(♠♦♥♣) ト、"
DATA "トークン ノ イチ(↑↓) ニ オウジタ ルール ト、"
DATA "ダイ=アルカナ ノ スウヒョウ ヲ ヨミ、"
DATA "ソレニ シタガウ。\n\n"
DATA "ソノ カード ガ(0)カ(13)ノトキ、ソレヲ シュウリョウ カード ト ヨブ。\n\n"
DATA "\L[B:@YSC_RMAIN_JA]"
DATA "\L[L:@YSC_RMKBD4_JA]"
DATA "\L[R:@YSC_RMKBD6_JA]"
DATA ""

@YSC_RMKBD6_JA
DATA "■ バン ヲ ツクル (6/6)\n\n"
DATA "シュウリョウ カード ガ、1ドメ、2ドメ ノ バアイ ハ、"
DATA "ソレ ヲ カード=ヤマ ニ モドシ、ステタ カード ト トモ ニ シャッフル。\n\n"
DATA "シュウリョウ カード ガ 3ドメ ニ デタラ、ゲーム シュウリョウ デ、"
DATA "カチ マケ ヲ シラベル。\n\n"
DATA "ナオ、サイショ ニ キメテ オケバ 3ド デナク、1ド デモ、ナンド デモヨイ。"
DATA "\L[B:@YSC_RMAIN_JA]"
DATA "\L[L:@YSC_RMKBD5_JA]"
DATA "\L[R:@YSC_RSUIT_JA]"
DATA ""

@YSC_RSUIT_JA
DATA "■ ルール ノ ヨミカタ (1/13)\n\n"
DATA "イッパン ニ タロット ノ ショウ=アルカナ ト "
DATA "トランプ ノ スート ノ タイオウ ハ メイカク デハ ナイ。\n\n"
DATA "シカシ、コノ ゲーム デハ ツギ ノ ヨウ ニ タイオウ サセル。:\n\n"
DATA "♠:ソード (ツルギ)\n"
DATA "♦:コイン (カネ)\n"
DATA "♥:カップ (ハイ)\n"
DATA "♣:ワンド (シャクジョウ)\n\n"
DATA "カッコ ナイ ハ、コノ ゲーム ナイ ノ ヨビカタ。"
DATA "ニホンゴ ノ ダイ=アルカナ ノ ヨビカタ モ ツウジョウ ト コトナル。"
DATA "\L[B:@YSC_RMAIN_JA]"
DATA "\L[L:@YSC_RMKBD6_JA]"
DATA "\L[R:@YSC_RSUIT2_JA]"
DATA ""

@YSC_RSUIT2_JA
DATA "■ ルール ノ ヨミカタ (2/13)\n\n"
DATA "カード ハ ツギ ノ ヨウニ オク。\n\n"
DATA "       [8]     \n"
DATA "    [6]   [4]  \n"
DATA "[0]    [5]     \n"
DATA "       [2]     \n"
DATA "  [3]       [1]\n"
DATA "       [7]     \n\n"
DATA "[1]-[6]ノ ダイ=アルカナ ノ ワキ、マタハ、[7][8]ノ スペース ニ "
DATA "ショウ=アルカナ ヲ オイテイク。\n\n"
DATA "\L[B:@YSC_RMAIN_JA]"
DATA "\L[L:@YSC_RSUIT_JA]"
DATA "\L[R:@YSC_RSUIT3_JA]"
DATA ""

@YSC_RSUIT3_JA
DATA "■ ルール ノ ヨミカタ (3/13)\n\n"
DATA "[1][2][3][7]ニハ コイン、[4][5][6]ニハ カップ、[8]ニハ、ソード。\n\n"
DATA "ルール デ [7]ハ「↓♦」ト シルス。[8]ハ「↑♠」ト シルス。\n\n"
DATA "「$」ハ ヒイタ カード ヲ シメス。"
DATA "タトエバ、「$♥」ハ ヒイタ カップ ノ カード ヲ シメス。"
DATA "\L[B:@YSC_RMAIN_JA]"
DATA "\L[L:@YSC_RSUIT2_JA]"
DATA "\L[R:@YSC_RSUIT4_JA]"
DATA ""

@YSC_RSUIT4_JA
DATA "■ ルール ノ ヨミカタ (4/13)\n\n"
DATA "カップ「♥」ヲ レイ ニ スル ト、トークン ノ アル コウ ノ:\n\n"
DATA "「@♥」ハ、ゲンザイ ノ コウ、\n\n"
DATA "「→♥」ハ、ミギ ノ コウ、\n\n"
DATA "「←♥」ハ、ヒダリ ノ コウ、\n\n"
DATA "「↑♥」ハ、ウエ ノ コウ、\n\n"
DATA "「↓♥」ハ、シタ ノ コウ、\n\n"
DATA "ソレゾレ ノ スベテ ノ カップ ノ カード ヲ シメス。\n\n"
DATA "\L[B:@YSC_RMAIN_JA]"
DATA "\L[L:@YSC_RSUIT3_JA]"
DATA "\L[R:@YSC_RSUIT5_JA]"
DATA ""

@YSC_RSUIT5_JA
DATA "■ ルール ノ ヨミカタ (5/13)\n\n"
DATA "[3] ノ ← ハ [4]、[4] ノ → ハ [3]。\n\n"
DATA "[6] ノ ← ハ [1]、[1] ノ → ハ [6]。\n\n"
DATA "[3][2][1] ノ ↑ ハ ソレゾレ [6][5][4]。\n\n"
DATA "[6][5][4] ノ ↓ ハ ソレゾレ [3][2][1]。\n\n"
DATA "[6] デ「←♦」ハ、「↓♦」スナワチ[7]。\n\n"
DATA "\L[B:@YSC_RMAIN_JA]"
DATA "\L[L:@YSC_RSUIT4_JA]"
DATA "\L[R:@YSC_RSUIT6_JA]"
DATA ""

@YSC_RSUIT6_JA
DATA "■ ルール ノ ヨミカタ (6/13)\n\n"
DATA "ルール ニハ ヒカク=ルール ト ヘンカ=ルール ガ アル。\n\n"
DATA "ヒカク=ルール ハ「○ > □」ノ カタチ ヲ シテイル。"
DATA "○ ト □ ノ「スコア」ヲ ヒカク シ、オオキケレバ ウゴク。\n\n"
DATA "ナオ、ルール ノ ナカ ニハ トドマル シカナイ モノ モ アル。\n\n"
DATA "マタ、ウゴク ト キマッテモ、トドマル コト ヲ エラベル モノ ガ アル。\n\n"
DATA "\L[B:@YSC_RMAIN_JA]"
DATA "\L[L:@YSC_RSUIT5_JA]"
DATA "\L[R:@YSC_RSUIT7_JA]"
DATA ""

@YSC_RSUIT7_JA
DATA "■ ルール ノ ヨミカタ (7/13)\n\n"
DATA "ヘンカ=ルール ハ、ウゴク カ、トドマル カ デ チガウ。\n\n"
DATA "トドマル トキ モ ウゴク ト キマッテカラ エラベル モノ ニハ、"
DATA "ソノタメ ノ ヘンカ=ルール ガ ベツ ニ アル。\n\n"
DATA "ヘンカ=ルール ハ イクツカ ノ「○⇒□」ノ カタチ ヲ シテイル。\n\n"
DATA "□ ガ 「×」ナラ カード ヲ ステバショ ニ ステル。"
DATA "ソレ イガイ ハ カード ヲ イドウスル。\n\n"
DATA "\L[B:@YSC_RMAIN_JA]"
DATA "\L[L:@YSC_RSUIT6_JA]"
DATA "\L[R:@YSC_RSUIT8_JA]"
DATA ""

@YSC_RSUIT8_JA
DATA "■ ルール ノ ヨミカタ (8/13)\n\n"
DATA "カード ノ「スコア」ハ、カード ニ カカレタ スウチ。\n\n"
DATA "「♥2」デアレバ「2」。「♥A」ハ「1」。\n\n"
DATA "「♥J」「♥C」「♥Q」「♥K」デアレバ、"
DATA "ソレゾレ、「11」「12」「13」「14」トスル。\n\n"
DATA "(「♥J」「♥C」「♥Q」「♥K」ノ スコア ヲ "
DATA "スベテ「10」トスル リュウギ モ アル。)"
DATA "\L[B:@YSC_RMAIN_JA]"
DATA "\L[L:@YSC_RSUIT7_JA]"
DATA "\L[R:@YSC_RSUIT9_JA]"
DATA ""

@YSC_RSUIT9_JA
DATA "■ ルール ノ ヨミカタ (9/13)\n\n"
DATA "Max ハ サイダイ。Max(@♥) ハ、"
DATA "ゲンザイ コウ ノ カップ ノ カード ノ スコア ガ "
DATA "サイダイ ノ モノ(ノ ドレカ ヒトツ)。\n\n"
DATA "Sum ハ ゴウケイ。Sum(@♦) ハ、"
DATA "ゲンザイ コウ ノ コイン ノ スコア ヲ "
DATA "スベテ タシタ モノ。\n\n"
DATA "\L[B:@YSC_RMAIN_JA]"
DATA "\L[L:@YSC_RSUIT8_JA]"
DATA "\L[R:@YSC_RSUITA_JA]"
DATA ""

@YSC_RSUITA_JA
DATA "■ ルール ノ ヨミカタ (10/13)\n\n"
DATA "カード ガ ナイ バアイ ノ Max ヤ Sum ノ スコア ハ、"
DATA " 0 ト ケイサン スル。\n\n"
DATA "タダシ、ヒツヨウ マーク 「!」ガ ツイテイル モノ ハ、"
DATA "ソノ カード ガ ナイ バアイ ハ、トドマル シカナイ。\n\n"
DATA "タトエバ、カード ガ ナケレバ、Max(@♦) ハ 0 トスルガ、"
DATA "Max(↓♥!) ハ、ソコデ ケイサン ヲ ヤメ、トドマル シカナイ。\n\n"
DATA "\L[B:@YSC_RMAIN_JA]"
DATA "\L[L:@YSC_RSUIT9_JA]"
DATA "\L[R:@YSC_RSUITB_JA]"
DATA ""

@YSC_RSUITB_JA
DATA "■ ルール ノ ヨミカタ (11/13)\n\n"
DATA "Suitable ハ「ドレカ ヒトツ デモ テキトウナ」。Suitable(@♥!) ハ、"
DATA "ゲンザイ コウ ノ カップ ノ ウチ ノ ドレカ ヒトツ デ、ソレ デ "
DATA "ヒカク=ルール ヲ オオキイ ト ハンダン デキル モノ。\n\n"
DATA "Min(Suitable(@♥)) ハ ソウ ハンダン デキル モノ ノ ナカ デ、"
DATA "サイショウ ノ モノ。\n\n"
DATA "コレ ガ ヒカク=ルール ノ ミギ ガワ ニ アルナラ、"
DATA "@♥ ノ サイショウ スコア ノ カード ニ カンシ カクニン スルダケデヨイ。"
DATA "\L[B:@YSC_RMAIN_JA]"
DATA "\L[L:@YSC_RSUITA_JA]"
DATA "\L[R:@YSC_RSUITC_JA]"
DATA ""

@YSC_RSUITC_JA
DATA "■ ルール ノ ヨミカタ (12/13)\n\n"
DATA "ダイ=アルカナ ノ「スコア」ハ タトエバ「(→A)[/♠]」ト カカレル。\n\n"
DATA "コノ トキ ミギ ノ コウ ノ ダイ=アルカナ ニ カンシ、"
DATA "「ダイ=アルカナ スウヒョウ」ヲ ミル。\n\n"
DATA "スウヒョウ ニ「♠○/□」ト アレバ、"
DATA "「[/♠]」ナノデ、□ ノ スウチ ガ スコア トナル。\n\n"
DATA "\L[B:@YSC_RMAIN_JA]"
DATA "\L[L:@YSC_RSUITB_JA]"
DATA "\L[R:@YSC_RSUITD_JA]"
DATA ""

@YSC_RSUITD_JA
DATA "■ ルール ノ ヨミカタ (13/13)\n\n"
DATA "タダシ ダイ=アルカナ ガ ギャク=イチ デ アレバ、"
DATA "スウヒョウ ノ サユウ ヲ ギャク ニ ヨム。\n\n"
DATA "ギャク=イチ デ スウヒョウ ニ「♠○/□」ト アレバ、"
DATA "「[/♠]」ナノデ、○ ノ スウチ ガ スコア トナル。\n\n"
DATA "マタ、ダイ=アルカナ ノ スウヒョウ ヲ ヨム トキ、"
DATA "ソレ ヲ 2バイ ヤ 3バイ ニスル リュウギ ガ アル。"
DATA "フツウ ハ 2バイ ニ スル。"
DATA "\L[B:@YSC_RMAIN_JA]"
DATA "\L[L:@YSC_RSUITC_JA]"
DATA "\L[R:@YSC_RWORL_JA]"
DATA ""

@YSC_RWORL_JA
DATA "■ カチ マケ\n\n"
DATA "ジョウカ[6][5][4]カラ ハジメタ バアイ、"
DATA "シュウリョウ カード ハ(0)、"
DATA "シュウリョウ ジ ニ[6]カ[5]ニ アレバ カチ。\n\n"
DATA "シモカ[3][2][1]カラ ハジメタ バアイ、"
DATA "シュウリョウ カード ハ(13)、"
DATA "シュウリョウ ジ ニ[2]カ[5]ニ アレバ カチ。\n\n"
DATA "ソレイガイ ナラ、マケ。\n\n"
DATA "\L[B:@YSC_RMAIN_JA]"
DATA "\L[L:@YSC_RSUITC_JA]"
DATA ""


@YSC_RSWAP_EN
DATA "■ Swap of 8 and 11\n\n"
DATA "When making a board, you must swap (8) and (11) by one of manners."
DATA "There are three manners.:\n\n"
DATA "●\L[@YSC_SWMEM_EN]the Memorial Method,\n\n"
DATA "●\L[@YSC_SWEXP_EN]the Expansive Method,\n\n"
DATA "●\L[@YSC_SWSOL_EN]the Solid Method.\n\n"
DATA "\L[B:@YSC_RMAIN_EN]"
DATA "\L[R:@YSC_SWMEM_EN]"
DATA ""

@YSC_SWMEM_EN
DATA "■ Memorial Method\n\n"
DATA "Simply, you must swap (8) or (11) anyway "
DATA "if one of which exists on the board.\n\n"
DATA "If (8) is reversal in one place, you place there (11) reversally.\n\n"
DATA "If (11) is reversal in one place, you place there (8) reversally.\n\n"
DATA "The point to preserve upright or reversal is the same in the other manners."
DATA "\L[B:@YSC_RSWAP_EN]"
DATA "\L[L:@YSC_RSWAP_EN]"
DATA "\L[R:@YSC_SWEXP_EN]"
DATA ""

@YSC_SWEXP_EN
DATA "■ Expansive Method\n\n"
DATA "When (8) and (11) appear simultaneously, swap them anyway.\n\n"
DATA "Otherwise:\n\n"
DATA "When the number of odd numbers of cards is greater than evens\N[SQ], "
DATA "swap to be more greater."
DATA "When it is less than evens\N[SQ], swap to be more less.\n\n"
DATA "When odds\N[SQ] and evens\N[SQ] are 3, swap only if (8) or (11) is upright."
DATA "\L[B:@YSC_RSWAP_EN]"
DATA "\L[L:@YSC_SWMEM_EN]"
DATA "\L[R:@YSC_SWSOL_EN]"
DATA ""

@YSC_SWSOL_EN
DATA "■ Solid Method (1/3)\n\n"
DATA "When the number of odd numbers of cards is 0,1,5,6, don\N[SQ]t swap. "
DATA "When it is 2,3,4, swap (8) and (11) if one of which exists.\n\n"
DATA "Then, after swap if you must swap, "
DATA "when odds\N[SQ] and evens\N[SQ] are 3, "
DATA "you must look spins (i.e. cards are upright or reveasal).\n\n"
DATA "\L[B:@YSC_RSWAP_EN]"
DATA "\L[L:@YSC_SWEXP_EN]"
DATA "\L[R:@YSC_SWSOL2_EN]"
DATA ""

@YSC_SWSOL2_EN
DATA "■ Solid Method (2/3)\n\n"
DATA "When all are upright, it is called as 'Force Whirl'.\n\n"
DATA "When all are reversal, it is called as 'Field Whirl'.\n\n"
DATA "When odds\N[SQ] are upright and evens\N[SQ] are reversal, "
DATA "it is called as 'Force Eclipse'. \n\n"
DATA "When odds\N[SQ] are reversal and evens\N[SQ] are upright, "
DATA "it is called as 'Field Eclipse'. \n\n"
DATA "\L[B:@YSC_RSWAP_EN]"
DATA "\L[L:@YSC_SWSOL_EN]"
DATA "\L[R:@YSC_SWSOL3_EN]"
DATA ""

@YSC_SWSOL3_EN
DATA "■ Solid Method (3/3)\n\n"
DATA "When 'Force Whirl' or 'Force Eclipse', "
DATA "you must place the token at first in the lower trigram and "
DATA "put the purpose card (0) horizontally.\n\n"
DATA "When 'Field Whirl' or 'Field Eclipse', "
DATA "you must place the token at first in the upper trigram and "
DATA "put the purpose card (13) horizontally.\n\n"
DATA "\L[B:@YSC_RSWAP_EN]"
DATA "\L[L:@YSC_SWSOL2_EN]"
DATA ""


@YSC_RSWAP_JA
DATA "■ 8 ト 11 ノ イレカエ\n\n"
DATA "バン ヲ ツクッタ トキ 8 ト 11 ガ アレバ、イレカエル。"
DATA "ソノ リュウギ ハ 3ツ アル。\n\n"
DATA "●\L[@YSC_SWMEM_JA]キネン=シキ\n\n"
DATA "●\L[@YSC_SWEXP_JA]カイ=シキ\n\n"
DATA "●\L[@YSC_SWSOL_JA]コ=シキ\n\n"
DATA "\L[B:@YSC_RMAIN_JA]"
DATA "\L[R:@YSC_SWMEM_JA]"
DATA ""

@YSC_SWMEM_JA
DATA "■ キネン=シキ\n\n"
DATA "トニカク(8)カ(11)ガ アレバ イレカエル ダケ。\n\n"
DATA "アル コウ デ、(8)ガ ギャク=イチ デ アレバ、"
DATA  "ソノ コウ ニ(11)ヲ ギャク=イチ ニ オク。\n\n"
DATA "アル コウ デ、(11)ガ ギャク=イチ デ アレバ、"
DATA  "ソノ コウ ニ(8)ヲ ギャク=イチ ニ オク。\n\n"
DATA "コノ セイ=ギャク ヲ マモル テンハ、"
DATA "コレイガイ ノ リュウギ ニ モ キョウツウスル。"
DATA "\L[B:@YSC_RSWAP_JA]"
DATA "\L[L:@YSC_RSWAP_JA]"
DATA "\L[R:@YSC_SWEXP_JA]"
DATA ""

@YSC_SWEXP_JA
DATA "■ カイ=シキ\n\n"
DATA "(8)ト(11)ガ ドウジ ニ デテイレバ、トニカク イレカエル。\n\n"
DATA "ソウデナイ トキ:\n\n"
DATA "キスウ ノ カード ノ マイスウ ガ "
DATA "オオイ ナラバ、ヨリ=オオク、スクナイ ナラバ ヨリ=スクナク "
DATA "ナルヨウニ イレカエル。\n\n"
DATA "キスウ ト グウスウ ノ マイスウ ガ 3マイ ヅツ ナラバ、"
DATA "(8) カ (11) ガ セイ=イチ ノ トキノミ イレカエル。\n\n"
DATA "\L[B:@YSC_RSWAP_JA]"
DATA "\L[L:@YSC_SWMEM_JA]"
DATA "\L[R:@YSC_SWSOL_JA]"
DATA ""

@YSC_SWSOL_JA
DATA "■ コ=シキ (1/3)\n\n"
DATA "キスウ ノ カード ノ マイスウ ガ 0,1,5,6 ノ トキ ハ イレカエ ヲ セズ、"
DATA "2,3,4 ノトキハ、(8)カ(11)ガ アレバ、イレカエル\n\n"
DATA "イレカエ ガ アレバ イレカエタ アト、キスウ ト グウスウ ノ マイスウ ガ "
DATA "3マイ ヅツ ナラバ、スピン(セイ=ギャク)ヲ ミル。\n\n"
DATA "\L[B:@YSC_RSWAP_JA]"
DATA "\L[L:@YSC_SWEXP_JA]"
DATA "\L[R:@YSC_SWSOL2_JA]"
DATA ""

@YSC_SWSOL2_JA
DATA "■ コ=シキ (2/3)\n\n"
DATA "スベテ セイ=イチ ノトキ「セン ケン」ト ヨブ。\n\n"
DATA "スベテ ギャク=イチ ノトキ「セン コン」ト ヨブ。\n\n"
DATA "キスウ ノ カード ガ スベテ セイ=イチ デ、"
DATA "グウスウ ノ カード ガ スベテ ギャク=イチ ノトキ"
DATA "「ジュウ ケン」ト ヨブ。\n\n"
DATA "キスウ ノ カード ガ スベテ ギャク=イチ デ、"
DATA "グウスウ ノ カード ガ スベテ セイ=イチ ノトキ"
DATA "「ジュウ コン」ト ヨブ。\n\n"
DATA "\L[B:@YSC_RSWAP_JA]"
DATA "\L[L:@YSC_SWSOL_JA]"
DATA "\L[R:@YSC_SWSOL3_JA]"
DATA ""

@YSC_SWSOL3_JA
DATA "■ コ=シキ (3/3)\n\n"
DATA "「セン ケン」マタハ「ジュウ ケン」ノトキ、"
DATA "ハジメ ノ トークン ハ シモカ ニ オカネバナラナイ。"
DATA "モクテキ カード ノ(0)ハ ヨコ ムキ ニ オク。\n\n"
DATA "「セン コン」マタハ「ジュウ コン」ノトキ、"
DATA "ハジメ ノ トークン ハ ジョウカ ニ オカネバナラナイ。"
DATA "モクテキ カード ノ(13)ハ ヨコ ムキ ニ オク。\n\n"
DATA "\L[B:@YSC_RSWAP_JA]"
DATA "\L[L:@YSC_SWSOL2_JA]"
DATA ""


@YSC_RMJTB_EN
DATA "\C[!CMK]\F[!MK]"
DATA "\C[!CMK]\C[G:JRFTRT_A]\C[G:JRFTRT_D]\F[MK]"
DATA "\C[!CMK]\F[CMK]"
DATA "■ SCORE TABLE of Major Arcana\n\n"
DATA "\C[!MK]Cards are drawn if you have invoked MKJRFTRT.\n\n"
DATA "  \L[@YSC_TBA01_EN](1) "
DATA "\L[@YSC_TBA02_EN](2) "
DATA "\L[@YSC_TBA03_EN](3) "
DATA "\L[@YSC_TBA04_EN](4) "
DATA "\L[@YSC_TBA05_EN](5)\n  "
DATA "\L[@YSC_TBA06_EN](6) "
DATA "\L[@YSC_TBA07_EN](7) "
DATA "\L[@YSC_TBA08_EN](8) "
DATA "\L[@YSC_TBA09_EN](9) "
DATA "\L[@YSC_TBA10_EN](10)\n  "
DATA "\L[@YSC_TBA11_EN](11)"
DATA "\L[@YSC_TBA12_EN](12)"
DATA "\L[@YSC_TBA13_EN](13)"
DATA "\L[@YSC_TBA14_EN](14)"
DATA "\L[@YSC_TBA15_EN](15)\n  "
DATA "\L[@YSC_TBA16_EN](16)"
DATA "\L[@YSC_TBA17_EN](17)"
DATA "\L[@YSC_TBA18_EN](18)"
DATA "\L[@YSC_TBA19_EN](19)"
DATA "\L[@YSC_TBA20_EN](20)\n  "
DATA "\L[@YSC_TBA21_EN](21)"
DATA "\L[@YSC_TBA00_EN](0)\n\n"
DATA "\C[MK]■ Cards of Minor Arcana\n\n"
DATA "\C[MK]\L[@YSC_TBCDS_EN](♠) Swords,\n\n"
DATA "\C[MK]\L[@YSC_TBCDD_EN](♦) Coins,\n\n"
DATA "\C[MK]\L[@YSC_TBCDH_EN](♥) Cups,\n\n"
DATA "\C[MK]\L[@YSC_TBCDC_EN](♣) Wands.\n\n"
DATA "\L[B:@YSC_RMAIN_EN]"
DATA ""

@YSC_RMJTB_JA
DATA "\C[!CMK]\F[!MK]"
DATA "\C[!CMK]\C[G:JRFTRT_A]\C[G:JRFTRT_D]\F[MK]"
DATA "\C[!CMK]\F[CMK]"
DATA "■ ダイ=アルカナ スウヒョウ\n\n"
DATA "\C[!MK]MKJRFTRT ヲ ジッコウ シテイレバ カード ガ ヒョウジ サレマス。\n\n"
DATA "  \L[@YSC_TBA01_JA](1) "
DATA "\L[@YSC_TBA02_JA](2) "
DATA "\L[@YSC_TBA03_JA](3) "
DATA "\L[@YSC_TBA04_JA](4) "
DATA "\L[@YSC_TBA05_JA](5)\n  "
DATA "\L[@YSC_TBA06_JA](6) "
DATA "\L[@YSC_TBA07_JA](7) "
DATA "\L[@YSC_TBA08_JA](8) "
DATA "\L[@YSC_TBA09_JA](9) "
DATA "\L[@YSC_TBA10_JA](10)\n  "
DATA "\L[@YSC_TBA11_JA](11)"
DATA "\L[@YSC_TBA12_JA](12)"
DATA "\L[@YSC_TBA13_JA](13)"
DATA "\L[@YSC_TBA14_JA](14)"
DATA "\L[@YSC_TBA15_JA](15)\n  "
DATA "\L[@YSC_TBA16_JA](16)"
DATA "\L[@YSC_TBA17_JA](17)"
DATA "\L[@YSC_TBA18_JA](18)"
DATA "\L[@YSC_TBA19_JA](19)"
DATA "\L[@YSC_TBA20_JA](20)\n  "
DATA "\L[@YSC_TBA21_JA](21)"
DATA "\L[@YSC_TBA00_JA](0)\n\n"
DATA "\C[MK]■ ショウ=アルカナ カード\n\n"
DATA "\C[MK]\L[@YSC_TBCDS_JA](♠) ソード (ツルギ)、\n\n"
DATA "\C[MK]\L[@YSC_TBCDD_JA](♦) コイン (カネ)、\n\n"
DATA "\C[MK]\L[@YSC_TBCDH_JA](♥) カップ (ハイ)、\n\n"
DATA "\C[MK]\L[@YSC_TBCDC_JA](♣) ワンド (シャクジョウ)。\n\n"
DATA "\L[B:@YSC_RMAIN_JA]"
DATA ""


@YSC_THANKS_EN
DATA "■ Thanks\n\n"
DATA "Thank you for playing this game."
DATA "Thank you for reading poor English."
DATA "\L[B:@YSC_START_EN]"
DATA "\L[L:@YSC_ABOUT4_EN]"
DATA ""

@YSC_THANKS_JA
DATA "■ アリガトウ\n\n"
DATA "コノ ゲーム デ アソンデ クレテ アリガトウ。"
DATA "マズイ ニホンゴ ヲ ヨンデ クレテ アリガトウ。"
DATA "\L[B:@YSC_START_JA]"
DATA "\L[L:@YSC_ABOUT4_JA]"
DATA ""


'== END YSCHLP ==
