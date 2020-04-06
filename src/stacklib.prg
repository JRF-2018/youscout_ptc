'== BEGIN STACKLIB ==
@STACKLIB_INIT
STACKLIB_VER$ = "0.01" 'Time-stamp: <2013-02-13T17:52:38Z>
STACKLIB_URI$ = "http://jrf.cocolog-nifty.com/archive/ptc/stacklib.prg"

'STACKLIB provides basic functions like assembler language.
'Only in this library, the functions preserve registers as possible.
'
'Discriminate the following variables as 'registers' against normal ones:
'  A, A$, TMP, TMP$, TMP$[], R, R$, RR$[], RA$[], RN, RT$, RE$
'(and ARGNUM for BP trick.)
'
'Callee must preserve variables, but caller must reserve registers in use. 

'STACKLIB ハ アセンブラ=フウ ノ キソ=テキ カンスウ ヲ テイギ。
'コノ ライブラリ デ ノミ、カンスウ ハ ナルタケ レジスタ ヲ ホゾン。
'
'ツギ ノ ヘンスウ ヲ レジスタ ト イイ、クベツ=スル:
'  A, A$, TMP, TMP$, TMP$[], R, R$, RR$[], RA$[], RN, RT$, RE$
'(ソシテ ARGNUM、コレハ BP ヨウ。)
'
'ヨビダシ サキ ハ ヘンスウ ハ ホゾン=セヨ。
'デモ、レジスタ ハ ヨビダシ モト ガ タイヒ=セヨ。

A = 0              'Accumulator
A$ = ""            'Accumulator
TMP = 0            'Accumulator
TMP$ = ""          'Accumulator
IF TMP_LEN == 0 THEN TMP_LEN = 1024
DIM TMP$[TMP_LEN, 2]  'Accumulator

R = 0              'Register of Number
R$ = ""            'Register of String
IF RR_LEN == 0 THEN RR_LEN = 1024
DIM RR$[RR_LEN]    'Register of aRray
IF RA_LEN == 0 THEN RA_LEN = 1024
DIM RA$[RA_LEN, 2] 'Register of Assoc
RN = 0             'Register of the Number of aRray or Assoc
RE$ = ""           'Register of Error Message
RT$ = "NUMBER"     'Type of Register: "NUMBER", "STRING", "ARRAY", "ASSOC", "NONE", "ERROR"
IF STACK_LEN == 0 THEN STACK_LEN = 1024
DIM STACK$[STACK_LEN]
SP = -1            'Stack Pointer
BP = -1            'Base Pointer (is not a register, but a normal variable.)

'for @ENTER and @LEAVE
IF DEBUG == 0 THEN DEBUG = 0	   
ARGNUM = 0	   'Special register to check stack errors.
IF FSTACK_LEN == 0 THEN FSTACK_LEN = 256
DIM FSTACK$[FSTACK_LEN]
FSP = -1	   'for DEBUG


'PROVIDE "STACKLIB"
RETURN

@PUSH_R
  SP = SP + 1
  IF SP >= STACK_LEN THEN @_PUSH_R_ERROR
  STACK$[SP] = STR$(R)
  RETURN
@_PUSH_R_ERROR
  PRINT "Stack Full!"
  STOP: RETURN


@POP_R
  IF SP < 0 THEN @_POP_R_ERROR
  RT$ = "NUMBER"
  R = VAL(STACK$[SP])
  SP = SP - 1
  RETURN
@_POP_R_ERROR
  PRINT "Out of Stack!"
  STOP: RETURN


@PUSH_RS
  SP = SP + 1
  IF SP >= STACK_LEN THEN @_PUSH_RS_ERROR
  STACK$[SP] = R$
  RETURN
@_PUSH_RS_ERROR
  PRINT "Stack Full!"
  STOP: RETURN


@POP_RS
  IF SP < 0 THEN @_POP_RS_ERROR
  RT$ = "STRING"
  R$ = STACK$[SP]
  SP = SP - 1
  RETURN
@_POP_RS_ERROR
  PRINT "Out of Stack!"
  STOP: RETURN


@ESCAPE '(STRING): STRING
  GOSUB @PUSH_R
  R$ = A$
  GOSUB @PUSH_RS
  R = A
  GOSUB @PUSH_R
  A$ = STACK$[SP - 3]

  R$ = ""
  A = 0
  @_ESCAPE_LP_1
  R = INSTR(A, A$, "\")
  IF R == -1 THEN @_ESCAPE_LP_1L
  R$ = R$ + MID$(A$, A, R - A) + "\\"
  A = R + 1
  GOTO @_ESCAPE_LP_1
@_ESCAPE_LP_1L
  R$ = R$ + MID$(A$, A, LEN(A$) - A)
  A = 0
  A$ = R$
  R$ = ""
@_ESCAPE_LP_2
  R = INSTR(A, A$, ",")
  IF R == -1 THEN @_ESCAPE_LP_2L
  R$ = R$ + MID$(A$, A, R - A) + "\x" + HEX$(ASC(","), 2)
  A = R + 1
  GOTO @_ESCAPE_LP_2
@_ESCAPE_LP_2L
  R$ = R$ + MID$(A$, A, LEN(A$) - A)

  STACK$[SP - 3] = R$
  GOSUB @POP_R
  A = R
  GOSUB @POP_RS
  A$ = R$
  GOSUB @POP_R
  GOSUB @POP_RS
  RETURN


@UNESCAPE  '(STRING): STRING
  GOSUB @PUSH_R
  R$ = A$
  GOSUB @PUSH_RS
  R = A
  GOSUB @PUSH_R
  R$ = TMP$
  GOSUB @PUSH_RS
  A$ = STACK$[SP - 4]

  R$ = ""
  A = 0
@_UNESCAPE_LP
  R = INSTR(A, A$, "\")
  IF (R == -1) OR (R == LEN(A$) - 1) THEN @_UNESCAPE_LP_L
  R$ = R$ + MID$(A$, A, R - A)
  TMP$ = MID$(A$, R + 1, 1)
  A = R + 2
  IF TMP$ == "\" THEN R$ = R$ + "\": GOTO @_UNESCAPE_LP
  IF TMP$ == "0" THEN R$ = R$: GOTO @_UNESCAPE_LP
  IF TMP$ == "x" OR TMP$ == "X" THEN @_UNESCAPE_X
  R$ = R$ + "\" + TMP$
  GOTO @_UNESCAPE_LP
@_UNESCAPE_X
  IF A + 2 >= LEN(A$) THEN R$ = R$ + "\" + TMP$:GOTO @_UNESCAPE_LP
  R = INSTR("0123456789ABCDEFabcdef", MID$(A$, A + 1, 1))
  IF R < 0 THEN R$ = R$ + "\" + TMP$: GOTO @_UNESCAPE_LP
  IF R > 15 THEN R = R - 6
  R = R + 16 * INSTR("0123456789ABCDEFabcdef", MID$(A$, A, 1))
  IF R < 0 THEN R$ = R$ + "\" + TMP$: GOTO @_UNESCAPE_LP
  IF R > 15 * 16 THEN R = R - 6 * 16
  R$ = R$ + CHR$(R)
  A = A + 2
  GOTO @_UNESCAPE_LP
@_UNESCAPE_LP_L
  R$ = R$ + MID$(A$, A, LEN(A$) - A)

  STACK$[SP - 4] = R$
  GOSUB @POP_RS
  TMP$ = R$
  GOSUB @POP_R
  A = R
  GOSUB @POP_RS
  A$ = R$
  GOSUB @POP_R
  GOSUB @POP_RS
  RETURN
  

@PUSH_RR
  SP = SP + 1
  IF SP < STACK_LEN THEN @_PUSH_RR_1
  PRINT "Stack Full!"
  STOP: RETURN
@_PUSH_RR_1

  GOSUB @PUSH_R
  GOSUB @PUSH_RS
  R$ = RT$
  GOSUB @PUSH_RS
  R = A
  GOSUB @PUSH_R
  R$ = A$
  GOSUB @PUSH_RS

  R$ = ""
  IF RN <= 0 THEN @_PUSH_RR_E
  FOR A = 0 TO RN - 1
    GOSUB @PUSH_RS
    R$ = RR$[A]: GOSUB @PUSH_RS
    GOSUB @ESCAPE
    A$ = R$
    IF A$ == "" THEN A$ = "\0"
    GOSUB @POP_RS
    IF R$ != "" THEN R$ = R$ + ","
    R$ = R$ + A$
  NEXT
@_PUSH_RR_E
  STACK$[SP - 5]  = R$

  GOSUB @POP_RS
  A$ = R$
  GOSUB @POP_R
  A = R
  GOSUB @POP_RS
  RT$ = R$
  GOSUB @POP_RS
  GOSUB @POP_R
  RETURN


@POP_RR
  IF SP >= 0 THEN @_POP_RR_1
  PRINT "Out of Stack!"
  STOP: RETURN
@_POP_RR_1

  GOSUB @PUSH_R
  GOSUB @PUSH_RS
  R$ = RT$
  GOSUB @PUSH_RS
  R = A
  GOSUB @PUSH_R
  R$ = A$
  GOSUB @PUSH_RS

  R$ = STACK$[SP - 5]
  A = 0
  RN = 0
@_POP_RR_LP
  R = INSTR(A, R$, ",")
  IF R == -1 THEN @_POP_RR_LP_L
  IF RN + 1 >= RR_LEN THEN @_POP_RR_ERR
  GOSUB @PUSH_RS
  R$ = MID$(R$, A, R - A): GOSUB @PUSH_RS
  GOSUB @UNESCAPE
  RR$[RN] = R$
  RN = RN + 1
  A = R + 1
  GOSUB @POP_RS
  GOTO @_POP_RR_LP
@_POP_RR_LP_L
  IF RN + 1 >= RR_LEN THEN @_POP_RR_ERR
  R$ = MID$(R$, A, LEN(R$) - A)
  IF R$ == "" THEN @_POP_RR_E
  GOSUB @PUSH_RS
  GOSUB @UNESCAPE
  RR$[RN] = R$
  RN = RN + 1
@_POP_RR_E

  GOSUB @POP_RS
  A$ = R$
  GOSUB @POP_R
  A = R
  GOSUB @POP_RS
  RT$ = R$
  GOSUB @POP_RS
  GOSUB @POP_R
  RT$ = "ARRAY"
  SP = SP - 1
  RETURN

@_POP_RR_ERR
  PRINT "Exceed the limit of RR!"
  STOP: RETURN


@PUSH_RA
  SP = SP + 1
  IF SP < STACK_LEN THEN @_PUSH_RA_1
  PRINT "Stack Full!"
  STOP: RETURN
@_PUSH_RA_1

  GOSUB @PUSH_R
  GOSUB @PUSH_RS
  R$ = RT$
  GOSUB @PUSH_RS
  R = A
  GOSUB @PUSH_R
  R$ = A$
  GOSUB @PUSH_RS

  R$ = ""
  IF RN <= 0 THEN @_PUSH_RA_E
  FOR A = 0 TO RN - 1
    GOSUB @PUSH_RS
    R$ = RA$[A, 0]: GOSUB @PUSH_RS
    GOSUB @ESCAPE
    A$ = R$
    IF A$ == "" THEN A$ = "\0"
    GOSUB @POP_RS
    IF R$ != "" THEN R$ = R$ + ","
    R$ = R$ + A$

    GOSUB @PUSH_RS
    R$ = RA$[A, 1]: GOSUB @PUSH_RS
    GOSUB @ESCAPE
    A$ = R$
    IF A$ == "" THEN A$ = "\0"
    GOSUB @POP_RS
    R$ = R$ + "," + A$
  NEXT
@_PUSH_RA_E

  STACK$[SP - 5]  = R$
  GOSUB @POP_RS
  A$ = R$
  GOSUB @POP_R
  A = R
  GOSUB @POP_RS
  RT$ = R$
  GOSUB @POP_RS
  GOSUB @POP_R
  RETURN


@POP_RA
  IF SP >= 0 THEN @_POP_RA_1
  PRINT "Out of Stack!"
  STOP: RETURN
@_POP_RA_1

  GOSUB @PUSH_R
  GOSUB @PUSH_RS
  R$ = RT$
  GOSUB @PUSH_RS
  R = A
  GOSUB @PUSH_R
  R$ = A$
  GOSUB @PUSH_RS

  R$ = STACK$[SP - 5]
  A = 0
  RN = 0
@_POP_RA_LP
  R = INSTR(A, R$, ",")
  IF R == -1 THEN @_POP_RA_LP_L
  IF (FLOOR(RN / 2) + 1) >= RA_LEN THEN @_POP_RA_ERR
  GOSUB @PUSH_RS
  R$ = MID$(R$, A, R - A): GOSUB @PUSH_RS
  GOSUB @UNESCAPE
  RA$[FLOOR(RN / 2), RN % 2] = R$
  RN = RN + 1
  A = R + 1
  GOSUB @POP_RS
  GOTO @_POP_RA_LP
@_POP_RA_LP_L
  IF FLOOR(RN / 2) + 1 >= RA_LEN THEN @_POP_RA_ERR
  IF LEN(R$) == A THEN @_POP_RA_E
  RA$[FLOOR(RN / 2), RN % 2] = MID$(R$, A, LEN(R$) - A)
  RN = RN + 1
  IF (RN % 2) != 0 THEN RA$[FLOOR(RN / 2), 1] = ""

 @_POP_RA_E
  RN = FLOOR(RN / 2)

  GOSUB @POP_RS
  A$ = R$
  GOSUB @POP_R
  A = R
  GOSUB @POP_RS
  RT$ = R$
  GOSUB @POP_RS
  GOSUB @POP_R
  RT$ = "ASSOC"
  SP = SP - 1
  RETURN

@_POP_RA_ERR
  PRINT "Exceed the limit of RA!"
  STOP: RETURN


@GET_RA '(KEY$: STRING): STRING
  GOSUB @PUSH_R
  R$ = A$
  GOSUB @PUSH_RS

  A$ = STACK$[SP - 2]

  R = 0
@_GET_RA_LP
  IF R >= RN GOTO @_GET_RA_E
  IF RA$[R, 0] == A$ GOTO @_GET_RA_1
  R = R + 1
  GOTO @_GET_RA_LP
@_GET_RA_E

  GOSUB @POP_RS
  A$ = R$
  GOSUB @POP_R
  GOSUB @POP_RS
  RT$ = "NONE"
  R$ = ""
  RETURN

@_GET_RA_1
  STACK$[SP - 2] = RA$[R, 1]
  GOSUB @POP_RS
  A$ = R$
  GOSUB @POP_R
  GOSUB @POP_RS
  RETURN


@SET_RA '(KEY$:STRING, VALUE$:STRING): NONE
  GOSUB @PUSH_RS
  GOSUB @PUSH_R
  R$ = A$
  GOSUB @PUSH_RS

  A$ = STACK$[SP - 4]

  R = 0
@_SET_RA_LP
  IF R >= RN THEN @_SET_RA_LPE
  IF RA$[R, 0] == A$ GOTO @_SET_RA_1
  R = R + 1
  GOTO @_SET_RA_LP  
@_SET_RA_LPE
  IF (RN + 1) < RA_LEN THEN @_SET_RA_2
  PRINT "Exceed the limit of RA!"
  STOP: RETURN

@_SET_RA_2
  R = RN
  RN = RN + 1
  RA$[R, 0] = A$
@_SET_RA_1
  RA$[R, 1] = STACK$[SP - 3]

  GOSUB @POP_RS
  A$ = R$
  GOSUB @POP_R
  GOSUB @POP_RS
  IF SP > 1 THEN STACK$[SP - 1] = R$
  GOSUB @POP_RS
  GOSUB @POP_RS
  RETURN


'Delete the (first) key, and return its value or NONE.

@DELETE_RA '(KEY$: STRING): STRING
  GOSUB @PUSH_RS
  GOSUB @PUSH_R
  R$ = A$
  GOSUB @PUSH_RS

  A$ = STACK$[SP - 3]

  A = 0
  R = 0
@_DELETE_RA_LP
  IF A >= RN THEN @_DELETE_RA_E
  IF TMP == 0 AND RA$[A, 0] == A$ THEN TMP = 1: A$ = RA$[A, 1]: GOTO @_DELETE_RA_LP_1
  RA$[R, 0] = RA$[A, 0]
  RA$[R, 1] = RA$[A, 1]
  R = R + 1
@_DELETE_RA_LP_1
  A = A + 1
  GOTO @_DELETE_RA_LP

@_DELETE_RA_E
  RN = R
  IF A == R THEN @_DELETE_RA_N
  STACK$[SP - 3] = A$

  GOSUB @POP_RS
  A$ = R$
  GOSUB @POP_R
  GOSUB @POP_RS
  GOSUB @POP_RS
  RETURN

@_DELETE_RA_N
  GOSUB @POP_RS
  A$ = R$
  GOSUB @POP_R
  GOSUB @POP_RS
  IF SP >= 0 THEN STACK$[SP] = R$
  GOSUB @POP_RS
  RT$ = "NONE"
  RETURN


@CLEAR_REGISTERS
  FOR R = 0 TO RR_LEN - 1
    RR$[R] = ""
  NEXT
  FOR R = 0 TO RA_LEN - 1
    RA$[R, 0] = ""
    RA$[R, 1] = ""
  NEXT
  FOR R = 0 TO TMP_LEN - 1
    TMP$[R, 0] = ""
    TMP$[R, 1] = ""
  NEXT
  R = 0
  R$ = ""
  RN = 0
  TMP = 0
  TMP$ = ""
  A = 0
  A$ = ""
  RT$ = "NONE"
  RE$ = ""
  RETURN


@ADD_STACK '()with(R:NUMBER): NONE
  IF SP + R >= STACK_LEN THEN @_ADD_STACK_ERR
  SP = SP + R
  RETURN
@_ADD_STACK_ERR
  PRINT "Stack Full!"
  STOP: RETURN


@SUBTRACT_STACK '()with(R:NUMBER): NONE
  IF SP - R < -1 THEN @_SUB_STACK_ERR
  SP = SP - R
  RETURN
@_SUB_STACK_ERR
  PRINT "Out of Stack!"
  STOP: RETURN


'By @ENTER, set BP for accessing the arguments,
'and reserve the function name to FSTACK$[] for debugging.

'@ENTER デ、ヒキスウ ノ サンショウ ノ タメ BP ヲ セッテイシ、
'デバッグ ノ タメ カンスウ メイ ヲ FSTACK$[] ニ ホゾン。

'Get R$ as a function name and ARGNUM.
@ENTER
  IF DEBUG == 0 THEN @_ENTER_NDB
  FSP = FSP + 1
  IF FSP >= FSTACK_LEN THEN @_ENTER_ERROR
  FSTACK$[FSP] = R$ + ", SP == " + STR$(SP)
@_ENTER_NDB
  SWAP R, BP
  GOSUB @PUSH_R
  SWAP R, BP
  BP = SP - 1 - ARGNUM
  RETURN

@_ENTER_ERROR
  PRINT "Function Stack Full!"
  STOP: RETURN


'By @LEAVE, reset BP and consume stack for the arguments.

'@LEAVE デ、BP ヲ モト ニ モドシ、ヒキスウ=ヨウ ノ STACK$ ヲ ヨミトバス。

'Get ARGNUM.
@LEAVE
  IF DEBUG == 0 THEN @_LEAVE_NDB
  GOSUB @CHECK_BP
  IF FSP < 0 THEN @_LEAVE_ERRF
  FSP = FSP - 1
@_LEAVE_NDB
  IF SP < 0 THEN @_LEAVE_ERRS
  SWAP SP, BP
  BP = VAL(STACK$[BP])
  RETURN

@_LEAVE_ERRS
  PRINT "Out of Stack!"
  STOP: RETURN
@_LEAVE_ERRF
  PRINT "Out of Function Stack!"
  STOP: RETURN


@CHECK_BP
  IF BP == SP - 1 - ARGNUM THEN RETURN
  PRINT "Stack don't meet!"
  STOP: RETURN


'== END STACKLIB ==
