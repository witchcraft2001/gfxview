
; =============== S U B	R O U T	I N E =======================================


clear0Screen:				; CODE XREF: InitHW+20p
		ld	hl, 4000h
		ld	e, 0F0h	; 'Ё'
		jr	loc_A599
; End of function clear0Screen


; =============== S U B	R O U T	I N E =======================================


clear1Screen:				; CODE XREF: InitHW+23p readBMP-2B2p
		ld	hl, 4140h
		ld	e, 0

loc_A599:				; CODE XREF: clear0Screen+5j
		in	a, (89h)
		ld	c, a
		in	a, (0A2h)
		ld	b, a
		push	bc
		ld	a, 50h ; 'P'
		out	(0A2h),	a
		ld	bc, 140h
		di
		ld	d, d
		ld	a, 0

loc_A5AB:				; CODE XREF: clear1Screen+1Ej
		ld	e, e
		ld	(hl), e
		ld	b, b
		inc	hl
		dec	bc
		ld	a, b
		or	c
		jr	nz, loc_A5AB
		ei
		pop	bc
		ld	a, b
		out	(0A2h),	a
		ld	a, c
		out	(89h), a
		ret
; End of function clear1Screen


; =============== S U B	R O U T	I N E =======================================


CopyToBuffAcc:				; CODE XREF: RAM:949Cp	RAM:95DDp ...
		push	iy
		in	a, (0A2h)	; Page1
		push	af
		ld	a, 50h ; 'P'
		out	(0A2h),	a	; Page1
		in	a, (0E2h)	; Page3
		push	af
		ld	a, (arrPages3+1) ; Массив выделенных страниц
		out	(0E2h),	a	; Page3
		in	a, (89h)	; Y_PORT
		push	af
		set	6, h
		ld	yl, e
		ld	de, 0C000h
		ex	de, hl
		ld	a, c
		di
		ld	d, d		; Acc On, Set Buflen
		ld	(hl), a
		ld	b, b		; Accel	Off

copy_acc_loop:				; CODE XREF: CopyToBuffAcc+30j
		push	bc
		ld	a, yl
		out	(89h), a	; Y_PORT
		ld	l, l		; Copy block
		ld	a, (de)
		ld	(hl), a
		ld	b, b		; Off
		ld	b, 0
		add	hl, bc
		inc	yl
		pop	bc
		djnz	copy_acc_loop
		ei
		pop	af
		out	(89h), a	; Y_PORT
		pop	af
		out	(0E2h),	a	; Page3
		pop	af
		out	(0A2h),	a	; Page1
		pop	iy
		ret
; End of function CopyToBuffAcc


; =============== S U B	R O U T	I N E =======================================


CopyFromBuffAcc:			; CODE XREF: RAM:9591p	RAM:96D7p ...
		push	iy
		in	a, (0A2h)	; Page1
		push	af
		ld	a, 50h ; 'P'
		out	(0A2h),	a	; Page1
		in	a, (0E2h)	; Page3
		push	af
		ld	a, (arrPages3+1) ; Массив выделенных страниц
		out	(0E2h),	a	; Page3
		in	a, (89h)	; Y_PORT
		push	af
		set	6, h
		ld	yl, e
		ld	a, yl
		out	(89h), a	; Y_PORT
		ld	de, 0C000h
		ex	de, hl
		ld	a, c
		di
		ld	d, d		; Acc On, Set buflen
		ld	(de), a
		ld	b, b		; Acc Off

loc_A621:				; CODE XREF: CopyFromBuffAcc+34j
		push	bc
		ld	a, yl
		out	(89h), a	; Y_PORT
		ld	l, l		; Copy Block
		ld	a, (hl)
		ld	(de), a
		ld	b, b		; Acc Off
		ld	b, 0
		add	hl, bc
		inc	yl
		pop	bc
		djnz	loc_A621
		ei
		pop	af
		out	(89h), a	; Y_PORT
		pop	af
		out	(0E2h),	a	; Page3
		pop	af
		out	(0A2h),	a	; Page1
		pop	iy
		ret
; End of function CopyFromBuffAcc


; =============== S U B	R O U T	I N E =======================================

; Fill window with accelerator
; HL - X
; E - Y
; C - Lenght
; B - Height

FillWndAcc:				; CODE XREF: prtDirName+3Fp
					; prtFiles+Cp ...
		ex	af, af'
		in	a, (0A2h)	; Page1
		push	af
		ld	a, 50h ; 'P'
		out	(0A2h),	a	; Page1
		in	a, (89h)	; Y_PORT
		push	af
		set	6, h
		ld	a, c
		ld	(loc_A659+1), a	; Lenght
		ex	af, af'
		or	0F0h ; 'Ё'
		ld	c, a
		di

loc_A655:				; CODE XREF: FillWndAcc+20j
		ld	a, e
		out	(89h), a	; Y_PORT
		ld	d, d		; Acc On, Set len

loc_A659:				; DATA XREF: FillWndAcc+Ew
		ld	a, 0		; Lenght
		ld	c, c		; Fill
		ld	(hl), c
		ld	b, b		; acc off
		inc	e
		djnz	loc_A655
		ei
		pop	af
		out	(89h), a	; Y_PORT
		pop	af
		out	(0A2h),	a	; Page1
		ret
; End of function FillWndAcc


; =============== S U B	R O U T	I N E =======================================


makeWindow:				; CODE XREF: RAM:949Fp	RAM:95E0p ...

; FUNCTION CHUNK AT A73C SIZE 0000006F BYTES
; FUNCTION CHUNK AT A7B8 SIZE 0000004F BYTES
; FUNCTION CHUNK AT A83D SIZE 00000033 BYTES

		ex	(sp), ix
		push	iy
		push	hl
		push	de
		push	bc
		push	af
		in	a, (89h)
		ld	c, a
		in	a, (0A2h)
		ld	b, a
		push	bc
		ld	l, (ix+0)
		ld	h, (ix+1)
		set	6, h
		ld	(word_A6DD), hl
		ld	l, (ix+2)
		ld	h, (ix+3)
		ld	(word_A6DF), hl
		ld	l, (ix+4)
		ld	h, (ix+5)
		ld	(word_A6E1), hl
		ld	l, (ix+6)
		ld	h, (ix+7)
		ld	(word_A6E3), hl
		ld	de, 8
		add	ix, de
		ld	a, 50h ; 'P'
		out	(0A2h),	a
		call	loc_A6E5

loc_A6AA:				; DATA XREF: makeWindow:loc_A6AAo
		ld	hl, loc_A6AA
		push	hl
		ld	a, (ix+0)
		inc	ix
		cp	1
		jp	z, loc_A73C
		cp	2
		jp	z, loc_A76E
		cp	3
		jp	z, loc_A7B8
		cp	4
		jp	z, sub_A834
		cp	5
		jp	z, loc_A83D
		pop	hl
		pop	bc
		ld	a, b
		out	(0A2h),	a
		ld	a, c
		out	(89h), a
		pop	af
		pop	bc
		pop	de
		pop	hl
		pop	iy
		ex	(sp), ix
		ret
; End of function makeWindow

; ---------------------------------------------------------------------------
word_A6DD:	dw 0			; DATA XREF: makeWindow+17w
					; RAM:loc_A6E5r ...
word_A6DF:	dw 0			; DATA XREF: makeWindow+20w RAM:A6F9r	...
word_A6E1:	dw 0			; DATA XREF: makeWindow+29w RAM:A70Dr
word_A6E3:	dw 0			; DATA XREF: makeWindow+32w RAM:A6EBr
; ---------------------------------------------------------------------------

loc_A6E5:				; CODE XREF: makeWindow+3Ep
		ld	hl, (word_A6DD)
		ld	de, 0FFF7h
		ld	a, (word_A6E3)
		sub	2
		ld	(loc_A706+1), a
		ld	(loc_A71C+1), a
		ld	(loc_A734+1), a
		ld	a, (word_A6DF)
		ld	yl, a
		out	(89h), a
		ld	(hl), d
		inc	a
		out	(89h), a
		di
		ld	d, d

loc_A706:				; DATA XREF: RAM:A6F0w
		ld	a, 0
		ld	e, e
		ld	(hl), d
		ld	b, b
		ld	(hl), d
		inc	hl
		ld	bc, (word_A6E1)
		dec	bc
		dec	bc

loc_A713:				; CODE XREF: RAM:A729j
		ld	a, yl
		out	(89h), a
		ld	(hl), d
		inc	a
		out	(89h), a
		ld	d, d

loc_A71C:				; DATA XREF: RAM:A6F3w
		ld	a, 0
		ld	b, b
		ld	a, 0F8h	; '°'
		ld	e, e
		ld	(hl), a
		ld	b, b
		ld	(hl), e
		inc	hl
		dec	bc
		ld	a, b
		or	c
		jr	nz, loc_A713
		ld	a, yl
		out	(89h), a
		ld	(hl), e
		inc	a
		out	(89h), a
		ld	d, d

loc_A734:				; DATA XREF: RAM:A6F6w
		ld	a, 0
		ld	e, e
		ld	(hl), e
		ld	b, b
		ld	(hl), e
		ei
		ret
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR makeWindow

loc_A73C:				; CODE XREF: makeWindow+4Cj
		ld	hl, (word_A6DD)
		ld	a, h
		and	3Fh ; '?'
		ld	h, a
		ld	e, (ix+0)
		inc	ix
		ld	d, (ix+0)
		inc	ix
		add	hl, de
		ex	de, hl
		ld	hl, (word_A6DF)
		ld	c, (ix+0)
		inc	ix
		ld	b, (ix+0)
		inc	ix
		add	hl, bc
		ld	c, l
		ld	b, h
		ld	a, (ix+0)
		inc	ix
		push	ix
		pop	hl
		call	prtString
		push	hl
		pop	ix
		ret
; ---------------------------------------------------------------------------

loc_A76E:				; CODE XREF: makeWindow+51j
		ld	hl, (word_A6DD)
		ld	c, (ix+0)
		inc	ix
		ld	b, (ix+0)
		inc	ix
		add	hl, bc
		ld	c, (ix+0)
		inc	ix
		inc	ix
		ld	a, (word_A6DF)
		add	a, c
		ld	yl, a
		ld	c, (ix+0)
		inc	ix
		ld	b, (ix+0)
		inc	ix
		ld	a, (ix+0)
		inc	ix
		inc	ix
		ld	(loc_A7AB+1), a
		ld	a, (ix+0)
		or	0F0h ; 'Ё'
		ld	d, a
		inc	ix
		di

loc_A7A6:				; CODE XREF: RAM:A7B4j
		ld	a, yl
		out	(89h), a
		ld	d, d
; END OF FUNCTION CHUNK	FOR makeWindow

loc_A7AB:				; DATA XREF: makeWindow+131w
		ld	a, 0
		ld	e, e
		ld	(hl), d
		ld	b, b
		inc	hl
		dec	bc
		ld	a, b
		or	c
		jr	nz, loc_A7A6
		ei
		ret
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR makeWindow

loc_A7B8:				; CODE XREF: makeWindow+56j
		ld	hl, (word_A6DD)
		ld	de, 0FFF7h

loc_A7BE:				; CODE XREF: sub_A834+6j
		ld	c, (ix+0)
		inc	ix
		ld	b, (ix+0)
		inc	ix
		add	hl, bc
		ld	c, (ix+0)
		inc	ix
		inc	ix
		ld	a, (word_A6DF)
		add	a, c
		ld	yl, a
		ld	c, (ix+0)
		inc	ix
		ld	b, (ix+0)
		inc	ix
		dec	bc
		dec	bc
		ld	a, c
		ld	(loc_A813+1), a
		ld	(loc_A81D+1), a
		ld	a, (ix+0)
		inc	ix
		inc	ix
		sub	2
		ld	(loc_A807+1), a
		ld	(loc_A82C+1), a
		add	a, yl
		inc	a
		ld	yh, a
		di
		ld	a, yl
		out	(89h), a
		ld	(hl), e
		inc	a
		out	(89h), a
		ld	d, d
; END OF FUNCTION CHUNK	FOR makeWindow

loc_A807:				; DATA XREF: makeWindow+189w
		ld	a, 0
		ld	e, e
		ld	(hl), e
		ld	b, b
		ld	(hl), e
		inc	hl
		ld	a, yl
		out	(89h), a
		ld	d, d

loc_A813:				; DATA XREF: makeWindow+17Aw
		ld	a, 0
		ld	c, c
		ld	(hl), e
		ld	b, b
		ld	a, yh
		out	(89h), a
		ld	d, d

loc_A81D:				; DATA XREF: makeWindow+17Dw
		ld	a, 0
		ld	c, c
		ld	(hl), d
		ld	b, b
		add	hl, bc
		ld	a, yl
		out	(89h), a
		ld	(hl), d
		inc	a
		out	(89h), a
		ld	d, d

loc_A82C:				; DATA XREF: makeWindow+18Cw
		ld	a, 0
		ld	e, e
		ld	(hl), d
		ld	b, b
		ld	(hl), d
		ei
		ret

; =============== S U B	R O U T	I N E =======================================


sub_A834:				; CODE XREF: makeWindow+5Bj
					; makeWindow+1F3p
		ld	hl, (word_A6DD)
		ld	de, 0F7FFh
		jp	loc_A7BE
; End of function sub_A834

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR makeWindow

loc_A83D:				; CODE XREF: makeWindow+60j
		ld	hl, (word_A6DD)
		ld	a, h
		and	3Fh ; '?'
		ld	h, a
		ld	e, (ix+0)
		ld	d, (ix+1)
		add	hl, de
		inc	hl
		inc	hl
		ex	de, hl
		ld	hl, (word_A6DF)
		ld	c, (ix+2)
		ld	b, (ix+3)
		add	hl, bc
		inc	hl
		inc	hl
		push	hl
		push	de
		call	sub_A834
		pop	de
		pop	bc
		ld	a, (ix+0)
		inc	ix
		push	ix
		pop	hl
		call	prtString
		push	hl
		pop	ix
		ret
; END OF FUNCTION CHUNK	FOR makeWindow
