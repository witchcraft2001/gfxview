		device	zxspectrum128
		org #8100-#16
EXEHeader	db "EXE"
		db	0
		dw	LoaderStart-EXEHeader	;Header lenght
		dw	0
		dw	LoaderEnd-LoaderStart	;Primary Loader Lenght
		dw	0,0,0
		dw	LoaderStart	; Load address
		dw	LoaderStart	; Start address
		dw	LoaderStart-1	; Stack address
;		org 8100h
LoaderStart
		di
		ld	(wARG),	ix
		ld	a, (ix-3)
		ld	(curFile), a
		ld	hl, strHello	
		ld	c, 5Ch		; PCHARS
		rst	10h
		ld	c, 0		; Version
		rst	10h
		ld	a, d
		or	a
		jr	nz, loc_8152
		ld	hl, strError
		ld	c, 5Ch		;PCHARS
		rst	10h
		ld	bc, 0FF41h	;EXIT
		rst	10h

strError:	db "Incorrect DOS version, need DOS 1.00 or high.\r\n",0

loc_8152:				
		ld	bc, 13Dh	; GETMEM
		rst	10h
		jr	nc, loc_8177
		ld	hl, strNoMemory
		ld	c, 5Ch 		;PCHARS
		rst	10h
		ld	bc, 0FF41h	;EXIT
		rst	10h
; ---------------------------------------------------------------------------
strNoMemory:	db "Not enough memory.\r\n",0
; ---------------------------------------------------------------------------

loc_8177:				
		ld	(idMemGfx), a
		ld	hl, arrPagesGfx
		ld	c, 0C5h		; EMM_FN5
		rst	8
		ld	a, (arrPagesGfx)
		out	(0E2h),	a	; Page3
		ld	hl, 8300h	; To
		ld	de, gfx_main_lenght	; File lenght
		ld	a, (curFile)
		ld	c, 13h		;READ
		rst	10h
		jp	c, exit
		ld	hl, (wARG)	;Проверка аргументов командной строки
		ld	a, 20h ; ' '

loc_8199:				
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
		ld	(idMem), a
		ld	hl, arrPages
		ld	c, 0C5h		; EMM_FN5
		rst	8

loc_81B2:
		ld	a, 0C0h	; 'А'
		out	(89h), a	; Y_PORT
		ld	a, (arrPages)
		out	(0A2h),	a	; Page1
		ld	hl, 4000h
		ld	de, 4000h
		ld	a, (curFile)
		ld	c, 13h		; READ
		rst	10h
		jp	c, exit

loc_81CA:
		ld	a, (arrPages+1)
		out	(0A2h),	a
		ld	hl, 4000h
		ld	de, 4000h
		ld	a, (curFile)
		ld	c, 13h		; READ
		rst	10h
		jp	c, exit
		ld	a, (arrPages+2)
		out	(0A2h),	a
		ld	hl, 4000h
		ld	de, 4000h
		ld	a, (curFile)
		ld	c, 13h		; READ
		rst	10h
		jp	c, exit
		ld	a, (arrPages+3)
		out	(0A2h),	a
		ld	hl, 4000h
		ld	de, 4000h
		ld	a, (curFile)
		ld	c, 13h		; READ
		rst	10h
		jp	c, exit
		ld	a, (arrPages+4)
		out	(0A2h),	a
		ld	hl, 4000h
		ld	de, 4000h
		ld	a, (curFile)
		ld	c, 13h		; READ
		rst	10h
		jp	c, exit

loc_821A:
		ld	a, (curFile)
		ld	c, 12h		; CLOSE
		rst	10h
		ld	ix, (wARG)
		ld	a, (idMemGfx)
		ld	(idMemory), a	; idMemoryGfx to GFXView main programm
		ld	a, (idMem)
		ld	(idMemory1), a	; idMemory to GFXView main programm
		jp	MainStart		; Start	main programm
; ---------------------------------------------------------------------------
strHello:	db "\r\n\r\n"
		db "The GFX Viewer, ver 1.00, Copyright (C)1999 by Enin Anton,"
		db " St-Petersburg.\r\n‚бҐ Їа ў  § йЁйҐ­л.\r\n",0
wARG:		dw 0			; DATA XREF: RAM:8101w	RAM:8194r ...
curFile:	db 0			; DATA XREF: RAM:8108w	RAM:818Br ...
idMemGfx:	db 0			; DATA XREF: RAM:loc_8177w RAM:8224r ...
idMem:		db 0			; DATA XREF: RAM:81A9w	RAM:822Ar ...
arrPagesGfx:	db 0			; DATA XREF: RAM:817Ao	RAM:8180r
		db    0
arrPages:	ds 5, 0
		db    0
; ---------------------------------------------------------------------------

exit:
		ld	a, (curFile)
		ld	c, 12h		; CLOSE
		rst	10h
		ld	a, (idMemGfx)
		ld	c, 3Eh ; '>'    ; RETMEM
		rst	10h
		ld	a, (idMem)
		ld	c, 3Eh ; '>'    ; RETMEM
		rst	10h
		ld	hl, strLoadError
		ld	c, 5Ch		; PCHARS
		rst	10h
		ld	bc, 0FF41h	; EXIT
		rst	10h
; ---------------------------------------------------------------------------
strLoadError:	db "Loading error.\r\n",0
		include "gfx_exp.inc"
LoaderEnd
		savebin	"gfx_loader.bin",EXEHeader,LoaderEnd-EXEHeader