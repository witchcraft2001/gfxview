showBWZXScr:				; CODE XREF: extDefinition+54j
		sub	a
		jr	loc_C6E7
; ---------------------------------------------------------------------------

showColorZXScr:				; CODE XREF: extDefinition+59j
		ld	a, 1

loc_C6E7:				; CODE XREF: extDefinition+C56j
		ld	(typeZXScr), a
		ld	hl, aZxScr	; "ZX-SCR  "
		ld	de, strType	; "        "
		ld	bc, 8
		ldir
		ld	a, 1
		ld	(btOpenedFile),	a ; 1 -	открыт файл, 0 - нет
		ld	(btPicCompress), a ; Сжатие файла: 0 - не сжатый; 1 - Не сжатый; 2 - Сжатый RLE	(BMP); 3 - long	series (PCX)
		ld	(btPicBitPerPix), a ; Бит на пиксел
		ld	hl, 100h
		ld	(wPicSizeX), hl
		ld	hl, 0C0h ; '└'
		ld	(wPicSizeY), hl
		ld	hl, tabZXPal	; ZX-SCR Pallette
		ld	de, 8000h	; Buffer for Pallette
		ld	bc, 40h	; '@'
		push	de
		ldir
		pop	hl
		ld	de, 1000h
		ld	bc, 0FFA4h	; PIC_SET_PAL
		ld	a, 1
		rst	8
		in	a, (0A2h)	; Page2
		push	af
		ld	hl, 0
		ld	de, 1800h
		call	Read
		ld	a, (typeZXScr)
		or	a
		jr	z, loc_C73E
		ld	de, 8000h
		ld	bc, 300h
		ldir
		jr	loc_C74B
; ---------------------------------------------------------------------------

loc_C73E:				; CODE XREF: extDefinition+CA5j
		ld	hl, 8000h
		ld	de, 8001h
		ld	bc, 2FFh
		ld	(hl), 47h ; 'G'
		ldir

loc_C74B:				; CODE XREF: extDefinition+CAFj
		pop	af
		out	(0A2h),	a
		ld	hl, viewSCR
		jp	View
; END OF FUNCTION CHUNK	FOR extDefinition
; ---------------------------------------------------------------------------
typeZXScr:	db 0			; DATA XREF: extDefinition:loc_C6E7w
					; extDefinition+CA1r
aZxScr:		db 'ZX-SCR  '       ; DATA XREF: extDefinition+C5Do
; ---------------------------------------------------------------------------

viewSCR:				; DATA XREF: extDefinition+CC1o
		in	a, (0A2h)
		ld	c, a
		in	a, (89h)
		ld	b, a
		push	bc
		ld	hl, 0
		ld	de, 0
		call	Read
		ld	c, 0C0h	; '└'

loc_C76F:				; CODE XREF: RAM:C807j
		exx
		ld	hl, bufTemp	; Temporary Buffer
		exx
		ld	e, l
		ld	a, h
		and	7
		jr	nz, loc_C783
		ld	a, h
		rra
		rra
		rra
		and	3
		add	a, 80h ; 'А'
		ld	d, a

loc_C783:				; CODE XREF: RAM:C778j
		ld	b, 20h ; ' '
		push	de
		push	hl

loc_C787:				; CODE XREF: RAM:C7D2j
		ld	a, (hl)
		inc	hl
		ex	af, af'
		ld	a, (de)
		inc	de
		exx
		ld	c, a
		res	3, c
		bit	6, a
		jr	z, loc_C796
		set	3, c

loc_C796:				; CODE XREF: RAM:C792j
		and	78h ; 'x'
		rrca
		rrca
		rrca
		ld	b, a
		ld	a, c
		and	0Fh
		ld	c, a
		ex	af, af'
		rlca
		ld	(hl), b
		jr	nc, loc_C7A6
		ld	(hl), c

loc_C7A6:				; CODE XREF: RAM:C7A3j
		inc	hl
		rlca
		ld	(hl), b
		jr	nc, loc_C7AC
		ld	(hl), c

loc_C7AC:				; CODE XREF: RAM:C7A9j
		inc	hl
		rlca
		ld	(hl), b
		jr	nc, loc_C7B2
		ld	(hl), c

loc_C7B2:				; CODE XREF: RAM:C7AFj
		inc	hl
		rlca
		ld	(hl), b
		jr	nc, loc_C7B8
		ld	(hl), c

loc_C7B8:				; CODE XREF: RAM:C7B5j
		inc	hl
		rlca
		ld	(hl), b
		jr	nc, loc_C7BE
		ld	(hl), c

loc_C7BE:				; CODE XREF: RAM:C7BBj
		inc	hl
		rlca
		ld	(hl), b
		jr	nc, loc_C7C4
		ld	(hl), c

loc_C7C4:				; CODE XREF: RAM:C7C1j
		inc	hl
		rlca
		ld	(hl), b
		jr	nc, loc_C7CA
		ld	(hl), c

loc_C7CA:				; CODE XREF: RAM:C7C7j
		inc	hl
		rlca
		ld	(hl), b
		jr	nc, loc_C7D0
		ld	(hl), c

loc_C7D0:				; CODE XREF: RAM:C7CDj
		inc	hl
		exx
		djnz	loc_C787
		pop	hl
		inc	h
		ld	a, h
		and	7
		jr	nz, loc_C7E5
		ld	a, l
		add	a, 20h ; ' '
		ld	l, a
		jr	c, loc_C7E5
		ld	a, h
		sub	8
		ld	h, a

loc_C7E5:				; CODE XREF: RAM:C7D9j	RAM:C7DFj
		ld	a, 0E0h	; 'р'
		sub	c
		out	(89h), a
		push	hl
		ld	hl, bufTemp	; Temporary Buffer
		ld	de, 4160h
		in	a, (0A2h)
		ex	af, af'
		ld	a, 50h ; 'P'
		out	(0A2h),	a
		di
		ld	d, d
		ld	a, 0
		ld	l, l
		ld	a, (hl)
		ld	(de), a
		ld	b, b
		ei
		ex	af, af'
		out	(0A2h),	a
		pop	hl
		pop	de
		dec	c
		jp	nz, loc_C76F
		pop	bc
		ld	a, b
		out	(89h), a
		ld	a, c
		out	(0A2h),	a
		ret
; ---------------------------------------------------------------------------
tabZXPal:	db 0, 0, 0, 0		; 0 ; DATA XREF: extDefinition+C7Fo
		db 0C8h, 0, 0, 0	; 4 ; ZX Palette
		db 0, 0, 0C8h, 0	; 8
		db 0C8h, 0, 0C8h, 0	; 0Ch
		db 0, 0C8h, 0, 0	; 10h
		db 0C8h, 0C8h, 0, 0	; 14h
		db 0, 0C8h, 0C8h, 0	; 18h
		db 0C8h, 0C8h, 0C8h, 0	; 1Ch
		db 0, 0, 0, 0		; 20h
		db 0FCh, 54h, 54h, 0	; 24h
		db 54h,	54h, 0FCh, 0	; 28h
		db 0FCh, 54h, 0FCh, 0	; 2Ch
		db 54h,	0FCh, 54h, 0	; 30h
		db 0FCh, 0FCh, 54h, 0	; 34h
		db 54h,	0FCh, 0FCh, 0	; 38h
		db 0FCh, 0FCh, 0FCh, 0	; 3Ch