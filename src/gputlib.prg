'== BEGIN GPUTLIB ==
@GPUTLIB_INIT
GPUTLIB_VER$ = "0.01" 'Time-stamp: <2013-02-11T19:40:04Z>
GPUTLIB_URI$ = "http://jrf.cocolog-nifty.com/archive/ptc/gputlib.prg"

'REQUIRE "STDLIB"

IF MAP_LEN == 0 THEN MAP_LEN = 16
DIM MAP[MAP_LEN] 'for temporary mapping.

'PROVIDE "GPUTLIB"
RETURN


'REV: Put reversally right to left if REV is 1, normally if REV is 0 .
'ROT: Rotation. ROT must be 0, 90, 180, or 270.
@G_PUT_PM '(X:NUMBER, Y:NUMBER, LABEL$:STRING, REV:NUMBER, ROT:NUMBER): NONE
  R = BP
  GOSUB @PUSH_R
  BP = SP - 1 - 5

  R = X: GOSUB @PUSH_R
  R = Y: GOSUB @PUSH_R
  R$ = LABEL$: GOSUB @PUSH_RS
  R = REV: GOSUB @PUSH_R
  R = ROT: GOSUB @PUSH_R
  R = W: GOSUB @PUSH_R
  R = H: GOSUB @PUSH_R
  R = I: GOSUB @PUSH_R
  R = J: GOSUB @PUSH_R
  R$ = L$: GOSUB @PUSH_RS
  FOR I=0 TO 16 - 1
    RR$[I] = STR$(MAP[I])
  NEXT
  RN = 16
  GOSUB @PUSH_RR

  X = VAL(STACK$[BP + 1])
  Y = VAL(STACK$[BP + 2])
  LABEL$ = STACK$[BP + 3]
  REV = VAL(STACK$[BP + 4])
  ROT = VAL(STACK$[BP + 5])

  RESTORE LABEL$ + "_PL"
  FOR I=0 TO 16 - 1
    READ A$
    IF A$ == "" THEN @_G_PUT_PM_1
    FOR J=0 TO 256 - 1
      IF A$ == CMAP$[J] THEN MAP[I] = J
    NEXT
@_G_PUT_PM_1
  NEXT

  RESTORE LABEL$ + "_SZ"
  READ W, H
  RESTORE LABEL$ + "_PM"

  IF ROT == 0 THEN @_G_PUT_PM_N90
  IF ROT != 270 THEN @_G_PUT_PM_N270
  FOR J = 0 TO H - 1
    READ L$
    IF REV THEN R$=L$: GOSUB @PUSH_RS: GOSUB @REVERSE_S: L$ = R$
    FOR I = 0 TO W - 1
      A = VAL("&H" + MID$(L$, I, 1))
      IF A == 0 THEN @_G_PUT_PM_270A
      GPSET Y + J, X + W - I - 1, MAP[A]
@_G_PUT_PM_270A
    NEXT
  NEXT

  GOTO @_G_PUT_PM_END
@_G_PUT_PM_N270
  IF ROT != 180 THEN @_G_PUT_PM_N180
  FOR J = 0 TO H - 1
    READ L$
    IF REV THEN R$=L$: GOSUB @PUSH_RS: GOSUB @REVERSE_S: L$ = R$
    FOR I = 0 TO W - 1
      A = VAL("&H" + MID$(L$, I, 1))
      IF A == 0 THEN @_G_PUT_PM_180A
      GPSET X + W - I - 1, Y + H - J - 1, MAP[A]
@_G_PUT_PM_180A
    NEXT
  NEXT

  GOTO @_G_PUT_PM_END
@_G_PUT_PM_N180
  IF ROT != 90 THEN @_G_PUT_PM_N90
  FOR J = 0 TO H - 1
    READ L$
    IF REV THEN R$=L$: GOSUB @PUSH_RS: GOSUB @REVERSE_S: L$ = R$
    FOR I = 0 TO W - 1
      A = VAL("&H" + MID$(L$, I, 1))
      IF A == 0 THEN @_G_PUT_PM_90A
      GPSET Y + H - J - 1, X + I, MAP[A]
@_G_PUT_PM_90A
    NEXT
  NEXT

  GOTO @_G_PUT_PM_END
@_G_PUT_PM_N90
  FOR J = 0 TO H - 1
    READ L$
    IF REV THEN R$=L$: GOSUB @PUSH_RS: GOSUB @REVERSE_S: L$ = R$
    FOR I = 0 TO W - 1
      A = VAL("&H" + MID$(L$, I, 1))
      IF A == 0 THEN @_G_PUT_PM_0A
      GPSET X + I, Y + J, MAP[A]
@_G_PUT_PM_0A
    NEXT
  NEXT

@_G_PUT_PM_END

  GOSUB @POP_RR
  FOR I=0 TO RN - 1
    MAP[I] = VAL(RR$[I])
  NEXT
  GOSUB @POP_RS: L$ = R$
  GOSUB @POP_R: J = R
  GOSUB @POP_R: I = R
  GOSUB @POP_R: H = R
  GOSUB @POP_R: W = R
  GOSUB @POP_R: ROT = R
  GOSUB @POP_R: REV = R
  GOSUB @POP_RS: LABEL$ = R$
  GOSUB @POP_R: Y = R
  GOSUB @POP_R: X = R

  ARGNUM = 5: GOSUB @CHECK_BP
  GOSUB @POP_R
  SP = BP
  BP = R
  RETURN


'COL: color number: 0 -- 255
'REV: currently ignored
'ROT: currently ignored
@G_PUT_BM '(X:NUMBER, Y:NUMBER, COL:NUMBER, LABEL$:STRING, REV:NUMBER, ROT:NUMBER): NONE
  R = BP
  GOSUB @PUSH_R
  BP = SP - 1 - 6

  R = X: GOSUB @PUSH_R
  R = Y: GOSUB @PUSH_R
  R = COL: GOSUB @PUSH_R
  R$ = LABEL$: GOSUB @PUSH_RS
'  R = REV: GOSUB @PUSH_R
'  R = ROT: GOSUB @PUSH_R
  R = W: GOSUB @PUSH_R
  R = H: GOSUB @PUSH_R
  R = I: GOSUB @PUSH_R
  R = J: GOSUB @PUSH_R
  R$ = L$: GOSUB @PUSH_RS

  X = VAL(STACK$[BP + 1])
  Y = VAL(STACK$[BP + 2])
  COL = VAL(STACK$[BP + 3])
  LABEL$ = STACK$[BP + 4]
'  REV = VAL(STACK$[BP + 5])
'  ROT = VAL(STACK$[BP + 6])

  RESTORE LABEL$ + "_SZ"
  READ W, H
  RESTORE LABEL$ + "_BM"
  FOR J = 0 TO H - 1
    READ L$
    FOR I = 0 TO W - 1
      IF I % 4 == 0 THEN A = VAL("&H" + MID$(L$, FLOOR(I / 4), 1))
      IF (NUM_TO_BIT[3 - I % 4] AND A) != 0 THEN GPSET X + I, Y + J, COL
    NEXT
  NEXT

  GOSUB @POP_RS: L$ = R$
  GOSUB @POP_R: J = R
  GOSUB @POP_R: I = R
  GOSUB @POP_R: H = R
  GOSUB @POP_R: W = R
'  GOSUB @POP_R: ROT = R
'  GOSUB @POP_R: REV = R
  GOSUB @POP_RS: LABEL$ = R$
  GOSUB @POP_R: COL = R
  GOSUB @POP_R: Y = R
  GOSUB @POP_R: X = R

  ARGNUM = 6: GOSUB @CHECK_BP
  GOSUB @POP_R
  SP = BP
  BP = R
  RETURN

'COL: color number: 0 -- 15
'X,Y: relative start point like BGOFS.
@BM_TO_CHR '(LABEL$:STRING, COL:NUMBER, X:NUMBER, Y:NUMBER): STRING
  R = BP
  GOSUB @PUSH_R
  BP = SP - 1 - 4

  R$ = LABEL$: GOSUB @PUSH_RS
  R = COL: GOSUB @PUSH_R
  R = X: GOSUB @PUSH_R
  R = Y: GOSUB @PUSH_R
  R = I: GOSUB @PUSH_R
  R = J: GOSUB @PUSH_R
  R = W: GOSUB @PUSH_R
  R = H: GOSUB @PUSH_R
  R$ = L$: GOSUB @PUSH_RS
  R$ = COL$: GOSUB @PUSH_RS

  LABEL$ = STACK$[BP + 1]
  COL = VAL(STACK$[BP + 2])
  X = VAL(STACK$[BP + 3])
  Y = VAL(STACK$[BP + 4])

  COL$ = HEX$(COL % 16, 1)
'  X = -X
'  Y = -Y

  RESTORE LABEL$ + "_SZ"
  READ W, H

  RESTORE LABEL$ + "_BM"

  FOR J = 0 TO H - 1
    READ L$
    A$ = ""
    FOR I = 0 TO W - 1
      IF I % 4 == 0 THEN A = VAL("&H" + MID$(L$, FLOOR(I / 4), 1))
      IF (NUM_TO_BIT[3 - I % 4] AND A) != 0 THEN A$ = A$ + COL$ ELSE A$ = A$ + "0"
    NEXT
    RR$[J] = A$
  NEXT

  R$ = ""
  FOR J = 0 TO 8 - 1
    FOR I = 0 TO 8 - 1
      A = (X + I >= 0 AND X + I < W) AND (Y + J >= 0 AND Y + J < H)
      IF A THEN A$ = MID$(RR$[Y + J], X + I, 1) ELSE A$ = "0"
      R$ = R$ + A$
    NEXT
  NEXT

  A$ = R$

  GOSUB @POP_RS: COL$ = R$
  GOSUB @POP_RS: L$ = R$
  GOSUB @POP_R: H = R
  GOSUB @POP_R: W = R
  GOSUB @POP_R: J = R
  GOSUB @POP_R: I = R
  GOSUB @POP_R: Y = R
  GOSUB @POP_R: X = R
  GOSUB @POP_R: COL = R
  GOSUB @POP_RS: LABEL$ = R$

  ARGNUM = 4: GOSUB @CHECK_BP
  GOSUB @POP_R
  SP = BP
  BP = R
  RT$ = "STRING"
  R$ = A$
  RETURN

'BW,BH: Block Width/Height or width/height in Console axis.
@PM_TO_CHR_R '(LABEL$:STRING, BW:NUMBER, BH:NUMBER): STRING
  R = BP
  GOSUB @PUSH_R
  BP = SP - 1 - 3

  R$ = LABEL$: GOSUB @PUSH_RS
  R = BW: GOSUB @PUSH_R
  R = BH: GOSUB @PUSH_R
  R = I: GOSUB @PUSH_R
  R = J: GOSUB @PUSH_R
  R = K: GOSUB @PUSH_R
  R = W: GOSUB @PUSH_R
  R = H: GOSUB @PUSH_R

  LABEL$ = STACK$[BP + 1]
  BW = VAL(STACK$[BP + 2])
  BH = VAL(STACK$[BP + 3])

  RESTORE LABEL$ + "_SZ"
  READ W, H

  RESTORE LABEL$ + "_PM"

  FOR I = 0 TO H - 1
    READ TMP$[I, 0]
  NEXT

  FOR I = 0 TO (BW * BH) - 1
    RR$[I] = ""
  NEXT

  FOR J = 0 TO BH - 1
    FOR I = 0 TO BW - 1
      A$ = ""
      FOR K = 0 TO 8 - 1
        IF (J * 8 + K >= H) OR (I * 8 >= W) THEN A$ = A$ + "0" * 8: GOTO @_PM_TO_CHR_R_1
	A = 8
	IF I * 8 + 8 > W THEN A = I * 8 + 8 - W
	A$ = A$ + MID$(TMP$[J * 8 + K, 0], I * 8, A) + "0" * (8 - A)
@_PM_TO_CHR_R_1
      NEXT
      RR$[J * BW + I] = A$
    NEXT
  NEXT
  RN = BW * BH

  GOSUB @POP_R: H = R
  GOSUB @POP_R: W = R
  GOSUB @POP_R: K = R
  GOSUB @POP_R: J = R
  GOSUB @POP_R: I = R
  GOSUB @POP_R: BH = R
  GOSUB @POP_R: BW = R
  GOSUB @POP_RS: LABEL$ = R$

  ARGNUM = 3: GOSUB @CHECK_BP
  GOSUB @POP_R
  SP = BP
  BP = R
  RT$ = "ARRAY"
  RETURN


@ROTATE_CHR '(STRING): STRING
  R = BP
  GOSUB @PUSH_R
  BP = SP - 1 - 1

  R$ = S$: GOSUB @PUSH_RS
  R = I: GOSUB @PUSH_R
  R = J: GOSUB @PUSH_R

  S$ = STACK$[BP + 1]

  A$ = ""
  FOR J = 0 TO 8 - 1
    FOR I = 0 TO 8 - 1
    A$ = A$ + MID$(S$, (7 - I) * 8 + J, 1)
    NEXT
  NEXT

  GOSUB @POP_R: J = R
  GOSUB @POP_R: I = R
  GOSUB @POP_RS: S$ = R$

  ARGNUM = 1: GOSUB @CHECK_BP
  GOSUB @POP_R
  SP = BP
  BP = R
  RT$ = "STRING"
  R$ = A$
  RETURN


'== END GPUTLIB ==
