mouseSwitchONOFF:			; DATA XREF: RAM:B77Ao
		ld	a, (MouseOn)	; Меняет режим мышки ВКЛ>ВЫКЛ и	наоборот
		xor	1
		ld	(MouseOn), a	; флаг мышки - вкл/выкл
		ld	c, 1		; SHOW CURSOR
		jr	z, loc_ABE3
		ld	c, 2		; HIDE CURSOR

loc_ABE3:				; CODE XREF: RAM:ABDFj
		rst	30h
		ret

; =============== S U B	R O U T	I N E =======================================

; Wait for release all buttons on mouse

mouseReleaseBtns:			; CODE XREF: showError+A0p
					; showError+32Ep ...
		ld	a, (MouseOn)	; флаг мышки - вкл/выкл
		or	a
		ret	nz

loc_ABEA:				; CODE XREF: mouseReleaseBtns+Aj
		ld	c, 3		; READ MOUSE STATE
		rst	30h
		or	a
		ret	z
		jr	loc_ABEA
; End of function mouseReleaseBtns


; =============== S U B	R O U T	I N E =======================================

; Проверка координат мыши

testCoords:				; CODE XREF: RAM:9322p	RAM:956Dp ...
		ld	a, (MouseOn)	; флаг мышки - вкл/выкл
		or	a
		ret	nz
		ld	c, 3		; READ MOUSE STATE
		rst	30h
		ex	af, af'

loc_ABFA:				; DATA XREF: testCoords:loc_AC07w
		ld	bc, 0
		ld	a, xl
		cp	c
		jr	nz, loc_AC07
		ld	a, xh
		cp	b
		jr	z, loc_AC0E

loc_AC07:				; CODE XREF: testCoords+Fj
		ld	(loc_ABFA+1), ix
		jp	mouseReleaseBtns ; Wait	for release all	buttons	on mouse
; ---------------------------------------------------------------------------

loc_AC0E:				; CODE XREF: testCoords+14j
		ex	af, af'
		or	a
		jr	nz, loc_AC27
		push	hl

loc_AC13:				; DATA XREF: testCoords:loc_AC27w
		ld	bc, 0
		or	a
		sbc	hl, bc
		pop	hl
		jr	nz, loc_AC27
		ex	de, hl
		push	hl

loc_AC1E:				; DATA XREF: testCoords+39w
		ld	bc, 0
		or	a
		sbc	hl, bc
		pop	hl
		ex	de, hl
		ret	z

loc_AC27:				; CODE XREF: testCoords+1Fj
					; testCoords+29j
		ld	(loc_AC13+1), hl
		ld	(loc_AC1E+1), de

loc_AC2E:				; CODE XREF: testCoords+DFj
		ld	c, (ix+0)
		ld	b, (ix+1)
		or	a
		sbc	hl, bc
		add	hl, bc
		jp	c, nxtCrds1
		ld	c, (ix+2)
		ld	b, (ix+3)
		sbc	hl, bc
		add	hl, bc
		jp	nc, nxtCrds1
		ld	c, (ix+4)
		ld	b, (ix+5)
		or	a
		ex	de, hl
		sbc	hl, bc
		add	hl, bc
		ex	de, hl
		jp	c, nxtCrds1
		ld	c, (ix+6)
		ld	b, (ix+7)
		ex	de, hl
		sbc	hl, bc
		add	hl, bc
		ex	de, hl
		jp	nc, nxtCrds1
		or	a
		jr	z, exec1
		bit	0, a
		jr	z, exec2
		bit	0, (ix+8)
		call	nz, pushButton
		ccf
		ret	nc
		bit	1, (ix+8)
		ret	nz
		ld	c, a
		ld	a, (ix+0Ch)
		or	(ix+0Dh)
		ld	a, c
		jr	z, nxtCrds1	; есть ли п/п запуска?
		bit	3, (ix+8)	; Запуск без возврата
		jr	z, loc_AC8A
		pop	af		; Запуск без возврата JP (BC)

loc_AC8A:				; CODE XREF: testCoords+96j
		ld	c, (ix+0Ch)	; Запуск CALL (BC)
		ld	b, (ix+0Dh)
		push	bc
		or	a
		ret
; ---------------------------------------------------------------------------

exec1:					; CODE XREF: testCoords+74j
		ld	c, a
		ld	a, (ix+0Ah)
		or	(ix+0Bh)
		ld	a, c
		jr	z, nxtCrds1
		bit	2, (ix+8)	; Запуск без возврата
		jr	z, loc_ACA4
		pop	af		; JP (BC)

loc_ACA4:				; CODE XREF: testCoords+B0j
		ld	c, (ix+0Ah)	; Запуск CALL (BC)
		ld	b, (ix+0Bh)
		push	bc
		or	a
		ret
; ---------------------------------------------------------------------------

exec2:					; CODE XREF: testCoords+78j
		ld	c, a		; Запуск по правой кнопке
		ld	a, (ix+0Eh)
		or	(ix+0Fh)
		ld	a, c
		jr	z, nxtCrds1
		bit	4, (ix+8)	; запуск без возврата
		jr	z, loc_ACBE
		pop	af		; JP (BC)

loc_ACBE:				; CODE XREF: testCoords+CAj
		ld	c, (ix+0Eh)	; CALL (BC)
		ld	b, (ix+0Fh)
		push	bc
		or	a
		ret
; ---------------------------------------------------------------------------

nxtCrds1:				; CODE XREF: testCoords+47j
					; testCoords+53j ...
		ld	bc, 10h
		add	ix, bc
		bit	7, (ix+1)	; конец	таблицы
		jp	z, loc_AC2E
		or	a
		ret
; End of function testCoords

; ---------------------------------------------------------------------------

pushButton:				; CODE XREF: testCoords+7Ep
		push	hl
		push	de
		ld	l, (ix+0)
		ld	h, (ix+1)
		ld	e, (ix+4)
		ld	d, (ix+5)
		ld	a, (ix+2)
		sub	(ix+0)
		ld	c, a
		ld	a, (ix+6)
		sub	(ix+4)
		ld	b, a
		push	hl
		push	de
		push	bc
		call	putPushBtn
		ld	a, 0Ah
		ld	(pausePh+1), a

pushLp:					; CODE XREF: RAM:AD40j
		push	ix
		call	testRun
		pop	ix

pushLp1:				; CODE XREF: RAM:AD47j
		ld	c, 3		; READ MOUSE STATE
		rst	30h
		or	a
		jr	z, pushBtnEx
		bit	0, a
		jr	z, pushBtnEx
		ld	c, (ix+0)
		ld	b, (ix+1)
		or	a
		sbc	hl, bc
		add	hl, bc
		jr	c, pushBtnEx
		ld	c, (ix+2)
		ld	b, (ix+3)
		sbc	hl, bc
		add	hl, bc
		ccf
		jr	c, pushBtnEx
		ex	de, hl
		ld	c, (ix+4)
		ld	b, (ix+5)
		or	a
		sbc	hl, bc
		add	hl, bc
		jr	c, pushBtnEx
		ld	c, (ix+6)
		ld	b, (ix+7)
		sbc	hl, bc
		ccf
		jr	c, pushBtnEx

pausePh:				; DATA XREF: RAM:ACF9w	RAM:AD43w
		ld	a, 0
		or	a
		jr	z, pushLp
		dec	a
		ld	(pausePh+1), a
		halt
		jr	pushLp1
; ---------------------------------------------------------------------------

pushBtnEx:				; CODE XREF: RAM:AD07j	RAM:AD0Bj ...
		pop	bc
		pop	de
		pop	hl
		push	af
		call	putPopBtn
		pop	af
		pop	de
		pop	hl
		ret

; =============== S U B	R O U T	I N E =======================================


testRun:				; CODE XREF: RAM:ACFEp
		bit	1, (ix+8)
		ret	z
		ld	c, (ix+0Ch)
		ld	b, (ix+0Dh)
		push	bc
		ret
; End of function testRun


; =============== S U B	R O U T	I N E =======================================


putPushBtn:				; CODE XREF: RAM:ACF4p

; FUNCTION CHUNK AT AD67 SIZE 0000003F BYTES

		ld	a, 0F7h	; 'ў'
		jr	putBtn
; End of function putPushBtn

; ---------------------------------------------------------------------------

putPopBtn:				; CODE XREF: RAM:AD4Dp
		ld	a, 7Fh ; ''
; START	OF FUNCTION CHUNK FOR putPushBtn

putBtn:					; CODE XREF: putPushBtn+2j
		push	iy
		ex	af, af'
		in	a, (0A2h)	; page1
		push	af
		ld	a, 50h ; 'P'
		out	(0A2h),	a	; page1
		in	a, (89h)	; Y_PORT
		push	af
		set	6, h
		ld	yl, e
		dec	c
		dec	c
		ld	a, c
		ld	(btnLen3+1), a
		ld	(btnLen31+1), a
		ld	a, b
		sub	2
		ld	(btnLen1+1), a
		ld	(btnLen2+1), a
		add	a, yl
		inc	a
		ld	yh, a
		ex	af, af'
		ld	e, a
		rrca
		rrca
		rrca
		rrca
		or	0F0h ; 'Ё'
		ld	d, a
		ld	a, e
		or	0F0h ; 'Ё'
		ld	e, a
		di
		ld	a, yl
		out	(89h), a	; Y_PORT
		ld	(hl), e
		inc	a
		out	(89h), a	; Y_PORT
		ld	d, d		; acc on, set len
; END OF FUNCTION CHUNK	FOR putPushBtn

btnLen1:				; DATA XREF: putPushBtn+23w
		ld	a, 0
		ld	e, e
		ld	(hl), e
		ld	b, b
		ld	(hl), e
		inc	hl
		ld	a, yl
		out	(89h), a
		ld	d, d

btnLen3:				; DATA XREF: putPushBtn+1Aw
		ld	a, 0
		ld	c, c
		ld	(hl), e
		ld	b, b
		ld	a, yh
		out	(89h), a
		ld	d, d

btnLen31:				; DATA XREF: putPushBtn+1Dw
		ld	a, 0
		ld	c, c
		ld	(hl), d
		ld	b, b
		ld	b, 0
		add	hl, bc
		ld	a, yl
		out	(89h), a
		ld	(hl), d
		inc	a
		out	(89h), a
		ld	d, d

btnLen2:				; DATA XREF: putPushBtn+26w
		ld	a, 0
		ld	e, e
		ld	(hl), d
		ld	b, b
		ld	(hl), d
		ei
		pop	af
		out	(89h), a
		pop	af
		out	(0A2h),	a
		pop	iy
		ret

; =============== S U B	R O U T	I N E =======================================


SetMsCursorArrow:			; CODE XREF: readDirectory+15p
					; showError+70p ...
		ld	a, (MouseOn)	; флаг мышки - вкл/выкл
		or	a
		ret	nz
		push	iy
		push	ix
		push	hl
		push	de
		push	bc
		ld	ix, sprCursorArrow
		ld	hl, 0D09h	; HGT/WDT
		ld	de, 0
		ld	c, 9		; LOAD CURSOR
		rst	30h
		pop	bc
		pop	de
		pop	hl
		pop	ix
		pop	iy
		halt
		ret
; End of function SetMsCursorArrow

; ---------------------------------------------------------------------------
sprCursorArrow:	db 0, 0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
					; DATA XREF: SetMsCursorArrow+Co
		db 0, 0FEh, 0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
		db 0, 0FEh, 0FEh, 0, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
		db 0, 0FEh, 0FEh, 0FEh,	0, 0FFh, 0FFh, 0FFh, 0FFh
		db 0, 0FEh, 0FEh, 0FEh,	0FEh, 0, 0FFh, 0FFh, 0FFh
		db 0, 0FEh, 0FEh, 0FEh,	0FEh, 0FEh, 0, 0FFh, 0FFh
		db 0, 0FEh, 0FEh, 0FEh,	0FEh, 0FEh, 0FEh, 0, 0FFh
		db 0, 0FEh, 0FEh, 0FEh,	0FEh, 0, 0, 0, 0
		db 0, 0FEh, 0FEh, 0, 0FEh, 0, 0FFh, 0FFh, 0FFh
		db 0, 0FEh, 0, 0, 0FEh,	0FEh, 0, 0FFh, 0FFh
		db 0, 0, 0FFh, 0FFh, 0,	0FEh, 0, 0FFh, 0FFh
		db 0, 0FFh, 0FFh, 0FFh,	0, 0FEh, 0FEh, 0, 0FFh
		db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0, 0, 0FFh, 0FFh

; =============== S U B	R O U T	I N E =======================================


SetMsCursorWait:			; CODE XREF: readDirectory+3p
					; showError+A3p ...
		ld	a, (MouseOn)	; флаг мышки - вкл/выкл
		or	a
		ret	nz
		push	iy
		push	ix
		push	hl
		push	de
		push	bc
		ld	ix, sprCursorWait
		ld	hl, 0E09h
		ld	de, 704h
		ld	c, 9		; LOAD CURSOR
		rst	30h
		pop	bc
		pop	de
		pop	hl
		pop	ix
		pop	iy
		halt
		ret
; End of function SetMsCursorWait

; ---------------------------------------------------------------------------
sprCursorWait:	db 0, 0, 0, 0, 0, 0, 0,	0, 0 ; DATA XREF: SetMsCursorWait+Co
		db 0, 0FEh, 0FEh, 0FEh,	0FEh, 0FEh, 0FEh, 0FEh,	0
		db 0, 0, 0, 0, 0, 0, 0,	0, 0
		db 0FFh, 0, 0FEh, 0FEh,	0FEh, 0FEh, 0FEh, 0, 0FFh
		db 0FFh, 0, 0FEh, 0FEh,	0FEh, 0, 0FEh, 0, 0FFh
		db 0FFh, 0FFh, 0, 0FEh,	0F0h, 0FEh, 0, 0FFh, 0FFh
		db 0FFh, 0FFh, 0FFh, 0,	0FEh, 0, 0FFh, 0FFh, 0FFh
		db 0FFh, 0FFh, 0FFh, 0,	0FEh, 0, 0FFh, 0FFh, 0FFh
		db 0FFh, 0FFh, 0, 0FEh,	0F0h, 0FEh, 0, 0FFh, 0FFh
		db 0FFh, 0, 0FEh, 0FEh,	0FEh, 0, 0FEh, 0, 0FFh
		db 0FFh, 0, 0FEh, 0FEh,	0FEh, 0FEh, 0FEh, 0, 0FFh
		db 0, 0, 0, 0, 0, 0, 0,	0, 0
		db 0, 0FEh, 0FEh, 0FEh,	0FEh, 0FEh, 0FEh, 0FEh,	0
		db 0, 0, 0, 0, 0, 0, 0,	0, 0
