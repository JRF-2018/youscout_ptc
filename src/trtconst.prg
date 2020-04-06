'== BEGIN TRTCONST ==
@TRTCONST_INIT
TRTCONST_VER$ = "0.04" 'Time-stamp: <2013-02-28T16:01:22Z>
TRTCONST_URI$ = "http://jrf.cocolog-nifty.com/archive/youscout/ptc/trtconst.prg"

'REQUIRE "STDLIB"

TAROT_NAME$ = "JRFTAROT"
TAROT_BASE$ = "JRFTRT" 'Tarot base name.
CARD_WIDTH = 36
CARD_HEIGHT = 56
BOARD_RGB$ = "10431F"
COL_BOARD = 255

COL_S = 2: COL_D = 3: COL_H = 4: COL_C = 5
COL_WHITE = 15: COL_BLACK = 14: COL_GREY = 1: COL_DARK_GREY = 7
COL_BLUE = COL_S: COL_GOLD = COL_D: COL_RED = COL_H: COL_GREEN = COL_C

BG_ALP_DATA_LEN = 5
DIM BG_ALP_DATA$[BG_ALP_DATA_LEN]
BG_ALP_DATA$[0] =  "A": BG_ALP_DATA$[1] =  "J": BG_ALP_DATA$[2] =  "C"
BG_ALP_DATA$[3] =  "Q": BG_ALP_DATA$[4] =  "K"

BG_SUIT_DATA_LEN = 6
DIM BG_SUIT_DATA_N$[BG_SUIT_DATA_LEN]
DIM BG_SUIT_DATA_C[BG_SUIT_DATA_LEN]
BG_SUIT_DATA_N$[0] = "CIRCLE": BG_SUIT_DATA_N$[1] = "BOX"
BG_SUIT_DATA_N$[2] = "SPADE": BG_SUIT_DATA_N$[3] = "DIA"
BG_SUIT_DATA_N$[4] = "HEART": BG_SUIT_DATA_N$[5] = "CLUB"
BG_SUIT_DATA_C[0] = 14: BG_SUIT_DATA_C[1] = 14: BG_SUIT_DATA_C[2] = 2
BG_SUIT_DATA_C[3] = 3: BG_SUIT_DATA_C[4] = 4: BG_SUIT_DATA_C[5] = 5

CHAR_LOGO_LEN = 3
DIM CHAR_LOGO$[CHAR_LOGO_LEN]
CHAR_LOGO$[0] = "@CHAR_EKI": CHAR_LOGO$[1] = "@CHAR_SOU": CHAR_LOGO$[2] = "@CHAR_ROKU"
LOGO_STR_EN$ = "Youscout": LOGO_STR_JA$ = "ヨウスコウ"
LOGO_SUB_STR$ = CHR$(160) + " Tarot Solitaire " + CHR$(160)

BGU1_NUM_OFFSET = 0
BGU1_ALP_OFFSET = 22

BGU1_SUIT_OFFSET = BGU1_ALP_OFFSET + BG_ALP_DATA_LEN: A = BGU1_SUIT_OFFSET '== 27
BGU1_SUIT_CIRCLE = 0 + A: BGU1_SUIT_BOX = 1 + A: BGU1_SUIT_S = 2 + A
BGU1_SUIT_D = 3 + A: BGU1_SUIT_H = 4 + A: BGU1_SUIT_C = 5 + A

'WHite CarD with no picture.
BGU1_WHCD_OFFSET = BGU1_SUIT_OFFSET  + BG_SUIT_DATA_LEN: A = BGU1_WHCD_OFFSET '== 33
BGU1_WHCD_C = 0 + A: BGU1_WHCD_TL = 1 + A: BGU1_WHCD_T = 2 + A
BGU1_WHCD_TR = 3 + A: BGU1_WHCD_L = 4 + A: BGU1_WHCD_R = 5 + A
BGU1_WHCD_BL = 6 + A: BGU1_WHCD_B = 7 + A: BGU1_WHCD_BR = 8 + A
BGU1_WHCD_TLP = 9 + A 'Top Left Point
BGU1_WHCD_TRP = 10 + A 'Bottom Left Point
BGU1_WHCD_BLP = 11 + A 'Bottom Left Point
BGU1_WHCD_TLWP = 12 + A 'Top Left with Point
BGU1_WHCD_TRWP = 13 + A 'Top Left with Point
BGU1_WHCD_BLWP = 14 + A 'Bottom Left with Point

DRAW_CWIN_NOINIT = TRUE
CWIN_CHR_BG_TL = 256 + BGU1_WHCD_TL: CWIN_CHR_BG_T = 256 + BGU1_WHCD_T
CWIN_CHR_BG_L = 256 + BGU1_WHCD_L: CWIN_CHR_BG_C = 256 + BGU1_WHCD_C

'ReD frame LiNe
BGU1_RDLN_OFFSET = BGU1_WHCD_OFFSET + 15: A = BGU1_RDLN_OFFSET '== 48
BGU1_RDLN_TL = 0 + A: BGU1_RDLN_T = 1 + A: BGU1_RDLN_L = 2 + A

'SoRoBaN
BGU1_SRBN_OFFSET = BGU1_RDLN_OFFSET  + 3: A = BGU1_SRBN_OFFSET '== 51
BGU1_SRBN_TAMAL = 0 + A: BGU1_SRBN_TAMAR = 1 + A: BGU1_SRBN_HARI = 2 + A
BGU1_SRBN_TEN = 3 + A: BGU1_SRBN_JIKUL = 4 + A: BGU1_SRBN_JIKUR = 5 + A
BGU1_SRBN_TL = 6 + A: BGU1_SRBN_T = 7 + A: BGU1_SRBN_TR = 8 + A
BGU1_SRBN_L = 9 + A: BGU1_SRBN_R = 10 + A: BGU1_SRBN_BL = 11 + A
BGU1_SRBN_B = 12 + A: BGU1_SRBN_BR = 13 + A

PM_SRBN_KADO$ = "@SOROBAN_KADO": PM_SRBN_WAKU$ = "@SOROBAN_WAKU"
PM_SRBN_JIKU$ = "@SOROBAN_JIKU": PM_SRBN_TAMA$ = "@SOROBAN_TAMA"
PM_SRBN_HARI$ = "@SOROBAN_HARI": PM_SRBN_TEN$ = "@SOROBAN_TEN"

'MISC Pixmaps
PM_TOKEN$ = "@YSCTOKEN"
PM_B00$ = "@" + TAROT_NAME$ + "_B00"
PM_DISCARDED$ = "@" + TAROT_NAME$ + "_DSC"
PM_TALON$ = "@" + TAROT_NAME$ + "_TLN"
PM_A00$ = "@" + TAROT_NAME$ + "_A00"
PM_A13$ = "@" + TAROT_NAME$ + "_A13"
PM_DISCARDED_W = 56
PM_DISCARDED_H = 56
PM_TALON_W = 43 'originally 44.
PM_TALON_H = 64 'originally 65.
PM_TOKEN_W = 32
PM_TOKEN_H = 32
'BGPL_TOKEN = 15
SPPL_TOKEN = 15
BGPL_B00 = 13
SPPL_B00 = 13
BGPL_DISCARDED = 12 'or 14
SPPL_DISCARDED = 12 'or 14
SPPL_A00 = 11
SPPL_A13 = 10
BGU1_MINI_CD = BGU1_SRBN_OFFSET + 14
BGU1_B00 = BGU1_MINI_CD + 1
BGU1_A00 = BGU1_B00 + 5 * 7
BGU1_A13 = BGU1_A00 + 5 * 7
BGU1_DISCARDED = BGU1_A13 + 5 * 7
BGU1_TOKEN = BGU1_DISCARDED + 7 * 7
BGU1_MISC_END = BGU1_TOKEN + 4 * 4
SPU7_B00 = 0
SPU7_A00 = SPU7_B00 + 8 * 8
SPU7_A13 = SPU7_A00 + 8 * 8
SPU7_TOKEN = SPU7_A13 + 8 * 8
SPU7_RDLN_TL = SPU7_TOKEN + 4 * 4
SPU7_RDLN_T = SPU7_RDLN_TL + 4 * 4
SPU7_NONE = SPU7_RDLN_T + 4
SPU7_END = SPU7_NONE + 4

SPU6_CDTL_S_OFS = 0
SPU6_CDTL_D_OFS = SPU6_CDTL_S_OFS + 14 * 4
SPU6_CDTL_H_OFS = SPU6_CDTL_D_OFS + 14 * 4
SPU6_CDTL_C_OFS = SPU6_CDTL_H_OFS + 14 * 4
SPU6_END = SPU6_CDTL_C_OFS + 14 * 4
SPU4_CDSTR_OFS = 0
SPU4_CDSBL_OFS = SPU4_CDSTR_OFS + 2 * 4 * 2
SPU4_RDLN_CD = SPU4_CDSBL_OFS + 4 * 4 * 8
SPU4_END = SPU4_RDLN_CD + 8 * 8

SPU5_WHCD = 0 * 64
SPU5_WHCD_PTL = 1 * 64
SPU5_WHCD_PT = 2 * 64
SPU5_WHCD_PL = 3 * 64
SPU5_END = 4 * 64

IF BGU1_MISC_END > 256 THEN PRINT "Too many BG CHR!": STOP: RETURN
IF SPU7_END > 256 THEN PRINT "Too many SPU CHR!": STOP: RETURN
IF SPU6_END > 256 THEN PRINT "Too many SPU CHR!": STOP: RETURN
IF SPU5_END > 256 THEN PRINT "Too many SPU CHR!": STOP: RETURN
IF SPU4_END > 256 THEN PRINT "Too many SPU CHR!": STOP: RETURN

GRP_ROWS = 3
GRP_FILE_A$ = TAROT_BASE$ + "_A" 'Major Arcana except A00 and A13
GRP_FILE_R$ = TAROT_BASE$ + "_R" 'Reversal Major Arcana
GRP_FILE_S$ = TAROT_BASE$ + "_S"
GRP_FILE_D$ = TAROT_BASE$ + "_D"
GRP_FILE_H$ = TAROT_BASE$ + "_H"
GRP_FILE_C$ = TAROT_BASE$ + "_C"
GRP_FILE_RS$ = TAROT_BASE$ + "RS"
GRP_FILE_RD$ = TAROT_BASE$ + "RD"
GRP_FILE_RH$ = TAROT_BASE$ + "RH"
GRP_FILE_RC$ = TAROT_BASE$ + "RC"
CHR_FILE_B$ = TAROT_BASE$ + "_B" 'BG
GRP_FILE_T$ = TAROT_BASE$ + "_T" 'Title background.
CHR_FILE_S4$ = TAROT_BASE$ + "S4" 'SP
CHR_FILE_S5$ = TAROT_BASE$ + "S5" 'SP
CHR_FILE_S6$ = TAROT_BASE$ + "S6" 'SP
CHR_FILE_S7$ = TAROT_BASE$ + "S7" 'SP
GRP_S_B00 = 5 * GRP_ROWS + 0
GRP_S_DISCARDED = 5 * GRP_ROWS + 1
GRP_S_TALON = 5 * GRP_ROWS + 2
GRP_D_A00 = 5 * GRP_ROWS + 0
GRP_D_A13 = 5 * GRP_ROWS + 1

'PROVIDE "TRTCONST"
RETURN


'== END TRTCONST ==