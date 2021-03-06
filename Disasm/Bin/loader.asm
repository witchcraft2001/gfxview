

;
; +-------------------------------------------------------------------------+
; |   This file	has been generated by The Interactive Disassembler (IDA)    |
; |	      Copyright	(c) 2011 Hex-Rays, <support@hex-rays.com>	    |
; |			 License info: 48-327F-7274-B7			    |
; |			       ESET spol. s r.o.			    |
; +-------------------------------------------------------------------------+
;
; Input	MD5   :	1E38F231C544C834E52554CF45252238
; Input	CRC32 :	3367DBC2

; ---------------------------------------------------------------------------
; File Name   :	D:\Develop\zx\Sprinter\GFXVIEW\Disasm\Bin\loader.bin
; Format      :	Binary file
; Base Address:	0000h Range: 8100h - 82D2h Loaded length: 01D2h

; Processor	  : z80	[]
; Target assembler: Zilog Macro	Assembler

; ===========================================================================

; Segment type:	Regular
		segment	RAM
		org 8100h
		di
		ld	(wARG),	ix
		ld	a, (ix+0FDh)
		ld	(curFile), a
		ld	hl, strHello	; "\r\n\r\nThe GFX Viewer, ver 1.00, Copyright"...
		ld	c, 5Ch ; '\'    ; Pchars
		rst	10h
		ld	c, 0		; Version
		rst	10h
		ld	a, d
		or	a
		jr	nz, loc_8152
		ld	hl, strError	; "Incorrect DOS version, need DOS 1.00 or"...
		ld	c, 5Ch ; '\'
		rst	10h
		ld	bc, 0FF41h
		rst	10h
; ---------------------------------------------------------------------------
strError:	.ascii 'Incorrect DOS version, need DOS 1.00 or high.\r\n',0
					; DATA XREF: RAM:8118o
; ---------------------------------------------------------------------------

loc_8152:				; CODE XREF: RAM:8116j
		ld	bc, 13Dh	; GETMEM
		rst	10h
		jr	nc, loc_8177
		ld	hl, strNoMemory	; "Not enough memory.\r\n"
		ld	c, 5Ch ; '\'
		rst	10h
		ld	bc, 0FF41h
		rst	10h
; ---------------------------------------------------------------------------
strNoMemory:	.ascii 'Not enough memory.\r\n',0 ; DATA XREF: RAM:8158o
; ---------------------------------------------------------------------------

loc_8177:				; CODE XREF: RAM:8156j
		ld	(idMemoryGfx), a
		ld	hl, arrPagesGfx
		ld	c, 0C5h	; '�'
		rst	8
		ld	a, (arrPagesGfx)
		out	(0E2h),	a	; Page3
		ld	hl, 8300h	; To
		ld	de, 4552h	; File lenght
		ld	a, (curFile)
		ld	c, 13h
		rst	10h
		jp	c, loc_82A5
		ld	hl, (wARG)
		ld	a, 20h ; ' '

loc_8199:				; CODE XREF: RAM:819Bj
		inc	hl
		cp	(hl)
		jr	c, loc_8199
		ld	a, (hl)
		inc	hl
		cp	20h ; ' '
		jr	z, loc_821A
		ld	bc, 53Dh	; GETMEM
		rst	10h
		jr	c, loc_821A
		ld	(idMemory), a
		ld	hl, arrPages
		ld	c, 0C5h	; '�'
		rst	8

loc_81B2:
		ld	a, 0C0h	; '�'
		out	(89h), a	; Y_PORT
		ld	a, (arrPages)
		out	(0A2h),	a	; Page1
		ld	hl, 4000h
		ld	de, 4000h
		ld	a, (curFile)
		ld	c, 13h		; READ
		rst	10h
		jp	c, loc_82A5

loc_81CA:
		ld	a, (arrPages+1)
		out	(0A2h),	a
		ld	hl, 4000h
		ld	de, 4000h
		ld	a, (curFile)
		ld	c, 13h		; READ
		rst	10h
		jp	c, loc_82A5
		ld	a, (arrPages+2)
		out	(0A2h),	a
		ld	hl, 4000h
		ld	de, 4000h
		ld	a, (curFile)
		ld	c, 13h		; READ
		rst	10h
		jp	c, loc_82A5
		ld	a, (arrPages+3)
		out	(0A2h),	a
		ld	hl, 4000h
		ld	de, 4000h
		ld	a, (curFile)
		ld	c, 13h		; READ
		rst	10h
		jp	c, loc_82A5
		ld	a, (arrPages+4)
		out	(0A2h),	a
		ld	hl, 4000h
		ld	de, 4000h
		ld	a, (curFile)
		ld	c, 13h		; READ
		rst	10h
		jp	c, loc_82A5

loc_821A:				; CODE XREF: RAM:81A1j	RAM:81A7j
		ld	a, (curFile)
		ld	c, 12h
		rst	10h
		ld	ix, (wARG)
		ld	a, (idMemoryGfx)
		ld	(9434h), a	; idMemoryGfx to GFXView main programm
		ld	a, (idMemory)
		ld	(9435h), a	; idMemory to GFXView main programm
		jp	9300h		; Start	main programm
; ---------------------------------------------------------------------------
strHello:	.ascii '\r\n'           ; DATA XREF: RAM:810Bo
		.ascii '\r\n'
		.ascii 'The GFX Viewer, ver 1.00, Copyright (C)1999 by Enin Anton, St'
		.ascii '-Petersburg.\r\n'
		.ascii '�� �ࠢ� ���饭�.\r\n',0
wARG:		dw 0			; DATA XREF: RAM:8101w	RAM:8194r ...
curFile:	db 0			; DATA XREF: RAM:8108w	RAM:818Br ...
idMemoryGfx:	db 0			; DATA XREF: RAM:loc_8177w RAM:8224r ...
idMemory:	db 0			; DATA XREF: RAM:81A9w	RAM:822Ar ...
arrPagesGfx:	db 0			; DATA XREF: RAM:817Ao	RAM:8180r
		db    0
arrPages:	db [ 5 ], 0		; 0 ; DATA XREF: RAM:81ACo RAM:81B6r ...
		db    0
; ---------------------------------------------------------------------------

loc_82A5:				; CODE XREF: RAM:8191j	RAM:81C7j ...
		ld	a, (curFile)
		ld	c, 12h		; CLOSE
		rst	10h
		ld	a, (idMemoryGfx)
		ld	c, 3Eh ; '>'    ; RETMEM
		rst	10h
		ld	a, (idMemory)
		ld	c, 3Eh ; '>'    ; RETMEM
		rst	10h
		ld	hl, strLoadError ; "Loading error.\r\n"
		ld	c, 5Ch ; '\'
		rst	10h
		ld	bc, 0FF41h	; EXIT
		rst	10h
; ---------------------------------------------------------------------------
strLoadError:	.ascii 'Loading error.\r\n',0 ; DATA XREF: RAM:82B7o
		ds 2Eh			; 0
; end of 'RAM'


		end
