; =============== S U B	R O U T	I N E =======================================


readBMP:				; DATA XREF: RAM:tblImageProco

; FUNCTION CHUNK AT BAED SIZE 000002CB BYTES

		sub	a
		ld	(btOpenedFile),	a ; 1 -	открыт файл, 0 - нет
		ld	ix, 8000h
		ld	hl, 0
		ld	de, 0
		ld	bc, 36h	; '6'
		push	ix
		call	doRead		; Чтение данных	в буфер
					; IX - куда
					; BC - сколько
					; HL -?
					; DE -?
		pop	ix
		ld	a, (ix+0)
		cp	42h ; 'B'
		ld	a, 82h ; 'В'
		scf
		ret	nz
		ld	a, (ix+1)
		cp	4Dh ; 'M'
		ld	a, 82h ; 'В'
		scf
		ret	nz
		ld	a, 1
		ld	(btOpenedFile),	a ; 1 -	открыт файл, 0 - нет
		call	setBMP
		ld	l, (ix+0Ah)	; Data offset
		ld	h, (ix+0Bh)
		ld	(wBMPDataOffsetLow), hl	; Data offset
		ld	l, (ix+0Ch)
		ld	h, (ix+0Dh)
		ld	(wBMPDataOffsetHigh), hl
		ld	l, (ix+12h)	; Width	Low word
		ld	h, (ix+13h)
		ld	(wPicSizeX), hl
		ld	a, (ix+14h)	; Width	high word
		or	(ix+15h)
		ld	a, 83h ; 'Г'
		scf
		ret	nz
		ld	l, (ix+16h)	; Height Low word
		ld	h, (ix+17h)
		ld	(wPicSizeY), hl
		ld	a, (ix+18h)	; Height High word
		or	(ix+19h)
		ld	a, 83h ; 'Г'
		scf
		ret	nz
		ld	a, (ix+1Ah)	; biPlanes ==1!
		dec	a
		ld	a, 83h ; 'Г'
		scf
		ret	nz
		ld	a, (ix+1Bh)	; biPlanes high	byte
		or	a
		ld	a, 83h ; 'Г'
		scf
		ret	nz
		ld	a, (ix+1Dh)	; biBitCount, Bit per Pixel high byte
		or	a
		ld	a, 83h ; 'Г'
		scf
		ret	nz
		ld	a, (ix+1Ch)	; biBitCount, Bit per Pixel
		cp	1
		jp	z, bmp1bpp
		cp	4
		jp	z, bmp4bpp
		cp	8
		ld	a, 83h ; 'Г'
		scf
		ret	nz

bmp8bpp:				; 8bpp
		ld	hl, 0Eh
		ld	c, (ix+0Eh)	; biSize low word
		ld	b, (ix+0Fh)	; Пропускаем 1й	и 2й заголовки в файле,	расчет смещения
		add	hl, bc
		ex	de, hl
		ld	hl, 0
		ld	c, (ix+10h)	; biSize High word
		ld	b, (ix+11h)
		adc	hl, bc
		ld	ix, 8000h	; Считываем палитру
		ld	bc, 400h
		push	ix
		call	doRead		; Чтение данных	в буфер
					; IX - куда
					; BC - сколько
					; HL -?
					; DE -?
		pop	hl
		ld	de, 0
		ld	bc, 0FFA4h	; PIC_SET_PAL
		ld	a, 1
		rst	8
		ld	hl, (wPicSizeX)
		ld	a, l		; Размер кратен	8?
		and	3
		jr	z, loc_BE86
		ld	a, l		; выравниваем размер изображения до границы в 8	пикселей
		or	3
		ld	l, a
		inc	hl

loc_BE86:				; CODE XREF: readBMP+C7j
		ld	(wBMPSize8), hl	; Размер BMP кратный 8
		ld	hl, bmpViewNoCompress
		ld	a, (btPicCompress) ; Сжатие файла: 0 - не сжатый; 1 - Не сжатый; 2 - Сжатый RLE	(BMP); 3 - long	series (PCX)
		dec	a
		jp	z, View
		ld	hl, bmpViewCompress
		jp	View
; ---------------------------------------------------------------------------

bmp1bpp:				; CODE XREF: readBMP+87j
		ld	hl, tblPal1
		ld	a, (btPalette)
		or	a
		jr	z, loc_BEA5
		ld	hl, tblPal2

loc_BEA5:				; CODE XREF: readBMP+E8j
		ld	de, 8000h
		ld	bc, 0Ch
		push	de
		ldir
		pop	hl
		ld	de, 300h
		ld	bc, 0FFA4h	; PIC_SET_PAL
		ld	a, 1
		rst	8
		ld	hl, (wPicSizeX)	; Размер кратен	2?
		bit	0, l
		jr	z, loc_BEC0
		inc	hl		; Выравниваем размер

loc_BEC0:				; CODE XREF: readBMP+105j
		srl	h
		rr	l
		srl	h
		rr	l
		srl	h
		rr	l
		ld	a, l
		and	3
		jr	z, loc_BED6
		ld	a, l
		or	3
		ld	l, a
		inc	hl

loc_BED6:				; CODE XREF: readBMP+117j
		ld	(wBMPSize8), hl	; Размер BMP кратный 8
		ld	hl, bmpView1bpp
		jp	View
; ---------------------------------------------------------------------------
tblPal1:	db 0, 0, 0, 0		; DATA XREF: readBMP-3Bo
					; readBMP:bmp1bppo
		db 0, 0, 0, 0
		db 0FFh, 0FFh, 0FFh, 0
tblPal2:	db 0, 0, 0, 0		; DATA XREF: readBMP-36o readBMP+EAo
		db 0FFh, 0FFh, 0FFh, 0
		db 0, 0, 0, 0
; ---------------------------------------------------------------------------

bmp4bpp:				; CODE XREF: readBMP+8Cj
		ld	a, (btPicCompress) ; Сжатие файла: 0 - не сжатый; 1 - Не сжатый; 2 - Сжатый RLE	(BMP); 3 - long	series (PCX)
		dec	a
		ld	a, 83h ; 'Г'
		scf
		ret	nz
		ld	hl, 0Eh
		ld	c, (ix+0Eh)	;  biSize low word
		ld	b, (ix+0Fh)
		add	hl, bc		; Пропускаем 1й	и 2й заголовки в файле,	расчет смещения
		ex	de, hl
		ld	hl, 0
		ld	c, (ix+10h)	;  biSize High word
		ld	b, (ix+11h)
		adc	hl, bc
		ld	ix, 8000h	; читаем палитру
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
		ld	hl, (wPicSizeX)	; Размер кратен	2?
		bit	0, l
		jr	z, loc_BF33
		inc	hl		; выравниваем размер

loc_BF33:				; CODE XREF: readBMP+178j
		srl	h
		rr	l
		ld	a, l
		and	3
		jr	z, loc_BF41
		ld	a, l
		or	3
		ld	l, a
		inc	hl

loc_BF41:				; CODE XREF: readBMP+182j
		ld	(wBMPSize8), hl	; Размер BMP кратный 8
		ld	hl, bmpView4bpp
		jp	View
; End of function readBMP

; ---------------------------------------------------------------------------
wBMPDataOffsetLow:dw 0			; DATA XREF: readBMP+38w RAM:BF96r ...
					; Data offset
wBMPDataOffsetHigh:dw 0			; DATA XREF: readBMP+41w RAM:BF93r ...
wBMPSize8:	dw 0			; DATA XREF: readBMP:loc_BE86w
					; readBMP:loc_BED6w ...
					; Размер BMP кратный 8

; =============== S U B	R O U T	I N E =======================================


setBMP:					; CODE XREF: readBMP+2Fp
		ld	hl, strType	; "        "
		ld	(hl), 42h ; 'B'
		inc	hl
		ld	(hl), 4Dh ; 'M'
		inc	hl
		ld	(hl), 50h ; 'P'
		inc	hl
		ld	b, 5
		ld	a, 20h ; ' '

loc_BF60:				; CODE XREF: setBMP+12j
		ld	(hl), a
		inc	hl
		djnz	loc_BF60
		ld	a, (ix+1Eh)	; RLE?
		or	(ix+1Fh)
		ld	a, 1		; Not compressed
		jr	z, loc_BF70
		ld	a, 2		; Compressed

loc_BF70:				; CODE XREF: setBMP+1Cj
		ld	(btPicCompress), a ; Сжатие файла: 0 - не сжатый; 1 - Не сжатый; 2 - Сжатый RLE	(BMP); 3 - long	series (PCX)
		ld	a, (ix+1Ch)	; BPP
		ld	(btPicBitPerPix), a ; Бит на пиксел
		ret
; End of function setBMP

; ---------------------------------------------------------------------------

bmpViewNoCompress:			; DATA XREF: readBMP+D1o
		push	iy
		in	a, (0A2h)	; Page1
		push	af
		in	a, (89h)	; Y_PORT
		push	af
		ex	de, hl
		ld	hl, (wPicSizeY)
		dec	hl
		or	a
		sbc	hl, de
		dec	h
		jp	p, loc_BF91
		ld	hl, 0

loc_BF91:				; CODE XREF: RAM:BF8Bj
		ld	c, l
		ld	b, h
		ld	hl, (wBMPDataOffsetHigh)
		ld	de, (wBMPDataOffsetLow)	; Data offset
		ld	a, b
		or	c
		jr	z, loc_BFB4
		push	hl
		push	de
		ld	hl, (wBMPSize8)	; Размер BMP кратный 8
		ld	de, 0
		call	mul32		; MUL 32? x32
		ex	de, hl
		ld	c, xl
		ld	b, xh
		pop	hl
		add	hl, bc
		ex	de, hl
		pop	bc
		adc	hl, bc

loc_BFB4:				; CODE XREF: RAM:BF9Cj
		ld	bc, (wPicSizeY)
		ld	a, b
		or	a
		ld	a, c
		jr	z, loc_BFBE
		sub	a

loc_BFBE:				; CODE XREF: RAM:BFBBj
		ld	yl, a
		ld	bc, (wViewTmp1)
		ex	de, hl
		add	hl, bc
		ex	de, hl
		jr	nc, loc_BFCA
		inc	hl

loc_BFCA:				; CODE XREF: RAM:BFC7j
		push	hl
		ld	hl, 140h
		ld	bc, (wPicSizeX)
		or	a
		sbc	hl, bc
		jr	nc, loc_BFDA
		add	hl, bc
		ld	c, l
		ld	b, h

loc_BFDA:				; CODE XREF: RAM:BFD5j
		pop	hl
		ld	ix, bufTemp	; Temporary Buffer

loc_BFDF:				; CODE XREF: RAM:C014j
		push	bc
		push	hl
		push	de
		call	doRead		; Чтение данных	в буфер
					; IX - куда
					; BC - сколько
					; HL -?
					; DE -?
		ld	a, 50h ; 'P'
		out	(0A2h),	a	; Page1
		ld	a, yl
		dec	a
		out	(89h), a	; Y_PORT
		ld	hl, bufTemp	; Temporary Buffer
		ld	de, 4140h
		di
		ld	d, d		; set len
		ld	a, 0
		ld	l, l		; Copy blk
		ld	a, (hl)
		ld	(de), a
		ld	b, b
		inc	h
		inc	d
		ld	d, d		; set len
		ld	a, 40h ; '@'
		ld	l, l		; copy blk
		ld	a, (hl)
		ld	(de), a
		ld	b, b
		ei
		pop	hl
		pop	de
		ld	bc, (wBMPSize8)	; Размер BMP кратный 8
		add	hl, bc
		ex	de, hl
		jr	nc, loc_C011
		inc	hl

loc_C011:				; CODE XREF: RAM:C00Ej
		pop	bc
		dec	yl
		jr	nz, loc_BFDF
		pop	af
		out	(89h), a	; Y_PORT
		pop	af
		out	(0A2h),	a	; Page1
		pop	iy
		ret
; ---------------------------------------------------------------------------

bmpViewCompress:			; DATA XREF: readBMP+DBo
		in	a, (0A2h)	; Page1
		push	af
		in	a, (89h)	; Y_PORT
		push	af
		ex	de, hl
		ld	hl, (wPicSizeY)
		dec	hl
		or	a
		sbc	hl, de
		dec	h
		jp	p, loc_C034
		ld	hl, 0

loc_C034:				; CODE XREF: RAM:C02Ej
		ld	c, l
		ld	b, h
		ld	hl, (wBMPDataOffsetHigh)
		ld	de, (wBMPDataOffsetLow)	; Data offset
		call	Read
		ld	a, b
		or	c
		jr	z, loc_C066
		ld	d, 0

loc_C046:				; CODE XREF: RAM:C04Fj	RAM:C05Cj ...
		call	Read1
		ld	a, (hl)
		inc	hl
		or	a
		jr	z, loc_C051
		inc	hl
		jr	loc_C046
; ---------------------------------------------------------------------------

loc_C051:				; CODE XREF: RAM:C04Cj
		call	Read1
		ld	a, (hl)
		inc	hl
		or	a
		jr	z, loc_C061
		ld	e, a
		add	hl, de
		rra
		jr	nc, loc_C046
		inc	hl
		jr	loc_C046
; ---------------------------------------------------------------------------

loc_C061:				; CODE XREF: RAM:C057j
		dec	bc
		ld	a, b
		or	c
		jr	nz, loc_C046

loc_C066:				; CODE XREF: RAM:C042j
		ld	bc, (wPicSizeY)
		ld	a, b
		or	a
		ld	a, c
		jr	z, loc_C070
		sub	a

loc_C070:				; CODE XREF: RAM:C06Dj
		ld	xl, a

loopRLE:				; CODE XREF: RAM:C10Aj
		ld	de, bufTemp	; Temporary Buffer

loc_C075:				; CODE XREF: RAM:C0C1j	RAM:C0C4j ...
		call	Read1
		ld	a, (hl)
		inc	hl
		or	a
		jr	nz, loc_C0C6
		call	Read1
		ld	a, (hl)
		inc	hl
		or	a
		jr	z, loc_C0DA
		cp	1
		jp	z, loc_C10D
		ld	c, a
		ld	b, 0
		call	Read1
		di
		ld	d, d		; set acc len
		ld	(de), a
		ld	b, b
		push	af
		push	hl
		or	a
		adc	hl, bc
		ld	a, l
		pop	hl
		jp	p, loc_C0B6
		push	af
		sub	a
		sub	l
		ld	c, a
		ld	d, d		; set acc len
		ld	(de), a
		ld	l, l		; copy blk
		ld	a, (hl)
		ld	(de), a
		ld	b, b
		add	hl, bc
		ex	de, hl
		add	hl, bc
		ex	de, hl
		call	Read1
		pop	af
		or	a
		jr	z, loc_C0BE
		ld	c, a
		ld	d, d		; set acc len
		ld	(de), a

loc_C0B6:				; CODE XREF: RAM:C09Bj
		ld	l, l		; copy blk
		ld	a, (hl)
		ld	(de), a
		ld	b, b
		add	hl, bc
		ex	de, hl
		add	hl, bc
		ex	de, hl

loc_C0BE:				; CODE XREF: RAM:C0B1j
		ei
		pop	af
		rra
		jr	nc, loc_C075
		inc	hl
		jr	loc_C075
; ---------------------------------------------------------------------------

loc_C0C6:				; CODE XREF: RAM:C07Bj
		ld	c, a
		ld	b, 0
		call	Read1
		di
		ld	d, d		; set acc len
		ld	(de), a
		ld	b, b
		ld	a, (hl)
		inc	hl
		ld	c, c		; fill
		ld	(de), a
		ld	b, b
		ex	de, hl
		add	hl, bc
		ex	de, hl
		jr	loc_C075
; ---------------------------------------------------------------------------

loc_C0DA:				; CODE XREF: RAM:C083j
		ld	a, xl
		dec	a
		out	(89h), a	; Y_PORT
		push	hl
		ld	hl, bufTemp	; Temporary Buffer
		ld	de, (wViewTmp1)
		add	hl, de
		ld	de, 4140h
		in	a, (0A2h)	; Page1
		ex	af, af'
		ld	a, 50h ; 'P'
		out	(0A2h),	a	; Page1
		di
		ld	d, d		; set acc len
		ld	a, 0
		ld	l, l		; copy blk
		ld	a, (hl)
		ld	(de), a
		ld	b, b
		inc	h
		inc	d
		ld	d, d		; set acc len
		ld	a, 40h ; '@'
		ld	l, l		; copy blk
		ld	a, (hl)
		ld	(de), a
		ld	b, b
		ei
		ex	af, af'
		out	(0A2h),	a	; Page1
		pop	hl
		dec	xl
		jp	nz, loopRLE

loc_C10D:				; CODE XREF: RAM:C087j
		pop	af
		out	(89h), a	; Y_PORT
		pop	af
		out	(0A2h),	a	; Page1
		ret
; ---------------------------------------------------------------------------

bmpView4bpp:				; DATA XREF: readBMP+18Co
		in	a, (0A2h)	; Page1
		push	af
		in	a, (89h)	; Y_PORT
		push	af
		ex	de, hl
		ld	hl, (wPicSizeY)
		dec	hl
		or	a
		sbc	hl, de
		dec	h
		jp	p, loc_C129
		ld	hl, 0

loc_C129:				; CODE XREF: RAM:C123j
		ld	c, l
		ld	b, h
		ld	hl, (wBMPDataOffsetHigh)
		ld	de, (wBMPDataOffsetLow)	; Data offset
		ld	a, b
		or	c
		jr	z, loc_C14C
		push	hl
		push	de
		ld	hl, (wBMPSize8)	; Размер BMP кратный 8
		ld	de, 0
		call	mul32		; MUL 32? x32
		ex	de, hl
		ld	c, xl
		ld	b, xh
		pop	hl
		add	hl, bc
		ex	de, hl
		pop	bc
		adc	hl, bc

loc_C14C:				; CODE XREF: RAM:C134j
		call	Read
		ld	bc, (wPicSizeY)
		ld	a, b
		or	a
		ld	a, c
		jr	z, loc_C159
		sub	a

loc_C159:				; CODE XREF: RAM:C156j
		ld	xl, a
		ld	bc, (wPicSizeX)
		srl	b
		rr	c
		ld	a, 0
		adc	a, a
		ld	(loc_C18B+1), a
		ld	a, (wBMPSize8)	; Размер BMP кратный 8
		sub	c
		ld	(loc_C19B+1), a

loc_C170:				; CODE XREF: RAM:C1D0j
		ld	de, bufTemp	; Temporary Buffer
		push	bc

loc_C174:				; CODE XREF: RAM:C189j
		call	Read1
		ld	a, (hl)
		rrca
		rrca
		rrca
		rrca
		and	0Fh
		ld	(de), a
		inc	de
		ld	a, (hl)
		inc	hl
		and	0Fh
		ld	(de), a
		inc	de
		dec	bc
		ld	a, b
		or	c
		jr	nz, loc_C174

loc_C18B:				; DATA XREF: RAM:C166w
		ld	a, 0
		or	a
		jr	z, loc_C19B
		call	Read1
		ld	a, (hl)
		rrca
		rrca
		rrca
		rrca
		and	0Fh
		ld	(de), a

loc_C19B:				; CODE XREF: RAM:C18Ej
					; DATA XREF: RAM:C16Dw
		ld	bc, 0
		add	hl, bc
		ld	a, xl
		dec	a
		out	(89h), a	; Y_PORT
		push	hl
		ld	hl, bufTemp	; Temporary Buffer
		ld	de, (wViewTmp1)
		add	hl, de
		ld	de, 4140h
		in	a, (0A2h)	; Page1
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
		pop	bc
		dec	xl
		jr	nz, loc_C170
		pop	af
		out	(89h), a	; Y_PORT
		pop	af
		out	(0A2h),	a	; Page1
		ret
; ---------------------------------------------------------------------------

bmpView1bpp:				; DATA XREF: readBMP+121o
		in	a, (0A2h)	; Page1
		push	af
		in	a, (89h)	; Y_PORT
		push	af
		ex	de, hl
		ld	hl, (wPicSizeY)
		dec	hl
		or	a
		sbc	hl, de
		dec	h
		jp	p, loc_C1EE
		ld	hl, 0

loc_C1EE:				; CODE XREF: RAM:C1E8j
		ld	c, l
		ld	b, h
		ld	hl, (wBMPDataOffsetHigh)
		ld	de, (wBMPDataOffsetLow)	; Data offset
		ld	a, b
		or	c
		jr	z, loc_C211
		push	hl
		push	de
		ld	hl, (wBMPSize8)	; Размер BMP кратный 8
		ld	de, 0
		call	mul32		; MUL 32? x32
		ex	de, hl
		ld	c, xl
		ld	b, xh
		pop	hl
		add	hl, bc
		ex	de, hl
		pop	bc
		adc	hl, bc

loc_C211:				; CODE XREF: RAM:C1F9j
		call	Read
		ld	bc, (wPicSizeY)
		ld	a, b
		or	a
		ld	a, c
		jr	z, loc_C21E
		sub	a

loc_C21E:				; CODE XREF: RAM:C21Bj
		ld	xl, a
		ld	bc, (wPicSizeX)
		ld	a, c
		srl	b
		rr	c
		srl	b
		rr	c
		srl	b
		rr	c
		and	7
		ld	(loc_C284+1), a
		ld	a, (wBMPSize8)	; Размер BMP кратный 8
		sub	c
		ld	(loc_C29D+1), a

loc_C23D:				; CODE XREF: RAM:C2D2j
		exx
		ld	de, bufTemp	; Temporary Buffer
		ld	bc, 102h
		exx
		push	bc

loc_C246:				; CODE XREF: RAM:C282j
		call	Read1
		ld	a, (hl)
		inc	hl
		exx
		ex	de, hl
		rlca
		ld	(hl), b
		jr	nc, loc_C252
		ld	(hl), c

loc_C252:				; CODE XREF: RAM:C24Fj
		inc	hl
		rlca
		ld	(hl), b
		jr	nc, loc_C258
		ld	(hl), c

loc_C258:				; CODE XREF: RAM:C255j
		inc	hl
		rlca
		ld	(hl), b
		jr	nc, loc_C25E
		ld	(hl), c

loc_C25E:				; CODE XREF: RAM:C25Bj
		inc	hl
		rlca
		ld	(hl), b
		jr	nc, loc_C264
		ld	(hl), c

loc_C264:				; CODE XREF: RAM:C261j
		inc	hl
		rlca
		ld	(hl), b
		jr	nc, loc_C26A
		ld	(hl), c

loc_C26A:				; CODE XREF: RAM:C267j
		inc	hl
		rlca
		ld	(hl), b
		jr	nc, loc_C270
		ld	(hl), c

loc_C270:				; CODE XREF: RAM:C26Dj
		inc	hl
		rlca
		ld	(hl), b
		jr	nc, loc_C276
		ld	(hl), c

loc_C276:				; CODE XREF: RAM:C273j
		inc	hl
		rlca
		ld	(hl), b
		jr	nc, loc_C27C
		ld	(hl), c

loc_C27C:				; CODE XREF: RAM:C279j
		inc	hl
		ex	de, hl
		exx
		dec	bc
		ld	a, b
		or	c
		jr	nz, loc_C246

loc_C284:				; DATA XREF: RAM:C233w
		ld	a, 0
		or	a
		jr	z, loc_C29D
		ld	xh, a
		call	Read1
		ld	a, (hl)
		exx
		ex	de, hl

loc_C291:				; CODE XREF: RAM:C299j
		rlca
		ld	(hl), b
		jr	nc, loc_C296
		ld	(hl), c

loc_C296:				; CODE XREF: RAM:C293j
		inc	hl
		dec	xh
		jr	nz, loc_C291
		ex	de, hl
		exx

loc_C29D:				; CODE XREF: RAM:C287j
					; DATA XREF: RAM:C23Aw
		ld	bc, 0
		add	hl, bc
		ld	a, xl
		dec	a
		out	(89h), a	; Y_PORT
		push	hl
		ld	hl, bufTemp	; Temporary Buffer
		ld	de, (wViewTmp1)
		add	hl, de
		ld	de, 4140h
		in	a, (0A2h)	; Page1
		ex	af, af'
		ld	a, 50h ; 'P'
		out	(0A2h),	a	; Page1
		di
		ld	d, d
		ld	a, 0
		ld	l, l		; Copy blk
		ld	a, (hl)
		ld	(de), a
		ld	b, b
		inc	h
		inc	d
		ld	d, d
		ld	a, 40h ; '@'
		ld	l, l		; Copy blk
		ld	a, (hl)
		ld	(de), a
		ld	b, b
		ei
		ex	af, af'
		out	(0A2h),	a	; Page1
		pop	hl
		pop	bc
		dec	xl
		jp	nz, loc_C23D
		pop	af
		out	(89h), a	; Y_PORT
		pop	af
		out	(0A2h),	a	; Page1
		ret
; ---------------------------------------------------------------------------
