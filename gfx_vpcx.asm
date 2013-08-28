readPCX:				; DATA XREF: RAM:942Fo
		sub	a		; PCX?
		ld	(btOpenedFile),	a ; 1 -	открыт файл, 0 - нет
		ld	ix, 8000h	; Чтение заголовка PCX
		ld	hl, 0
		ld	de, 0
		ld	bc, 80h	; 'А'
		push	ix
		call	doRead		; Чтение данных	в буфер
					; IX - куда
					; BC - сколько
					; HL -?
					; DE -?
		pop	ix
		ld	a, (ix+0)	; Manufacturer == 0x0a
		cp	0Ah
		ld	a, 85h ; 'Е'
		scf
		ret	nz
		ld	a, 1
		ld	(btOpenedFile),	a ; 1 -	открыт файл, 0 - нет
		call	setPCX
		ld	e, (ix+4)	; window size X
		ld	d, (ix+5)
		ld	l, (ix+8)
		ld	h, (ix+9)
		or	a
		sbc	hl, de
		inc	hl
		ld	(wPicSizeX), hl
		ld	e, (ix+6)	; window size  Y
		ld	d, (ix+7)
		ld	l, (ix+0Ah)
		ld	h, (ix+0Bh)
		or	a
		sbc	hl, de
		inc	hl
		ld	(wPicSizeY), hl
		ld	c, (ix+1)	; version
		ld	a, c
		or	a		; верс 2.5
		ld	a, 86h ; 'Ж'
		scf
		ret	z
		ld	a, c
		cp	3		; верс 2.8 без информации о палитре
		ld	a, 86h ; 'Ж'
		scf
		ret	z
		ld	a, c
		cp	6
		ld	a, 86h ; 'Ж'
		ccf
		ret	c
		ld	a, (ix+2)	; Encoding
		dec	a
		ld	a, 87h ; 'З'
		scf
		ret	nz
		ld	hl, 0
		ld	b, (ix+41h)	; Num Planes
		ld	e, (ix+42h)	; Bytes	per Line
		ld	d, (ix+43h)

loc_C356:				; CODE XREF: RAM:C357j
		add	hl, de
		djnz	loc_C356
		ld	(pcxBytesPerFullLine), hl
		ld	a, (ix+3)	; Bits per pixel
		cp	8
		ld	a, 86h ; 'Ж'
		scf
		ret	nz
		ld	ix, 8000h	; Read pallette
		ld	hl, (fileSizeHigh)
		ld	de, (fileSizeLow)
		ld	bc, 301h
		or	a
		ex	de, hl
		sbc	hl, bc
		ex	de, hl
		jr	nc, loc_C37B
		dec	hl

loc_C37B:				; CODE XREF: RAM:C378j
		call	doRead		; Чтение данных	в буфер
					; IX - куда
					; BC - сколько
					; HL -?
					; DE -?
		ld	ix, 8000h
		ld	c, (ix+0)
		ld	a, c
		cp	0Ah
		ld	a, 86h ; 'Ж'
		ret	c
		ld	a, c
		cp	0Bh
		ld	a, 86h ; 'Ж'
		scf
		ret	z
		ld	a, c
		cp	0Dh
		ld	a, 86h ; 'Ж'
		ccf
		ret	c
		ld	hl, 8001h
		ld	de, bufTemp	; Temporary Buffer
		ld	bc, 300h
		push	de
		ldir
		pop	hl
		ld	b, 0
		push	ix

loc_C3AA:				; CODE XREF: RAM:C3C5j
		ld	a, (hl)
		inc	hl
		ld	e, (hl)
		inc	hl
		ld	d, (hl)
		inc	hl
		ld	(ix+0),	d
		inc	ix
		ld	(ix+0),	e
		inc	ix
		ld	(ix+0),	a
		inc	ix
		ld	(ix+0),	0
		inc	ix
		djnz	loc_C3AA
		pop	hl
		ld	de, 0
		ld	bc, 0FFA4h	; PIC_SET_PAL
		ld	a, 1
		rst	8
		ld	hl, viewPCX
		jp	View
; ---------------------------------------------------------------------------
pcxBytesPerFullLine:dw 0		; DATA XREF: RAM:C359w	RAM:loc_C44Br ...

; =============== S U B	R O U T	I N E =======================================


setPCX:					; CODE XREF: RAM:C302p
		ld	hl, strType	; "        "
		ld	(hl), 50h ; 'P'
		inc	hl
		ld	(hl), 43h ; 'C'
		inc	hl
		ld	(hl), 58h ; 'X'
		inc	hl
		ld	(hl), 20h ; ' '
		inc	hl
		ex	de, hl
		ld	hl, strPCXVersion ; "2.5 "
		ld	a, (ix+1)
		or	a
		jr	z, loc_C403
		ld	hl, a2_8	; "2.8 "
		cp	2
		jr	z, loc_C403
		ld	hl, a2_8a	; "2.8a"
		cp	3
		jr	z, loc_C403
		ld	hl, a3_0	; "3.0 "

loc_C403:				; CODE XREF: setPCX+17j setPCX+1Ej ...
		ldi
		ldi
		ldi
		ldi
		ld	a, (ix+2)
		cp	1
		ld	a, 3
		jr	z, loc_C415
		sub	a

loc_C415:				; CODE XREF: setPCX+39j
		ld	(btPicCompress), a ; Сжатие файла: 0 - не сжатый; 1 - Не сжатый; 2 - Сжатый RLE	(BMP); 3 - long	series (PCX)
		ld	b, (ix+41h)
		sub	a

loc_C41C:				; CODE XREF: setPCX+46j
		add	a, (ix+3)
		djnz	loc_C41C
		ld	(btPicBitPerPix), a ; Бит на пиксел
		ret
; End of function setPCX

; ---------------------------------------------------------------------------
strPCXVersion:	db '2.5 '           ; DATA XREF: setPCX+10o
a2_8:		db '2.8 '           ; DATA XREF: setPCX+19o
a2_8a:		db '2.8a'           ; DATA XREF: setPCX+20o
a3_0:		db '3.0 '           ; DATA XREF: setPCX+27o
; ---------------------------------------------------------------------------

viewPCX:				; DATA XREF: RAM:C3D1o
		in	a, (0A2h)
		ld	c, a
		in	a, (89h)
		ld	b, a
		push	bc
		ld	c, l
		ld	b, h
		ld	hl, 0
		ld	de, 80h	; 'А'
		call	Read
		ld	a, b
		or	c
		jr	z, loc_C473

loc_C44B:				; CODE XREF: RAM:C471j
		ld	de, (pcxBytesPerFullLine)

loc_C44F:				; CODE XREF: RAM:C46Cj
		call	Read1
		ld	a, (hl)
		inc	hl
		bit	7, a
		jr	z, loc_C469
		bit	6, a
		jr	z, loc_C469
		push	bc
		and	3Fh ; '?'
		dec	a
		ld	c, a
		ld	b, 0
		ex	de, hl
		sbc	hl, bc
		ex	de, hl
		pop	bc
		inc	hl

loc_C469:				; CODE XREF: RAM:C456j	RAM:C45Aj
		dec	de
		ld	a, d
		or	e
		jr	nz, loc_C44F
		dec	bc
		ld	a, b
		or	c
		jr	nz, loc_C44B

loc_C473:				; CODE XREF: RAM:C449j
		ld	bc, (wPicSizeY)
		ld	a, b
		or	a
		ld	a, c
		jr	z, loc_C47D
		sub	a

loc_C47D:				; CODE XREF: RAM:C47Aj
		ld	xh, a
		ld	xl, 0

loc_C482:				; CODE XREF: RAM:C4F3j
		ld	de, (pcxBytesPerFullLine)
		ld	bc, bufTemp	; Temporary Buffer

loc_C489:				; CODE XREF: RAM:C497j	RAM:C4C0j
		call	Read1
		ld	a, (hl)
		inc	hl
		bit	7, a
		jr	nz, loc_C49B

loc_C492:				; CODE XREF: RAM:C49Dj
		ld	(bc), a
		inc	bc
		dec	de
		ld	a, d
		or	e
		jr	nz, loc_C489
		jr	loc_C4C2
; ---------------------------------------------------------------------------

loc_C49B:				; CODE XREF: RAM:C490j
		bit	6, a
		jr	z, loc_C492
		push	bc
		and	3Fh ; '?'
		ld	c, a
		ld	b, 0
		ex	de, hl
		sbc	hl, bc
		ex	de, hl
		pop	bc
		di
		ld	d, d
		ld	(bc), a
		ld	b, b
		push	af
		call	Read1
		ld	a, (hl)
		inc	hl
		ld	c, c
		ld	(bc), a
		ld	b, b
		ei
		pop	af
		add	a, c
		ld	c, a
		jr	nc, loc_C4BE
		inc	b

loc_C4BE:				; CODE XREF: RAM:C4BBj
		ld	a, d
		or	e
		jr	nz, loc_C489

loc_C4C2:				; CODE XREF: RAM:C499j
		ld	a, xl
		out	(89h), a	; Y_PORT
		push	hl
		ld	hl, bufTemp	; Temporary Buffer
		ld	de, (wViewTmp1)
		add	hl, de
		ld	de, 4140h
		in	a, (0A2h)
		ex	af, af'
		ld	a, 50h ; 'P'
		out	(0A2h),	a	; Page1
		di
		ld	d, d
		ld	a, 0
		ld	l, l
		ld	a, (hl)
		ld	(de), a
		ld	b, b
		inc	h
		inc	d
		ld	d, d
		ld	a, 40h ; '@'
		ld	l, l
		ld	a, (hl)
		ld	(de), a
		ld	b, b
		ei
		ex	af, af'
		out	(0A2h),	a	; Page1
		pop	hl
		inc	xl
		dec	xh
		jp	nz, loc_C482
		pop	bc
		ld	a, b
		out	(89h), a	; Y_PORT
		ld	a, c
		out	(0A2h),	a	; Page1
		ret
; ---------------------------------------------------------------------------
