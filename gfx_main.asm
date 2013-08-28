		device zxspectrum128
		org 8300h
GFXviewStart
		include "gfx_pal.asm"
		insert	"font.bin"
arrPages1:	ds 100h, 0		; 0 ; DATA XREF: Read+61o sub_AFF7o ...
byte_9100:	ds 200h, 0		; 0 ; DATA XREF: Read+3Cr sub_AFF7+Ao	...
; ---------------------------------------------------------------------------

MainStart:
		di
		ld	(getArgument+1), ix
		ld	sp, 92FFh
		sub	a
		out	(0FEh),	a
		call	InitHW
		call	getArgument
		call	getMemDrv
		call	showMenus
		call	changeDrive
		call	readDirectory

MainLoop:				; CODE XREF: RAM:9328j	RAM:9331j ...
		halt
		ld	ix, tblMsMain
		call	testCoords	; Проверка координат мыши
		ld	c, 31h ; '1'    ; SCANKEY
		rst	10h
		jr	z, MainLoop
		res	7, d
		ld	a, b
		and	30h ; '0'
		cp	30h ; '0'
		jr	z, MainLoop
		ld	a, b
		and	0E0h ; 'р'
		jr	nz, MainLoop
		ld	ix, tblKeyMain1
		bit	4, b
		jr	nz, loc_9344
		ld	ix, tblKeyMain

loc_9344:				; CODE XREF: RAM:933Ej	RAM:9360j
		ld	a, (ix+0)
		inc	ix
		cp	0FFh
		jr	z, MainLoop
		ld	l, a
		ld	h, (ix+0)
		inc	ix
		ld	c, (ix+0)
		inc	ix
		ld	b, (ix+0)
		inc	ix
		or	a
		sbc	hl, de
		jr	nz, loc_9344
		ld	hl, MainLoop
		push	hl
		push	bc
		ret
; ---------------------------------------------------------------------------

quit:					; CODE XREF: RAM:9A1Aj
					; DATA XREF: RAM:9A30o	...
		call	returnResurces	; Освобождает память и закрывает файл
		call	restoreHW	; Восстановление параметров
		ld	a, (idMemory)
		ld	c, 3Eh ; '>'    ; RETMEM
		rst	10h
		ld	bc, 41h	; 'A'   ; EXIT
		rst	10h
; ---------------------------------------------------------------------------
bDrvCount:	db 0			; DATA XREF: changeDrive+21r
					; getMemDrv:loc_AFCBw ...
					; Количество устройств в системе
strMask:	db '*.*',0          ; DATA XREF: getDirso getFileso
ptrFiles:	dw 0			; DATA XREF: readDir+23w
					; addDirDescriptorr ...
wFilesCnt2:	dw 0			; DATA XREF: readDir+3Cw readDir+65w ...
wFilesCnt1:	dw 0			; DATA XREF: readDir+39w
					; readDir:loc_9B51r ...
wFilesPage:	dw 0			; DATA XREF: readDir+14w prtFiles+2Er	...
wFilesCursor:	dw 0			; DATA XREF: readDir+18w spr0d+11r ...
wNumFiles:	dw 0			; DATA XREF: readDir+1Cw readDir+32w ...
					; Количество файлов
bufFile:	ds 21h, 0		; DATA XREF: openFile+3o openFile+11o	...
specFile:	ds 0Fh, 0		; DATA XREF: openFile+69o
					; extDefinition+8o
specFileTmp:	ds 18h, 0		; DATA XREF: RAM:9752o	RAM:AFF1o ...
fileManipulator:db 0			; DATA XREF: fileRead+2Ar fileRead+34r ...
idMemory2:	db 0			; DATA XREF: RAM:AFE8r
					; openFile:loc_BA63w
memAllocated:	db 0			; DATA XREF: Readr Read1+1Dr ...
fileSizeLow:	dw 0			; DATA XREF: openFile+1Bw RAM:C36Cr
fileSizeHigh:	dw 0			; DATA XREF: openFile+24w RAM:C369r
offLow:		dw 0			; DATA XREF: Read+10w Read+50r ...
offHigh:	dw 0			; DATA XREF: Read+7w Read+43r	...
bufStack:	dw 0			; DATA XREF: fileRead:loc_A588r
					; extDefinitionw
btOpenedFile:	db 0			; DATA XREF: RAM:fnFileInfor
					; getMemDrv+7Cw ...
					; 1 - открыт файл, 0 - нет
wPicSizeX:	dw 0			; DATA XREF: RAM:978Dr	readBMP-1B5r ...
wPicSizeY:	dw 0			; DATA XREF: RAM:9797r	readBMP-147r ...
btCountZoom:	db 0			; DATA XREF: readBMP:zoomInr
					; readBMP-14w ...
wViewTmp1:	dw 0			; DATA XREF: readBMP-2C5w readBMP-1ABr ...
wViewTmp2:	dw 0			; DATA XREF: readBMP-2C2w
					; readBMP:loopViewerr ...
btPalette:	db 0			; DATA XREF: readBMP-43r readBMP-3Ew ...
strType:	db '        '       ; DATA XREF: RAM:loc_976Eo setBMPo ...
btPicBitPerPix:	db 0			; DATA XREF: RAM:97AAr
					; readBMP:InvertPalr ...
					; Бит на пиксел
btPicCompress:	db 0			; DATA XREF: RAM:97B6r	readBMP+D4r ...
					; Сжатие файла:	0 - не сжатый; 1 - Не сжатый; 2	- Сжатый RLE (BMP); 3 -	long series (PCX)
aUnknown:	db 'unknown'        ; DATA XREF: RAM:97B0o
		ds 5, 20h
		ds 3, 2Dh
		ds 9, 20h
aRle:		db 'RLE'
		ds 9, 20h
aLongSeries:	db 'long series'
		db  20h
strExt:		db 'BMPPCXICO',0    ; DATA XREF: filterExt+7o
					; extDefinition+Bo
tblImageProc:	dw readBMP		; DATA XREF: extDefinition+4o
		dw readPCX		; PCX?
		dw readICO
MouseOn:	db 0			; DATA XREF: RAM:mouseSwitchONOFFr
					; RAM:ABDAw ...
					; флаг мышки - вкл/выкл
idMemory:	db 0EEh			; DATA XREF: RAM:936Er	RAM:9456r ...
idMemory1:	db 0E9h			; DATA XREF: sub_AFF7+3r sub_AFF7+4Fr
idMemory3:	db 0			; DATA XREF: getMemDrv:memOKw
					; getMemDrv+75r
arrPages3:	db 0, 0, 0		; DATA XREF: readDir+6r readDir+90w ...
					; Массив выделенных страниц
		db    0
; ---------------------------------------------------------------------------

getArgument:				; CODE XREF: RAM:930Ep
					; DATA XREF: RAM:9301w
		ld	hl, 0
		ld	a, 20h ; ' '

loc_9440:				; CODE XREF: RAM:9442j
		inc	hl
		cp	(hl)
		jr	c, loc_9440
		ld	a, (hl)
		inc	hl
		cp	20h ; ' '
		ret	nz
		push	hl
		pop	ix
		call	openFile
		push	af
		call	closeFile	; Закрыть файл,	если был открыт
		call	restoreHW	; Восстановление параметров
		ld	a, (idMemory)
		ld	c, 3Eh ; '>'    ; RETMEM
		rst	10h
		pop	af
		ld	b, 0
		jr	nc, exitDOS
		ld	hl, aDosError	; "DOS error"
		bit	7, a
		jr	z, loc_946B
		ld	hl, aUnsupportForma ; "Unsupport format"

loc_946B:				; CODE XREF: RAM:9466j
		and	7Fh ; ''
		jr	z, exitDOS
		dec	a
		jr	z, loc_947C
		ld	e, a
		ld	bc, 0FFFFh
		sub	a

loc_9477:				; CODE XREF: RAM:947Aj
		cpir
		dec	e
		jr	nz, loc_9477

loc_947C:				; CODE XREF: RAM:9470j
		ld	c, 5Ch ; '\'    ; PCHARS
		rst	10h
		ld	a, '.'
		ld	c, 5Bh ; '['    ; PUTCHAR
		rst	10h
		ld	a, 0Dh
		ld	c, 5Bh ; '['    ; PUTCHAR
		rst	10h
		ld	a, 0Ah
		ld	c, 5Bh ; '['    ; PUTCHAR
		rst	10h
		ld	b, 0FFh

exitDOS:				; CODE XREF: RAM:945Fj	RAM:946Dj
		ld	c, 41h ; 'A'    ; EXIT
		rst	10h

mnuHelp:				; DATA XREF: RAM:B61Do	RAM:B74Do ...
		ld	hl, 98h	; 'Ш'
		ld	de, 44h	; 'D'
		ld	bc, 8080h
		call	CopyToBuffAcc
		call	makeWindow
; ---------------------------------------------------------------------------
		db 98h,	0, 44h,	0, 80h,	0, 80h,	0
		db 2, 3, 0, 3, 0, 7Ah, 0, 0Ah
		db 0, 0, 1, 36h, 0, 4, 0
		db  0Fh
aHelp_0:	db 'Help',0
		db 1, 34h, 0, 14h, 0
		db    0
aKeys:		db 'Keys:',0
		db 1, 1Ah, 0, 20h, 0, 0, 1Bh, 18h
		db 19h,	1Ah, 20h
aHomeEnd:	db 'Home End ',0
		db 1, 14h, 0, 2Ah, 0, 0
aPageupPagedown:db 'PageUp PageDown',0
		db 1, 34h, 0, 34h, 0, 0
aEnter:		db 'Enter',0
		db 1, 0Ah, 0, 40h, 0, 0
aAltA__iChangeD:db 'Alt+A..I - Change drive',0
		db 1, 5, 0, 4Ch, 0, 0
aAltEscSetResMo:db 'Alt+Esc - Set,Res mouse',0
		db 1, 18h, 0, 58h, 0, 0
aEscQuitToDos:	db 'Esc - Quit to DOS',0
		db 4, 30h, 0, 6Ah, 0, 23h, 0, 0Eh
		db 0, 1, 3Ch, 0, 6Dh, 0, 0
aOk:		db 'Ok',0
		db    0
; ---------------------------------------------------------------------------

loc_9569:				; CODE XREF: RAM:9573j	RAM:9577j ...
		ld	ix, tblMsHelp
		call	testCoords	; Проверка координат мыши
		ld	c, 31h ; '1'    ; SCANKEY
		rst	10h
		jr	z, loc_9569
		ld	a, b
		or	a
		jr	nz, loc_9569
		ld	a, e
		cp	1Bh
		jr	z, leaveHelp
		cp	0Dh
		jr	z, leaveHelp
		res	5, a
		cp	4Fh ; 'O'
		jr	nz, loc_9569

leaveHelp:				; CODE XREF: RAM:957Cj	RAM:9580j
					; DATA XREF: ...
		ld	hl, 98h	; 'Ш'
		ld	de, 44h	; 'D'
		ld	bc, 8080h
		call	CopyFromBuffAcc
		ret
; ---------------------------------------------------------------------------

mnuInfo:				; DATA XREF: RAM:B62Do	RAM:B759o ...
		ld	c, 0		; VERSION
		rst	10h
		ld	hl,  aDosVersion+0Dh
		ld	a, d
		call	verToText
		ld	(hl), '.'
		inc	hl
		ld	a, e
		call	verToText
		ld	hl,  aFreeMemory+0Dh
		ld	b, 6
		ld	a, 20h ; ' '

loc_95AD:				; CODE XREF: RAM:95AFj
		ld	(hl), a
		inc	hl
		djnz	loc_95AD
		ld	c, 3Ch ; '<'    ; FREEMEM
		rst	10h
		push	bc
		ld	b, 4

loc_95B7:				; CODE XREF: RAM:95BBj
		sla	l
		rl	h
		djnz	loc_95B7
		ld	ix,  aMemory+8
		call	memToText
		pop	hl
		ld	b, 4

loc_95C7:				; CODE XREF: RAM:95CBj
		sla	l
		rl	h
		djnz	loc_95C7
		ld	ix,  aFreeMemory+0Dh
		call	memToText
		ld	hl, 0A8h ; 'и'
		ld	de, 50h	; 'P'
		ld	bc, 7278h
		call	CopyToBuffAcc
		call	makeWindow
; ---------------------------------------------------------------------------
		db 0A8h, 0, 50h, 0, 78h, 0, 72h, 0
		db 2, 3, 0, 3, 0, 72h, 0, 0Ah
		db 0, 0, 1, 2Eh, 0, 4, 0, 0Fh
aSystem_0:	db 'System',0
		db 1, 8, 0, 14h, 0, 0
aAuthorEninAnto:db 'Author: Enin Anton',0
		db 1, 8, 0, 1Eh, 0, 0
aViewerVersion1:db 'Viewer version: 1.00',0
		db 1, 8, 0, 28h, 0, 0
aLastEdition01_:db 'Last edition: 01.11.99',0
		db 1, 8, 0, 3Ah, 0, 0
aDosVersion:	db 'DOS version:       ',0 ; DATA XREF: RAM:9598o
		db 1, 8, 0, 44h, 0, 0
aMemory:	db 'Memory:       ',0 ; DATA XREF: RAM:95BDo
		db 1, 8, 0, 4Eh, 0, 0
aFreeMemory:	db 'Free memory:       ',0 ; DATA XREF: RAM:95A6o
					; RAM:95CDo
		db 4, 30h, 0, 5Dh, 0, 23h, 0, 0Eh
		db 0, 1, 3Ch, 0, 60h, 0, 0
aOk_0:		db 'Ok',0
		db    0
; ---------------------------------------------------------------------------

loc_96AF:				; CODE XREF: RAM:loc_96B9j RAM:96BDj ...
		ld	ix, tblMsInfo
		call	testCoords	; Проверка координат мыши
		ld	c, 31h ; '1'    ; SCANKEY
		rst	10h

loc_96B9:
		jr	z, loc_96AF
		ld	a, b
		or	a
		jr	nz, loc_96AF
		ld	a, e
		cp	1Bh
		jr	z, leaveInfo
		cp	0Dh
		jr	z, leaveInfo
		res	5, a
		cp	4Fh ; 'O'
		jr	nz, loc_96AF

leaveInfo:				; CODE XREF: RAM:96C2j	RAM:96C6j
					; DATA XREF: ...
		ld	hl, 0A8h ; 'и'
		ld	de, 50h	; 'P'
		ld	bc, 7278h
		call	CopyFromBuffAcc
		ret

; =============== S U B	R O U T	I N E =======================================


verToText:				; CODE XREF: RAM:959Cp	RAM:95A3p
		ld	b, 2Fh ; '/'
		ld	c, 0

loc_96DF:				; CODE XREF: verToText+7j
		inc	b
		sub	64h ; 'd'
		jr	nc, loc_96DF
		add	a, 64h ; 'd'
		ex	af, af'
		ld	a, b
		cp	30h ; '0'
		jr	z, loc_96EE
		set	0, c

loc_96EE:				; CODE XREF: verToText+Fj
		bit	0, c
		jr	z, loc_96F4
		ld	(hl), a
		inc	hl

loc_96F4:				; CODE XREF: verToText+15j
		ex	af, af'
		ld	b, 2Fh ; '/'

loc_96F7:				; CODE XREF: verToText:loc_96FAj
		inc	b
		sub	0Ah

loc_96FA:
		jr	nc, loc_96F7
		add	a, 0Ah
		ex	af, af'
		ld	a, b
		cp	30h ; '0'
		jr	z, loc_9706
		set	0, c

loc_9706:				; CODE XREF: verToText+27j
		bit	0, c
		jr	z, loc_970C
		ld	(hl), a
		inc	hl

loc_970C:				; CODE XREF: verToText+2Dj
		ex	af, af'
		add	a, 30h ; '0'
		ld	(hl), a
		inc	hl
		ret
; End of function verToText


; =============== S U B	R O U T	I N E =======================================


memToText:				; CODE XREF: RAM:95C1p	RAM:95D1p
		ld	e, 0
		ld	bc, 3E8h	; 1000
		call	divideBC
		ld	bc, 64h	; 'd'   ; 100
		call	divideBC
		ld	bc, 0Ah		; 10
		call	divideBC
		ld	a, l
		add	a, 30h ; '0'
		ld	(ix+0),	a
		ld	(ix+1),	4Bh ; 'K'
		ld	(ix+2),	62h ; 'b'
		ret
; End of function memToText


; =============== S U B	R O U T	I N E =======================================


divideBC:				; CODE XREF: memToText+5p memToText+Bp ...
		ld	a, 2Fh ; '/'
		or	a

loc_9738:				; CODE XREF: divideBC+6j
		inc	a
		sbc	hl, bc
		jr	nc, loc_9738
		add	hl, bc
		cp	30h ; '0'
		jr	z, loc_9744
		set	0, e

loc_9744:				; CODE XREF: divideBC+Bj
		bit	0, e
		ret	z
		ld	(ix+0),	a
		inc	ix
		ret
; End of function divideBC

; ---------------------------------------------------------------------------

fnFileInfo:				; DATA XREF: RAM:B63Do	RAM:B761o ...
		ld	a, (btOpenedFile) ; 1 -	открыт файл, 0 - нет
		or	a
		ret	z
		ld	hl, specFileTmp
		ld	de,  aName+7
		ld	b, 8

loc_975A:				; CODE XREF: RAM:9762j
		ld	a, (hl)
		cp	'.'
		jr	z, loc_9764
		ld	(de), a
		inc	hl
		inc	de
		djnz	loc_975A

loc_9764:				; CODE XREF: RAM:975Dj
		ld	a, b
		or	a
		jr	z, loc_976E
		ld	a, ' '

loc_976A:				; CODE XREF: RAM:976Cj
		ld	(de), a
		inc	de
		djnz	loc_976A

loc_976E:				; CODE XREF: RAM:9766j
		ld	hl, strType	; "        "
		ld	de,  aFormat+9
		ld	bc, 8
		ldir
		ld	hl,  aWidth+8
		ld	de,  aHeight+9
		ld	b, 0Ch
		ld	a, ' '

loc_9783:				; CODE XREF: RAM:9787j
		ld	(hl), a
		inc	hl
		ld	(de), a
		inc	de
		djnz	loc_9783
		ld	ix,  aWidth+8
		ld	hl, (wPicSizeX)
		call	resolToText
		ld	ix,  aHeight+9
		ld	hl, (wPicSizeY)
		call	resolToText
		ld	hl,  aBitsPerPixel+11h
		push	hl
		ld	b, 8
		ld	a, ' '

loc_97A5:				; CODE XREF: RAM:97A7j
		ld	(hl), a
		inc	hl
		djnz	loc_97A5
		pop	hl
		ld	a, (btPicBitPerPix) ; Бит на пиксел
		call	bppToText
		ld	hl, aUnknown	; "unknown"
		ld	de,  aEncoding+0Bh
		ld	a, (btPicCompress) ; Сжатие файла: 0 - не сжатый; 1 - Не сжатый; 2 - Сжатый RLE	(BMP); 3 - long	series (PCX)
		add	a, a
		add	a, a
		ld	c, a
		add	a, a
		add	a, c
		ld	c, a
		ld	b, 0
		add	hl, bc
		ld	bc, 0Bh
		ldir
		ld	hl, 0A8h ; 'и'
		ld	de, 60h	; '`'
		ld	bc, 7278h
		call	CopyToBuffAcc
		call	makeWindow
; ---------------------------------------------------------------------------
		db 0A8h, 0, 60h, 0, 78h, 0, 72h, 0
		db 2, 3, 0, 3, 0, 72h, 0, 0Ah
		db 0, 0, 1, 31h, 0, 4, 0, 0Fh
aImage_0:	db 'Image',0
		db 1, 8, 0, 14h, 0, 0
aName:		db 'Name:          ',0 ; DATA XREF: RAM:9755o
		db 1, 8, 0, 1Eh, 0, 0
aFormat:	db 'Format:          ',0 ; DATA XREF: RAM:9771o
		db 1, 8, 0, 2Ch, 0, 0
aWidth:		db 'Width:              ',0 ; DATA XREF: RAM:9779o
					; RAM:9789o
		db 1, 8, 0, 36h, 0, 0
aHeight:	db 'Height:              ',0 ; DATA XREF: RAM:977Co
					; RAM:9793o
		db 1, 8, 0, 40h, 0, 0
aBitsPerPixel:	db 'Bits per pixel:          ',0
		db 1, 8, 0, 4Eh, 0, 0
aEncoding:	db 'Encoding:             ',0 ; DATA XREF: RAM:97B3o
		db 4, 18h, 0, 5Dh, 0, 23h, 0, 0Eh
		db 0, 1, 24h, 0, 60h, 0, 0
aOk_1:		db 'Ok',0
		db 4, 42h, 0, 5Dh, 0, 23h, 0, 0Eh
		db 0, 1, 49h, 0, 60h, 0, 0
aView:		db 'View',0
		db    0
; ---------------------------------------------------------------------------

loc_98BD:				; CODE XREF: RAM:98C7j	RAM:98CBj ...
		ld	ix, tblMsFileInfo
		call	testCoords	; Проверка координат мыши
		ld	c, 31h ; '1'
		rst	10h
		jr	z, loc_98BD
		ld	a, b
		or	a
		jr	nz, loc_98BD
		ld	a, e
		cp	1Bh
		jr	z, leaveFileInfo
		cp	0Dh
		jr	z, leaveFileInfo
		res	5, a
		cp	4Fh ; 'O'
		jr	z, leaveFileInfo
		cp	56h ; 'V'
		jr	nz, loc_98BD

errFileInfo:				; DATA XREF: RAM:B891o
		call	extDefinition
		jr	nc, loc_98BD
		push	af
		call	leaveFileInfo
		pop	af
		call	showError
		ret

; =============== S U B	R O U T	I N E =======================================


leaveFileInfo:				; CODE XREF: RAM:98D0j	RAM:98D4j ...
		ld	hl, 0A8h ; 'и'
		ld	de, 60h	; '`'
		ld	bc, 7278h
		call	CopyFromBuffAcc
		ret
; End of function leaveFileInfo


; =============== S U B	R O U T	I N E =======================================


resolToText:				; CODE XREF: RAM:9790p	RAM:979Ap
		ld	e, 0
		ld	bc, 2710h	; 10000
		call	divBCIX
		ld	bc, 3E8h	; 1000
		call	divBCIX
		ld	bc, 64h	; 'd'   ; 100
		call	divBCIX
		ld	bc, 0Ah		; 10
		call	divBCIX
		ld	a, l
		add	a, 30h ; '0'
		ld	(ix+0),	a
		ld	(ix+1),	20h ; ' '
		ld	(ix+2),	70h ; 'p'
		ld	(ix+3),	69h ; 'i'
		ld	(ix+4),	78h ; 'x'
		ld	(ix+5),	65h ; 'e'
		ld	(ix+6),	6Ch ; 'l'
		ld	(ix+7),	73h ; 's'
		ret
; End of function resolToText


; =============== S U B	R O U T	I N E =======================================


divBCIX:				; CODE XREF: resolToText+5p
					; resolToText+Bp ...
		ld	a, 2Fh ; '/'
		or	a

loc_993B:				; CODE XREF: divBCIX+6j
		inc	a
		sbc	hl, bc
		jr	nc, loc_993B
		add	hl, bc
		cp	30h ; '0'
		jr	z, loc_9947
		set	0, e

loc_9947:				; CODE XREF: divBCIX+Bj
		bit	0, e
		ret	z
		ld	(ix+0),	a
		inc	ix
		ret
; End of function divBCIX


; =============== S U B	R O U T	I N E =======================================


bppToText:				; CODE XREF: RAM:97ADp
		ld	b, 2Fh ; '/'
		ld	c, 0

loc_9954:				; CODE XREF: bppToText+7j
		inc	b
		sub	64h ; 'd'
		jr	nc, loc_9954
		add	a, 64h ; 'd'
		ex	af, af'
		ld	a, b
		cp	30h ; '0'
		jr	z, loc_9963
		set	0, c

loc_9963:				; CODE XREF: bppToText+Fj
		bit	0, c
		jr	z, loc_9969
		ld	(hl), a
		inc	hl

loc_9969:				; CODE XREF: bppToText+15j
		ex	af, af'
		ld	b, 2Fh ; '/'

loc_996C:				; CODE XREF: bppToText+1Fj
		inc	b
		sub	0Ah
		jr	nc, loc_996C
		add	a, 0Ah
		ex	af, af'
		ld	a, b
		cp	30h ; '0'
		jr	z, loc_997B
		set	0, c

loc_997B:				; CODE XREF: bppToText+27j
		bit	0, c
		jr	z, loc_9981
		ld	(hl), a
		inc	hl

loc_9981:				; CODE XREF: bppToText+2Dj
		ex	af, af'
		add	a, 30h ; '0'
		ld	(hl), a
		inc	hl
		ld	(hl), 20h ; ' '
		inc	hl
		ld	(hl), 62h ; 'b'
		inc	hl
		ld	(hl), 69h ; 'i'
		inc	hl
		ld	(hl), 74h ; 't'
		inc	hl
		ld	(hl), 73h ; 's'
		ret
; End of function bppToText

; ---------------------------------------------------------------------------

dlgQuit:				; DATA XREF: RAM:B5EFo	RAM:B64Do ...
		ld	hl, 0A8h ; 'и'
		ld	de, 74h	; 't'
		ld	bc, 3C80h
		call	CopyToBuffAcc
		call	makeWindow
; ---------------------------------------------------------------------------
		db 0A8h, 0, 74h, 0, 80h, 0, 3Ch, 0
		db 2, 3, 0, 3, 0, 7Ah, 0, 0Ah
		db 0, 0, 1, 38h, 0, 4, 0, 0Fh
aQuit_0:	db 'Quit',0
		db 1, 24h, 0, 14h, 0, 0
aAreYouSure?:	db 'Are you sure?',0
		db 4, 18h, 0, 24h, 0, 23h, 0, 0Eh
		db 0, 1, 20h, 0, 27h, 0, 0
aYes:		db 'Yes',0
		db 4, 48h, 0, 24h, 0, 23h, 0, 0Eh
		db 0, 1, 53h, 0, 27h, 0, 0
aNo:		db 'No',0
		db    0
; ---------------------------------------------------------------------------

loopQuit:				; CODE XREF: RAM:9A05j	RAM:9A09j ...
		ld	ix, tblMsQuit
		call	testCoords	; Проверка координат мыши
		ld	c, 31h ; '1'    ; SCANKEY
		rst	10h
		jr	z, loopQuit
		ld	a, b
		or	a
		jr	nz, loopQuit
		ld	a, e
		cp	1Bh
		jr	z, leaveQuit
		cp	0Dh
		scf
		jr	z, leaveQuit
		res	5, a
		cp	59h ; 'Y'
		scf
		jp	z, quit
		cp	4Eh ; 'N'
		jr	nz, loopQuit

leaveQuit:				; CODE XREF: RAM:9A0Ej	RAM:9A13j
					; DATA XREF: ...
		ld	hl, 0A8h ; 'и'
		ld	de, 74h	; 't'
		ld	bc, 3C80h
		push	af
		call	CopyFromBuffAcc
		pop	af
		ret	nc
		ld	hl, quit
		ex	(sp), hl
		ret

; =============== S U B	R O U T	I N E =======================================


changeDrive:				; CODE XREF: RAM:9317p	showError+B5p ...
		ld	hl, 3Bh	; ';'
		ld	(word_9AA5), hl
		ld	(word_9ABB), hl
		ld	a, 41h ; 'A'
		ld	(strDrv1), a	; " :"
		ld	a, 41h ; 'A'
		ld	(strDrv2), a	; " :"
		ld	c, 2		; CURDISK
		rst	10h
		ld	c, a
		push	iy
		ld	iy, tblMSDrives
		ld	ix, tblKbdDrives
		ld	a, (bDrvCount)	; Количество устройств в системе
		ld	b, a

loc_9A5A:				; CODE XREF: changeDrive+5Aj
		push	iy
		push	ix
		push	bc
		ld	a, c
		or	a
		push	af
		call	nz, showWndDrv1
		pop	af
		call	z, showWndDrv2
		ld	hl, (word_9AA5)
		ld	de, (word_9AA9)
		add	hl, de
		ld	(word_9AA5), hl
		ld	(word_9ABB), hl
		ld	hl, strDrv1	; " :"
		inc	(hl)
		ld	hl, strDrv2	; " :"
		inc	(hl)
		pop	bc
		dec	c
		pop	ix
		ld	de, 4
		add	ix, de
		pop	iy
		ld	de, 10h
		add	iy, de
		djnz	loc_9A5A
		ld	(ix+0),	0FFh
		ld	(iy+0),	0
		ld	(iy+1),	80h ; 'А'
		pop	iy
		ret
; End of function changeDrive

; ---------------------------------------------------------------------------

showWndDrv1:				; CODE XREF: changeDrive+2Dp
		call	makeWindow
; ---------------------------------------------------------------------------
		db  13h
		db    0
word_9AA5:	dw 0			; DATA XREF: changeDrive+3w
					; changeDrive+34r ...
		db  23h	; #
		db    0
word_9AA9:	dw 0Eh			; DATA XREF: changeDrive+37r
		db 1, 0Dh, 0, 3, 0, 0
strDrv1:	db ' :',0           ; DATA XREF: changeDrive+Bw
					; changeDrive+42o
		db    0
; ---------------------------------------------------------------------------
		ret
; ---------------------------------------------------------------------------

showWndDrv2:				; CODE XREF: changeDrive+31p
		call	makeWindow
; ---------------------------------------------------------------------------
		db  13h
		db    0
word_9ABB:	dw 0			; DATA XREF: changeDrive+6w
					; changeDrive+3Fw
		db 23h,	0, 0Eh,	0, 2, 2, 0, 2
		db 0, 1Fh, 0, 0Ah, 0, 4, 1, 0Dh
		db 0, 3, 0, 0Fh
strDrv2:	db ' :',0           ; DATA XREF: changeDrive+10w
					; changeDrive+46o
		db    0
; ---------------------------------------------------------------------------
		ret

; =============== S U B	R O U T	I N E =======================================


readDirectory:				; CODE XREF: RAM:931Ap	showError+B8p ...
		call	prtDirName
		call	SetMsCursorWait
		call	readDir
		call	sub_AA16
		call	prtFiles
		call	prtFileInfo
		call	spr0d
		call	SetMsCursorArrow
		ret
; End of function readDirectory


; =============== S U B	R O U T	I N E =======================================


readDir:				; CODE XREF: readDirectory+6p
		in	a, (0A2h)
		push	af
		in	a, (0E2h)
		push	af
		ld	a, (arrPages3)	; Массив выделенных страниц
		out	(0A2h),	a
		ld	a, (arrPages3+1) ; Массив выделенных страниц
		out	(0E2h),	a
		ld	ix, 0
		ld	(wFilesPage), ix
		ld	(wFilesCursor),	ix
		ld	(wNumFiles), ix	; Количество файлов
		ld	hl, 4000h
		ld	(ptrFiles), hl
		ld	a, 0C0h	; '└'
		out	(89h), a
		sub	a
		ld	(hl), a
		call	getDirs		; Поиск	папок?
		call	getFiles	; Поиск	файлов?
		ld	(wNumFiles), ix	; Количество файлов
		ld	hl, 0C000h
		ld	(wFilesCnt1), hl
		ld	(wFilesCnt2), hl
		sub	a
		ld	(hl), a
		ld	ix, 4000h
		ld	hl, 4000h
		push	ix
		push	hl
		sub	a
		cp	(hl)
		jr	z, loc_9B51

loc_9B3E:				; CODE XREF: readDir+60j
		bit	4, (ix+0Fh)
		push	hl
		call	nz, sub_9B89
		pop	hl
		ld	bc, 18h
		add	ix, bc
		add	hl, bc
		sub	a
		cp	(hl)
		jr	nz, loc_9B3E

loc_9B51:				; CODE XREF: readDir+4Dj
		ld	hl, (wFilesCnt1)
		ld	(wFilesCnt2), hl
		sub	a
		ld	(hl), a
		pop	hl
		pop	ix
		sub	a
		cp	(hl)
		jr	z, loc_9B73

loc_9B60:				; CODE XREF: readDir+82j
		bit	4, (ix+0Fh)
		push	hl
		call	z, sub_9B89
		pop	hl
		ld	bc, 18h
		add	ix, bc
		add	hl, bc
		sub	a
		cp	(hl)
		jr	nz, loc_9B60

loc_9B73:				; CODE XREF: readDir+6Fj
		ld	hl, (wFilesCnt1)
		sub	a
		ld	(hl), a
		in	a, (0A2h)
		ld	(arrPages3+1), a ; Массив выделенных страниц
		in	a, (0E2h)
		ld	(arrPages3), a	; Массив выделенных страниц
		pop	af
		out	(0E2h),	a	; Page3
		pop	af
		out	(0A2h),	a	; Page1
		ret
; End of function readDir


; =============== S U B	R O U T	I N E =======================================


sub_9B89:				; CODE XREF: readDir+54p readDir+76p
		ex	de, hl
		ld	hl, (wFilesCnt2)

loc_9B8D:				; CODE XREF: sub_9B89+1Ej
		sub	a
		cp	(hl)
		jp	z, loc_9BA9
		push	de
		push	hl
		ld	b, 0Eh

loc_9B96:				; CODE XREF: sub_9B89+13j
		ld	a, (de)
		cp	(hl)
		jr	nz, loc_9B9E
		inc	de
		inc	hl
		djnz	loc_9B96

loc_9B9E:				; CODE XREF: sub_9B89+Fj
		pop	hl
		pop	de
		jp	c, loc_9BA9
		ld	bc, 18h
		add	hl, bc
		jr	loc_9B8D
; ---------------------------------------------------------------------------

loc_9BA9:				; CODE XREF: sub_9B89+6j sub_9B89+17j
		push	de
		push	hl
		ex	de, hl
		ld	hl, (wFilesCnt1)
		push	hl
		or	a
		sbc	hl, de
		ld	c, l
		ld	b, h
		pop	de
		ld	hl, 18h
		add	hl, de
		ld	(wFilesCnt1), hl
		sub	a
		ld	(hl), a
		ex	de, hl
		dec	hl
		dec	de
		ld	a, b
		or	c
		jr	z, loc_9BC8
		lddr

loc_9BC8:				; CODE XREF: sub_9B89+3Bj
		pop	de
		pop	hl
		ld	bc, 18h
		ldir
		ret
; End of function sub_9B89


; =============== S U B	R O U T	I N E =======================================

; Поиск	папок?

getDirs:				; CODE XREF: readDir+2Cp
		ld	hl, strMask	; "*.*"
		ld	de, 8000h	; Buffer
		ld	bc, 119h	; F_FIRST
		ld	a, 10h		; 10h -	subdirectory
		push	ix
		push	de
		rst	10h
		pop	hl
		pop	ix
		ret	c

findNext:				; CODE XREF: getDirs+23j
		call	addDirDescriptor
		ld	de, 8000h	; Buffer
		ld	bc, 11Ah	; F_NEXT
		push	ix
		push	de
		rst	10h
		pop	hl
		pop	ix
		jr	nc, findNext
		ret
; End of function getDirs


; =============== S U B	R O U T	I N E =======================================


addDirDescriptor:			; CODE XREF: getDirs:findNextp
		ld	de, (ptrFiles)
		ld	bc, 18h
		ex	de, hl
		add	hl, bc
		sbc	hl, bc
		ex	de, hl
		ret	c
		push	hl
		ld	bc, 20h	; ' '
		add	hl, bc
		ld	a, (hl)
		inc	hl
		ld	b, (hl)
		inc	hl
		ld	c, (hl)
		pop	hl
		bit	4, a
		ret	z
		ld	a, b
		cp	2Eh ; '.'
		jr	nz, loc_9C1A
		ld	a, c
		cp	21h ; '!'
		ret	c

loc_9C1A:				; CODE XREF: addDirDescriptor+1Ej
		push	hl
		ld	bc, 20h	; ' '
		add	hl, bc
		ld	a, (hl)
		inc	hl
		ex	af, af'
		ld	c, 0Fh
		ld	a, 3Ch ; '<'
		ld	(de), a
		inc	de
		dec	c
		sub	a

loc_9C2A:				; CODE XREF: addDirDescriptor+37j
		ldi
		cp	(hl)
		jr	nz, loc_9C2A
		ld	a, 3Eh ; '>'
		ld	(de), a
		inc	de
		dec	c
		ld	b, c
		sub	a

loc_9C36:				; CODE XREF: addDirDescriptor+42j
		ld	(de), a
		inc	de
		djnz	loc_9C36
		pop	hl
		ex	af, af'
		ld	(de), a
		inc	de
		push	hl
		ld	bc, 1Ch
		add	hl, bc
		ldi
		ldi
		ldi
		ldi
		pop	hl
		ld	bc, 16h
		add	hl, bc
		ldi
		ldi
		ldi
		ldi
		inc	ix
		ld	(ptrFiles), de
		sub	a
		ld	(de), a
		ret
; End of function addDirDescriptor


; =============== S U B	R O U T	I N E =======================================

; Поиск	файлов?

getFiles:				; CODE XREF: readDir+2Fp
		ld	hl, strMask	; "*.*"
		ld	de, 8000h	; buffer
		ld	bc, 119h	; F_FIRST
		ld	a, 27h ; '''    ; Attribute:
					; 01h -	Read Only file
					; 02h -	Hidden file
					; 04h -	System file
					; 20h -	Archive
		push	ix
		push	de
		rst	10h
		pop	hl
		pop	ix
		ret	c

loc_9C74:				; CODE XREF: getFiles+23j
		call	addFileDescriptor
		ld	de, 8000h	; buffer
		ld	bc, 11Ah	; F_NEXT
		push	ix
		push	de
		rst	10h
		pop	hl
		pop	ix
		jr	nc, loc_9C74
		ret
; End of function getFiles


; =============== S U B	R O U T	I N E =======================================


addFileDescriptor:			; CODE XREF: getFiles:loc_9C74p
		push	ix
		push	hl
		call	filterExt
		pop	hl
		pop	ix
		ret	nz
		ld	de, (ptrFiles)
		ld	bc, 18h
		ex	de, hl
		add	hl, bc
		sbc	hl, bc
		ex	de, hl
		ret	c
		push	hl
		ld	bc, 20h	; ' '
		add	hl, bc
		ld	a, (hl)
		inc	hl
		ex	af, af'
		ld	c, 0Fh
		ld	a, (hl)

loc_9CA9:				; CODE XREF: addFileDescriptor+2Bj
		call	checkSymbols
		ld	(de), a
		inc	hl
		inc	de
		dec	c
		ld	a, (hl)
		or	a
		jr	nz, loc_9CA9
		ld	b, c
		sub	a

loc_9CB6:				; CODE XREF: addFileDescriptor+31j
		ld	(de), a
		inc	de
		djnz	loc_9CB6
		pop	hl
		ex	af, af'
		ld	(de), a
		inc	de
		push	hl
		ld	bc, 1Ch
		add	hl, bc
		ldi
		ldi
		ldi
		ldi
		pop	hl
		ld	bc, 16h
		add	hl, bc
		ldi
		ldi
		ldi
		ldi
		inc	ix
		ld	(ptrFiles), de
		sub	a
		ld	(de), a
		ret
; End of function addFileDescriptor


; =============== S U B	R O U T	I N E =======================================


checkSymbols:				; CODE XREF: addFileDescriptor:loc_9CA9p
		cp	41h ; 'A'
		ret	c
		cp	5Bh ; '['
		jr	nc, loc_9CEB
		set	5, a
		ret
; ---------------------------------------------------------------------------

loc_9CEB:				; CODE XREF: checkSymbols+5j
		cp	80h ; 'А'
		ret	c
		cp	0A0h ; 'а'
		ret	nc
		set	5, a
		cp	90h ; 'Р'
		ret	c
		set	6, a
		res	4, a
		ret
; End of function checkSymbols


; =============== S U B	R O U T	I N E =======================================

; Проверка поддерживаемых расширений файлов

filterExt:				; CODE XREF: addFileDescriptor+3p
		push	hl
		pop	ix
		ld	de, 21h	; '!'
		add	hl, de
		ld	de, strExt	; "BMPPCXICO"
		ld	a, 2Eh ; '.'

loc_9D07:				; CODE XREF: filterExt+Ej
		inc	hl
		cp	(hl)
		jr	nz, loc_9D07
		inc	hl
		ex	de, hl

loc_9D0D:				; CODE XREF: filterExt+28j
		push	de
		ld	bc, 300h

loc_9D11:				; CODE XREF: filterExt+20j
		ld	a, (de)
		res	5, a
		cp	(hl)
		jr	z, loc_9D19
		set	0, c

loc_9D19:				; CODE XREF: filterExt+1Aj
		inc	hl
		inc	de
		djnz	loc_9D11
		pop	de
		ld	a, c
		or	a
		ret	z
		sub	a
		cp	(hl)
		jr	nz, loc_9D0D
		ld	l, (ix+1Ch)
		ld	h, (ix+1Dh)
		ld	e, (ix+1Eh)
		ld	d, (ix+1Fh)
		ld	a, d
		or	e
		or	l
		ret	nz
		ld	a, h
		cp	18h
		ret	z
		cp	1Bh
		ret
; End of function filterExt


; =============== S U B	R O U T	I N E =======================================


fileNumToAddr:				; CODE XREF: prtFiles+31p spr0d+16p ...
		add	hl, hl
		add	hl, hl
		add	hl, hl
		ld	e, l
		ld	d, h
		add	hl, hl
		add	hl, de
		set	6, h
		set	7, h
		ret
; End of function fileNumToAddr


; =============== S U B	R O U T	I N E =======================================


prtDirName:				; CODE XREF: readDirectoryp
		ld	c, 2		; CURDISK
		rst	10h
		ld	hl, 8000h
		add	a, 41h ; 'A'
		ld	(hl), a
		inc	hl
		ld	(hl), 3Ah ; ':'
		inc	hl
		ld	c, 1Eh		; CURDIR
		rst	10h
		ld	ix, 8000h
		ld	hl, 0
		ld	b, l
		ld	a, (ix+0)

loc_9D63:				; CODE XREF: prtDirName+32j
		inc	ix
		ld	e, a
		ld	d, 87h ; 'З'
		ld	a, (de)
		ld	c, a
		add	hl, bc
		ld	de, 0C0h ; '└'
		ex	de, hl
		or	a
		sbc	hl, de
		add	hl, de
		ex	de, hl
		jr	c, loc_9D98
		ld	a, (ix+0)
		or	a
		jr	nz, loc_9D63

loc_9D7C:				; CODE XREF: prtDirName+5Cj
		ld	hl, 3Dh	; '='
		ld	de, 2Ch	; ','
		ld	bc, 9C6h
		ld	a, 8
		call	FillWndAcc	; Fill window with accelerator
					; HL - X
					; E - Y
					; C - Lenght
					; B - Height
		ld	hl, 8000h
		ld	de, 40h	; '@'
		ld	bc, 2Dh	; '-'
		sub	a
		call	prtString
		ret
; ---------------------------------------------------------------------------

loc_9D98:				; CODE XREF: prtDirName+2Cj
		ld	(ix-1), 2Eh ; '.'
		ld	(ix+0),	2Eh ; '.'
		ld	(ix+1),	0
		jr	loc_9D7C
; End of function prtDirName


; =============== S U B	R O U T	I N E =======================================


prtFiles:				; CODE XREF: readDirectory+Cp
					; RAM:B383p ...
		ld	hl, 3Dh	; '='
		ld	de, 3Ah	; ':'
		ld	b, 82h ; 'В'
		ld	c, 61h ; 'a'
		ld	a, 8
		call	FillWndAcc	; Fill window with accelerator
					; HL - X
					; E - Y
					; C - Lenght
					; B - Height
		ld	hl, 0A2h ; 'в'
		ld	de, 3Ah	; ':'
		ld	b, 82h ; 'В'
		ld	c, 61h ; 'a'
		ld	a, 8
		call	FillWndAcc	; Fill window with accelerator
					; HL - X
					; E - Y
					; C - Lenght
					; B - Height
		ld	hl, (wNumFiles)	; Количество файлов
		ld	a, h
		or	l
		jp	z, loc_AA3D
		in	a, (0E2h)
		push	af
		ld	a, (arrPages3)	; Массив выделенных страниц
		out	(0E2h),	a
		ld	hl, (wFilesPage)
		call	fileNumToAddr
		push	hl
		ld	hl, tblFilesCoord
		ld	b, 20h ; ' '

loc_9DE0:				; CODE XREF: prtFiles+52j
		ld	e, (hl)
		inc	hl
		ld	c, (hl)
		inc	hl
		ex	(sp), hl
		push	hl
		push	bc
		sub	a
		ld	b, a
		ld	d, a
		call	prtString
		pop	bc
		pop	hl
		ld	de, 18h
		add	hl, de
		sub	a
		cp	(hl)
		jr	z, loc_9DFA
		ex	(sp), hl
		djnz	loc_9DE0

loc_9DFA:				; CODE XREF: prtFiles+4Fj
		pop	hl
		pop	af
		out	(0E2h),	a
		call	loc_AA3D
		ret
; End of function prtFiles

; ---------------------------------------------------------------------------
tblFilesCoord:	db 41h,	3Bh, 41h, 43h, 41h, 4Bh, 41h, 53h; 0 ; DATA XREF: prtFiles+35o
					; spr0d+1Do
		db 41h,	5Bh, 41h, 63h, 41h, 6Bh, 41h, 73h; 8
		db 41h,	7Bh, 41h, 83h, 41h, 8Bh, 41h, 93h; 10h
		db 41h,	9Bh, 41h, 0A3h,	41h, 0ABh, 41h,	0B3h; 18h
		db 0A6h, 3Bh, 0A6h, 43h, 0A6h, 4Bh, 0A6h, 53h; 20h
		db 0A6h, 5Bh, 0A6h, 63h, 0A6h, 6Bh, 0A6h, 73h; 28h
		db 0A6h, 7Bh, 0A6h, 83h, 0A6h, 8Bh, 0A6h, 93h; 30h
		db 0A6h, 9Bh, 0A6h, 0A3h, 0A6h,	0ABh, 0A6h, 0B3h; 38h

; =============== S U B	R O U T	I N E =======================================


spr0d:					; CODE XREF: readDirectory+12p
					; RAM:B191p ...
		ld	a, 0Dh
		jr	printFilename
; ---------------------------------------------------------------------------

sprNull:				; CODE XREF: RAM:B18Ap	RAM:loc_B1A4p ...
		sub	a

printFilename:				; CODE XREF: spr0d+2j
		ex	af, af'
		in	a, (0E2h)
		push	af
		ld	a, (arrPages3)	; Массив выделенных страниц
		out	(0E2h),	a
		ld	hl, (wFilesPage)
		ld	de, (wFilesCursor)
		add	hl, de
		call	fileNumToAddr
		ld	ix, (wFilesCursor)
		ld	de, tblFilesCoord
		add	ix, ix
		add	ix, de
		ld	e, (ix+0)
		ld	c, (ix+1)
		sub	a
		ld	b, a
		ld	d, a
		ld	a, (hl)
		or	a
		jr	z, loc_9E77
		ex	af, af'
		call	prtString

loc_9E77:				; CODE XREF: spr0d+2Fj
		pop	af
		out	(0E2h),	a
		ret
; End of function spr0d


; =============== S U B	R O U T	I N E =======================================


prtFileInfo:				; CODE XREF: readDirectory+Fp
					; RAM:B194p ...
		push	iy
		in	a, (0E2h)	; Page3
		push	af
		ld	a, (arrPages3)	; Массив выделенных страниц
		out	(0E2h),	a	; Page3
		ld	hl, (wFilesPage)
		ld	de, (wFilesCursor)
		add	hl, de
		call	fileNumToAddr
		set	7, h
		push	hl
		pop	iy
		ld	de, strSpace	; "     "
		call	calcSize
		ld	de, strDate	; "  .  .  "
		call	calcDate
		ld	de, strTime	; "  :  "
		call	calcTime
		ld	hl, 3Dh	; '='
		ld	de, 0CEh ; '╬'
		ld	bc, 0AC6h
		ld	a, 8
		call	FillWndAcc	; Fill window with accelerator
					; HL - X
					; E - Y
					; C - Lenght
					; B - Height
		push	iy
		pop	hl
		ld	a, (hl)
		or	a
		jr	z, loc_9EED
		ld	de, 3Eh	; '>'
		ld	bc, 0D0h ; '╨'
		sub	a
		call	prtString
		ld	hl, strSpace	; "     "
		ld	de, 9Bh	; 'Ы'
		ld	bc, 0D0h ; '╨'
		sub	a
		call	prtString
		ld	hl, strDate	; "  .  .  "
		ld	de, 0BBh ; '╗'
		ld	bc, 0D0h ; '╨'
		sub	a
		call	prtString
		ld	hl, strTime	; "  :  "
		ld	de, 0E8h ; 'ш'
		ld	bc, 0D0h ; '╨'
		sub	a
		call	prtString

loc_9EED:				; CODE XREF: prtFileInfo+3Fj
		pop	af
		out	(0E2h),	a	; Page3
		pop	iy
		ret
; End of function prtFileInfo


; =============== S U B	R O U T	I N E =======================================


calcSize:				; CODE XREF: prtFileInfo+1Dp

; FUNCTION CHUNK AT 9F7B SIZE 00000009 BYTES

		bit	4, (iy+0Fh)
		jp	nz, putDIRStr
		res	7, (iy+0Fh)
		ld	a, 49h ; 'I'
		ld	(loc_9F55+1), a
		push	de
		ld	c, (iy+10h)
		ld	e, 0
		ld	d, (iy+11h)
		ld	l, (iy+12h)
		ld	h, (iy+13h)

loc_9F12:				; CODE XREF: calcSize+39j calcSize+48j
		srl	h
		rr	l
		rr	d
		rr	e
		srl	h
		rr	l
		rr	d
		rr	e
		ld	a, (loc_9F55+1)
		add	a, 2
		ld	(loc_9F55+1), a
		ld	a, h
		or	a
		jr	nz, loc_9F12
		ld	h, l
		ld	l, d
		ld	a, e
		or	c
		jr	z, loc_9F35
		inc	hl

loc_9F35:				; CODE XREF: calcSize+3Fj
		push	hl
		ld	bc, 0D8F0h	; -10000
		add	hl, bc
		pop	hl
		jr	c, loc_9F12
		pop	de
		ld	bc, 3E8h	; 1000
		call	divBC
		ld	bc, 64h	; 'd'   ; 100
		call	divBC
		ld	bc, 0Ah		; 10
		call	divBC
		ld	a, l		; 0
		add	a, 30h ; '0'
		ld	(de), a
		inc	de

loc_9F55:				; DATA XREF: calcSize+Dw calcSize+2Fr	...
		ld	a, 0
		ld	(de), a
		ret
; End of function calcSize


; =============== S U B	R O U T	I N E =======================================


divBC:					; CODE XREF: calcSize+4Ep calcSize+54p ...
		ld	a, 2Fh ; '/'
		or	a

loc_9F5C:				; CODE XREF: divBC+6j
		inc	a
		sbc	hl, bc
		jr	nc, loc_9F5C
		add	hl, bc
		cp	30h ; '0'
		jr	z, loc_9F6A
		set	7, (iy+0Fh)

loc_9F6A:				; CODE XREF: divBC+Bj
		bit	7, (iy+0Fh)
		jr	nz, loc_9F72
		ld	a, 20h ; ' '

loc_9F72:				; CODE XREF: divBC+15j
		ld	(de), a
		inc	de
		ret
; End of function divBC

; ---------------------------------------------------------------------------
strSpace:	db '     ',0        ; DATA XREF: prtFileInfo+1Ao
					; prtFileInfo+4Bo
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR calcSize

putDIRStr:				; CODE XREF: calcSize+4j
		ld	hl, aDir	; "<DIR>"
		ld	bc, 5
		ldir
		ret
; END OF FUNCTION CHUNK	FOR calcSize
; ---------------------------------------------------------------------------
aDir:		db '<DIR>'          ; DATA XREF: calcSize:putDIRStro

; =============== S U B	R O U T	I N E =======================================


calcDate:				; CODE XREF: prtFileInfo+23p
		ex	de, hl
		ld	a, (iy+16h)
		and	1Fh
		call	div10
		inc	hl
		ld	c, (iy+16h)
		ld	b, (iy+17h)
		srl	b
		rr	c
		srl	b
		rr	c
		srl	b
		rr	c
		srl	b
		rr	c
		srl	b
		rr	c
		ld	a, c
		and	0Fh
		call	div10
		inc	hl
		ld	a, (iy+17h)
		srl	a
		add	a, 50h ; 'P'
		sub	64h ; 'd'
		jr	nc, loc_9FC1
		add	a, 64h ; 'd'

loc_9FC1:				; CODE XREF: calcDate+34j
		call	div10
		ret
; End of function calcDate

; ---------------------------------------------------------------------------
strDate:	db '  .  .  ',0     ; DATA XREF: prtFileInfo+20o
					; prtFileInfo+58o

; =============== S U B	R O U T	I N E =======================================


calcTime:				; CODE XREF: prtFileInfo+29p
		ex	de, hl
		ld	a, (iy+15h)
		and	0F8h ; '°'
		rra
		rra
		rra
		call	div10
		inc	hl
		ld	c, (iy+14h)
		ld	b, (iy+15h)
		srl	b
		rr	c
		srl	b
		rr	c
		srl	b
		rr	c
		srl	b
		rr	c
		srl	b
		rr	c
		ld	a, c
		and	3Fh ; '?'
		call	div10
		ret
; End of function calcTime

; ---------------------------------------------------------------------------
strTime:	db '  :  ',0        ; DATA XREF: prtFileInfo+26o
					; prtFileInfo+65o

; =============== S U B	R O U T	I N E =======================================


div10:					; CODE XREF: calcDate+6p calcDate+27p	...
		ld	b, 2Fh ; '/'

loc_A004:				; CODE XREF: div10+5j
		inc	b
		sub	0Ah
		jr	nc, loc_A004
		add	a, 0Ah
		ld	(hl), b
		inc	hl
		add	a, '0'
		ld	(hl), a
		inc	hl
		ret
; End of function div10


; =============== S U B	R O U T	I N E =======================================


getCurDisk:				; CODE XREF: getMemDrv+4Fp RAM:B4DBp ...
		ld	c, 2		; CURDISK
		rst	10h
		ld	(btCurDisk), a	; Текущий диск
		ret
; End of function getCurDisk

; ---------------------------------------------------------------------------
btCurDisk:	db 0			; DATA XREF: getCurDisk+3w
					; showError+A9r
					; Текущий диск

; =============== S U B	R O U T	I N E =======================================


showError:				; CODE XREF: RAM:98EAp	showError+B2j ...
		or	a
		ret	z
		jp	m, loc_A2AA
		ld	hl, aDosError	; "DOS error"
		ld	bc, 0FFFFh
		and	7Fh ; ''
		dec	a
		jr	z, loc_A031
		ld	e, a
		sub	a

loc_A02C:				; CODE XREF: showError+15j
		cpir
		dec	e
		jr	nz, loc_A02C

loc_A031:				; CODE XREF: showError+Ej
		call	sub_A40C
		push	hl
		push	bc
		ld	hl, 60h	; '`'
		ld	de, 62h	; 'b'
		ld	bc, 3C80h
		call	CopyToBuffAcc
		call	makeWindow
; ---------------------------------------------------------------------------
		db 60h,	0, 62h,	0, 80h,	0, 3Ch,	0
		db 2, 3, 0, 3, 0, 7Ah, 0, 0Ah
		db 0, 9, 1, 35h, 0, 4, 0, 0Fh
aError:		db 'Error',0
		db 4, 30h, 0, 24h, 0, 23h, 0, 0Eh
		db 0, 1, 3Bh, 0, 27h, 0, 0
aOk_2:		db 'Ok',0
		db    0
; ---------------------------------------------------------------------------
		pop	bc
		ld	hl, 0A0h ; 'а'
		srl	b
		rr	c
		or	a
		sbc	hl, bc
		ex	de, hl
		pop	hl
		ld	bc, 76h	; 'v'
		sub	a
		call	prtString
		call	SetMsCursorArrow

loc_A08D:				; CODE XREF: showError+7Dj
					; showError+81j ...
		ld	ix, tblMsError
		call	testCoords	; Проверка координат мыши
		ld	c, 31h ; '1'
		rst	10h
		jr	z, loc_A08D
		ld	a, b
		or	a
		jr	nz, loc_A08D
		ld	a, e
		cp	1Bh
		jr	z, setCurDrv
		cp	0Dh
		jr	z, setCurDrv
		ld	a, d
		res	5, a
		cp	4Fh ; 'O'
		jr	nz, loc_A08D

setCurDrv:				; CODE XREF: showError+86j
					; showError+8Aj
					; DATA XREF: ...
		ld	hl, 60h	; '`'
		ld	de, 62h	; 'b'
		ld	bc, 3C80h
		call	CopyFromBuffAcc
		halt
		call	mouseReleaseBtns ; Wait	for release all	buttons	on mouse
		call	SetMsCursorWait
		ld	hl, strDisk	; " :\\"
		ld	a, (btCurDisk)	; Текущий диск
		add	a, 41h ; 'A'
		ld	(hl), a
		ld	c, 1Dh		; CHDIR
		rst	10h
		jp	c, showError
		call	changeDrive
		call	readDirectory
		call	SetMsCursorArrow
		ret
; ---------------------------------------------------------------------------
strDisk:				; DATA XREF: showError+A6o
		db " :\\",0
aDosError:	db 'DOS error',0    ; DATA XREF: RAM:9461o showError+5o
aInvalidDriveLe:db 'Invalid drive letter',0
aFileNotFound:	db 'File not found',0
aInvalidPath:	db 'Invalid path',0
aDosError_0:	db 'DOS error',0
aCanTOpenFile:	db 'Can\'t open file',0
aFileExists:	db 'File exists',0
aReadOnly:	db 'Read only',0
aDirectoryOverf:db 'Directory overflow',0
aNoAvaliableSpa:db 'No avaliable space',0
aDirectoryNotEm:db 'Directory not empty',0
aEraseCurrentDi:db 'Erase current directory',0
aInvalidMedia:	db 'Invalid media',0
aInvalidOperati:db 'Invalid operation',0
aDirectoryExist:db 'Directory exists',0
aInvalidName:	db 'Invalid name',0
aInvalidExeFile:db 'Invalid EXE file',0
aIncorrectExeVe:db 'Incorrect EXE version',0
aDosError_1:	db 'DOS error',0
aDriveNotReady:	db 'Drive not ready',0
aDriveError:	db 'Drive error',0
aDriveError_0:	db 'Drive error',0
aDriveError_1:	db 'Drive error',0
aReadOnly_0:	db 'Read only',0
aReadError:	db 'Read error',0
aWriteError:	db 'Write error',0
aDriveError_2:	db 'Drive error',0
aDosError_2:	db 'DOS error',0
aDosError_3:	db 'DOS error',0
aNoEnoughMemory:db 'No enough memory',0
aInvalidMemoryI:db 'Invalid memory indeficator',0
; ---------------------------------------------------------------------------

loc_A2AA:				; CODE XREF: showError+2j
		ld	hl, aUnsupportForma ; "Unsupport format"
		ld	bc, 0FFFFh
		and	7Fh ; ''
		ret	z
		dec	a
		jr	z, loc_A2BD
		ld	e, a
		sub	a

loc_A2B8:				; CODE XREF: showError+2A1j
		cpir
		dec	e
		jr	nz, loc_A2B8

loc_A2BD:				; CODE XREF: showError+29Aj
		call	sub_A40C
		push	hl
		push	bc
		ld	hl, 5Ch	; '\'
		ld	de, 62h	; 'b'
		ld	bc, 3C88h
		call	CopyToBuffAcc
		call	makeWindow
; ---------------------------------------------------------------------------
		db 5Ch,	0, 62h,	0, 88h,	0, 3Ch,	0
		db 2, 3, 0, 3, 0, 82h, 0, 0Ah
		db 0, 2, 1, 30h, 0, 4, 0
		db  0Fh
aMessage:	db 'Message',0
		db 4, 34h, 0, 24h, 0, 23h, 0, 0Eh
		db 0, 1, 3Fh, 0, 27h, 0
		db    0
aOk_3:		db 'Ok',0
		db    0
; ---------------------------------------------------------------------------
		pop	bc
		ld	hl, 0A0h ; 'а'
		srl	b
		rr	c
		or	a
		sbc	hl, bc
		ex	de, hl
		pop	hl
		ld	bc, 76h	; 'v'
		sub	a
		call	prtString
		call	SetMsCursorArrow

loc_A31B:				; CODE XREF: showError+30Bj
					; showError+30Fj ...
		ld	ix, tblMSMessage
		call	testCoords	; Проверка координат мыши
		ld	c, 31h ; '1'
		rst	10h
		jr	z, loc_A31B
		ld	a, b
		or	a
		jr	nz, loc_A31B
		ld	a, e
		cp	1Bh
		jr	z, leaveMsg
		cp	0Dh
		jr	z, leaveMsg
		ld	a, d
		res	5, a
		cp	4Fh ; 'O'
		jr	nz, loc_A31B

leaveMsg:				; CODE XREF: showError+314j
					; showError+318j
					; DATA XREF: ...
		ld	hl, 5Ch	; '\'
		ld	de, 62h	; 'b'
		ld	bc, 3C88h
		call	CopyFromBuffAcc
		halt
		call	mouseReleaseBtns ; Wait	for release all	buttons	on mouse
		ret
; End of function showError

; ---------------------------------------------------------------------------
aUnsupportForma:db 'Unsupport format',0 ; DATA XREF: RAM:9468o
					; showError:loc_A2AAo
aThisFileIsNotB:db 'This file is not BMP',0
aUnsupportBmpVe:db 'Unsupport BMP version',0
aUnsupportBmpEn:db 'Unsupport BMP encoding',0
aThisFileIsNotP:db 'This file is not PCX',0
aUnsupportPcxVe:db 'Unsupport PCX version',0
aUnsupportPcxEn:db 'Unsupport PCX encoding',0
aThisFileIsNotI:db 'This file is not ICO',0
aUnsupportIcoVe:db 'Unsupport ICO version',0

; =============== S U B	R O U T	I N E =======================================


sub_A40C:				; CODE XREF: showError:loc_A031p
					; showError:loc_A2BDp
		push	hl
		ld	bc, 0
		ld	d, 87h ; 'З'

loc_A412:				; CODE XREF: sub_A40C+11j
		ld	e, (hl)
		inc	hl
		ld	a, (de)
		add	a, c
		ld	c, a
		ld	a, b
		adc	a, 0
		ld	b, a
		sub	a
		cp	(hl)
		jr	nz, loc_A412
		pop	hl
		ret
; End of function sub_A40C


; =============== S U B	R O U T	I N E =======================================

; Чтение данных	в буфер
; IX - куда
; BC - сколько
; HL -?
; DE -?

doRead:					; CODE XREF: sub_AFF7+37p readBMP+13p	...
		call	Read
		push	hl
		or	a
		adc	hl, bc
		jp	m, loc_A437
		pop	hl
		ld	e, xl
		ld	d, xh
		call	FastCopyBlk	; Fast copy block with acc
					; HL - From
					; DE - To
					; BC - len
		call	calcOffset
		ret
; ---------------------------------------------------------------------------

loc_A437:				; CODE XREF: doRead+7j
		ex	(sp), hl
		ex	de, hl
		ld	hl, 8000h
		or	a
		sbc	hl, de
		ld	c, l
		ld	b, h
		ex	de, hl
		ld	e, xl
		ld	d, xh
		call	FastCopyBlk	; Fast copy block with acc
					; HL - From
					; DE - To
					; BC - len
		call	Read1
		pop	bc
		res	7, b
		res	6, b
		call	FastCopyBlk	; Fast copy block with acc
					; HL - From
					; DE - To
					; BC - len
		call	calcOffset
		ret
; End of function doRead


; =============== S U B	R O U T	I N E =======================================

; Fast copy block with acc
; HL - From
; DE - To
; BC - len

FastCopyBlk:				; CODE XREF: doRead+Fp	doRead+25p ...
		ld	a, b
		or	a
		jr	z, loc_A469
		di

loc_A45D:				; CODE XREF: FastCopyBlk+Ej
		ld	d, d		; acc on, set len
		ld	a, 0
		ld	l, l		; copy blk
		ld	a, (hl)
		ld	(de), a
		ld	b, b		; acc off
		inc	h
		inc	d
		djnz	loc_A45D
		ei

loc_A469:				; CODE XREF: FastCopyBlk+2j
		ld	a, c
		or	a
		ret	z
		di
		ld	d, d		; Acc On, Set len
		ld	(de), a
		ld	l, l		; Copy Blk
		ld	a, (hl)
		ld	(de), a
		ld	b, b		; acc off
		ei
		ld	a, c
		add	a, e
		ld	e, a
		jr	nc, loc_A47A
		inc	d

loc_A47A:				; CODE XREF: FastCopyBlk+1Fj
		ld	a, c
		add	a, l
		ld	l, a
		ret	nc
		inc	h
		ret
; End of function FastCopyBlk


; =============== S U B	R O U T	I N E =======================================


Read:					; CODE XREF: doReadp RAM:C03Dp ...
		ld	a, (memAllocated)
		or	a
		jr	nz, loc_A4B4
		push	bc
		ld	(offHigh), hl
		ld	a, d
		and	0C0h ; '└'
		ld	b, a
		ld	c, 0
		ld	(offLow), bc
		ld	a, d
		rla
		rl	l
		rla
		rl	l
		ld	a, l
		exx
		ld	l, a
		ld	h, 90h ; 'Р'
		ld	a, (hl)
		out	(0A2h),	a	; Page1
		inc	h
		ld	a, (hl)
		ld	(hl), 1
		dec	h
		or	a
		call	z, fileRead
		exx
		res	7, d
		set	6, d
		ex	de, hl
		pop	bc
		ret
; ---------------------------------------------------------------------------

loc_A4B4:				; CODE XREF: Read+4j
		push	bc
		push	de
		ld	a, d
		and	0C0h ; '└'
		ld	d, a
		ld	e, 0
		ld	a, (byte_9100)
		or	a
		jr	z, loc_A4D9
		push	de
		ld	de, (offHigh)
		or	a
		ex	de, hl
		sbc	hl, de
		ex	de, hl
		pop	de
		jr	nz, loc_A4D9
		push	hl
		ld	hl, (offLow)
		or	a
		sbc	hl, de
		pop	hl
		jr	z, loc_A4EB

loc_A4D9:				; CODE XREF: Read+40j Read+4Dj
		ld	(offHigh), hl
		ld	(offLow), de
		exx
		ld	hl, arrPages1
		ld	a, (hl)
		out	(0A2h),	a	; Page1
		call	fileRead
		exx

loc_A4EB:				; CODE XREF: Read+57j
		pop	de
		res	7, d
		set	6, d
		ex	de, hl
		pop	bc
		ret
; End of function Read


; =============== S U B	R O U T	I N E =======================================


Read1:					; CODE XREF: doRead+28p RAM:loc_C046p	...
		bit	7, h
		ret	z
		res	7, h
		set	6, h
		push	hl
		push	bc
		push	af
		ld	hl, (offLow)
		ld	bc, 4000h
		add	hl, bc
		ld	(offLow), hl
		ld	hl, (offHigh)
		ld	b, c
		adc	hl, bc
		ld	(offHigh), hl
		ld	a, (memAllocated)
		or	a
		jr	nz, loc_A529
		exx
		inc	l
		ld	a, (hl)
		out	(0A2h),	a	; Page1
		inc	h
		ld	a, (hl)
		ld	(hl), 1
		dec	h
		or	a
		call	z, fileRead
		exx
		pop	af
		pop	bc
		pop	hl
		ret
; ---------------------------------------------------------------------------

loc_A529:				; CODE XREF: Read1+21j
		exx
		call	fileRead
		exx
		pop	af
		pop	bc
		pop	hl
		ret
; End of function Read1


; =============== S U B	R O U T	I N E =======================================


calcOffset:				; CODE XREF: doRead+12p doRead+33p
		ex	de, hl
		res	7, d
		res	6, d
		ld	hl, (offLow)
		add	hl, de
		ex	de, hl
		ld	hl, (offHigh)
		ret	nc
		inc	hl
		ret
; End of function calcOffset


; =============== S U B	R O U T	I N E =======================================


fileRead:				; CODE XREF: Read+29p Read+67p ...
		push	iy
		push	ix
		push	hl
		push	de
		push	bc
		exx
		push	hl
		push	de
		push	bc
		ld	c, 31h ; '1'    ; SCANKEY
		rst	10h
		jr	z, loc_A55E
		ld	a, b
		or	a
		jr	nz, loc_A55E
		ld	a, e
		cp	1Bh
		ld	a, 0
		scf
		jr	z, loc_A588

loc_A55E:				; CODE XREF: fileRead+Ej fileRead+12j
		ld	a, 0C0h	; '└'
		out	(89h), a	; Y_PORT
		ld	ix, (offLow)
		ld	hl, (offHigh)
		ld	bc, 15h		; MOVE_FP
		ld	a, (fileManipulator)
		rst	10h
		ld	hl, 4000h
		ld	de, 4000h
		ld	a, (fileManipulator)
		ld	c, 13h		; READ
		rst	10h
		pop	bc
		pop	de
		pop	hl
		exx
		pop	bc
		pop	de
		pop	hl
		pop	ix
		pop	iy
		ret	nc

loc_A588:				; CODE XREF: fileRead+1Aj
		ld	sp, (bufStack)
		ret
; End of function fileRead

		include "gfx_wind.asm"
		include	"gfx_prt.asm"

; =============== S U B	R O U T	I N E =======================================


sub_AA16:				; CODE XREF: readDirectory+9p
		ld	e, 20h ; ' '
		ld	c, 0B2h	; '▓'
		call	sub_AB27
		ld	c, l
		ld	b, h
		ld	hl, 20h	; ' '
		ld	de, (wNumFiles)	; Количество файлов
		or	a
		sbc	hl, de
		jr	c, loc_AA2E
		ld	de, 20h	; ' '

loc_AA2E:				; CODE XREF: sub_AA16+13j
		call	sub_AB68
		ld	a, h
		or	l
		jr	z, loc_AA36
		inc	bc

loc_AA36:				; CODE XREF: sub_AA16+1Dj
		ld	(word_AA3B), bc
		ret
; End of function sub_AA16

; ---------------------------------------------------------------------------
word_AA3B:	dw 0			; DATA XREF: sub_AA16:loc_AA36w
					; RAM:AA9Er ...
; ---------------------------------------------------------------------------

loc_AA3D:				; CODE XREF: prtFiles+23j prtFiles+58p ...
		ld	hl, (wFilesPage)
		ld	bc, (wNumFiles)	; Количество файлов
		ld	de, 20h	; ' '
		push	bc
		push	hl
		add	hl, de
		sbc	hl, bc
		pop	hl
		jr	c, loc_AA5A
		jr	z, loc_AA5A
		ld	l, c
		ld	h, b
		sbc	hl, de
		jr	nc, loc_AA57+1

loc_AA57:				; CODE XREF: RAM:AA55j
		ld	hl, 0

loc_AA5A:				; CODE XREF: RAM:AA4Dj	RAM:AA4Fj
		ex	de, hl
		ld	c, 0B2h	; '▓'
		call	sub_AB39
		ld	c, l
		ld	l, h
		ld	h, a
		pop	de
		call	sub_AB92
		ld	xl, a
		or	a
		jr	z, loc_AA7B
		ld	hl, 47h	; 'G'
		ld	de, 0C0h ; '└'
		ld	b, 0Bh
		ld	c, xl
		ld	a, 8
		call	FillWndAcc	; Fill window with accelerator
					; HL - X
					; E - Y
					; C - Lenght
					; B - Height

loc_AA7B:				; CODE XREF: RAM:AA6Aj
		ld	c, xl
		ld	b, 0
		ld	a, 0B2h	; '▓'
		sub	xl
		ld	xl, a
		push	iy
		in	a, (0A2h)
		push	af
		ld	a, 50h ; 'P'
		out	(0A2h),	a
		in	a, (89h)
		push	af
		ld	hl, 47h	; 'G'
		add	hl, bc
		ld	(word_B673), hl
		push	hl
		set	6, h
		ld	yl, 0C0h ; '└'
		ld	de, (word_AA3B)
		ld	a, xl
		sub	e
		jr	nc, loc_AAAE
		neg
		sub	e
		neg
		ld	e, a
		sub	a

loc_AAAE:				; CODE XREF: RAM:AAA5j
		ld	xl, a
		ld	a, e
		dec	a
		ld	(loc_AAC4+1), a
		ld	(loc_AAF7+1), a
		dec	a
		ld	(loc_AADF+1), a
		dec	de
		dec	de
		di
		ld	a, yl
		out	(89h), a
		ld	d, d

loc_AAC4:				; DATA XREF: RAM:AAB2w
		ld	a, 0
		ld	b, b
		ld	a, 0FFh
		ld	c, c
		ld	(hl), a
		ld	b, b
		push	hl
		add	hl, de
		inc	hl
		ld	(hl), 0F7h ; 'ў'
		pop	hl
		ld	b, 9

loc_AAD4:				; CODE XREF: RAM:AAEBj
		inc	yl
		ld	a, yl
		out	(89h), a
		push	hl
		ld	(hl), 0FFh
		inc	hl
		ld	d, d

loc_AADF:				; DATA XREF: RAM:AAB9w
		ld	a, 0
		ld	b, b
		ld	a, 0F8h	; '°'
		ld	c, c
		ld	(hl), a
		ld	b, b
		add	hl, de
		ld	(hl), 0F7h ; 'ў'
		pop	hl
		djnz	loc_AAD4
		inc	yl
		ld	a, yl
		out	(89h), a
		ld	(hl), 0FFh
		inc	hl
		ld	d, d

loc_AAF7:				; DATA XREF: RAM:AAB5w
		ld	a, 0
		ld	b, b
		ld	a, 0F7h	; 'ў'
		ld	c, c
		ld	(hl), a
		ld	b, b
		ei
		add	hl, de
		inc	hl
		ld	a, h
		and	3Fh ; '?'
		ld	h, a
		ld	(word_B681), hl
		pop	hl
		pop	af
		out	(89h), a	; Y_PORT
		pop	af
		out	(0A2h),	a	; Page1
		pop	iy
		ld	bc, (word_AA3B)
		add	hl, bc
		ld	a, xl
		or	a
		ret	z
		ld	c, a
		ld	de, 0C0h ; '└'
		ld	b, 0Bh
		ld	a, 8
		call	FillWndAcc	; Fill window with accelerator
					; HL - X
					; E - Y
					; C - Lenght
					; B - Height
		ret

; =============== S U B	R O U T	I N E =======================================


sub_AB27:				; CODE XREF: sub_AA16+4p
		sub	a
		ld	l, a
		ld	h, a
		ld	d, a
		cp	c
		ret	z
		cp	e
		ret	z
		ld	h, c
		ld	b, 8

loc_AB32:				; CODE XREF: sub_AB27:loc_AB36j
		add	hl, hl
		jr	nc, loc_AB36
		add	hl, de

loc_AB36:				; CODE XREF: sub_AB27+Cj
		djnz	loc_AB32
		ret
; End of function sub_AB27


; =============== S U B	R O U T	I N E =======================================


sub_AB39:				; CODE XREF: RAM:AA5Dp
		sub	a
		ld	l, a
		ld	h, a
		cp	c
		ret	z
		or	d
		or	e
		ret	z
		ld	a, c
		ld	c, 0
		ld	b, 8

loc_AB46:				; CODE XREF: sub_AB39:loc_AB4Cj
		add	hl, hl
		rla
		jr	nc, loc_AB4C
		add	hl, de
		adc	a, c

loc_AB4C:				; CODE XREF: sub_AB39+Fj
		djnz	loc_AB46
		ret
; End of function sub_AB39


; =============== S U B	R O U T	I N E =======================================

; MUL 32? x32

mul32:					; CODE XREF: RAM:BFA6p	RAM:C13Ep ...
		ld	ix, 0
		ld	a, 20h ; ' '

loc_AB55:				; CODE XREF: mul32+16j
		add	ix, ix
		adc	hl, hl
		rl	e
		rl	d
		jr	nc, loc_AB64
		add	ix, bc
		jr	nc, loc_AB64
		inc	hl

loc_AB64:				; CODE XREF: mul32+Ej mul32+12j
		dec	a
		jr	nz, loc_AB55
		ret
; End of function mul32


; =============== S U B	R O U T	I N E =======================================


sub_AB68:				; CODE XREF: sub_AA16:loc_AA2Ep
		ld	a, d
		or	e
		ret	z
		ld	hl, 0
		ld	a, b
		ld	b, 10h

loc_AB71:				; CODE XREF: sub_AB68:loc_AB7Bj
		rl	c
		rla
		adc	hl, hl
		sbc	hl, de
		ccf
		jr	nc, loc_AB8A

loc_AB7B:				; CODE XREF: sub_AB68+20j
		djnz	loc_AB71
		rl	c
		rla
		ld	b, a
		ret
; ---------------------------------------------------------------------------

loc_AB82:				; CODE XREF: sub_AB68:loc_AB8Aj
		rl	c
		rla
		adc	hl, hl
		add	hl, de
		jr	c, loc_AB7B

loc_AB8A:				; CODE XREF: sub_AB68+11j
		djnz	loc_AB82
		rl	c
		rla
		add	hl, de
		ld	b, a
		ret
; End of function sub_AB68


; =============== S U B	R O U T	I N E =======================================


sub_AB92:				; CODE XREF: RAM:AA64p
		ld	a, d
		cpl
		ld	d, a
		ld	a, e
		cpl
		ld	e, a
		inc	de
		ld	a, c
		ld	b, 8

loc_AB9C:				; CODE XREF: sub_AB92+18j sub_AB92+20j
		add	hl, hl
		jr	c, loc_ABAD
		add	a, a
		jr	nc, loc_ABA3
		inc	hl

loc_ABA3:				; CODE XREF: sub_AB92+Ej
		push	hl
		add	hl, de
		jr	nc, loc_ABA9
		ex	(sp), hl
		inc	a

loc_ABA9:				; CODE XREF: sub_AB92+13j
		pop	hl
		djnz	loc_AB9C
		ret
; ---------------------------------------------------------------------------

loc_ABAD:				; CODE XREF: sub_AB92+Bj
		adc	a, a
		jr	nc, loc_ABB1
		inc	hl

loc_ABB1:				; CODE XREF: sub_AB92+1Cj
		add	hl, de
		djnz	loc_AB9C
		ret
; End of function sub_AB92

; ---------------------------------------------------------------------------
		ld	a, b
		or	c
		ret	z
		ex	de, hl
		ld	hl, 0
		ld	a, 20h ; ' '

loc_ABBE:				; CODE XREF: RAM:ABCCj	RAM:ABD2j
		add	ix, ix
		ex	de, hl
		adc	hl, hl
		ex	de, hl
		adc	hl, hl
		sbc	hl, bc
		jr	nc, loc_ABCF
		add	hl, bc
		dec	a
		jr	nz, loc_ABBE
		ret
; ---------------------------------------------------------------------------

loc_ABCF:				; CODE XREF: RAM:ABC8j
		inc	ix
		dec	a
		jr	nz, loc_ABBE
		ret
; ---------------------------------------------------------------------------

		include "gfx_ms.asm"
; =============== S U B	R O U T	I N E =======================================


InitHW:					; CODE XREF: RAM:930Bp
		ld	c, 0		; Init Mouse
		rst	30h
		ld	c, 2		; Hide Cursor
		rst	30h
		ld	c, 51h ; 'Q'    ; GETVMOD
		rst	10h
		ld	(idVMODE+1), a
		ld	a, b
		ld	(restoreHW+1), a ; Восстановление параметров
		in	a, (0A2h)	; Page2
		ld	(idPage1+1), a
		in	a, (89h)	; Y_PORT
		ld	(buf_YPORT+1), a
		ld	bc, 50h	; 'P'   ; SETVMOD
		ld	a, 81h ; 'Б'    ; 320x256x256
		rst	10h
		call	clear0Screen
		call	clear1Screen
		ld	bc, 150h	; SETVMOD + 1 Screen
		ld	a, 81h ; 'Б'    ;  320x256x256
		rst	10h
		ld	bc, 54h	; 'T'   ; SELPAGE
		rst	10h
		ld	hl, tblPallette	; Palette
		ld	de, 0
		ld	bc, 0FFA4h	; PIC_SET_PAL
		sub	a
		rst	8
		ret
; End of function InitHW

; ---------------------------------------------------------------------------

restoreHW:				; CODE XREF: RAM:936Bp	RAM:9453p ...
		ld	b, 0		; Восстановление параметров

idVMODE:				; DATA XREF: InitHW+9w
		ld	a, 0
		ld	c, 50h ; 'P'    ; SETVMOD
		rst	10h

idPage1:				; DATA XREF: InitHW+12w
		ld	a, 0
		out	(0A2h),	a	; Page1

buf_YPORT:				; DATA XREF: InitHW+17w
		ld	a, 0
		out	(89h), a
		ret

; =============== S U B	R O U T	I N E =======================================


getMemDrv:				; CODE XREF: RAM:9311p
		ld	bc, 33Dh	; GETMEM
		rst	10h
		jr	nc, memOK
		call	restoreHW	; Восстановление параметров
		ld	hl, aNotEnoughMemor ; "Not enough memory to run program.\r\n"
		ld	c, 5Ch ; '\'    ; PCHARS
		rst	10h
		ld	a, (idMemory)
		ld	c, 3Eh ; '>'    ; RETMEM
		rst	10h
		ld	bc, 0FF41h	; Exit
		rst	10h
; ---------------------------------------------------------------------------
aNotEnoughMemor:db 'Not enough memory to run program.',0x0d,0x0a,0 ; DATA XREF: getMemDrv+9o
; ---------------------------------------------------------------------------

memOK:					; CODE XREF: getMemDrv+4j
		ld	(idMemory3), a
		ld	hl, arrPages3	; Массив выделенных страниц
		ld	c, 0C5h	; '┼'   ; EMM_FN5
		rst	8
		ld	c, 1		; SHOW MOUSE CURSOR
		rst	30h		; Mouse	INT
		call	SetMsCursorWait
		call	sub_AFF7	; что-то читает	из файла fileManipulator
		call	getCurDisk

getCurDrv:				; CODE XREF: getMemDrv+60j
					; getMemDrv+63j
		ld	c, 2
		rst	10h
		ld	c, 1
		rst	10h
		jr	nc, drvOK
		call	showError
		call	SetMsCursorWait
		jr	getCurDrv
; ---------------------------------------------------------------------------

drvOK:					; CODE XREF: getMemDrv+58j
		or	a
		jr	z, getCurDrv
		cp	0Ah
		jr	c, loc_AFCB
		ld	a, 9

loc_AFCB:				; CODE XREF: getMemDrv+67j
		ld	(bDrvCount), a	; Количество устройств в системе
		call	SetMsCursorArrow
		ret
; ---------------------------------------------------------------------------

returnResurces:				; CODE XREF: RAM:quitp
		ld	c, 2		; HIDE MOUSE CURSOR
		rst	30h
		ld	a, (idMemory3)
		ld	c, 3Eh ; '>'    ; RETMEM
		rst	10h

closeFile:				; CODE XREF: RAM:9450p	RAM:B4D5p ...
		sub	a		; Закрыть файл,	если был открыт
		ld	(btOpenedFile),	a ; 1 -	открыт файл, 0 - нет
		ld	a, (fileManipulator)
; End of function getMemDrv

		ld	c, 12h		; CLOSE
		or	a
		call	nz, 10h
		ld	a, (idMemory2)
		ld	c, 3Eh ; '>'    ; RETMEM
		or	a
		call	nz, 10h
		ld	hl, specFileTmp
		sub	a
		ld	(hl), a
		ret

; =============== S U B	R O U T	I N E =======================================

; что-то читает	из файла fileManipulator

sub_AFF7:				; CODE XREF: getMemDrv+4Cp
		ld	hl, arrPages1
		ld	a, (idMemory1)
		ld	c, 0C5h	; '┼'   ; EMM_FN5
		rst	8
		ret	c
		ld	hl, byte_9100
		ld	a, 1

loc_B006:				; CODE XREF: sub_AFF7+11j
		ld	(hl), a
		inc	l
		jr	nz, loc_B006
		push	iy
		in	a, (0E2h)	; Page3
		ld	c, a
		in	a, (89h)	; Y_PORT
		ld	b, a
		push	bc
		ld	a, 50h ; 'P'
		out	(0E2h),	a	; Page3
		ld	ix, 0C000h
		ld	hl, 0
		ld	de, 0
		ld	bc, 140h
		ld	yl, 0

loc_B027:				; CODE XREF: sub_AFF7+44j
		ld	a, yl
		out	(89h), a
		push	hl
		push	de
		push	bc
		call	doRead		; Чтение данных	в буфер
					; IX - куда
					; BC - сколько
					; HL -?
					; DE -?
		pop	bc
		pop	hl
		pop	de
		add	hl, bc
		ex	de, hl
		jr	nc, loc_B039
		inc	hl

loc_B039:				; CODE XREF: sub_AFF7+3Fj
		inc	yl
		jr	nz, loc_B027
		pop	bc
		ld	a, b
		out	(89h), a	; Y_PORT
		ld	a, c
		out	(0E2h),	a	; Page3
		pop	iy
		ld	a, (idMemory1)
		ld	c, 3Eh ; '>'    ; RETMEM
		rst	10h
		ret
; End of function sub_AFF7

; ---------------------------------------------------------------------------

showMenus:				; CODE XREF: RAM:9314p
		call	makeWindow
; ---------------------------------------------------------------------------
		db 39h,	0, 0Eh,	0, 0CEh, 0, 16h, 0
		db 2, 3, 0, 3, 0, 0C8h,	0, 10h
		db 0, 0, 1, 3Ch, 0, 7, 0, 0Fh
aGfxViewerV1_00:db 'GFX Viewer v1.00',0
		db    0
; ---------------------------------------------------------------------------
		call	makeWindow
; ---------------------------------------------------------------------------
		db 39h,	0, 24h,	0, 0CEh, 0, 0B8h, 0
		db 3, 2, 0, 6, 0, 0CAh,	0, 0Ch
		db 0, 3, 2, 0, 14h, 0, 65h, 0
		db 86h,	0, 3, 67h, 0, 14h, 0, 65h
		db 0, 86h, 0, 3, 2, 0, 9Bh, 0
		db 0CAh, 0, 0Dh, 0, 5, 3, 0, 9Ch
		db 0, 0Bh, 0, 0Bh, 0, 0, 11h, 0
		db 4, 0Eh, 0, 9Ch, 0, 0B2h, 0, 0Bh
		db 0, 5, 0C0h, 0, 9Ch, 0, 0Bh, 0
		db 0Bh,	0, 0, 10h, 0, 3, 2, 0
		db 0A9h, 0, 0CAh, 0, 0Ch, 0, 0
; ---------------------------------------------------------------------------
		call	makeWindow
; ---------------------------------------------------------------------------
		db 39h,	0, 0DCh, 0, 0CEh, 0, 14h, 0
		db 1, 3Ch, 0, 6, 0, 0
aEninAntonC1999:db 'Enin Anton (c)1999',0
		db    0
; ---------------------------------------------------------------------------
		ld	a, (bDrvCount)	; Количество устройств в системе
		ld	b, a
		sub	a

loc_B0FE:				; CODE XREF: RAM:B100j
		add	a, 0Eh
		djnz	loc_B0FE
		add	a, 6
		ld	(byte_B10A+6), a
		call	makeWindow
; ---------------------------------------------------------------------------
byte_B10A:	db 10h,	0, 38h,	0, 29h,	0, 0, 0	; DATA XREF: RAM:B104w
		db 0
; ---------------------------------------------------------------------------
		call	makeWindow
; ---------------------------------------------------------------------------
		db 7, 1, 38h, 0, 2Eh, 0, 45h, 0
		db 4, 3, 0, 3, 0, 28h, 0, 0Eh
		db 0, 1, 0Dh, 0, 6, 0, 0
aHelp:		db 'Help',0
		db 4, 3, 0, 11h, 0, 28h, 0, 0Eh
		db 0, 1, 6, 0, 14h, 0, 0
aSystem:	db 'System',0
		db 4, 3, 0, 1Fh, 0, 28h, 0, 0Eh
		db 0, 1, 9, 0, 22h, 0, 0
aImage:		db 'Image',0
		db 4, 3, 0, 34h, 0, 28h, 0, 0Eh
		db 0, 1, 0Eh, 0, 37h, 0, 0
aQuit:		db 'Quit',0
		db    0
; ---------------------------------------------------------------------------
		ret
; ---------------------------------------------------------------------------

curFilePrew:				; DATA XREF: RAM:B725o
		ld	hl, (wNumFiles)	; Количество файлов
		ld	a, h
		or	l
		ret	z
		ld	hl, (wFilesCursor)
		ld	a, h
		or	l
		jr	nz, loc_B188
		ld	hl, (wFilesPage)
		ld	a, h
		or	l
		ret	z
		jr	loc_B1A4
; ---------------------------------------------------------------------------

loc_B188:				; CODE XREF: RAM:B17Ej
		dec	hl
		push	hl
		call	sprNull
		pop	hl
		ld	(wFilesCursor),	hl
		call	spr0d
		call	prtFileInfo
		ret
; ---------------------------------------------------------------------------

scrollLeft:				; DATA XREF: RAM:B65Do
		ld	hl, (wNumFiles)	; Количество файлов
		ld	a, h
		or	l
		ret	z
		ld	hl, (wFilesPage)
		ld	a, h
		or	l
		ret	z

loc_B1A4:				; CODE XREF: RAM:B186j
		call	sprNull
		in	a, (0E2h)
		push	af
		ld	a, (arrPages3)	; Массив выделенных страниц
		out	(0E2h),	a
		ld	hl, (wFilesPage)
		dec	hl
		ld	(wFilesPage), hl
		call	fileNumToAddr
		push	hl
		ld	hl, (wFilesPage)
		ld	de, 10h
		add	hl, de
		ld	de, (wNumFiles)	; Количество файлов
		or	a
		sbc	hl, de
		add	hl, de
		jr	c, loc_B1CC
		ex	de, hl

loc_B1CC:				; CODE XREF: RAM:B1C9j
		call	fileNumToAddr
		push	hl
		ld	hl, 0A6h ; 'ж'
		ld	d, 3Bh ; ';'
		ld	e, 43h ; 'C'
		ld	bc, 785Ah
		call	scroll
		ld	hl, 0A6h ; 'ж'
		ld	de, 3Bh	; ';'
		ld	bc, 85Ah
		ld	a, 8
		call	FillWndAcc	; Fill window with accelerator
					; HL - X
					; E - Y
					; C - Lenght
					; B - Height
		pop	hl
		ld	de, 0A6h ; 'ж'
		ld	bc, 3Bh	; ';'
		ld	a, (hl)
		or	a
		ld	a, 0
		call	nz, prtString
		ld	hl, 41h	; 'A'
		ld	d, 3Bh ; ';'
		ld	e, 43h ; 'C'
		ld	bc, 785Ah
		call	scroll
		ld	hl, 41h	; 'A'
		ld	de, 3Bh	; ';'
		ld	bc, 85Ah
		ld	a, 8
		call	FillWndAcc	; Fill window with accelerator
					; HL - X
					; E - Y
					; C - Lenght
					; B - Height
		pop	hl
		ld	de, 41h	; 'A'
		ld	bc, 3Bh	; ';'
		sub	a
		call	prtString
		pop	af
		out	(0E2h),	a
		call	spr0d
		call	prtFileInfo
		call	loc_AA3D
		ret
; ---------------------------------------------------------------------------

curFileNext:				; DATA XREF: RAM:B729o
		ld	bc, (wNumFiles)	; Количество файлов
		ld	a, b
		or	c
		ret	z
		ld	hl, (wFilesCursor)
		inc	hl
		push	hl
		ld	de, (wFilesPage)
		add	hl, de
		or	a
		sbc	hl, bc
		pop	hl
		ret	nc
		ld	de, 20h	; ' '
		or	a
		sbc	hl, de
		jr	nc, loc_B26F
		add	hl, de
		push	hl
		call	sprNull
		pop	hl
		ld	(wFilesCursor),	hl
		call	spr0d
		call	prtFileInfo
		ret
; ---------------------------------------------------------------------------

scrollRight:				; DATA XREF: RAM:B66Do
		ld	hl, (wNumFiles)	; Количество файлов
		ld	a, h
		or	l
		ret	z
		ld	hl, (wFilesPage)
		ld	de, 20h	; ' '
		add	hl, de
		ld	de, (wNumFiles)	; Количество файлов
		or	a
		sbc	hl, de
		ret	nc

loc_B26F:				; CODE XREF: RAM:B248j
		call	sprNull
		in	a, (0E2h)
		push	af
		ld	a, (arrPages3)	; Массив выделенных страниц
		out	(0E2h),	a
		ld	hl, (wFilesPage)
		ld	de, 20h	; ' '
		add	hl, de
		call	fileNumToAddr
		push	hl
		ld	hl, (wFilesPage)
		inc	hl
		ld	(wFilesPage), hl
		ld	de, 0Fh
		add	hl, de
		call	fileNumToAddr
		push	hl
		ld	hl, 41h	; 'A'
		ld	d, 43h ; 'C'
		ld	e, 3Bh ; ';'
		ld	bc, 785Ah
		call	scroll
		ld	hl, 41h	; 'A'
		ld	de, 0B3h ; '│'
		ld	bc, 85Ah
		ld	a, 8
		call	FillWndAcc	; Fill window with accelerator
					; HL - X
					; E - Y
					; C - Lenght
					; B - Height
		pop	hl
		ld	de, 41h	; 'A'
		ld	bc, 0B3h ; '│'
		sub	a
		call	prtString
		ld	hl, 0A6h ; 'ж'
		ld	d, 43h ; 'C'
		ld	e, 3Bh ; ';'
		ld	bc, 785Ah
		call	scroll
		ld	hl, 0A6h ; 'ж'
		ld	de, 0B3h ; '│'
		ld	bc, 85Ah
		ld	a, 8
		call	FillWndAcc	; Fill window with accelerator
					; HL - X
					; E - Y
					; C - Lenght
					; B - Height
		pop	hl
		ld	de, 0A6h ; 'ж'
		ld	bc, 0B3h ; '│'
		sub	a
		call	prtString
		pop	af
		out	(0E2h),	a
		call	spr0d
		call	prtFileInfo
		call	loc_AA3D
		ret
; ---------------------------------------------------------------------------

curFilePageLeft:			; DATA XREF: RAM:B72Do
		ld	hl, (wNumFiles)	; Количество файлов
		ld	a, h
		or	l
		ret	z
		ld	hl, (wFilesCursor)
		ld	a, h
		or	l
		jp	z, curPagePrew
		ld	de, 10h
		sbc	hl, de
		jr	nc, loc_B305
		ld	hl, 0

loc_B305:				; CODE XREF: RAM:B300j
		push	hl
		call	sprNull
		pop	hl
		ld	(wFilesCursor),	hl
		call	spr0d
		call	prtFileInfo
		ret
; ---------------------------------------------------------------------------

curFilePageRight:			; DATA XREF: RAM:B731o
		ld	hl, (wNumFiles)	; Количество файлов
		ld	a, h
		or	l
		ret	z
		ld	hl, (wFilesCursor)
		ld	de, 1Fh
		or	a
		push	hl
		sbc	hl, de
		pop	hl
		jp	z, curPageNext
		ld	de, 10h
		add	hl, de
		ld	de, 1Fh
		ex	de, hl
		sbc	hl, de
		jr	nc, loc_B337
		ld	de, 1Fh

loc_B337:				; CODE XREF: RAM:B332j
		ex	de, hl
		push	hl
		ld	de, (wFilesPage)
		add	hl, de
		ld	bc, (wNumFiles)	; Количество файлов
		or	a
		sbc	hl, bc
		pop	hl
		jr	c, loc_B359
		ld	hl, (wNumFiles)	; Количество файлов
		or	a
		sbc	hl, de
		dec	hl
		push	hl
		ld	de, (wFilesCursor)
		or	a
		sbc	hl, de
		pop	hl
		ret	z

loc_B359:				; CODE XREF: RAM:B346j
		push	hl
		call	sprNull
		pop	hl
		ld	(wFilesCursor),	hl
		call	spr0d
		call	prtFileInfo
		ret
; ---------------------------------------------------------------------------

curPagePrew:				; CODE XREF: RAM:B2F8j
					; DATA XREF: RAM:B67Do	...
		ld	hl, (wNumFiles)	; Количество файлов
		ld	a, h
		or	l
		ret	z
		ld	hl, (wFilesPage)
		ld	a, h
		or	l
		jp	z, curFileHome
		ld	de, 20h	; ' '
		sbc	hl, de
		jr	nc, loc_B380
		ld	hl, 0

loc_B380:				; CODE XREF: RAM:B37Bj
		ld	(wFilesPage), hl
		call	prtFiles
		call	spr0d
		call	prtFileInfo
		ld	a, (MouseOn)	; флаг мышки - вкл/выкл
		or	a
		ret	nz
		ld	b, 7

loc_B393:				; CODE XREF: RAM:B39Cj
		push	bc
		ld	c, 3
		rst	30h
		pop	bc
		bit	0, a
		ret	z
		halt
		djnz	loc_B393
		ret
; ---------------------------------------------------------------------------

curPageNext:				; CODE XREF: RAM:B325j
					; DATA XREF: RAM:B68Do	...
		ld	bc, (wNumFiles)	; Количество файлов
		ld	a, b
		or	c
		ret	z
		ld	hl, (wFilesPage)
		ld	de, 20h	; ' '
		add	hl, de
		or	a
		sbc	hl, bc
		jp	nc, curFileEnd
		add	hl, bc
		ld	(wFilesPage), hl
		ld	de, (wFilesCursor)
		add	hl, de
		or	a
		sbc	hl, bc
		jr	c, loc_B3CF
		ld	hl, (wNumFiles)	; Количество файлов
		ld	de, (wFilesPage)
		or	a
		sbc	hl, de
		dec	hl
		ld	(wFilesCursor),	hl

loc_B3CF:				; CODE XREF: RAM:B3BFj
		call	prtFiles
		call	spr0d
		call	prtFileInfo
		ld	a, (MouseOn)	; флаг мышки - вкл/выкл
		or	a
		ret	nz
		ld	b, 7

loc_B3DF:				; CODE XREF: RAM:B3E8j
		push	bc
		ld	c, 3
		rst	30h
		pop	bc
		bit	0, a
		ret	z
		halt
		djnz	loc_B3DF
		ret
; ---------------------------------------------------------------------------

curFileHome:				; CODE XREF: RAM:B373j
					; DATA XREF: RAM:B73Do
		ld	hl, (wNumFiles)	; Количество файлов
		ld	a, h
		or	l
		ret	z
		ld	hl, (wFilesPage)
		ld	a, h
		or	l
		jr	nz, loc_B40F
		ld	de, (wFilesCursor)
		ld	a, d
		or	e
		ret	z
		call	sprNull
		ld	hl, 0
		ld	(wFilesCursor),	hl
		call	spr0d
		call	prtFileInfo
		ret
; ---------------------------------------------------------------------------

loc_B40F:				; CODE XREF: RAM:B3F6j
		call	sprNull
		ld	hl, 0
		ld	(wFilesPage), hl
		ld	(wFilesCursor),	hl
		call	prtFiles
		call	spr0d
		call	prtFileInfo
		ret
; ---------------------------------------------------------------------------

curFileEnd:				; CODE XREF: RAM:B3B0j
					; DATA XREF: RAM:B741o
		ld	bc, (wNumFiles)	; Количество файлов
		ld	a, b
		or	c
		ret	z
		ld	hl, (wFilesPage)
		ld	de, (wFilesCursor)
		add	hl, de
		inc	hl
		or	a
		sbc	hl, bc
		ret	z
		call	sprNull
		ld	hl, (wFilesPage)
		ld	de, 20h	; ' '
		add	hl, de
		inc	hl
		ld	bc, (wNumFiles)	; Количество файлов
		or	a
		sbc	hl, bc
		jr	z, loc_B464
		jr	c, loc_B464
		ld	hl, (wNumFiles)	; Количество файлов
		ld	de, (wFilesPage)
		or	a
		sbc	hl, de
		dec	hl
		ld	(wFilesCursor),	hl
		call	spr0d
		call	prtFileInfo
		ret
; ---------------------------------------------------------------------------

loc_B464:				; CODE XREF: RAM:B44Bj	RAM:B44Dj
		ld	hl, (wNumFiles)	; Количество файлов
		ld	de, 20h	; ' '
		or	a
		sbc	hl, de
		ld	(wFilesPage), hl
		ld	hl, 1Fh
		ld	(wFilesCursor),	hl
		call	prtFiles
		call	spr0d
		call	prtFileInfo
		ret
; ---------------------------------------------------------------------------

scroll:					; CODE XREF: RAM:B1DAp	RAM:B203p ...
		in	a, (0A2h)
		push	af
		ld	a, 50h ; 'P'
		out	(0A2h),	a
		in	a, (89h)
		push	af
		set	6, h
		di
		ld	a, b
		ld	(loc_B492+1), a
		ld	d, d		; acc on, set len

loc_B492:				; DATA XREF: RAM:B48Ew
		ld	a, 0
		ld	b, b
		ld	b, c

loc_B496:				; CODE XREF: RAM:B4A3j
		ld	a, d
		out	(89h), a	; Y_PORT
		ld	a, a
		ld	a, (hl)
		ld	b, b
		ld	a, e
		out	(89h), a	; Y_PORT
		ld	a, a
		ld	(hl), a
		ld	b, b
		inc	hl
		djnz	loc_B496
		ei
		pop	af
		out	(89h), a
		pop	af
		out	(0A2h),	a
		ret
; ---------------------------------------------------------------------------

chDrv0:					; DATA XREF: RAM:B69Do	RAM:B77Eo
		sub	a
		jr	chDrive
; ---------------------------------------------------------------------------

chDrv1:					; DATA XREF: RAM:B6ADo	RAM:B782o
		ld	a, 1
		jr	chDrive
; ---------------------------------------------------------------------------

chDrv2:					; DATA XREF: RAM:B6BDo	RAM:B786o
		ld	a, 2
		jr	chDrive
; ---------------------------------------------------------------------------

chDrv3:					; DATA XREF: RAM:B6CDo	RAM:B78Ao
		ld	a, 3
		jr	chDrive
; ---------------------------------------------------------------------------

chDrv4:					; DATA XREF: RAM:B6DDo	RAM:B78Eo
		ld	a, 4
		jr	chDrive
; ---------------------------------------------------------------------------

chDrv5:					; DATA XREF: RAM:B6EDo	RAM:B792o
		ld	a, 5
		jr	chDrive
; ---------------------------------------------------------------------------

chDrv6:					; DATA XREF: RAM:B6FDo	RAM:B796o
		ld	a, 6
		jr	chDrive
; ---------------------------------------------------------------------------

chDrv7:					; DATA XREF: RAM:B70Do	RAM:B79Ao
		ld	a, 7
		jr	chDrive
; ---------------------------------------------------------------------------

chDrv8:					; DATA XREF: RAM:B71Do	RAM:B79Eo
		ld	a, 8

chDrive:				; CODE XREF: RAM:B4AEj	RAM:B4B2j ...
		ld	hl, asc_B4F4	; " :\\"
		add	a, 41h ; 'A'
		ld	(hl), a
		push	hl
		call	closeFile	; Закрыть файл,	если был открыт
		call	sprNull
		call	getCurDisk
		call	SetMsCursorWait
		pop	hl
		ld	c, 1Dh		; CHDIR
		rst	10h
		push	af
		call	changeDrive
		call	SetMsCursorArrow
		pop	af
		jp	c, showError
		call	readDirectory
		ret
; ---------------------------------------------------------------------------
asc_B4F4:	db " :\\",0         ; DATA XREF: RAM:chDriveo

; =============== S U B	R O U T	I N E =======================================


onFirstPanel:				; CODE XREF: RAM:clickFirstPanelp
					; DATA XREF: RAM:B5FBo
		ex	de, hl
		ld	e, (ix+4)
		ld	d, (ix+5)
		or	a
		sbc	hl, de
		srl	l
		srl	l
		srl	l
		jr	loc_B51E
; ---------------------------------------------------------------------------

onSecPanel:				; CODE XREF: RAM:clickSecPanelp
					; DATA XREF: RAM:B60Bo
		ex	de, hl
		ld	e, (ix+4)
		ld	d, (ix+5)
		or	a
		sbc	hl, de
		ld	a, l
		srl	a
		srl	a
		srl	a
		add	a, 10h
		ld	l, a

loc_B51E:				; CODE XREF: onFirstPanel+10j
		ld	bc, (wNumFiles)	; Количество файлов
		ld	a, b
		or	c
		ret	z
		push	hl
		ld	de, (wFilesPage)
		add	hl, de
		or	a
		sbc	hl, bc
		pop	hl
		ret	nc
		ld	de, (wFilesCursor)
		or	a
		sbc	hl, de
		ret	z
		add	hl, de
		push	hl
		call	sprNull
		pop	hl
		ld	(wFilesCursor),	hl
		call	spr0d
		call	prtFileInfo
		ret
; End of function onFirstPanel

; ---------------------------------------------------------------------------

clickFirstPanel:			; DATA XREF: RAM:B5FDo
		call	onFirstPanel
		jr	select
; ---------------------------------------------------------------------------

clickSecPanel:				; DATA XREF: RAM:B60Do
		call	onSecPanel

select:					; CODE XREF: RAM:B54Bj
					; DATA XREF: RAM:B745o	...
		in	a, (0E2h)
		push	af
		ld	a, (arrPages3)	; Массив выделенных страниц
		out	(0E2h),	a
		ld	hl, (wFilesPage)
		ld	de, (wFilesCursor)
		add	hl, de
		call	fileNumToAddr
		ld	de, 8000h
		ld	bc, 18h
		ldir
		pop	af
		out	(0E2h),	a
		ld	ix, 8000h
		ld	a, (ix+0)
		or	a
		ret	z
		bit	4, (ix+0Fh)
		jr	z, loc_B59A
		call	getCurDisk
		ld	hl, 8001h
		ld	a, 3Eh ; '>'
		push	hl

loc_B586:				; CODE XREF: RAM:B588j
		inc	hl
		cp	(hl)
		jr	nz, loc_B586
		ld	(hl), 0
		pop	hl
		ld	c, 1Dh		; CHDIR
		rst	10h
		jp	c, showError
		call	readDirectory
		call	mouseReleaseBtns ; Wait	for release all	buttons	on mouse
		ret
; ---------------------------------------------------------------------------

loc_B59A:				; CODE XREF: RAM:B57Bj
		call	checkName
		jr	nz, loc_B5A5
		call	extDefinition
		ret	nc
		jr	loc_B5BE
; ---------------------------------------------------------------------------

loc_B5A5:				; CODE XREF: RAM:B59Dj
		call	SetMsCursorWait
		call	closeFile	; Закрыть файл,	если был открыт
		call	mouseReleaseBtns ; Wait	for release all	buttons	on mouse
		call	getCurDisk
		ld	ix, 8000h
		call	openFile
		jr	c, loc_B5BE
		call	SetMsCursorArrow
		ret
; ---------------------------------------------------------------------------

loc_B5BE:				; CODE XREF: RAM:B5A3j	RAM:B5B8j
		push	af
		ld	bc, 54h	; 'T'
		rst	10h
		ld	a, (MouseOn)	; флаг мышки - вкл/выкл
		or	a
		ld	c, 1
		call	nz, 30h
		pop	af
		call	showError
		ret

; =============== S U B	R O U T	I N E =======================================


checkName:				; CODE XREF: RAM:loc_B59Ap
		ld	hl, 8000h
		ld	de, specFileTmp
		ld	b, 18h

loc_B5D9:				; CODE XREF: checkName+Dj
		ld	a, (de)
		cp	(hl)
		ret	nz
		inc	hl
		inc	de
		djnz	loc_B5D9
		ret
; End of function checkName

; ---------------------------------------------------------------------------
tblMsMain:	db 0, 0, 40h, 1, 0, 0, 0, 1 ; DATA XREF: RAM:931Eo
		db 0, 0, 0, 0, 0, 0
		dw dlgQuit
		db 3Dh,	0, 9Eh,	0, 3Bh,	0, 0BBh, 0
		db 0, 0
		dw onFirstPanel
		dw clickFirstPanel
		db 0, 0, 0A2h, 0, 3, 1,	3Bh, 0
		db 0BBh, 0, 0, 0
		dw onSecPanel
		dw clickSecPanel
		db 0, 0, 0Ah, 1, 32h, 1, 3Bh, 0
		db 49h,	0, 1, 0, 0, 0
		dw mnuHelp
		db 0, 0, 0Ah, 1, 32h, 1, 49h, 0
		db 57h,	0, 1, 0, 0, 0
		dw mnuInfo
		db 0, 0, 0Ah, 1, 32h, 1, 57h, 0
		db 65h,	0, 1, 0, 0, 0
		dw fnFileInfo
		db 0, 0, 0Ah, 1, 32h, 1, 6Ch, 0
		db 7Ah,	0, 1, 0, 0, 0
		dw dlgQuit
		db 0, 0, 3Ch, 0, 47h, 0, 0C0h, 0
		db 0CBh, 0, 3, 0, 0, 0
		dw scrollLeft
		db 0, 0, 0F9h, 0, 4, 1,	0C0h, 0
		db 0CBh, 0, 3, 0, 0, 0
		dw scrollRight
		db 0, 0, 47h, 0
word_B673:	dw 0			; DATA XREF: RAM:AA95w
		db 0C0h, 0, 0CBh, 0, 0,	0, 0, 0
		dw curPagePrew
		db 0, 0
word_B681:	dw 0			; DATA XREF: RAM:AB06w
		db 0F9h, 0, 0C0h, 0, 0CBh, 0, 0, 0
		db 0, 0
		dw curPageNext
		db 0, 0
tblMSDrives:	db 13h,	0, 36h,	0, 3Bh,	0, 49h,	0 ; DATA XREF: changeDrive+19o
		db 1, 0, 0, 0
		dw chDrv0
		db 0, 0, 13h, 0, 36h, 0, 49h, 0
		db 57h,	0, 1, 0, 0, 0
		dw chDrv1
		db 0, 0, 13h, 0, 36h, 0, 57h, 0
		db 65h,	0, 1, 0, 0, 0
		dw chDrv2
		db 0, 0, 13h, 0, 36h, 0, 65h, 0
		db 73h,	0, 1, 0, 0, 0
		dw chDrv3
		db 0, 0, 13h, 0, 36h, 0, 73h, 0
		db 81h,	0, 1, 0, 0, 0
		dw chDrv4
		db 0, 0, 13h, 0, 36h, 0, 81h, 0
		db 8Fh,	0, 1, 0, 0, 0
		dw chDrv5
		db 0, 0, 13h, 0, 36h, 0, 8Fh, 0
		db 9Dh,	0, 1, 0, 0, 0
		dw chDrv6
		db 0, 0, 13h, 0, 36h, 0, 9Dh, 0
		db 0ABh, 0, 1, 0, 0, 0
		dw chDrv7
		db 0, 0, 13h, 0, 36h, 0, 0ABh, 0
		db 0B9h, 0, 1, 0, 0, 0
		dw chDrv8
		db 0, 0, 0, 80h
tblKeyMain:	db    0			; DATA XREF: RAM:9340o
		db 58h
		dw curFilePrew
		db    0
		db  52h	; R
		dw curFileNext
		db    0
		db  54h	; T
		dw curFilePageLeft
		db    0
		db  56h	; V
		dw curFilePageRight
		db    0
		db  59h	; Y
		dw curPagePrew
		db    0
		db  53h	; S
		dw curPageNext
		db    0
		db  57h	; W
		dw curFileHome
		db    0
		db 51h
		dw curFileEnd
		db  0Dh
		db  28h	; (
		dw select
		db  20h
		db  38h	; 8
		dw select
		db    0
		db  3Bh	; ;
		dw mnuHelp
		db  48h	; H
		db  22h	; "
		dw mnuHelp
		db  68h	; h
		db  22h	; "
		dw mnuHelp
		db  53h	; S
		db  1Eh
		dw mnuInfo
		db  73h	; s
		db  1Eh
		dw mnuInfo
		db  49h	; I
		db  17h
		dw fnFileInfo
		db  69h	; i
		db  17h
		dw fnFileInfo
		db  51h	; Q
		db  10h
		dw dlgQuit
		db  71h	; q
		db  10h
		dw dlgQuit
		db  1Bh
		db    1
		dw dlgQuit
		db    0
		db  44h	; D
		dw dlgQuit
		db 0FFh
tblKeyMain1:	db    0			; DATA XREF: RAM:9338o
		db    1
		dw mouseSwitchONOFF	; Меняет режим мышки ВКЛ>ВЫКЛ и	наоборот
tblKbdDrives:	db    0			; DATA XREF: changeDrive+1Do
		db  1Dh
		dw chDrv0
		db    0
		db  2Eh	; .
		dw chDrv1
		db    0
		db  2Ch	; ,
		dw chDrv2
		db    0
		db  1Fh
		dw chDrv3
		db    0
		db  12h
		dw chDrv4
		db    0
		db  20h
		dw chDrv5
		db    0
		db  21h	; !
		dw chDrv6
		db    0
		db  17h
		dw chDrv7
		db    0
		db  23h	; #
		dw chDrv8
		db 0FFh
tblMsHelp:	db 0, 0, 40h, 1, 0, 0, 0, 1 ; DATA XREF: RAM:loc_9569o
		db 10h,	0, 0, 0, 0, 0
		dw leaveHelp
		db 0C8h, 0, 0EBh, 0, 0AEh, 0, 0BCh, 0
		db 9, 0, 0, 0
		dw leaveHelp
		db 0, 0, 0, 0, 98h, 0, 0, 0
		db 0, 1, 8, 0, 0, 0
		dw leaveHelp
		db 0, 0, 18h, 1, 40h, 1, 0, 0
		db 0, 1, 8, 0, 0, 0
		dw leaveHelp
		db 0, 0, 0, 0, 40h, 1, 0, 0
		db 44h,	0, 8, 0, 0, 0
		dw leaveHelp
		db 0, 0, 0, 0, 40h, 1, 0C4h, 0
		db 0, 1, 8, 0, 0, 0
		dw leaveHelp
		db 0, 0, 0, 80h
tblMsInfo:	db 0, 0, 40h, 1, 0, 0, 0, 1 ; DATA XREF: RAM:loc_96AFo
		db 10h,	0, 0, 0, 0, 0
		dw leaveInfo
		db 0D8h, 0, 0FBh, 0, 0ADh, 0, 0BBh, 0
		db 9, 0, 0, 0
		dw leaveInfo
		db 0, 0, 0, 0, 0A8h, 0,	0, 0
		db 0, 1, 8, 0, 0, 0
		dw leaveInfo
		db 0, 0, 20h, 1, 40h, 1, 0, 0
		db 0, 1, 8, 0, 0, 0
		dw leaveInfo
		db 0, 0, 0, 0, 40h, 1, 0, 0
		db 50h,	0, 8, 0, 0, 0
		dw leaveInfo
		db 0, 0, 0, 0, 40h, 1, 0C2h, 0
		db 0, 1, 8, 0, 0, 0
		dw leaveInfo
		db 0, 0, 0, 80h
tblMsFileInfo:	db 0, 0, 40h, 1, 0, 0, 0, 1 ; DATA XREF: RAM:loc_98BDo
		db 10h,	0, 0, 0, 0, 0
		dw leaveFileInfo
		db 0C0h, 0, 0E3h, 0, 0BDh, 0, 0CBh, 0
		db 9, 0, 0, 0
		dw leaveFileInfo
		db 0, 0, 0EAh, 0, 0Dh, 1, 0BDh,	0
		db 0CBh, 0, 9, 0, 0, 0
		dw errFileInfo
		db 0, 0, 0, 0, 0A8h, 0,	0, 0
		db 0, 1, 8, 0, 0, 0
		dw leaveFileInfo
		db 0, 0, 20h, 1, 40h, 1, 0, 0
		db 0, 1, 8, 0, 0, 0
		dw leaveFileInfo
		db 0, 0, 0, 0, 40h, 1, 0, 0
		db 60h,	0, 8, 0, 0, 0
		dw leaveFileInfo
		db 0, 0, 0, 0, 40h, 1, 0D2h, 0
		db 0, 1, 8, 0, 0, 0
		dw leaveFileInfo
		db 0, 0, 0, 80h
tblMsQuit:	db 0, 0, 40h, 1, 0, 0, 0, 1 ; DATA XREF: RAM:loopQuito
		db 10h,	0, 0, 0, 0, 0
		dw leaveQuit
		db 0C0h, 0, 0E3h, 0, 98h, 0, 0A6h, 0
		db 9, 0, 0, 0
		dw quit
		db 0, 0, 0F0h, 0, 13h, 1, 98h, 0
		db 0A6h, 0, 9, 0, 0, 0
		dw leaveQuit
		db 0, 0, 0, 0, 0A8h, 0,	0, 0
		db 0, 1, 8, 0, 0, 0
		dw leaveQuit
		db 0, 0, 28h, 1, 40h, 1, 0, 0
		db 0, 1, 8, 0, 0, 0
		dw leaveQuit
		db 0, 0, 0, 0, 40h, 1, 0, 0
		db 74h,	0, 8, 0, 0, 0
		dw leaveQuit
		db 0, 0, 0, 0, 40h, 1, 0B0h, 0
		db 0, 1, 8, 0, 0, 0
		dw leaveQuit
		db 0, 0, 0, 80h
tblMsError:	db 0, 0, 40h, 1, 0, 0, 0, 1 ; DATA XREF: showError:loc_A08Do
		db 10h,	0, 0, 0, 0, 0
		dw setCurDrv
		db 90h,	0, 0B3h, 0, 86h, 0, 94h, 0
		db 9, 0, 0, 0
		dw setCurDrv
		db 0, 0, 0, 0, 60h, 0, 0, 0
		db 0, 1, 8, 0, 0, 0
		dw setCurDrv
		db 0, 0, 0E0h, 0, 40h, 1, 0, 0
		db 0, 1, 8, 0, 0, 0
		dw setCurDrv
		db 0, 0, 0, 0, 40h, 1, 0, 0
		db 62h,	0, 8, 0, 0, 0
		dw setCurDrv
		db 0, 0, 0, 0, 40h, 1, 9Eh, 0
		db 0, 1, 8, 0, 0, 0
		dw setCurDrv
		db 0, 0, 0, 80h
tblMSMessage:	db 0, 0, 40h, 1, 0, 0, 0, 1 ; DATA XREF: showError:loc_A31Bo
		db 10h,	0, 0, 0, 0, 0
		dw leaveMsg
		db 90h,	0, 0B3h, 0, 86h, 0, 94h, 0
		db 9, 0, 0, 0
		dw leaveMsg
		db 0, 0, 0, 0, 5Ch, 0, 0, 0
		db 0, 1, 8, 0, 0, 0
		dw leaveMsg
		db 0, 0, 0, 0, 40h, 1, 0, 0
		db 62h,	0, 8, 0, 0, 0
		dw leaveMsg
		db 0, 0, 0, 0, 40h, 1, 9Eh, 0
		db 0, 1, 8, 0, 0, 0
		dw leaveMsg
		db 0, 0, 0E4h, 0, 40h, 1, 0, 0
		db 0, 1, 8, 0, 0, 0
		dw leaveMsg
		db 0, 0, 0, 80h

; =============== S U B	R O U T	I N E =======================================


openFile:				; CODE XREF: RAM:944Cp	RAM:B5B5p
		push	ix
		pop	hl
		ld	de, bufFile
		ld	bc, 119h	; F_FIRST
		ld	a, 37h ; '7'
		rst	10h
		ret	c
		sub	a
		ld	(memAllocated),	a
		ld	ix, bufFile
		ld	l, (ix+1Ch)
		ld	h, (ix+1Dh)
		ld	(fileSizeLow), hl
		ld	e, (ix+1Eh)
		ld	d, (ix+1Fh)
		ld	(fileSizeHigh),	de
		ld	a, d
		or	a
		jr	nz, loc_BA57
		ld	a, h
		rla
		rl	e
		rl	d
		rla
		rl	e
		rl	d
		ld	a, h
		and	3Fh ; '?'
		or	l
		jr	z, loc_BA4B
		inc	de

loc_BA4B:				; CODE XREF: openFile+3Bj
		ld	a, d
		or	a
		jr	nz, loc_BA57
		ld	b, e
		ld	c, 3Dh ; '='    ; GETMEM
		push	bc
		rst	10h
		pop	bc
		jr	nc, loc_BA63

loc_BA57:				; CODE XREF: openFile+2Aj openFile+40j
		ld	a, 1
		ld	(memAllocated),	a
		ld	bc, 13Dh	; GETMEM
		push	bc
		rst	10h
		pop	bc
		ret	c

loc_BA63:				; CODE XREF: openFile+48j
		ld	(idMemory2), a
		ld	hl, arrPages1
		ld	c, 0C5h	; '┼'   ; EMM_FN5
		push	bc
		rst	8
		pop	bc
		ld	hl, byte_9100
		sub	a

loc_BA72:				; CODE XREF: openFile+67j
		ld	(hl), a
		inc	hl
		djnz	loc_BA72
		ld	hl, specFile
		ld	a, 1
		ld	c, 11h		; OPEN
		rst	10h
		ret	c
		ld	(fileManipulator), a
		ld	hl, 8000h
		ld	de, specFileTmp
		ld	bc, 18h
		ldir
; End of function openFile


; =============== S U B	R O U T	I N E =======================================

; Определение функции обработки	по расширению файла

extDefinition:				; CODE XREF: RAM:errFileInfop
					; RAM:B59Fp

; FUNCTION CHUNK AT C6E2 SIZE 00000072 BYTES

		ld	(bufStack), sp
		ld	ix, tblImageProc
		ld	hl, specFile
		ld	de, strExt	; "BMPPCXICO"
		ld	a, 2Eh ; '.'

loc_BA9D:				; CODE XREF: extDefinition+12j
		inc	hl
		cp	(hl)
		jr	nz, loc_BA9D
		inc	hl
		ex	de, hl

loc_BAA3:				; CODE XREF: extDefinition+38j
		ld	c, (ix+0)
		inc	ix
		ld	b, (ix+0)
		inc	ix
		push	bc
		push	de
		ld	bc, 300h

loc_BAB2:				; CODE XREF: extDefinition+2Fj
		ld	a, (de)
		res	5, a
		cp	(hl)
		jr	z, loc_BABA
		set	0, c

loc_BABA:				; CODE XREF: extDefinition+29j
		inc	hl
		inc	de
		djnz	loc_BAB2
		pop	de
		ld	a, c
		or	a
		ret	z
		pop	bc
		sub	a
		cp	(hl)
		jr	nz, loc_BAA3
		ld	ix, bufFile
		ld	l, (ix+1Ch)
		ld	h, (ix+1Dh)
		ld	e, (ix+1Eh)
		ld	d, (ix+1Fh)
		ld	a, d
		or	e
		or	l
		ld	a, 81h ; 'Б'
		scf
		ret	nz
		ld	a, h		; Проверка по длине файла 6144 или 6912
		cp	18h
		jp	z, showBWZXScr
		cp	1Bh
		jp	z, showColorZXScr
		ld	a, 81h ; 'Б'
		scf
		ret
; End of function extDefinition

		include	"gfx_view.asm"
bufTemp:	equ	$			; DATA XREF: readBMP-2BFo readBMP-2BCt ...
						; Temporary Buffer


GFXviewEnd
gfx_main_lenght	equ GFXviewEnd-GFXviewStart
		savebin	"gfx_main.bin",GFXviewStart,GFXviewEnd-GFXviewStart
		export idMemory1
		export idMemory
		export MainStart
		export gfx_main_lenght