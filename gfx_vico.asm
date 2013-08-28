readICO:				; DATA XREF: RAM:9431o
		sub	a
		ld	(btOpenedFile),	a ; 1 -	открыт файл, 0 - нет
		ld	ix, 8000h	; Read header
		ld	hl, 0
		ld	de, 0
		ld	bc, 16h
		call	doRead		; Чтение данных	в буфер
					; IX - куда
					; BC - сколько
					; HL -?
					; DE -?
		ld	a, (ix+2)	; type 1 - ico,	2 - cur
		dec	a
		ld	a, 88h ; 'И'
		scf
		ret	nz
		ld	a, 1
		ld	(btOpenedFile),	a ; 1 -	открыт файл, 0 - нет
		call	setICO
		ld	a, (ix+8)
		cp	10h
		ld	a, 89h ; 'Й'
		scf
		ret	nz
		ld	l, (ix+4)	; Images count
		ld	h, (ix+5)
		dec	hl
		ld	a, h
		or	l
		ld	a, 89h ; 'Й'
		scf			; Не поддерживается количество изображений !=1
		ret	nz
		ld	a, (ix+6)	; width
		cp	20h ; ' '       ; ==32?
		ld	a, 89h ; 'Й'
		scf
		ret	nz
		ld	a, (ix+7)	; height
		cp	20h ; ' '       ; ==32?
		ld	a, 89h ; 'Й'
		scf
		ret	nz
		ld	ix, 8000h	; Расчет смещения???
		ld	hl, 16h		; длина	заголовка 6+16 байт
		ld	de, 28h	; '('
		add	hl, de
		push	hl
		ld	de, 40h	; '@'   ; размер палитры
		add	hl, de
		ld	(wICOoffset), hl ; Смещение в файле ICO	после заголовка	и палитры
		pop	de
		ld	hl, 0		; чтение палитры
		ld	bc, 40h	; '@'
		push	ix
		call	doRead		; Чтение данных	в буфер
					; IX - куда
					; BC - сколько
					; HL -?
					; DE -?
		pop	hl
		ld	de, 1000h
		ld	bc, 0FFA4h	; PIC_SET_PAL
		ld	a, 1
		rst	8
		ld	hl, viewICO
		jp	View
; ---------------------------------------------------------------------------
wICOoffset:	dw 0			; DATA XREF: RAM:C55Aw	RAM:C5B8r
					; Смещение в файле ICO после заголовка и палитры

; =============== S U B	R O U T	I N E =======================================


setICO:					; CODE XREF: RAM:C51Fp
		ld	hl, strType	; "        "
		ld	(hl), 49h ; 'I'
		inc	hl
		ld	(hl), 43h ; 'C'
		inc	hl
		ld	(hl), 4Fh ; 'O'
		inc	hl
		ld	b, 5
		ld	a, 20h ; ' '

loc_C58B:				; CODE XREF: setICO+12j
		ld	(hl), a
		inc	hl
		djnz	loc_C58B
		ld	a, 1
		ld	(btPicCompress), a ; Сжатие файла: 0 - не сжатый; 1 - Не сжатый; 2 - Сжатый RLE	(BMP); 3 - long	series (PCX)
		sub	a
		ld	b, (ix+8)	; colors
		dec	b
		dec	a

loc_C59A:				; CODE XREF: setICO+22j
		inc	a
		srl	b
		jr	c, loc_C59A
		ld	(btPicBitPerPix), a ; Бит на пиксел
		ld	h, 0
		ld	l, (ix+6)	; width
		ld	(wPicSizeX), hl
		ld	l, (ix+7)	; height
		ld	(wPicSizeY), hl
		ret
; End of function setICO

; ---------------------------------------------------------------------------

viewICO:				; DATA XREF: RAM:C573o
		ld	ix, 8000h
		ld	hl, 0
		ld	de, (wICOoffset) ; Смещение в файле ICO	после заголовка	и палитры
		ld	bc, 200h
		call	doRead		; Чтение данных	в буфер
					; IX - куда
					; BC - сколько
					; HL -?
					; DE -?
		ld	a, (btCountZoom)
		or	a
		jr	nz, loc_C61A
		in	a, (0A2h)
		ld	c, a
		in	a, (89h)
		ld	b, a
		push	bc
		ld	a, 50h ; 'P'
		out	(0A2h),	a
		ld	hl, 41B0h
		ld	bc, 6000h
		di
		ld	d, d
		ld	a, 60h ; '`'
		ld	b, b

loc_C5DE:				; CODE XREF: RAM:C5E6j
		ld	a, 50h ; 'P'
		out	(89h), a
		ld	e, e
		ld	(hl), c
		ld	b, b
		inc	hl
		djnz	loc_C5DE
		ei
		ld	hl, 8000h
		ld	de, 41D0h
		ld	c, 20h ; ' '
		ld	xl, 8Fh	; 'П'

loc_C5F4:				; CODE XREF: RAM:C610j
		push	de
		ld	a, xl
		out	(89h), a
		ld	b, 10h

loc_C5FB:				; CODE XREF: RAM:C60Aj
		ld	a, (hl)
		rrca
		rrca
		rrca
		rrca
		and	0Fh
		ld	(de), a
		inc	de
		ld	a, (hl)
		and	0Fh
		ld	(de), a
		inc	de
		inc	hl
		djnz	loc_C5FB
		pop	de
		dec	xl
		dec	c
		jr	nz, loc_C5F4
		pop	bc
		ld	a, b
		out	(89h), a
		ld	a, c
		out	(0A2h),	a
		ret
; ---------------------------------------------------------------------------

loc_C61A:				; CODE XREF: RAM:C5C6j
		dec	a
		jr	nz, loc_C684
		in	a, (0A2h)
		ld	c, a
		in	a, (89h)
		ld	b, a
		push	bc
		ld	a, 50h ; 'P'
		out	(0A2h),	a
		ld	hl, 41B0h
		ld	bc, 6000h
		di
		ld	d, d
		ld	a, 60h ; '`'
		ld	b, b

loc_C633:				; CODE XREF: RAM:C63Bj
		ld	a, 50h ; 'P'
		out	(89h), a
		ld	e, e
		ld	(hl), c
		ld	b, b
		inc	hl
		djnz	loc_C633
		ei
		ld	hl, 8000h
		ld	de, 41C0h
		ld	c, 20h ; ' '
		ld	xl, 9Fh	; 'Я'

loc_C649:				; CODE XREF: RAM:C67Aj
		push	de
		ld	a, xl
		out	(89h), a
		ld	b, 10h

loc_C650:				; CODE XREF: RAM:C663j
		ld	a, (hl)
		rrca
		rrca
		rrca
		rrca
		and	0Fh
		ld	(de), a
		inc	de
		ld	(de), a
		inc	de
		ld	a, (hl)
		inc	hl
		and	0Fh
		ld	(de), a
		inc	de
		ld	(de), a
		inc	de
		djnz	loc_C650
		pop	de
		di
		ld	d, d
		ld	a, 40h ; '@'
		ld	l, l
		ld	a, (de)
		ld	b, b
		dec	xl
		ld	a, xl
		out	(89h), a
		ld	l, l
		ld	(de), a
		ld	b, b
		ei
		dec	xl
		dec	c
		jr	nz, loc_C649
		pop	bc
		ld	a, b
		out	(89h), a
		ld	a, c
		out	(0A2h),	a
		ret
; ---------------------------------------------------------------------------

loc_C684:				; CODE XREF: RAM:C61Bj
		in	a, (0A2h)
		ld	c, a
		in	a, (89h)
		ld	b, a
		push	bc
		ld	a, 50h ; 'P'
		out	(0A2h),	a
		ld	hl, 8000h
		ld	de, 41B0h
		ld	c, 20h ; ' '
		ld	xl, 0AFh ; 'п'

loc_C69A:				; CODE XREF: RAM:C6D8j
		push	de
		ld	a, xl
		out	(89h), a
		ld	b, 10h

loc_C6A1:				; CODE XREF: RAM:C6B8j
		ld	a, (hl)
		rrca
		rrca
		rrca
		rrca
		and	0Fh
		ld	(de), a
		inc	de
		ld	(de), a
		inc	de
		ld	(de), a
		inc	de
		ld	a, (hl)
		inc	hl
		and	0Fh
		ld	(de), a
		inc	de
		ld	(de), a
		inc	de
		ld	(de), a
		inc	de
		djnz	loc_C6A1
		pop	de
		di
		ld	d, d
		ld	a, 60h ; '`'
		ld	l, l
		ld	a, (de)
		ld	b, b
		dec	xl
		ld	a, xl
		out	(89h), a
		ld	l, l
		ld	(de), a
		ld	b, b
		dec	xl
		ld	a, xl
		out	(89h), a
		ld	l, l
		ld	(de), a
		ld	b, b
		ei
		dec	xl
		dec	c
		jr	nz, loc_C69A
		pop	bc
		ld	a, b
		out	(89h), a
		ld	a, c
		out	(0A2h),	a
		ret
