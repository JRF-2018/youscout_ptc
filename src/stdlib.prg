'== BEGIN STDLIB ==
@STDLIB_INIT
STDLIB_VER$ = "0.04" 'Time-stamp: <2013-02-27T22:27:37Z>
STDLIB_URI$ = "http://jrf.cocolog-nifty.com/archive/ptc/stdlib.prg"

'REQUIRE "STACKLIB"

'STDLIB provides basic functions.
'
'SR or SARRAY means STRING of ARRAY.
'SA or SASSOC means STRING of ASSOC.

'MPTR means a NUMBER which indicates an allocated pointer of M$[].

'STDLIB ハ キソ=テキ カンスウ ヲ テイギ。
'
'SR ヤ SARRAY ハ STRING of ARRAY ヲ アラワス。
'SA ヤ SASSOC ハ STRING of ASSOC ヲ アラワス。

'MPTR ハ NUMBER デ、ワリアテラレタ M$[] ノ ポインタ ヲ アラワス。

'Limits
GRP_WIDTH = 256: GRP_HEIGHT = 192
CON_WIDTH = 32: CON_HEIGHT = 24
FONT_WIDTH = 8: FONT_HEIGHT = 8

'Bit shift
IF NUM_TO_BIT_LEN == 0 THEN NUM_TO_BIT_LEN = 16
DIM NUM_TO_BIT[NUM_TO_BIT_LEN]
NUM_TO_BIT[0] = 1: NUM_TO_BIT[1] = 2: NUM_TO_BIT[2] = 4: NUM_TO_BIT[3] = 8
NUM_TO_BIT[4] = 16: NUM_TO_BIT[5] = 32: NUM_TO_BIT[6] = 64
NUM_TO_BIT[7] = 128: NUM_TO_BIT[8] = 256: NUM_TO_BIT[9] = &H200
NUM_TO_BIT[10] = &H400: NUM_TO_BIT[11] = &H800: NUM_TO_BIT[12] = &H1000
NUM_TO_BIT[13] = &H2000: NUM_TO_BIT[14] = &H4000: NUM_TO_BIT[15] = &H8000

'about M$[]
IF M_LEN == 0 THEN M_LEN = 1024
DIM M$[M_LEN]
M$[0] = "NULL,\0"
M_ALLOC_N = 1
M_FREE_M = -1

'About GRP.
R_GPAGE = 0 'Reserve GPAGE.
D_GPAGE = 1 'Drawing GPAGE.
U_GPAGE = 2 'Upper GPAGE.
L_GPAGE = 3 'Lower GPAGE.
GPAGE 1, L_GPAGE, L_GPAGE
GPAGE 0, U_GPAGE, U_GPAGE
G_PAGE = 0: BG_PAGE = 0: SP_PAGE = 0

'Usually, if you want to draw on U_GPAGE or L_GPAGE,
'you gosub @SWITCH_U_GPAGE or @SWITCH_L_GPAGE, and draw on D_GPAGE
'and then gosub @SHIPOUT_U_GPAGE or @SHIPOUT_L_GPAGE.
'The value of D_GPAGE, U_GPAGE and L_GPAGE change on each SHIPOUT.

'フツウ、U_GPAGE カ L_GPAGE ニ エガキタイ トキ、
'@SWITCH_U_GPAGE カ @SWITCH_L_GPAGE ニ GOSUB シテカラ、D_GPAGE ニ エガク。
'ソシテ、 @SHIPOUT_U_GPAGE カ @SHIPOUT_L_GPAGE ニ GOSUB。
'SHIPOUT スル ゴトニ D_GPAGE, U_GPAGE, L_GPAGE ノ アタイ ハ カワル。

'These variables are allocated for G_PUT_PM.
IF CMAP_LEN == 0 THEN CMAP_LEN = 256
DIM CMAP$[CMAP_LEN] 'which must preserve global color mapping.

'About BUTTON
BUTTON_UP = 1: BUTTON_DOWN = 2: BUTTON_LEFT = 4: BUTTON_RIGHT = 8
BUTTON_A = 16: BUTTON_B = 32: BUTTON_X = 64: BUTTON_Y = 128
BUTTON_L = 256: BUTTON_R = 512: BUTTON_START = 1024

'About Console.
DIM VIRTUAL_CON$[2, CON_HEIGHT]
FOR A = 0 TO CON_HEIGHT - 1
  VIRTUAL_CON$[0, A] = "0000" * CON_WIDTH
  VIRTUAL_CON$[1, A] = "0000" * CON_WIDTH
NEXT
DIM CLIP_CX[2], CLIP_CY[2], CLIP_CW[2], CLIP_CH[2], LAST_CX[2], LAST_CY[2]
DIM CON_COL[2], CON_BG_COL[2]
CLIP_CX[0] = 0: CLIP_CY[0] = 0: CLIP_CX[1] = 0: CLIP_CY[1] = 0
CLIP_CW[0] = CON_WIDTH: CLIP_CH[0] = CON_HEIGHT
CLIP_CW[1] = CON_WIDTH: CLIP_CH[1] = CON_HEIGHT
LAST_CX[0] = 0: LAST_CY[0] = 0: LAST_CX[1] = 0: LAST_CY[1] = 0
LAST_DISP = 1
CON_COL[0] = 0: CON_BG_COL[0] = 0: CON_COL[1] = 0: CON_BG_COL[1] = 0
DEBUG_CON_COL = 0

CON_DECORATE = TRUE
SUIT_CHARS$ = "♠♦♥♣"
'BUTTON_CHARS$ i.e. "ABXYLR"
BUTTON_CHARS$ = CHR$(1) + CHR$(2) + CHR$(24) + CHR$(25) + CHR$(12) + CHR$(18)
DECORATE_CHARS$ = SUIT_CHARS$ + BUTTON_CHARS$
DECORATE_COLS$ = "B7C5D3B4RR"

IF CWIN_STACK_LEN == 0 THEN CWIN_STACK_LEN = (CON_HEIGHT + 1) * 4
DIM CWIN_STACK$[CWIN_STACK_LEN]
CWIN_SP = -1

DRAW_CWIN_NOINIT = FALSE
CWIN_CHR_BG_TL = 256
CWIN_CHR_BG_T = 256 + 1: CWIN_CHR_BG_L = 256 + 2: CWIN_CHR_BG_C = 256 + 3

'Named Charcters (excluded displayable ASCII \x20 - \x7E but \x20,\x5C,\x7E).
A$="" + "@NULL:" + CHR$(0)  + "@A:" + CHR$(1) + "@B:" + CHR$(2)
A$=A$ + "@BAR:" + CHR$(3) + "@ROCKET:" + CHR$(4) + "@PLANE:" + CHR$(5)
A$=A$ + "@INVADER:" + CHR$(6) + "@FACE:" + CHR$(7) + "@FACE2:" + CHR$(8)
A$=A$ + "@TAB:" + CHR$(9) + "@STAR:" + CHR$(10) + "@HAND:" + CHR$(11)
A$=A$ + "@L:" + CHR$(12) + "@RET:" + CHR$(13) + "@UFO:" + CHR$(14)
A$=A$ + "@UFO2:" + CHR$(15) + "@NOTE:" + CHR$(16) + "@NOTE2:" + CHR$(17)
A$=A$ + "@R:" + CHR$(18) + "@CROSS:" + CHR$(19) + "@TIME:" + CHR$(20)
A$=A$ + "@DOTTL:" + CHR$(21) + "@DOTT:" + CHR$(22) + "@DOTL:" + CHR$(23)
A$=A$ + "@X:" + CHR$(24) + "@Y:" + CHR$(25) + "@TARGET:" + CHR$(26)
A$=A$ + "@SNAKE:" + CHR$(27) + "@RIGHT:" + CHR$(28) + "@LEFT:" + CHR$(29)
A$=A$ + "@UP:" + CHR$(30) + "@DOWN:" + CHR$(31) + "@DQ:" + CHR$(34)
A$=A$ + "@SQ:" + CHR$(39) + "@YEN:" + CHR$(92) + "@TILDA:" + CHR$(126)
A$=A$ + "@BACKSLASH:" + CHR$(127) 
CHR_NAME_0$ = A$

A$="" + "@BOX2:" + CHR$(224) + "@CIRCLE2:" + CHR$(225) + "@TRIANGLE2:" + CHR$(226)
A$=A$ + "@ITRIANGLE2:" + CHR$(227) + "@BOX:" + CHR$(228) + "@CIRCLE:" + CHR$(229)
A$=A$ + "@TRIANGLE:" + CHR$(230) + "@ITRIANGLE:" + CHR$(231) + "@HOUSE:" + CHR$(232)
A$=A$ + "@BOMB:" + CHR$(233) + "@DOOR:" + CHR$(234) + "@KEY:" + CHR$(235)
A$=A$ + "@CARUP:" + CHR$(236) + "@CARRIGHT:" + CHR$(237) + "@CARDOWN:" + CHR$(238)
A$=A$ + "@CARLEFT:" + CHR$(239) + "@SPADE:" + CHR$(240) + "@DIA:" + CHR$(241)
A$=A$ + "@HEART:" + CHR$(242) + "@CLUB:" + CHR$(243) + "@MANUP:" + CHR$(244)
A$=A$ + "@MANRIGHT:" + CHR$(245) + "@MANDOWN:" + CHR$(246) + "@MANLEFT:" + CHR$(247)
CHR_NAME_1$ = A$

A$="" + "@SQUARE:" + CHR$(128) + "@FILL:" + CHR$(151) + "@BOTTOMRIGHT:" + CHR$(156)
A$=A$ + "@BOTTOMLEFT:" + CHR$(157) + "@TOPRIGHT:" + CHR$(158) + "@TOPLEFT:" + CHR$(159)
A$=A$ + "@LTOP:" + CHR$(248) + "@LLEFT:" + CHR$(249) + "@LRIGHT:" + CHR$(250)
A$=A$ + "@LBOTTOM:" + CHR$(251) + "@LSLASH:" + CHR$(252) + "@LBACKSLASH:" + CHR$(253)
A$=A$ + "@LX:" + CHR$(254) + "@CHECKER:" + CHR$(255)
CHR_NAME_2$ = A$

A$="" + "@TET0000:" + CHR$(32) + "@TET1000:" + CHR$(129) + "@TET0100:" + CHR$(130)
A$=A$ + "@TET1100:" + CHR$(131) + "@TET0010:" + CHR$(132) + "@TET1010:" + CHR$(133)
A$=A$ + "@TET0110:" + CHR$(134) + "@TET1110:" + CHR$(135) + "@TET0001:" + CHR$(136)
A$=A$ + "@TET1001:" + CHR$(137) + "@TET0011:" + CHR$(138) + "@TET1101:" + CHR$(139)
A$=A$ + "@TET0011:" + CHR$(140) + "@TET1011:" + CHR$(141) + "@TET0111:" + CHR$(142)
A$=A$ + "@TET1111:" + CHR$(143) + "@WAYNEW:" + CHR$(144) + "@WAYEWS:" + CHR$(145)
A$=A$ + "@WAYNES:" + CHR$(146) + "@WAYNESW:" + CHR$(147) + "@WAYNSW:" + CHR$(149)
A$=A$ + "@WAYEW:" + CHR$(149) + "@WAYNS:" + CHR$(150) + "@WAYES:" + CHR$(152)
A$=A$ + "@WAYSW:" + CHR$(153) + "@WAYNE:" + CHR$(154) + "@WAYNW:" + CHR$(155)
CHR_NAME_3$ = A$

A$="" + "@J_NAMI:" + CHR$(160) + "@J_MARU:" + CHR$(161) + "@J_OPEN:" + CHR$(162)
A$=A$ + "@J_CLOSE:" + CHR$(163) + "@J_TEN:" + CHR$(164) + "@J_NAKAGURO:" + CHR$(165)
A$=A$ + "@J_WO:" + CHR$(166) + "@J_LA:" + CHR$(167) + "@J_LI:" + CHR$(168)
A$=A$ + "@J_LU:" + CHR$(169) + "@J_LE:" + CHR$(170) + "@J_LO:" + CHR$(171)
A$=A$ + "@J_LYA:" + CHR$(172) + "@J_LYA:" + CHR$(172) + "@J_LYU:" + CHR$(173)
A$=A$ + "@J_LYO:" + CHR$(174) + "@J_LTU:" + CHR$(175) + "@J_BOU:" + CHR$(176)
A$=A$ + "@J_A:" + CHR$(177) + "@J_I:" + CHR$(178) + "@J_U:" + CHR$(179)
A$=A$ + "@J_E:" + CHR$(180) + "@J_O:" + CHR$(181) + "@J_KA:" + CHR$(182)
A$=A$ + "@J_KI:" + CHR$(183) + "@J_KU:" + CHR$(184) + "@J_KE:" + CHR$(185)
A$=A$ + "@J_KO:" + CHR$(186) + "@J_SA:" + CHR$(187) + "@J_SI:" + CHR$(188)
A$=A$ + "@J_SU:" + CHR$(189) + "@J_SE:" + CHR$(190) + "@J_SO:" + CHR$(191)
CHR_NAME_4$ = A$

A$="" + "@J_TA:" + CHR$(192) + "@J_TI:" + CHR$(193) + "@J_TU:" + CHR$(194)
A$=A$ + "@J_TE:" + CHR$(195) + "@J_TO:" + CHR$(196) + "@J_NA:" + CHR$(197)
A$=A$ + "@J_NI:" + CHR$(198) + "@J_NU:" + CHR$(199) + "@J_NE:" + CHR$(200)
A$=A$ + "@J_NO:" + CHR$(201) + "@J_HA:" + CHR$(202) + "@J_HI:" + CHR$(203)
A$=A$ + "@J_HU:" + CHR$(204) + "@J_HE:" + CHR$(205) + "@J_HO:" + CHR$(206)
A$=A$ + "@J_MA:" + CHR$(207) + "@J_MI:" + CHR$(208) + "@J_MU:" + CHR$(209)
A$=A$ + "@J_ME:" + CHR$(210) + "@J_MO:" + CHR$(211) + "@J_YA:" + CHR$(212)
A$=A$ + "@J_YU:" + CHR$(213) + "@J_YO:" + CHR$(214) + "@J_RA:" + CHR$(215)
A$=A$ + "@J_RI:" + CHR$(216) + "@J_RU:" + CHR$(217) + "@J_RE:" + CHR$(218)
A$=A$ + "@J_RO:" + CHR$(219) + "@J_WA:" + CHR$(220) + "@J_N:" + CHR$(221)
A$=A$ + "@J_DAKUTEN:" + CHR$(222) + "@J_HANDAKUTEN:" + CHR$(223)
CHR_NAME_5$ = A$

'PROVIDE "STDLIB"
RETURN


'About SARRAY and SASSOC.

@NTH_SR '(SR$:SARRAY, I:NUMBER): STRING
  R = BP
  GOSUB @PUSH_R
  BP = SP - 1 - 2

  R$ = SR$: GOSUB @PUSH_RS
  R = I: GOSUB @PUSH_R
  R = J: GOSUB @PUSH_R

  SR$ = STACK$[BP + 1]
  I = FLOOR(VAL(STACK$[BP + 2]))

  J = 0
  IF I < 0 THEN A = 0: GOTO @_NTH_SR_E
@_NTH_SR_LP
  IF I == 0 THEN @_NTH_SR_Z
  A = INSTR(J, SR$, ",")
  IF -1 == A THEN A = 0: GOTO @_NTH_SR_E
  J = A + 1
  I = I - 1
  GOTO @_NTH_SR_LP
@_NTH_SR_Z
  IF LEN(SR$) <= J THEN A = 0: GOTO @_NTH_SR_E
  A = INSTR(J, SR$, ",")
  IF -1 == A THEN R$ = SR$ ELSE R$ = MID$(SR$, J, A - J)
  GOSUB @PUSH_RS
  GOSUB @UNESCAPE
  A$ = R$
  A = 1

@_NTH_SR_E
  GOSUB @POP_R: J = R
  GOSUB @POP_R: I = R
  GOSUB @POP_RS: SR$ = R$

  ARGNUM = 2: GOSUB @CHECK_BP
  GOSUB @POP_R
  SP = BP
  BP = R
  IF A == 0 THEN RT$ = "NONE" ELSE RT$ = "STRING": R$ = A$
  RETURN


@SET_NTH_SR '(SR$:SARRAY, I:NUMBER, VALUE$:STRING): SARRAY
  R = BP
  GOSUB @PUSH_R
  BP = SP - 1 - 3

  R$ = SR$: GOSUB @PUSH_RS
  R = I: GOSUB @PUSH_R
  R$ = VALUE$: GOSUB @PUSH_RS
  R = J: GOSUB @PUSH_R

  SR$ = STACK$[BP + 1]
  I = VAL(STACK$[BP + 2])
  VALUE$ = STACK$[BP + 3]

  R$ = VALUE$: GOSUB @PUSH_RS
  GOSUB @ESCAPE
  VALUE$ = R$

  J = 0
  IF I < 0 THEN A = 0: GOTO @_SET_NTH_SR_E
@_SET_NTH_SR_LP
  IF I == 0 THEN @_SET_NTH_SR_Z
  A = INSTR(J, SR$, ",")
  IF -1 == A THEN A = 0: GOTO @_SET_NTH_SR_E
  J = A + 1
  I = I - 1
  GOTO @_SET_NTH_SR_LP
@_SET_NTH_SR_Z
  IF LEN(SR$) <= J THEN A = 0: GOTO @_SET_NTH_SR_E
  A = INSTR(J, SR$, ",")
  IF -1 == A THEN A = LEN(SR$)
  A$ = SUBST$(SR$, J, A - J, VALUE$)
  A = 1

@_SET_NTH_SR_E
  IF A == 0 THEN A$ = SR$ + "," * (SR$ != "") + "\0," * (I - 1) + VALUE$

  GOSUB @POP_R: J = R
  GOSUB @POP_RS: VALUE$ = R$
  GOSUB @POP_R: I = R
  GOSUB @POP_RS: SR$ = R$

  GOSUB @POP_R
  SP = BP
  BP = R
  RT$ = "STRING"
  R$ = A$
  RETURN


@GET_SA '(SA$:SASSOC, KEY$:STRING): STRING
  R = BP
  GOSUB @PUSH_R
  BP = SP - 1 - 2

  R$ = SA$: GOSUB @PUSH_RS
  R$ = KEY$: GOSUB @PUSH_RS

  SA$ = STACK$[BP + 1]
  KEY$ = STACK$[BP + 2]

  R$ = SA$: GOSUB @PUSH_RS
  GOSUB @POP_RA

  R$ = KEY$: GOSUB @PUSH_RS
  GOSUB @GET_RA

  IF RT$ == "NONE" THEN A = 0 ELSE A = 1
  A$ = R$

  GOSUB @POP_RS: KEY$ = R$
  GOSUB @POP_RS: SA$ = R$

  GOSUB @POP_R
  SP = BP
  BP = R
  IF A == 0 THEN RT$ = "NONE" ELSE RT$ = "STRING"
  R$ = A$
  RETURN


@SET_SA '(SA$:SASSOC, KEY$:STRING, VALUE$:STRING): SASSOC
  R = BP
  GOSUB @PUSH_R
  BP = SP - 1 - 3

  R$ = SA$: GOSUB @PUSH_RS
  R$ = KEY$: GOSUB @PUSH_RS
  R$ = VALUE$: GOSUB @PUSH_RS

  SA$ = STACK$[BP + 1]
  KEY$ = STACK$[BP + 2]
  VALUE$ = STACK$[BP + 3]

  R$ = SA$: GOSUB @PUSH_RS
  GOSUB @POP_RA

  R$ = KEY$: GOSUB @PUSH_RS
  R$ = VALUE$: GOSUB @PUSH_RS
  GOSUB @SET_RA
  GOSUB @PUSH_RA
  GOSUB @POP_RS

  A$ = R$

  GOSUB @POP_RS: VALUE$ = R$
  GOSUB @POP_RS: KEY$ = R$
  GOSUB @POP_RS: SA$ = R$

  GOSUB @POP_R
  SP = BP
  BP = R
  RT$ = "STRING"
  R$ = A$
  RETURN


'Delete the (first) key, and return SASSOC.
'Or do nothing if the key doesn't exist.

@DELETE_SA '(SA$:SASSOC, KEY$:STRING): SASSOC
  R = BP
  GOSUB @PUSH_R
  BP = SP - 1 - 2

  R$ = SA$: GOSUB @PUSH_RS
  R$ = KEY$: GOSUB @PUSH_RS

  SA$ = STACK$[BP + 1]
  KEY$ = STACK$[BP + 2]

  R$ = SA$: GOSUB @PUSH_RS
  GOSUB @POP_RA

  R$ = KEY$: GOSUB @PUSH_RS
  GOSUB @DELETE_RA
'  IF RT$ == "NONE" THEN A = 0 ELSE A = 1

  GOSUB @POP_RS: KEY$ = R$
  GOSUB @POP_RS: SA$ = R$

  GOSUB @POP_R
  SP = BP
  BP = R
'  IF A == 0 THEN RT$ = "NONE": RETURN
  GOSUB @PUSH_RA
  GOSUB @POP_RS
  RETURN


@LEN_SR '(SR$:SARRAY): STRING
  R = BP
  GOSUB @PUSH_R
  BP = SP - 1 - 1

  R$ = SR$: GOSUB @PUSH_RS

  SR$ = STACK$[BP + 1]

  R$ = SR$: GOSUB @PUSH_RS
  GOSUB @POP_RR

  A = RN

  GOSUB @POP_RS: SR$ = R$
  GOSUB @POP_R
  SP = BP
  BP = R
  RT$ = "NUMBER"
  R = A
  RETURN


@LEN_SA '(SA$:SASSOC): STRING
  R = BP
  GOSUB @PUSH_R
  BP = SP - 1 - 1

  R$ = SA$: GOSUB @PUSH_RS

  SA$ = STACK$[BP + 1]

  R$ = SA$: GOSUB @PUSH_RS
  GOSUB @POP_RA

  A = RN

  GOSUB @POP_RS: SA$ = R$

  GOSUB @POP_R
  SP = BP
  BP = R
  RT$ = "NUMBER"
  R = A
  RETURN


@REVERSE_S '(STRING): STRING
  R = BP
  GOSUB @PUSH_R
  BP = SP - 1 - 1

  R$ = STACK$[BP + 1]
  A$ = ""
  FOR A = LEN(R$) - 1 TO 0 STEP -1
    A$ = A$ + MID$(R$, A, 1)
  NEXT

  GOSUB @POP_R
  SP = BP
  BP = R
  RT$ = "STRING"
  R$ = A$
  RETURN


'== About M$[] ==

@M_ALLOC '(NONE): MPTR
  IF M_FREE_M == -1 THEN @_M_ALLOC_NEW
  R = M_FREE_M
  IF MID$(M$[R], 0, 4) == "NULL" THEN M_FREE_M = -1 ELSE M_FREE_M = VAL("&H" + MID$(M$[R], 0, 4))
  M$[R] = ""
  RETURN
@_M_ALLOC_NEW
  IF M_ALLOC_N == M_LEN THEN @_M_ALLOC_FULL
  R = M_ALLOC_N
  M_ALLOC_N = M_ALLOC_N + 1
  RETURN
@_M_ALLOC_FULL
  PRINT "M$[] full!"
  STOP: RETURN


@M_FREE '(P: MPTR): NONE
  R = BP
  GOSUB @PUSH_R
  BP = SP - 1 - 1

  R = VAL(STACK$[BP + 1])

  IF R >= M_ALLOC_N OR R < 0 THEN @_M_FREE_ERR
  IF M_FREE_M == -1 THEN M$[R] = "NULL,\0" ELSE M$[R] = HEX$(M_FREE_M, 4) + ",\0"
  M_FREE_M = R

  GOSUB @POP_R
  SP = BP
  BP = R
  RETURN

@_M_FREE_ERR
  PRINT "@M_FREE: Illegal pointer!"
  STOP: RETURN


'== About Graphics ==

@SWITCH_U_GPAGE '(NONE): NONE
  G_PAGE = 0: GPAGE 0, D_GPAGE , U_GPAGE
  RETURN


@SWITCH_L_GPAGE '(NONE): NONE
  G_PAGE = 1: GPAGE 1, D_GPAGE , L_GPAGE
  RETURN


@SHIPOUT_U_GPAGE '(NONE): NONE
  G_PAGE = 0: GPAGE 0, D_GPAGE, D_GPAGE
  TMP = D_GPAGE
  D_GPAGE = U_GPAGE
  U_GPAGE = TMP
  RETURN


@SHIPOUT_L_GPAGE '(NONE): NONE
  G_PAGE = 1: GPAGE 1, D_GPAGE, D_GPAGE
  TMP = D_GPAGE
  D_GPAGE = L_GPAGE
  L_GPAGE = TMP
  RETURN

@GPAGE_U '(NONE): NONE
  G_PAGE = 0: GPAGE 0, U_GPAGE, U_GPAGE
  RETURN

@GPAGE_L '(NONE): NONE
  G_PAGE = 1: GPAGE 1, L_GPAGE, L_GPAGE
  RETURN

@BGPAGE_U '(NONE): NONE
  BG_PAGE = 0: BGPAGE 0
  RETURN

@BGPAGE_L '(NONE): NONE
  BG_PAGE = 1: BGPAGE 1
  RETURN

@SPPAGE_U '(NONE): NONE
  SP_PAGE = 0: SPPAGE 0
  RETURN

@SPPAGE_L '(NONE): NONE
  SP_PAGE = 1: SPPAGE 1
  RETURN


'DISP: 0: Upper display, 1: Lower display, -1: Both.
'"DATA" at LABEL$ must begin by the size of the color map.
@READ_CMAP '(DISP:NUMBER, PLANE$:STRING, LABEL$:STRING)
  R = BP
  GOSUB @PUSH_R
  BP = SP - 1 - 3

  R = DISP: GOSUB @PUSH_R
  R$ = PLANE$: GOSUB @PUSH_RS
  R$ = LABEL$: GOSUB @PUSH_RS
  R = I: GOSUB @PUSH_R

  DISP = VAL(STACK$[BP + 1])
  PLANE$ = STACK$[BP + 2]
  LABEL$ = STACK$[BP + 3]

  FOR A = 2 - 1 TO 0 STEP -1
    IF !(DISP == A OR DISP == -1) THEN @_READ_CMAP_1
    IF A == 0 THEN GOSUB @GPAGE_U ELSE GOSUB @GPAGE_L
    RESTORE LABEL$
    READ R
    FOR I = 0 TO R - 1
      READ A$
      IF A$ != "" THEN CMAP$[I] = A$: COLSET PLANE$, I, A$
    NEXT
@_READ_CMAP_1
  NEXT

  GOSUB @POP_R: I = R
  GOSUB @POP_RS: LABEL$ = R$
  GOSUB @POP_RS: PLANE$ = R$
  GOSUB @POP_R: DISP = R

  ARGNUM = 3: GOSUB @CHECK_BP
  GOSUB @POP_R
  SP = BP
  BP = R
  RETURN


'== about Console ==

'DISP: 0: Upper Display, 1: Lower Display.
'S$: with escape sequence. "\\" == "\", "\xA0" == CHR$(&HA0),
'    "\[1]" == PARAM$[1], "\0" == ""
'    "\cF" changes color to 15, "\CF" changes background color to 15,
'    "\cR" restores color to CON_COL[DISP],
'    "\CR" restores bg color to CON_BG_COL[DISP],
'    "\N[NAME]" is replaced with a named char defined in CHR_NAME_*$,
'    "\n": line break, "\t": tab.
'    Hex numbers must be in upper case for VAL("&H" + ).
@CON_PRINT '(DISP:NUMBER, CX:NUMBER, CY:NUMBER, S$:STRING, PARAM$:SARRAY): NONE
  GOSUB @POP_RR

@CON_PRINT_RR '(DISP:NUMBER, CX:NUMBER, CY:NUMBER, S$:STRING)with(RR$[]): NONE
  R = BP
  GOSUB @PUSH_R
  BP = SP - 1 - 4

  R = DISP: GOSUB @PUSH_R
  R = CX: GOSUB @PUSH_R
  R = CY: GOSUB @PUSH_R
  R$ = S$: GOSUB @PUSH_RS
  R = COL: GOSUB @PUSH_R
  R = BGCOL: GOSUB @PUSH_R
  R = COLQ: GOSUB @PUSH_R
  R = I: GOSUB @PUSH_R
  R = J: GOSUB @PUSH_R

  DISP = VAL(STACK$[BP + 1])
  CX = VAL(STACK$[BP + 2])
  CY = VAL(STACK$[BP + 3])
  S$ = STACK$[BP + 4]

  COLQ = 0
  COL = CON_COL[DISP]
  BGCOL = CON_BG_COL[DISP]
@_CON_PRINT_LP
  IF LEN(S$) == 0 THEN @_CON_PRINT_E
  I = INSTR(0, S$, "\")
  IF I == -1 THEN R$ = S$: GOSUB @_CON_PRINT_F: GOTO @_CON_PRINT_E
  IF I != 0 THEN R$ = MID$(S$, 0, I): GOSUB @_CON_PRINT_F
  S$ = MID$(S$, I + 1, LEN(S$) - I - 1)
  IF S$ == "" THEN R$  = "\": GOSUB @_CON_PRINT_F: GOTO @_CON_PRINT_E
  A$ = MID$(S$, 0, 1)
  S$ = MID$(S$, 1, LEN(S$) - 1)
  IF A$ == "\" THEN R$ = "\": GOSUB @_CON_PRINT_F: GOTO @_CON_PRINT_LP
  IF A$ == "[" THEN GOSUB @_CON_PRINT_PARAM: GOTO @_CON_PRINT_LP
  IF A$ == "x" OR A$ == "X" THEN GOSUB @_CON_PRINT_X: GOTO @_CON_PRINT_LP
  IF A$ == "c" THEN GOSUB @_CON_PRINT_COL: GOTO @_CON_PRINT_LP
  IF A$ == "C" THEN GOSUB @_CON_PRINT_BGCOL: GOTO @_CON_PRINT_LP
  IF A$ == "N" THEN GOSUB @_CON_PRINT_CHRN: GOTO @_CON_PRINT_LP
  IF A$ == "n" THEN CY = CY + 1: CX = CLIP_CX[DISP]: GOTO @_CON_PRINT_LP
  IF A$ == "t" THEN CX = FLOOR((CX + TABSTEP) / TABSTEP) * TABSTEP: GOTO @_CON_PRINT_LP
  IF A$ == "0" THEN @_CON_PRINT_LP
  R$ = "\" + A$: GOSUB @_CON_PRINT_F
  GOTO @_CON_PRINT_LP

@_CON_PRINT_F
  COLOR COL, BGCOL
  I = 0
@_CON_PRINT_F_LP
  IF I >= LEN(R$) THEN RETURN
  A = ASC(MID$(R$, I, 1))
  I = I + 1
  IF A == 13 THEN CY = CY + 1: CX = CLIP_CX[DISP]: GOTO @_CON_PRINT_F_LP
  IF A == 9 THEN CX = FLOOR((CX + TABSTEP) / TABSTEP) * TABSTEP: GOTO @_CON_PRINT_F_LP
  IF CX < 0 OR CY < 0 OR CX < CLIP_CX[DISP] OR CY < CLIP_CY[DISP]  THEN @_CON_PRINT_F_2
  IF CX >= CON_WIDTH OR CY >= CON_HEIGHT THEN @_CON_PRINT_F_2
  IF CX >= CLIP_CX[DISP] + CLIP_CW[DISP] THEN @_CON_PRINT_F_2
  IF CY >= CLIP_CY[DISP] + CLIP_CH[DISP] THEN @_CON_PRINT_F_2
  IF CON_DECORATE != TRUE OR COLQ THEN @_CON_PRINT_F_1
  J = INSTR(0, DECORATE_CHARS$, CHR$(A))
  IF J == -1 THEN @_CON_PRINT_F_1
  A$ = MID$(DECORATE_COLS$, J, 1)
  IF A$ == "R" THEN @_CON_PRINT_F_1
  IF DISP == 0 THEN LOCATE CX, CY: COLOR VAL("&H" + A$): PRINT CHR$(A);: COLOR COL, BGCOL
  IF DISP == 1 THEN PNLSTR CX, CY, CHR$(A), VAL("&H" + A$)
  A = A + BGCOL * 256 + VAL("&H" + A$) * 256 * 16
  A$ = VIRTUAL_CON$[DISP, CY]
  A$ = SUBST$(A$, CX * 4, 4, HEX$(A, 4))
  VIRTUAL_CON$[DISP, CY] = A$
  GOTO @_CON_PRINT_F_2
@_CON_PRINT_F_1
  IF DISP == 0 THEN LOCATE CX, CY: PRINT CHR$(A);
  IF DISP == 1 THEN PNLSTR CX, CY, CHR$(A), COL
  A = A + BGCOL * 256 + COL * 256 * 16
  A$ = VIRTUAL_CON$[DISP, CY]
  A$ = SUBST$(A$, CX * 4, 4, HEX$(A, 4))
  VIRTUAL_CON$[DISP, CY] = A$
@_CON_PRINT_F_2
  CX = CX + 1
  IF CX >= CLIP_CX[DISP] + CLIP_CW[DISP] THEN CX = CLIP_CX[DISP]: CY = CY + 1
  GOTO @_CON_PRINT_F_LP

@_CON_PRINT_PARAM
  I = INSTR(0, S$, "]")
  IF I == -1 THEN R$ = "\[": GOSUB @_CON_PRINT_F: RETURN
  A = VAL(MID$(S$, 0, I))
  IF A < 0 OR A >= RN THEN R$ = "\[": GOSUB @_CON_PRINT_F: RETURN
  S$ = MID$(S$, I + 1, LEN(S$) - I - 1)
  R$ = RR$[A]
  GOSUB @_CON_PRINT_F
  RETURN

@_CON_PRINT_X
  IF LEN(S$) < 2 THEN R$ = "\" + A$: GOSUB @_CON_PRINT_F: RETURN
  A = INSTR(0, "0123456789ABCDEFabcdef", MID$(S$, 1, 1))
  IF A < 0 THEN R$ = "\" + A$: GOSUB @_CON_PRINT_F: RETURN
  IF A > 15 THEN A = A - 6
  A = A + 16 * INSTR(0, "0123456789ABCDEFabcdef", MID$(S$, 0, 1))
  IF A < 0 THEN R$ = "\" + A$: GOSUB @_CON_PRINT_F: RETURN
  IF A > 15 * 16 THEN A = A - 6 * 16
  R$ = CHR$(A)
  S$ = MID$(S$, 2, LEN(S$) - 2)
  GOSUB @_CON_PRINT_F
  RETURN

@_CON_PRINT_COL
  IF LEN(S$) < 1 THEN R$ = "\" + A$: GOSUB @_CON_PRINT_F: RETURN
  A = INSTR(0, "0123456789ABCDEFabcdefR", MID$(S$, 0, 1))
  IF A == -1 THEN R$ = "\" + A$: GOSUB @_CON_PRINT_F: RETURN
  IF A > 15 THEN A = A - 6
  IF A == 16 THEN COL = CON_COL[DISP]: COLQ = 0 ELSE COL = A: COLQ = 1
  S$ = MID$(S$, 1, LEN(S$) - 1)
  RETURN

@_CON_PRINT_BGCOL
  IF LEN(S$) < 1 THEN R$ = "\" + A$: GOSUB @_CON_PRINT_F: RETURN
  A = INSTR(0, "0123456789ABCDEFabcdefR", MID$(S$, 0, 1))
  IF A == -1 THEN R$ = "\" + A$: GOSUB @_CON_PRINT_F: RETURN
  IF A > 15 THEN A = A - 6
  IF A == 16 THEN BGCOL = CON_BG_COL[DISP] ELSE BGCOL = A
  S$ = MID$(S$, 1, LEN(S$) - 1)
  RETURN

@_CON_PRINT_CHRN
  IF LEN(S$) < 3 OR MID$(S$, 0, 1) != "[" THEN R$ = "\" + A$: GOSUB @_CON_PRINT_F: RETURN
  A = INSTR(0, S$, "]")
  IF A == -1 THEN  R$ = "\" + A$: GOSUB @_CON_PRINT_F: RETURN
  A$ = MID$(S$, 1, A - 1)
  S$ = MID$(S$, A + 1, LEN(S$) - A - 1)
  IF MID$(A$, 0, 2) == "J_" THEN @_CON_PRINT_CNJ
  IF MID$(A$, 0, 3) == "WAY" THEN @_CON_PRINT_CN3
  IF MID$(A$, 0, 3) == "TET" THEN @_CON_PRINT_CN3
  A = INSTR(0, CHR_NAME_0$, "@" + A$ + ":")
  IF A != -1 THEN R$ = MID$(CHR_NAME_0$, A + LEN(A$) + 2, 1): GOSUB @_CON_PRINT_F: RETURN
  A = INSTR(0, CHR_NAME_1$, "@" + A$ + ":")
  IF A != -1 THEN R$ = MID$(CHR_NAME_1$, A + LEN(A$) + 2, 1): GOSUB @_CON_PRINT_F: RETURN
  A = INSTR(0, CHR_NAME_2$, "@" + A$ + ":")
  IF A != -1 THEN R$ = MID$(CHR_NAME_2$, A + LEN(A$) + 2, 1): GOSUB @_CON_PRINT_F: RETURN
  R$ = "\N[" + A$ + "]"
  GOSUB @_CON_PRINT_F
  RETURN
@_CON_PRINT_CN3
  A = INSTR(0, CHR_NAME_3$, "@" + A$ + ":")
  IF A != -1 THEN R$ = MID$(CHR_NAME_3$, A + LEN(A$) + 2, 1): GOSUB @_CON_PRINT_F: RETURN
  R$ = "\N[" + A$ + "]"
  GOSUB @_CON_PRINT_F
  RETURN
@_CON_PRINT_CNJ
  A = INSTR(0, CHR_NAME_4$, "@" + A$ + ":")
  IF A != -1 THEN R$ = MID$(CHR_NAME_4$, A + LEN(A$) + 2, 1): GOSUB @_CON_PRINT_F: RETURN
  A = INSTR(0, CHR_NAME_5$, "@" + A$ + ":")
  IF A != -1 THEN R$ = MID$(CHR_NAME_5$, A + LEN(A$) + 2, 1): GOSUB @_CON_PRINT_F: RETURN
  R$ = "\N[" + A$ + "]"
  GOSUB @_CON_PRINT_F
  RETURN

@_CON_PRINT_E
  COLOR DEBUG_CON_COL, 0 'for DEBUG
  LAST_CX[DISP] = CX
  LAST_CY[DISP] = CY
  LAST_DISP = DISP

  GOSUB @POP_R: J = R
  GOSUB @POP_R: I = R
  GOSUB @POP_R: COLQ = R
  GOSUB @POP_R: BGCOL = R
  GOSUB @POP_R: COL = R
  GOSUB @POP_RS: S$ = R$
  GOSUB @POP_R: CY = R
  GOSUB @POP_R: CX = R
  GOSUB @POP_R: DISP = R

  ARGNUM = 4: GOSUB @CHECK_BP
  GOSUB @POP_R
  SP = BP
  BP = R
  RETURN


'Returns RR$[0]<-CW, RR$[1]<-CH
'Approximate CON_PRINTing size. Not precise.
'For example, direct control codes like CHR$(13) is not interpreted,
'and illegal \N[NAME] is not checked.
@PRINT_SIZE_R '(CLIPCW: NUMBER, S$: STRING, PARAM$: SARRAY): ARRAY
  R = BP
  GOSUB @PUSH_R
  BP = SP - 1 - 3

  R = CLIPCW: GOSUB @PUSH_R
  R$ = S$: GOSUB @PUSH_RS
  R$ = PARAM$: GOSUB @PUSH_RS
  R = CW: GOSUB @PUSH_R
  R = CH: GOSUB @PUSH_R
  R = MAX_CW: GOSUB @PUSH_R

  CLIPCW = VAL(STACK$[BP + 1])
  S$ = STACK$[BP + 2]
  PARAM$ = STACK$[BP + 3]

  R$ = PARAM$: GOSUB @PUSH_RS
  GOSUB @POP_RR

  MAX_CW = 0
  CW = 0
  CH = 0
@_PRINT_SIZE_LP
  A = INSTR(0, S$, "\")
  IF -1 == A THEN A$=S$: S$="" ELSE A$=MID$(S$,0,A): S$=MID$(S$,A + 1,LEN(S$)-A-1)
  CW = CW + LEN(A$)
  IF A == -1 THEN @_PRINT_SIZE_LE
  IF CW > CLIPCW THEN CH = CH +  FLOOR(CW / CLIPCW): CW = CW % CLIPCW: MAX_CW = CLIPCW
  IF CW > MAX_CW THEN MAX_CW = CW
  IF LEN(S$) < 1 THEN CW = CW + 1: GOTO @_PRINT_SIZE_LE
  A$ = MID$(S$, 0, 1)
  S$ = MID$(S$, 1, LEN(S$) - 1)

  IF A$ == "\" THEN CW = CW + 1: GOTO @_PRINT_SIZE_LE
  IF A$ == "[" THEN GOSUB @_PRINT_SIZE_PA: GOTO @_PRINT_SIZE_LE
  IF A$ == "x" OR A$ == "X" THEN CW = CW + 1: S$ = MID$(S$, 2, LEN(S$) - 2): GOTO @_PRINT_SIZE_LE
  IF A$ == "c" THEN S$ = MID$(S$, 1, LEN(S$) - 1): GOTO @_PRINT_SIZE_LE
  IF A$ == "C" THEN S$ = MID$(S$, 1, LEN(S$) - 1): GOTO @_PRINT_SIZE_LE
  IF A$ == "N" THEN GOSUB @_PRINT_SIZE_CHRN: GOTO @_PRINT_SIZE_LE
  IF A$ == "n" THEN GOSUB @_PRINT_SIZE_NL: GOTO @_PRINT_SIZE_LE
  IF A$ == "t" THEN CW = FLOOR((CW + TABSTEP) / TABSTEP) * TABSTEP: GOTO @_PRINT_SIZE_LP
  IF A$ == "0" THEN @_PRINT_SIZE_LE
  CW = CW + 2
@_PRINT_SIZE_LE
  IF CW > CLIPCW THEN CH = CH +  FLOOR(CW / CLIPCW): CW = CW % CLIPCW: MAX_CW = CLIPCW
  IF CW > MAX_CW THEN MAX_CW = CW
  IF S$ != "" THEN @_PRINT_SIZE_LP

  IF CW != 0 THEN CH = CH + 1

  RR$[0] = STR$(MAX_CW)
  RR$[1] = STR$(CH)

  GOSUB @POP_R: MAX_CW = R
  GOSUB @POP_R: CH = R
  GOSUB @POP_R: CW = R
  GOSUB @POP_RS: PARAM$ = R$
  GOSUB @POP_RS: S$ = R$
  GOSUB @POP_R: CLIPCW = R
  
  ARGNUM = 3: GOSUB @CHECK_BP
  GOSUB @POP_R
  SP = BP
  BP = R
  RN = 2
  RETURN

@_PRINT_SIZE_CHRN
  A = INSTR(0, S$, "]")
  IF A == -1 THEN RETURN
  CW = CW + 1
  S$ = MID$(S$, A + 1, LEN(S$) - A - 1)
  RETURN

@_PRINT_SIZE_PA
  A = INSTR(0, S$, "]")
  IF A == -1 THEN RETURN
  A$ = MID$(S$, 0, A)
  S$ = MID$(S$, A + 1, LEN(S$) - A - 1)
  A = VAL(A$)
  IF A < RN THEN CW = CW + LEN(RR$[A])
  RETURN

@_PRINT_SIZE_NL
  CW = CW + 1
  IF CW > MAX_CW AND CW <= CLIPCW THEN MAX_CW = CW
  CH = CH + 1
  CW = 0
  RETURN


@CON_CLS '(DISP: NUMBER): NONE
  R = BP
  GOSUB @PUSH_R
  BP = SP - 1 - 1

  R = DISP: GOSUB @PUSH_R
  R = I: GOSUB @PUSH_R

  DISP = VAL(STACK$[BP + 1])
  
  IF DISP != 0 THEN @_CON_CLS_L
  COLOR 0, 0
  FOR I = 0 TO  CLIP_CH[DISP] - 1
    LOCATE CLIP_CX[DISP], CLIP_CY[DISP] + I
    PRINT CHR$(0) * CLIP_CW[DISP]
  NEXT
  GOTO @_CON_CLS_1
@_CON_CLS_L
  FOR I = 0 TO  CLIP_CH[DISP] - 1
    PNLSTR CLIP_CX[DISP], CLIP_CY[DISP] + I, CHR$(0) * CLIP_CW[DISP], 0
  NEXT
@_CON_CLS_1
  FOR I = 0 TO CLIP_CH[DISP] - 1
    A$ = VIRTUAL_CON$[DISP, CLIP_CY[DISP] + I]
    A$ = SUBST$(A$, CLIP_CX[DISP] * 4, CLIP_CW[DISP] * 4, "0000" * CLIP_CW[DISP])
    VIRTUAL_CON$[DISP, CLIP_CY[DISP] + I] = A$
  NEXT

  LAST_CX[DISP] = CLIP_CX[DISP]
  LAST_CY[DISP] = CLIP_CY[DISP]
  LAST_DISP = DISP

  GOSUB @POP_R: I = R
  GOSUB @POP_R: DISP = R

  ARGNUM = 1: GOSUB @CHECK_BP
  GOSUB @POP_R
  SP = BP
  BP = R
  RETURN


'LABELed DATA must be ended by "".
@CON_PRINT_L '(L$:LABEL, PARAM$:SARRAY): NONE
  R = BP
  GOSUB @PUSH_R
  BP = SP - 1 - 2

  R$ = L$: GOSUB @PUSH_RS
  R$ = PARAM$: GOSUB @PUSH_RS
  R = I: GOSUB @PUSH_R
  R = N: GOSUB @PUSH_R
  R = RBP: GOSUB @PUSH_R
  RBP = SP + 1

  L$ = STACK$[BP + 1]
  PARAM$ = STACK$[BP + 2]

  RESTORE L$
  N = 0
@_CON_PRINT_L_1
  READ A$
  IF A$ == "" THEN @_CON_PRINT_L_1E
  R = 1: GOSUB @ADD_STACK
  STACK$[RBP + N] = A$
  N = N + 1
  GOTO @_CON_PRINT_L_1
@_CON_PRINT_L_1E

  FOR I = 0 TO N - 1
    R = LAST_DISP: GOSUB @PUSH_R
    R = LAST_CX[1]: GOSUB @PUSH_R
    R = LAST_CY[1]: GOSUB @PUSH_R
    R$ = STACK$[RBP + I]: GOSUB @PUSH_RS
    R$ = PARAM$: GOSUB @PUSH_RS
    GOSUB @CON_PRINT
  NEXT

  R = N: GOSUB @SUBTRACT_STACK
  GOSUB @POP_R: RBP = R
  GOSUB @POP_R: N = R
  GOSUB @POP_R: I = R
  GOSUB @POP_RS: PARAM$ = R$
  GOSUB @POP_RS: L$ = R$

  ARGNUM = 2: GOSUB @CHECK_BP
  GOSUB @POP_R
  SP = BP
  BP = R
  RETURN


'DISP: 0: Upper Display, 1: Lower Display.
@PUSH_CWIN '(DISP:NUMBER, CX:NUMBER, CY:NUMBER, CW:NUMBER, CH:NUMBER): NONE
  R = BP
  GOSUB @PUSH_R
  BP = SP - 1 - 5

  R = DISP: GOSUB @PUSH_R
  R = CX: GOSUB @PUSH_R
  R = CY: GOSUB @PUSH_R
  R = CW: GOSUB @PUSH_R
  R = CH: GOSUB @PUSH_R
  R = I: GOSUB @PUSH_R
  R = J: GOSUB @PUSH_R

  DISP = VAL(STACK$[BP + 1])
  CX = VAL(STACK$[BP + 2])
  CY = VAL(STACK$[BP + 3])
  CW = VAL(STACK$[BP + 4])
  CH = VAL(STACK$[BP + 5])

  R = BG_PAGE: GOSUB @PUSH_R
  BG_PAGE = DISP: BGPAGE DISP
  IF CWIN_SP + 1 + CH >= CWIN_STACK_LEN THEN @_PUSH_CWIN_ERROR
  CWIN_SP = CWIN_SP + 1 + CH
  FOR J = 0 TO CH - 1
    R$ = ""
    A$ = ""
    FOR I = 0 TO CW - 1
      R$ = R$ + MID$(VIRTUAL_CON$[DISP, CY + J], (CX + I) * 4, 4)
      BGREAD(0, CX + I, CY + J), A
      A$ = A$ + HEX$(A, 4)
    NEXT
    CWIN_STACK$[CWIN_SP - J - 1] = A$ + R$
  NEXT
  RR$[0] = STR$(DISP)
  RR$[1] = STR$(CX)
  RR$[2] = STR$(CY)
  RR$[3] = STR$(CW)
  RR$[4] = STR$(CH)
  RR$[5] = STR$(CLIP_CX[DISP])
  RR$[6] = STR$(CLIP_CY[DISP])
  RR$[7] = STR$(CLIP_CW[DISP])
  RR$[8] = STR$(CLIP_CH[DISP])
  RR$[9] = STR$(LAST_CX[DISP])
  RR$[10] = STR$(LAST_CY[DISP])
  RR$[11] = STR$(CON_COL[DISP])
  RR$[12] = STR$(CON_BG_COL[DISP])
  RR$[13] = STR$(LAST_DISP)
  RN = 14
  GOSUB @PUSH_RR
  GOSUB @POP_RS
  CWIN_STACK$[CWIN_SP] = R$
  GOSUB @POP_R: BG_PAGE = R: BGPAGE BG_PAGE

  GOSUB @POP_R: J = R
  GOSUB @POP_R: I = R
  GOSUB @POP_R: CH = R
  GOSUB @POP_R: CW = R
  GOSUB @POP_R: CY = R
  GOSUB @POP_R: CX = R
  GOSUB @POP_R: DISP = R

  ARGNUM = 5: GOSUB @CHECK_BP
  GOSUB @POP_R
  SP = BP
  BP = R
  RETURN

@_PUSH_CWIN_ERROR
  PRINT "Console Window: Stack Full!"
  STOP: RETURN


@POP_CWIN '(NONE): NONE
  R = BP
  GOSUB @PUSH_R
  BP = SP - 1 - 0

  R = DISP: GOSUB @PUSH_R
  R = CX: GOSUB @PUSH_R
  R = CY: GOSUB @PUSH_R
  R = CW: GOSUB @PUSH_R
  R = CH: GOSUB @PUSH_R
  R = I: GOSUB @PUSH_R
  R = J: GOSUB @PUSH_R

  IF CWIN_SP < 0 THEN @_POP_CWIN_ERROR
  R$ = CWIN_STACK$[CWIN_SP]
  GOSUB @PUSH_RS
  GOSUB @POP_RR
  DISP = VAL(RR$[0])
  CX = VAL(RR$[1])
  CY = VAL(RR$[2])
  CW = VAL(RR$[3])
  CH = VAL(RR$[4])
  CLIP_CX[DISP] = VAL(RR$[5])
  CLIP_CY[DISP] = VAL(RR$[6])
  CLIP_CW[DISP] = VAL(RR$[7])
  CLIP_CH[DISP] = VAL(RR$[8])
  LAST_CX[DISP] = VAL(RR$[9])
  LAST_CY[DISP] = VAL(RR$[10])
  CON_COL[DISP] = VAL(RR$[11])
  CON_BG_COL[DISP] = VAL(RR$[12])
  LAST_DISP = VAL(RR$[13])

  IF CWIN_SP - CH - 1 < -1 THEN @_POP_CWIN_ERROR
  R = BG_PAGE: GOSUB @PUSH_R
  BG_PAGE = DISP: BGPAGE DISP
  FOR J = 0 TO CH - 1
    R$ = MID$(CWIN_STACK$[CWIN_SP - J - 1], CW * 4, CW * 4)
    A$ = VIRTUAL_CON$[DISP, CY + J]
    A$ = SUBST$(A$, CX * 4, CW * 4, R$)
    VIRTUAL_CON$[DISP, CY + J] = A$
    A$ = MID$(CWIN_STACK$[CWIN_SP - J - 1], 0, CW * 4)
    FOR I = 0 TO CW - 1
      A = VAL("&H" + MID$(R$, I * 4, 4))
      IF DISP != 0 THEN @_POP_CWIN_1L
      COLOR FLOOR(A / 4096), FLOOR((A % 4096) / 256)
      LOCATE CX + I, CY + J
      PRINT CHR$(A % 256)
      GOTO @_POP_CWIN_1E
@_POP_CWIN_1L
      PNLSTR CX + I, CY + J, CHR$(A % 256), FLOOR(A / 4096)
@_POP_CWIN_1E
      BGPUT 0, CX + I, CY + J, MID$(A$, I * 4, 4)
    NEXT
  NEXT
  GOSUB @POP_R: BG_PAGE = R: BGPAGE BG_PAGE
  CWIN_SP = CWIN_SP - CH - 1

  GOSUB @POP_R: J = R
  GOSUB @POP_R: I = R
  GOSUB @POP_R: CH = R
  GOSUB @POP_R: CW = R
  GOSUB @POP_R: CY = R
  GOSUB @POP_R: CX = R
  GOSUB @POP_R: DISP = R

  ARGNUM = 0: GOSUB @CHECK_BP
  GOSUB @POP_R
  SP = BP
  BP = R
  RETURN

@_POP_CWIN_ERROR
  PRINT "Console Window: Out of Stack!"
  STOP: RETURN


'Returns RR$[0]: Character, RR$[1]: COLOR, RR$[2]: BG_COLOR.
@CON_CHK_R '(DISP:NUMBER, CX:NUMBER, CY:NUMBER): ARRAY
  R = BP
  GOSUB @PUSH_R
  BP = SP - 1 - 3

  R = DISP: GOSUB @PUSH_R
  R = CX: GOSUB @PUSH_R
  R = CY: GOSUB @PUSH_R

  DISP = VAL(STACK$[BP + 1])
  CX = VAL(STACK$[BP + 2])
  CY = VAL(STACK$[BP + 3])

  A = VAL("&H" + MID$(VIRTUAL_CON$[DISP, CY], CX * 4, 4))
  RR$[0] = CHR$(A % 256)
  RR$[1] = STR$(FLOOR(A / 4096))
  RR$[2] = STR$(FLOOR((A % 4096) / 256))
  RN = 3

  GOSUB @POP_R: CY = R
  GOSUB @POP_R: CX = R
  GOSUB @POP_R: DISP = R

  ARGNUM = 3: GOSUB @CHECK_BP
  GOSUB @POP_R
  SP = BP
  BP = R
  RT$ = "ARRAY"
  RETURN


@DRAW_CWIN_INIT '(NONE): NONE
  GOSUB @BGPAGE_U
  A$ = "0" + "F" * 7 + "F" * 8 * 7
  CHRSET "BGU" + STR$(FLOOR(CWIN_CHR_BG_TL / 256)), CWIN_CHR_BG_TL % 256, A$
  A$ = "F" * 8 * 8
  CHRSET "BGU" + STR$(FLOOR(CWIN_CHR_BG_T / 256)), CWIN_CHR_BG_T % 256, A$
  CHRSET "BGU" + STR$(FLOOR(CWIN_CHR_BG_L / 256)), CWIN_CHR_BG_L % 256, A$
  CHRSET "BGU" + STR$(FLOOR(CWIN_CHR_BG_C / 256)), CWIN_CHR_BG_C % 256, A$
  GOSUB @BGPAGE_L
  A$ = "0" + "F" * 7 + "F" * 8 * 7
  CHRSET "BGU" + STR$(FLOOR(CWIN_CHR_BG_TL / 256)), CWIN_CHR_BG_TL % 256, A$
  A$ = "F" * 8 * 8
  CHRSET "BGU" + STR$(FLOOR(CWIN_CHR_BG_T / 256)), CWIN_CHR_BG_T % 256, A$
  CHRSET "BGU" + STR$(FLOOR(CWIN_CHR_BG_L / 256)), CWIN_CHR_BG_L % 256, A$
  CHRSET "BGU" + STR$(FLOOR(CWIN_CHR_BG_C / 256)), CWIN_CHR_BG_C % 256, A$
  DRAW_CWIN_NOINIT = TRUE
  RETURN


@DRAW_CWIN '(DISP:NUMBER, LAYER:NUMBER, CX: NUMBER, CY: NUMBER, CW: NUMBER, CH:NUMBER): NONE
  R = BP
  GOSUB @PUSH_R
  BP = SP - 1 - 6

  R = DISP: GOSUB @PUSH_R
  R = LAYER: GOSUB @PUSH_R
  R = CX: GOSUB @PUSH_R
  R = CY: GOSUB @PUSH_R
  R = CW: GOSUB @PUSH_R
  R = CH: GOSUB @PUSH_R
  R = I: GOSUB @PUSH_R
  R = J: GOSUB @PUSH_R

  DISP = VAL(STACK$[BP + 1])
  LAYER = VAL(STACK$[BP + 2])
  CX = VAL(STACK$[BP + 3])
  CY = VAL(STACK$[BP + 4])
  CW = VAL(STACK$[BP + 5])
  CH = VAL(STACK$[BP + 6])

  IF CW < 2 OR CH < 2 THEN PRINT "CWIN must be larger than 2x2.": STOP: RETURN

  R = BG_PAGE: GOSUB @PUSH_R
  IF DRAW_CWIN_NOINIT != TRUE THEN GOSUB @DRAW_CWIN_INIT
  BG_PAGE = DISP: BGPAGE DISP

  FOR J = 0 TO CH - 1
    FOR I = 0 TO CW - 1
      A = CWIN_CHR_BG_C
      IF I == 0 THEN @_DRAW_CWIN_L
      IF I == CW - 1 THEN @_DRAW_CWIN_R
      IF J == 0 THEN A = CWIN_CHR_BG_T
      IF J == CH - 1 THEN A = CWIN_CHR_BG_T + NUM_TO_BIT[11]
      GOTO @_DRAW_CWIN_BP
@_DRAW_CWIN_L
      A = CWIN_CHR_BG_L
      IF J == 0 THEN A = CWIN_CHR_BG_TL
      IF J == CH - 1 THEN A = CWIN_CHR_BG_TL + NUM_TO_BIT[11]
      GOTO @_DRAW_CWIN_BP
@_DRAW_CWIN_R
      A = CWIN_CHR_BG_L + NUM_TO_BIT[10]
      IF J == 0 THEN A = CWIN_CHR_BG_TL + NUM_TO_BIT[10]
      IF J == CH - 1 THEN A = CWIN_CHR_BG_TL + NUM_TO_BIT[11] + NUM_TO_BIT[10]
      GOTO @_DRAW_CWIN_BP
@_DRAW_CWIN_BP
      BGPUT LAYER, CX + I, CY + J, A
    NEXT
  NEXT

  GOSUB @POP_R: BG_PAGE = R: BGPAGE BG_PAGE

  GOSUB @POP_R: J = R
  GOSUB @POP_R: I = R
  GOSUB @POP_R: CH = R
  GOSUB @POP_R: CW = R
  GOSUB @POP_R: CY = R
  GOSUB @POP_R: CX = R
  GOSUB @POP_R: LAYER = R
  GOSUB @POP_R: DISP = R

  ARGNUM = 6: GOSUB @CHECK_BP
  GOSUB @POP_R
  SP = BP
  BP = R
  RETURN


'== END STDLIB ==
