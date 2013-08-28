; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR readBMP

View:					; CODE XREF: readBMP+D8j readBMP+DEj ...
		ld	(viewProc+1), hl
		ld	hl, 0
		ld	(wViewTmp1), hl
		ld	(wViewTmp2), hl
		ld	hl, bufTemp	; Temporary Buffer
		ld	de, bufTemp+1	; Temporary Buffer
		ld	bc, 0FFFh
		ld	(hl), 0
		ldir
		call	clear1Screen
		call	mouseReleaseBtns ; Wait	for release all	buttons	on mouse
		ld	c, 2		; Hide Cursor
		rst	30h
		ld	bc, 154h	; SELPAGE
		rst	10h
		ld	c, 3		; READ MOUSE STATE
		rst	30h
		ld	(crdMouseX+1), hl
		ld	(crdMouseY+1), de

loopViewer:				; CODE XREF: readBMP-11j readBMP-3j
					; DATA XREF: ...
		ld	hl, (wViewTmp2)

viewProc:				; DATA XREF: readBMP:Vieww
		call	0

loopV:					; CODE XREF: readBMP-214j readBMP-20Fj ...
		ld	a, (MouseOn)	; флаг мышки - вкл/выкл
		or	a
		jr	nz, loc_BBA1
		ld	c, 3		; READ MOUSE STATE
		rst	30h
		bit	0, a
		jp	nz, clkLeftBtn	; Pressed Left Btn

crdMouseX:				; DATA XREF: readBMP-2A2w readBMP-284w ...
		ld	bc, 0
		ld	(crdMouseX+1), hl
		or	a
		sbc	hl, bc
		jp	nz, loc_BBFC

crdMouseY:				; DATA XREF: readBMP-29Fw readBMP-278w ...
		ld	bc, 0
		ld	(crdMouseY+1), de
		or	a
		ex	de, hl
		sbc	hl, bc
		jp	nz, loc_BC6A
		ld	hl, (crdMouseX+1)
		ld	a, h
		or	l
		jr	nz, loc_BB5E
		ld	c, 3		; READ MOUSE STATE
		rst	30h
		ld	hl, 0A0h ; 'а'
		ld	(crdMouseX+1), hl
		ld	c, 4		; GOTO MOUSE CURSOR
		rst	30h

loc_BB5E:				; CODE XREF: readBMP-268j
		ld	hl, (crdMouseX+1)
		ld	bc, 13Fh
		or	a
		sbc	hl, bc
		jr	nz, loc_BB75
		ld	c, 3		; READ MOUSE STATE
		rst	30h
		ld	hl, 0A0h ; 'а'
		ld	(crdMouseX+1), hl
		ld	c, 4		; GOTO MOUSE CURSOR
		rst	30h

loc_BB75:				; CODE XREF: readBMP-251j
		ld	hl, (crdMouseY+1)
		ld	a, h
		or	l
		jr	nz, loc_BB89
		ld	c, 3		; READ MOUSE STATE
		rst	30h
		ld	de, 80h	; 'А'
		ld	(crdMouseY+1), de
		ld	c, 4		; MOVE MOUSE CURSOR
		rst	30h

loc_BB89:				; CODE XREF: readBMP-23Ej
		ld	hl, (crdMouseY+1)
		ld	bc, 0FFh
		or	a
		sbc	hl, bc
		jr	nz, loc_BBA1
		ld	c, 3		; READ MOUSE STATE
		rst	30h
		ld	de, 80h	; 'А'
		ld	(crdMouseY+1), de
		ld	c, 4		; GOTO MOUSE CURSOR
		rst	30h

loc_BBA1:				; CODE XREF: readBMP-291j readBMP-226j
		ld	c, 31h ; '1'    ; SCANKEY
		rst	10h
		jp	z, loopV
		ld	a, b
		or	a
		jp	nz, loopV
		ld	a, e
		cp	1Bh
		jr	z, clkLeftBtn
		cp	0Dh
		jr	z, clkLeftBtn
		cp	20h ; ' '
		jr	z, clkLeftBtn
		cp	2Ah ; '*'
		jp	z, InvertPal	; Возможно это инвертирование палитры
		cp	2Bh ; '+'
		jp	z, zoomIn
		cp	2Dh ; '-'
		jp	z, zoomOut
		or	a
		jp	nz, loopV
		ld	hl, loopV
		push	hl
		ld	a, d
		cp	54h ; 'T'
		jp	z, loc_BCC3
		cp	56h ; 'V'
		jp	z, loc_BCE5
		cp	58h ; 'X'
		jp	z, loc_BD22
		cp	52h ; 'R'
		jp	z, loc_BD40
		pop	hl
		jp	loopV
; ---------------------------------------------------------------------------

clkLeftBtn:				; CODE XREF: readBMP-28Aj readBMP-209j ...
		ld	bc, 54h	; 'T'   ; SELPAGE
		rst	10h
		ld	a, (MouseOn)	; флаг мышки - вкл/выкл
		or	a
		ret	nz
		ld	c, 1		; SHOW MOUSE CURSOR
		rst	30h
		call	SetMsCursorArrow
		call	mouseReleaseBtns ; Wait	for release all	buttons	on mouse
		ret
; ---------------------------------------------------------------------------

loc_BBFC:				; CODE XREF: readBMP-27Ej
		ld	bc, loopV
		push	bc
		jr	c, loc_BC22
		ex	de, hl
		ld	hl, (wPicSizeX)
		ld	bc, 140h
		or	a
		sbc	hl, bc
		ret	c
		ld	hl, (wViewTmp1)
		ld	a, h
		or	l
		ret	z
		sbc	hl, de
		jr	nc, loc_BC1A
		ld	hl, 0

loc_BC1A:				; CODE XREF: readBMP-1A3j
		ld	(wViewTmp1), hl
		ld	hl, loopViewer
		ex	(sp), hl
		ret
; ---------------------------------------------------------------------------

loc_BC22:				; CODE XREF: readBMP-1B8j
		ex	de, hl
		ld	hl, (wPicSizeX)
		ld	bc, 140h
		or	a
		sbc	hl, bc
		ret	c
		ld	hl, 0
		or	a
		sbc	hl, de
		ex	de, hl
		ld	hl, (wViewTmp1)
		push	hl
		ld	bc, 140h
		add	hl, bc
		ld	bc, (wPicSizeX)
		or	a
		sbc	hl, bc
		pop	hl
		ret	z
		add	hl, de
		ld	e, l
		ld	d, h
		ld	bc, 140h
		add	hl, bc
		ld	bc, (wPicSizeX)
		or	a
		sbc	hl, bc
		jr	z, loc_BC61
		jr	c, loc_BC61
		ld	hl, (wPicSizeX)
		ld	bc, 140h
		or	a
		sbc	hl, bc
		ex	de, hl

loc_BC61:				; CODE XREF: readBMP-165j readBMP-163j
		ld	(wViewTmp1), de
		ld	hl, loopViewer
		ex	(sp), hl
		ret
; ---------------------------------------------------------------------------

loc_BC6A:				; CODE XREF: readBMP-270j
		ld	bc, loopV
		push	bc
		jr	c, loc_BC8B
		ex	de, hl
		ld	hl, (wPicSizeY)
		dec	h
		ret	m
		ld	hl, (wViewTmp2)
		ld	a, h
		or	l
		ret	z
		sbc	hl, de
		jr	nc, loc_BC83
		ld	hl, 0

loc_BC83:				; CODE XREF: readBMP-13Aj
		ld	(wViewTmp2), hl
		ld	hl, loopViewer
		ex	(sp), hl
		ret
; ---------------------------------------------------------------------------

loc_BC8B:				; CODE XREF: readBMP-14Aj
		ex	de, hl
		ld	hl, 0
		or	a
		sbc	hl, de
		ex	de, hl
		ld	hl, (wPicSizeY)
		dec	h
		ret	m
		ld	hl, (wViewTmp2)
		push	hl
		inc	h
		ld	bc, (wPicSizeY)
		or	a
		sbc	hl, bc
		pop	hl
		ret	z
		add	hl, de
		ld	e, l
		ld	d, h
		inc	h
		ld	bc, (wPicSizeY)
		or	a
		sbc	hl, bc
		jr	z, loc_BCBA
		jr	c, loc_BCBA
		ld	de, (wPicSizeY)
		dec	d

loc_BCBA:				; CODE XREF: readBMP-107j readBMP-105j
		ex	de, hl
		ld	(wViewTmp2), hl
		ld	hl, loopViewer
		ex	(sp), hl
		ret
; ---------------------------------------------------------------------------

loc_BCC3:				; CODE XREF: readBMP-1E5j
		ld	hl, (wPicSizeX)
		ld	de, 140h
		or	a
		sbc	hl, de
		ret	c
		ld	hl, (wViewTmp1)
		ld	a, h
		or	l
		ret	z
		ld	de, 10h
		sbc	hl, de
		jr	nc, loc_BCDD
		ld	hl, 0

loc_BCDD:				; CODE XREF: readBMP-E0j
		ld	(wViewTmp1), hl
		ld	hl, loopViewer
		ex	(sp), hl
		ret
; ---------------------------------------------------------------------------

loc_BCE5:				; CODE XREF: readBMP-1E0j
		ld	hl, (wPicSizeX)
		ld	de, 140h
		or	a
		sbc	hl, de
		ret	c
		ld	hl, (wViewTmp1)
		ld	de, 10h
		add	hl, de
		ld	e, l
		ld	d, h
		ld	bc, 140h
		add	hl, bc
		ld	bc, (wPicSizeX)
		or	a
		sbc	hl, bc
		jr	z, loc_BD19
		jr	c, loc_BD19
		ld	a, h
		or	a
		jr	nz, loc_BD0F
		ld	a, l
		cp	10h
		ret	z

loc_BD0F:				; CODE XREF: readBMP-AFj
		ld	hl, (wPicSizeX)
		ld	bc, 140h
		or	a
		sbc	hl, bc
		ex	de, hl

loc_BD19:				; CODE XREF: readBMP-B5j readBMP-B3j
		ld	(wViewTmp1), de
		ld	hl, loopViewer
		ex	(sp), hl
		ret
; ---------------------------------------------------------------------------

loc_BD22:				; CODE XREF: readBMP-1DBj
		ld	hl, (wPicSizeY)
		dec	h
		ret	m
		ld	hl, (wViewTmp2)
		ld	a, h
		or	l
		ret	z
		ld	de, 10h
		or	a
		sbc	hl, de
		jr	nc, loc_BD38
		ld	hl, 0

loc_BD38:				; CODE XREF: readBMP-85j
		ld	(wViewTmp2), hl
		ld	hl, loopViewer
		ex	(sp), hl
		ret
; ---------------------------------------------------------------------------

loc_BD40:				; CODE XREF: readBMP-1D6j
		ld	hl, (wPicSizeY)
		dec	h
		ret	m
		ld	hl, (wViewTmp2)
		ld	de, 10h
		add	hl, de
		ld	e, l
		ld	d, h
		inc	h
		ld	bc, (wPicSizeY)
		or	a
		sbc	hl, bc
		jr	z, loc_BD67
		jr	c, loc_BD67
		ld	a, h
		or	a
		jr	nz, loc_BD62
		ld	a, l
		cp	10h
		ret	z

loc_BD62:				; CODE XREF: readBMP-5Cj
		ld	de, (wPicSizeY)
		dec	d

loc_BD67:				; CODE XREF: readBMP-62j readBMP-60j
		ex	de, hl
		ld	(wViewTmp2), hl
		ld	hl, loopViewer
		ex	(sp), hl
		ret
; ---------------------------------------------------------------------------

InvertPal:				; CODE XREF: readBMP-1FDj
		ld	a, (btPicBitPerPix) ; Возможно это инвертирование палитры
		dec	a
		ret	nz
		ld	a, (btPalette)
		xor	1
		ld	(btPalette), a
		ld	hl, tblPal1
		jr	z, loc_BD85
		ld	hl, tblPal2

loc_BD85:				; CODE XREF: readBMP-38j
		ld	de, 8000h
		ld	bc, 0Ch
		push	de
		ldir
		pop	hl
		ld	de, 300h
		ld	bc, 0FFA4h	; PIC_SET_PAL
		ld	a, 1
		rst	8		; BIOS
		jp	loopV
; ---------------------------------------------------------------------------

zoomIn:					; CODE XREF: readBMP-1F8j
		ld	a, (btCountZoom)
		cp	2
		jp	z, loopV
		inc	a
		ld	(btCountZoom), a
		jp	loopViewer
; ---------------------------------------------------------------------------

zoomOut:				; CODE XREF: readBMP-1F3j
		ld	a, (btCountZoom)
		or	a
		jp	z, loopV
		dec	a
		ld	(btCountZoom), a
		jp	loopViewer

;┬ъы■ўхэшх сшсышюЄхъ юЄюсЁрцхэш  Ёрчышўэ√ї ЇюЁьрЄют

		include	"gfx_vbmp.asm"
		include	"gfx_vpcx.asm"
		include	"gfx_vico.asm"
		include	"gfx_vscr.asm"

