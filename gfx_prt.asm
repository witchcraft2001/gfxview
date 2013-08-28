; =============== S U B	R O U T	I N E =======================================


prtString:				; CODE XREF: prtDirName+4Cp
					; prtFiles+44p	...
		push	iy
		push	ix
		ex	af, af'
		in	a, (89h)	; Y_PORT
		push	af
		in	a, (0A2h)	; Page1
		push	af
		ex	af, af'
		ld	yh, c
		or	0F0h ; 'Ё'
		ld	c, a
		push	de
		push	bc
		exx
		pop	bc
		pop	hl
		set	6, h
		exx
		ld	a, 50h ; 'P'
		out	(0A2h),	a	; Page1
		ld	a, (hl)
		inc	hl

loopPrtString:				; CODE XREF: prtString+198j
		exx
		ld	e, a
		ld	d, 87h ; 'З'    ; #8700 - фонт
		ld	a, (de)
		inc	d
		ex	af, af'
		ld	a, yh
		out	(89h), a
		ld	b, a
		ld	a, (de)
		inc	d
		rlca
		jr	nc, loc_A8A1
		ld	(hl), c

loc_A8A1:				; CODE XREF: prtString+2Ej
		inc	hl
		rlca
		jr	nc, loc_A8A6
		ld	(hl), c

loc_A8A6:				; CODE XREF: prtString+33j
		inc	hl
		rlca
		jr	nc, loc_A8AB
		ld	(hl), c

loc_A8AB:				; CODE XREF: prtString+38j
		inc	hl
		rlca
		jr	nc, loc_A8B0
		ld	(hl), c

loc_A8B0:				; CODE XREF: prtString+3Dj
		inc	hl
		rlca
		jr	nc, loc_A8B5
		ld	(hl), c

loc_A8B5:				; CODE XREF: prtString+42j
		inc	hl
		rlca
		jr	nc, loc_A8BA
		ld	(hl), c

loc_A8BA:				; CODE XREF: prtString+47j
		inc	hl
		rlca
		jr	nc, loc_A8BF
		ld	(hl), c

loc_A8BF:				; CODE XREF: prtString+4Cj
		inc	hl
		rlca
		jr	nc, loc_A8C4
		ld	(hl), c

loc_A8C4:				; CODE XREF: prtString+51j
		inc	b
		ld	a, b
		out	(89h), a	; Y_PORT
		ld	a, (de)
		inc	d
		rrca
		jr	nc, loc_A8CE
		ld	(hl), c

loc_A8CE:				; CODE XREF: prtString+5Bj
		dec	hl
		rrca
		jr	nc, loc_A8D3
		ld	(hl), c

loc_A8D3:				; CODE XREF: prtString+60j
		dec	hl
		rrca
		jr	nc, loc_A8D8
		ld	(hl), c

loc_A8D8:				; CODE XREF: prtString+65j
		dec	hl
		rrca
		jr	nc, loc_A8DD
		ld	(hl), c

loc_A8DD:				; CODE XREF: prtString+6Aj
		dec	hl
		rrca
		jr	nc, loc_A8E2
		ld	(hl), c

loc_A8E2:				; CODE XREF: prtString+6Fj
		dec	hl
		rrca
		jr	nc, loc_A8E7
		ld	(hl), c

loc_A8E7:				; CODE XREF: prtString+74j
		dec	hl
		rrca
		jr	nc, loc_A8EC
		ld	(hl), c

loc_A8EC:				; CODE XREF: prtString+79j
		dec	hl
		rrca
		jr	nc, loc_A8F1
		ld	(hl), c

loc_A8F1:				; CODE XREF: prtString+7Ej
		inc	b
		ld	a, b
		out	(89h), a	; Y_PORT
		ld	a, (de)
		inc	d
		rlca
		jr	nc, loc_A8FB
		ld	(hl), c

loc_A8FB:				; CODE XREF: prtString+88j
		inc	hl
		rlca
		jr	nc, loc_A900
		ld	(hl), c

loc_A900:				; CODE XREF: prtString+8Dj
		inc	hl
		rlca
		jr	nc, loc_A905
		ld	(hl), c

loc_A905:				; CODE XREF: prtString+92j
		inc	hl
		rlca
		jr	nc, loc_A90A
		ld	(hl), c

loc_A90A:				; CODE XREF: prtString+97j
		inc	hl
		rlca
		jr	nc, loc_A90F
		ld	(hl), c

loc_A90F:				; CODE XREF: prtString+9Cj
		inc	hl
		rlca
		jr	nc, loc_A914
		ld	(hl), c

loc_A914:				; CODE XREF: prtString+A1j
		inc	hl
		rlca
		jr	nc, loc_A919
		ld	(hl), c

loc_A919:				; CODE XREF: prtString+A6j
		inc	hl
		rlca
		jr	nc, loc_A91E
		ld	(hl), c

loc_A91E:				; CODE XREF: prtString+ABj
		inc	b
		ld	a, b
		out	(89h), a	; Y_PORT
		ld	a, (de)
		inc	d
		rrca
		jr	nc, loc_A928
		ld	(hl), c

loc_A928:				; CODE XREF: prtString+B5j
		dec	hl
		rrca
		jr	nc, loc_A92D
		ld	(hl), c

loc_A92D:				; CODE XREF: prtString+BAj
		dec	hl
		rrca
		jr	nc, loc_A932
		ld	(hl), c

loc_A932:				; CODE XREF: prtString+BFj
		dec	hl
		rrca
		jr	nc, loc_A937
		ld	(hl), c

loc_A937:				; CODE XREF: prtString+C4j
		dec	hl
		rrca
		jr	nc, loc_A93C
		ld	(hl), c

loc_A93C:				; CODE XREF: prtString+C9j
		dec	hl
		rrca
		jr	nc, loc_A941
		ld	(hl), c

loc_A941:				; CODE XREF: prtString+CEj
		dec	hl
		rrca
		jr	nc, loc_A946
		ld	(hl), c

loc_A946:				; CODE XREF: prtString+D3j
		dec	hl
		rrca
		jr	nc, loc_A94B
		ld	(hl), c

loc_A94B:				; CODE XREF: prtString+D8j
		inc	b
		ld	a, b
		out	(89h), a	; Y_PORT
		ld	a, (de)
		inc	d
		rlca
		jr	nc, loc_A955
		ld	(hl), c

loc_A955:				; CODE XREF: prtString+E2j
		inc	hl
		rlca
		jr	nc, loc_A95A
		ld	(hl), c

loc_A95A:				; CODE XREF: prtString+E7j
		inc	hl
		rlca
		jr	nc, loc_A95F
		ld	(hl), c

loc_A95F:				; CODE XREF: prtString+ECj
		inc	hl
		rlca
		jr	nc, loc_A964
		ld	(hl), c

loc_A964:				; CODE XREF: prtString+F1j
		inc	hl
		rlca
		jr	nc, loc_A969
		ld	(hl), c

loc_A969:				; CODE XREF: prtString+F6j
		inc	hl
		rlca
		jr	nc, loc_A96E
		ld	(hl), c

loc_A96E:				; CODE XREF: prtString+FBj
		inc	hl
		rlca
		jr	nc, loc_A973
		ld	(hl), c

loc_A973:				; CODE XREF: prtString+100j
		inc	hl
		rlca
		jr	nc, loc_A978
		ld	(hl), c

loc_A978:				; CODE XREF: prtString+105j
		inc	b
		ld	a, b
		out	(89h), a	; Y_PORT
		ld	a, (de)
		inc	d
		rrca
		jr	nc, loc_A982
		ld	(hl), c

loc_A982:				; CODE XREF: prtString+10Fj
		dec	hl
		rrca
		jr	nc, loc_A987
		ld	(hl), c

loc_A987:				; CODE XREF: prtString+114j
		dec	hl
		rrca
		jr	nc, loc_A98C
		ld	(hl), c

loc_A98C:				; CODE XREF: prtString+119j
		dec	hl
		rrca
		jr	nc, loc_A991
		ld	(hl), c

loc_A991:				; CODE XREF: prtString+11Ej
		dec	hl
		rrca
		jr	nc, loc_A996
		ld	(hl), c

loc_A996:				; CODE XREF: prtString+123j
		dec	hl
		rrca
		jr	nc, loc_A99B
		ld	(hl), c

loc_A99B:				; CODE XREF: prtString+128j
		dec	hl
		rrca
		jr	nc, loc_A9A0
		ld	(hl), c

loc_A9A0:				; CODE XREF: prtString+12Dj
		dec	hl
		rrca
		jr	nc, loc_A9A5
		ld	(hl), c

loc_A9A5:				; CODE XREF: prtString+132j
		inc	b
		ld	a, b
		out	(89h), a	; Y_PORT
		ld	a, (de)
		inc	d
		rlca
		jr	nc, loc_A9AF
		ld	(hl), c

loc_A9AF:				; CODE XREF: prtString+13Cj
		inc	hl
		rlca
		jr	nc, loc_A9B4
		ld	(hl), c

loc_A9B4:				; CODE XREF: prtString+141j
		inc	hl
		rlca
		jr	nc, loc_A9B9
		ld	(hl), c

loc_A9B9:				; CODE XREF: prtString+146j
		inc	hl
		rlca
		jr	nc, loc_A9BE
		ld	(hl), c

loc_A9BE:				; CODE XREF: prtString+14Bj
		inc	hl
		rlca
		jr	nc, loc_A9C3
		ld	(hl), c

loc_A9C3:				; CODE XREF: prtString+150j
		inc	hl
		rlca
		jr	nc, loc_A9C8
		ld	(hl), c

loc_A9C8:				; CODE XREF: prtString+155j
		inc	hl
		rlca
		jr	nc, loc_A9CD
		ld	(hl), c

loc_A9CD:				; CODE XREF: prtString+15Aj
		inc	hl
		rlca
		jr	nc, loc_A9D2
		ld	(hl), c

loc_A9D2:				; CODE XREF: prtString+15Fj
		inc	b
		ld	a, b
		out	(89h), a	; Y_PORT
		ld	a, (de)
		inc	d
		rrca
		jr	nc, loc_A9DC
		ld	(hl), c

loc_A9DC:				; CODE XREF: prtString+169j
		dec	hl
		rrca
		jr	nc, loc_A9E1
		ld	(hl), c

loc_A9E1:				; CODE XREF: prtString+16Ej
		dec	hl
		rrca
		jr	nc, loc_A9E6
		ld	(hl), c

loc_A9E6:				; CODE XREF: prtString+173j
		dec	hl
		rrca
		jr	nc, loc_A9EB
		ld	(hl), c

loc_A9EB:				; CODE XREF: prtString+178j
		dec	hl
		rrca
		jr	nc, loc_A9F0
		ld	(hl), c

loc_A9F0:				; CODE XREF: prtString+17Dj
		dec	hl
		rrca
		jr	nc, loc_A9F5
		ld	(hl), c

loc_A9F5:				; CODE XREF: prtString+182j
		dec	hl
		rrca
		jr	nc, loc_A9FA
		ld	(hl), c

loc_A9FA:				; CODE XREF: prtString+187j
		dec	hl
		rrca
		jr	nc, loc_A9FF
		ld	(hl), c

loc_A9FF:				; CODE XREF: prtString+18Cj
		ex	af, af'
		ld	e, a
		ld	d, 0
		add	hl, de
		exx
		ld	a, (hl)
		inc	hl
		or	a
		jp	nz, loopPrtString
		pop	af
		out	(0A2h),	a	; Page1
		pop	af
		out	(89h), a	; Y_PORT
		pop	ix
		pop	iy
		ret
; End of function prtString
