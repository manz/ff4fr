; ----------------------------------------------------------------------------
;  Final Fantasy IV (French Translation) - Use modified X816 to compile to IPS file
; modifé: 10:06 21/02/2004
; ---------------------------------------------------------------------------


.incsrc "asm2ips.asm" ; j'ai taxé le nom a Mera :)
.memmapset (LOW,YES)

.detect on

.asctable                       ;  set up ascii table map for 8x8 text
32 = $20 : "A".."Z" = $42 : "a".."z" = $5C
.end


VRAMCPYM .MACRO (source,vramptr,count,channel,mode)	
	PHP
	PHA
	PHX
	
	;jsr.w vblank_wrk
	
	LDA.B #$80
	STA.W $2115
	LDX.W #!vramptr
	STX.W $2116	
	LDX.W #!mode
	STX.W $4300+channel<<4	
	LDA.B #^source
	STA.W $4304+channel<<4
	LDX.W #!source
	STX.W $4302+channel<<4	
	LDX.W #!count
	STX.W $4305+channel<<4
	LDA.B #$01<<channel
	STA $420B

	NOP
	NOP
	
	PLX
	PLA
	PLP
.ENDM

.patch ($00B463)
	JSL.L vwfstart
	RTS
.endp (1)

.patch ($208000)
; ******************
; ** Declarations **
; ******************

	CNTR = $15	;old $15
	CURRENT_C = $30
	pixel_c = $20
	BITSLEFT = $04
	TILEPOS = $06
	CNTR2 = $08
	TEMP = $0A
;vramcpy call;
	scroll = $10
	vsize = $12
;buildmap call
	winstate = $17
	tstart = $18
	nchars = $19
	
	oldtilepos = $F6
	
	WRAM = $421B
	WRAM2 = $423B
	WRAMPTR = $2108

	;FONTADDR = $3FE370
	;LENTBL = $3FDA00

;** routine principale
vwfstart:

	SEP #$20
	REP #$10
	
	LDA.B #$01
	STA.W $420D
	
	LDA.B CNTR
	STA $7E523D

	LDA.B CURRENT_C
	STA $7E523E

	LDA.B BITSLEFT
	STA $7E523F

	LDA.B TILEPOS
	STA $7E5240
	
	LDA.B CNTR2
	STA $7E5241

	LDA.B TEMP
	STA $7E5242

	STZ CNTR
	
	STZ CURRENT_C
	STZ TILEPOS

	stz oldtilepos

	STZ CNTR2
	STZ TEMP

	STZ pixel_c
	STZ pixel_c+1
	
	LDA.B #$01
	STA.B winstate
	
	
	LDA.B #$08
	STA.B BITSLEFT

	JSR.W clr		; on efface un peu de Wram
	
	LDA #$02
	STA $210C
	
	jsr.w vblank_wrk
	.vramcpym ($7E421B,$6800,$0690,7,$1801)		;copie de l'image de la v	wf
	jsr.w vblank_wrk
	.vramcpym ($7E421B,$6800+$348,$0690,7,$1801)		;copie de l'image de la vwf
	
	jsr.w vblank_wrk
	.vramcpym ($0AF000,$6000,$1000,7,$1801)	;on copie la font 8x8
	;JSL.L wclear
	
	JSR.W ChargeLettre
	BRA firstrun
	
main:	
	JSR.W ChargeLettreInc
	
firstrun:
	JMP.W parse
	BRA main
fin:
	LDA $7E523D
	STA.B $00

	LDA $7E523E
	STA.B $01

	LDA $7E523F
	STA.B $02

	JSR.W wdisplay
	STZ.B TILEPOS
	
	LDA.B #$01
	STA.B $ED
	STA.B $DE

	RTL

;******************
;** Parsing code **
;******************

parse:

	; Message Break
	CMP #$00
	BNE _nxt1
	JMP.W fin
	
_nxt1:
	CMP #$01
	BNE _nxt2
	JMP.W newline
	
_nxt2:	
	CMP #$02
	BNE _nxt6
	JMP.W space
	
_nxt6:
	;Changement de Musique
	CMP #$03
	BNE _nxt3
	JMP.W musique
	
_nxt3:
	; Nom des personages
	CMP #$04
	BNE _nxt4
	JMP.W printname
_nxt4:

	; Delay avant de fermer ?
	CMP #$05
	BNE _nxt5
	;	JMP.W _code05
	_nxt5:
	
	CMP #$08
	BNE _nxt8
	JMP.W _code08
	
_nxt8:	
	CMP #$FB
	BNE _nxtFB
	STZ.B winstate
	
_nxtfb:	
	CMP #$FC
	BNE _nxtFC
	JMP.W suit3
	
_nxtFC:	
	CMP #$FF
	BNE _nxtFF
	JMP.W retour_auto
	
_nxtFF:

	; on fabrique le pointeur de font et le pointeur vers la wram
	;retour auto a ajouter ici
	
return_a:

	JSR.W makeptr
	JSR.W ShiftNew
	JSR.W wdisplay

	JMP.W main
	
	
;***********
;** Space **
;***********
space:
	JSR.W ChargeLettreInc
	CLC
	ADC.B TILEPOS
	JMP.W main

;******************
;Cout en gils
;******************

_code08:
	LDA.W $08F8
	STA.B $30
	LDA.W $08F9
	STA.B $31
	LDA.W $08FA
	STA.B $32
	JSL.L $15C324

	LDX.W #$0000

_loop_B5C3:
	LDA.B $36,X
	CMP #$80
	BNE _loop_B5D2
	INX
	CPX.W #$0005
	BEQ _loop_B5D2
	JMP _loop_B5C3

_loop_B5D2:
	LDA.B $36,X
		; Old code
		;00B5D4 STA $0774,Y
		;00B5D7 LDA #$FF
		;00B5D9 STA $0834,Y
		;00B5DC INY
	PHX
	PHY
	
	STA.B CURRENT_C			;appel de la vwf
	;JSR.W vwf.makeptr		;
	;JSR.W vwf.shift			;

	JSR.W makeptr
	JSR.W ShiftNew
	JSR.W wdisplay
	
	PLY
	PLX

	INX
	CPX.W #$0006
	BNE _loop_B5D2

	JMP.W main

;================================
;Nouveau Cadre
;================================

nouveau_cadre:
		
	JSR.W vramcpy2

	LDA.B #$00
	STA.B TILEPOS
	JSR.W incpointer
	LDA.B #$01
	STA.B $ED
	RTL


;****************
;** printfname **
;****************
printname:
	JSR.W ChargeLettreInc
	ASL
	STA.B $18
	ASL
	CLC
	ADC $18
	STA.B $18
	STZ.B $19
	LDX.W $18

	STZ CNTR
	
next:
	LDX.B $18
	LDA $1500,X
	STA.B CURRENT_C
	CMP #$FF
	BEQ exit
	INX
	PHX
	JSR.W makeptr
	JSR.W ShiftNew
	JSR.W wdisplay
	PLX

suite:
	INC.B $18

	INC.B CNTR
	LDA.B CNTR
	CMP #$06
	BEQ exit
	JMP.W next
exit:
	JMP.W main

;********************
;** Nouvelle ligne **
;********************
newline:
	STZ.B pixel_c
	STZ.B pixel_c+1

	REP #$20
	LDA.W #$0008
	SEP #$20

	STA.B BITSLEFT

	LDA.B TILEPOS
	CLC
	;Second line
	CMP #$1A+1
	BCS suit
	
	LDA.B #$1A
	STA.B TILEPOS
	BRA end
suit:

	;Third Line
	CMP #$34+1
	BCS suit2
	LDA.B #$34
	STA.B TILEPOS
	BRA end
suit2:
	
	;Forth Line
	CMP #$4E+1
	BCS suit3

	LDA.B #$4E
	STA.B TILEPOS
	BRA end

suit3:	

	STZ CURRENT_C
	STZ TILEPOS
	STZ CNTR2
	STZ TEMP

	STZ pixel_c
	STZ pixel_c+1

	LDA.B #$08
	STA.B BITSLEFT

	JSR.W clr
	JSR.W waitpad
	JSR.W wdisplay
end:

	JMP.W main

;*************
;** Musique **
;*************

musique:
	JSR.W ChargeLettreInc
	STA $1E01
	LDA.B #$01
	STA $1E00

	JSL $048004
	JMP.W main

_code05:
	JSR.W ChargeLettreInc
	STZ $19
	ASL
	ROL $19
	ASL
	ROL $19
	ASL
	ROL $19
	STA $18
	LDX $18
	STX $08F4
	LDX $0000
	STX $08F6
	JMP.W main

;*******************
;** Shift Routine **
;*******************

ShiftNew:
	REP #$20
	LDA.W #$0010
	STA.B CNTR
	SEP #$20

	PHB
	LDA.B #$7E
	PHA
	PLB

Boucle2:
	REP #$20
	LDA.W #$0000
	STZ.B CNTR2
	SEP #$20
	PHX
	LDA.B BITSLEFT
	
	CMP #$08
	BNE _shift
	PLX
	;REP #$20
	LDA.L FONTADDR,X
	;SEP #$20
	INX
	XBA
	BRA _store
		
_shift:
	TAX			; using math multiplication
	LDA.L vwf.shifttbl,X
	STA.L $004202		; MULTPILIER

		
	PLX
		
	;REP #$20
		
	LDA.L FONTADDR,X
	INX

	STA.L $004203		; MULTIPLICAND
	
	REP #$20
	NOP
	NOP
	NOP
	NOP
	LDA.L $004216	; the result is stored in $4216-$4217
	SEP #$20

_store:
	INY
	XBA
		
	ORA.W WRAM,Y
	STA.W WRAM,Y
	XBA
	STA.W WRAM2,Y
		
	INY
				
	DEC CNTR
	BNE Boucle2
		
	PLB
	PHA
	PLA

	REP #$20
	STZ.B TEMP
	LDA.W #$0000
	LDX.W #$0000
	SEP #$20

	LDA.B CURRENT_C
	TAX

	LDA.L LENTBL,X
	STA.B TEMP
		
	REP #$20
	CLC
	
	ADC.B pixel_c
	INC
	CLC
	STA.B pixel_c
	LDA.W #$0000
	SEP #$20

	LDA.B BITSLEFT

	CLC
	SBC.B TEMP

loopdec:
	CMP #$00
	BMI coupe
	BEQ coupe
		
	STA.B BITSLEFT
	RTS

coupe:
	CLC
	ADC #$08
	INC TILEPOS
	BRA loopdec


vwf.shifttbl:
.db %00000000				; dummy entrie =0
.db %00000010				;1
.db %00000100				;2
.db %00001000				;3
.db %00010000				;4
.db %00100000				;5
.db %01000000				;6
.db %10000000				;7
.db %10000000				;8

;************************
;** build font pointer **
;************************

makeptr:
	PHA	
	
	LDX.W #$0000
	LDY.W #$0000
	LDA.B CURRENT_C
	REP #$20
	ASL
	ASL
	ASL
	ASL
	TAX
	LDA.W #$0000
	SEP #$20

	LDA.B TILEPOS
	sta.b oldtilepos
	REP #$20
	ASL
	ASL
	ASL
	ASL
	ASL
	sta.b oldtilepos
	TAY
	SEP #$20
	PLA
	RTS

;===================================
;Build map 2
;
;===================================
buildmap2:

debut2:
	STA.W $0834,X
	INC
	STA.W $0774,X
	INX
	INC

	DEC nchars
	BNE debut2
RTS

;*********************
;** Build Image Map **
;*********************

buildmap:

	LDA.B #$00
	LDX.W #$0000
	
debut:
	
	STA $0834,X
	INC

	STA $0774,X
	INX
	INC
	CPX #$00C0
	BMI debut	
	RTS

;===================================
;Vram Copy 2
;
;===================================
vramcpy:
;utilisation du channel 7 du transfer de DMA

	PHP
	PHA
	PHX
	;desactive interrupts
	;LDA.W $4200
	;AND.B #$7F
	;STA.W $4200

	LDA.B #$80
	STA $2115
	STZ $420B
	
	STX.W $2116

	LDA.B #$01
	STA $4370
	LDA.B #$18
	STA $4371

	LDA.B #$7E
	STA $4374
	LDX.W #WRAM

	STX.W $4372
	STY.W $4375


	LDA.B #$80
	STA $420B
	STZ $2102
	STZ $420B
	STZ $4300

	;active interupts
	;LDA.W $4200
	;CLC
	;ADC.B #$80
	
	PLX
	PLA
	PLP
RTS

;===================================
;Vram Copy
;
;===================================
vramcpy2:

	PHP
	PHA
	PHX

	LDA.B #$06		;change l'addresse du tile set du BG3 à $6000
	STA.W $210C		;dans la vram

	LDA.B #$80
	STA $2115
	STZ $420B
	
	LDA.B #$01
	STA $4300
	LDA.B #$18
	STA $4301

	LDA.B #$7E
	STA $4304
	LDX.W #WRAM
	STX.W $4302

	LDX.W #$6800
	STX.W $2116

	LDX.W #$0D20
	STX.W $4305


	LDA.B #$01
	STA $420B
	STZ $2102
	STZ $420B
	STZ $4300


	PLX
	PLA
	PLP
RTS

;===================================
;Clear Wram
;
;===================================
clr:
	PHB			;efface la la ram pour y stocker l'image
	LDA.B #$7E
	PHA
	PLB
	LDX.W #$0000
@lop:
	LDA.B #$FF
	STA.W WRAM,X
	INX

	LDA.B #$00
	STA.W WRAM,X
	INX

	CPX.W #$0D10
		
	BNE @lop
	
@lop2:
		
	LDA.B #$00
	STA.W WRAM,X
		
	INX
		
	CPX.W #$0D20
	BNE @lop2

	PLB
	PHA
	PLA
	;.vramcpym ($7E421B,$6800,$0D10,7,$1801)		;copie de l'image de la vwf
	
	RTS

;*****************
;** Retour auto **
;*****************
;on cherche l'espace suivant
retour_auto:

	PHX
	LDX.W #$0000
	LDY.W $0772	;on sauve la position de lecture dans Y
	STZ.B temp
	STZ.B temp+1
	LDA.B $3F
	;LDA.B CURRENT_C
	PHA
	BRA firstrun2
loopchr:
	JSR.W chargelettreinc
	
;règles de césure
	BEQ chrfound	;Message Break \n<end>\n\n
	CMP #$FF	;espace
	BEQ chrfound
	CMP #$FC	;<new>
	BEQ chrfound
	CMP #$01	;\n
	BEQ chrfound

	firstrun2:
	;REP #$20
	TAX
	;SEP #$20

	LDA.L lentbl,X ; on load la largeur de la lettre
	INC

	REP #$20
	CLC
	ADC.B temp
	STA.B temp
	SEP #$20
	
	;else
	BRA loopchr

	chrfound:

	REP #$20
	LDA.W #$0000
	LDA.B pixel_c
	CLC
	ADC.B temp

	CMP.W #$00CD	;largeur max en pixel
	BMI noreturn
retour:
	SEP #$20
	PLA
	STA.B $3F
	STY.W $0772	; restoration de la position du texte
	PLX
	JMP.W newline
	
	noreturn:
	;LDA.W #$0000
	SEP #$20
	PLA
	STA.B $3F
	STY.W $0772	; restauration de la position du texte
	JSR.W chargelettre ; ça evite a certains caractères de passer à la trappe
	PLX
	JMP.W return_a


;Wait for vblank routine


;Wait for joypad 1
Waitpad:
	PHA
	LDA.B winstate
	BEQ nowaitpad
	
padloop:
	LDA.W $4218
	BEQ padloop
	PLA
	JSR.W clr	
	jsr.w vblank_wrk
	.vramcpym ($7E421B,$6800,$0690,7,$1801)		;copie de l'image de la vwf
	jsr.w vblank_wrk
	.vramcpym ($7E48AB,$6800+$348,$0690,7,$1801)		;copie de l'image de la vwf
	RTS
	
nowaitpad:
	
	LDA.B #$10
	STA CNTR
	nowaitloop:
	WAI
	WAI
	WAI
	WAI
	DEC CNTR
	BNE nowaitloop
	PLA
	jsr.w clr
	jsr.w vblank_wrk
	.vramcpym ($7E421B,$6800,$0690,7,$1801)		;copie de l'image de la vwf
	jsr.w vblank_wrk
	.vramcpym ($7E48AB,$6800+$348,$0690,7,$1801)		;copie de l'image de la vwf
	
	RTS

vblank_wrk:
l1:
	lda $4212 
	bmi l1
l2:
	lda $4212
	bpl l2
	rts

wdisplay:


;wait for vblank to transfer

	jsr.w vblank_wrk

;	php 
	sep #$20


	;.vramcpym ($7E421B,$6800,$0040,7,$1801)		;copie de l'image de la vwf
	;macro expansion
	
	PHP
	PHA
	PHX

	LDA.B #$80
	STA.W $2115
	
	;lda tilepos
	
	rep #$20
	pha

	lda.b oldtilepos
	lsr			; addresse vram /2
	clc
	adc.w #$6800
	sta.w $2116

	
	lda.b oldtilepos
	clc
	adc.w #$421B
	sta.w $4372
	
	pla
	sep #$20
	
	channel = 7
	
	LDX.W #$1801
	STX.W $4300+channel<<4
	LDA.B #$7E
	STA.W $4304+channel<<4
	;LDX.W #$421B
	;STX.W $4302+channel<<4	
	LDX.W #$0040
	STX.W $4305+channel<<4
	LDA.B #$01<<channel
	STA $420B

	NOP
	NOP
	
	PLX
	PLA
	PLP
	

;; transfer

	LDA.B #$06		;change l'addresse du tile set du BG3 à $6000
	STA.W $210C		;dans la vram
	LDA.B #$0A<<2+1		;déplacement du tileset
	STA.W $2109		;vers $2800 ?

	STZ.W $2111		;horizontal scrool BG3
	STZ.W $2111

	STZ.W $2112		;vertical scrool BG3
	STZ.W $2112
	
	LDA.B winstate
	BEQ nowindow
	
	.vramcpym (winmap,$2840,endmap-winmap,7,$1801)	;copie de la map
	BRA window
	
nowindow:
	.vramcpym (intromap,$2840,$0280,7,$1801)	;copie de la map	
	
	window:
	LDA.B #$0F		;screen:ON luminosité au max
	STA.W $2100
		

	WAI			;wait for interrupts
;WAI
	;WAI
	RTS

wclear:
	LDX #$2840
	STX $2116
	STZ $10
	LDX #!clearmap
	STX $4302
	LDA #^clearmap
	STA $4304
	LDX #endclearmap-clearmap
	STX $4305

	LDA #$01
	STA $420B
	NOP
	RTL

wclose:
	

	
winmap:
.dw $2000,$2000,$2016,$2017,$2017,$2017,$2017,$2017,$2017,$2017,$2017,$2017,$2017,$2017,$2017,$2017,$2017,$2017,$2017,$2017,$2017,$2017,$2017,$2017,$2017,$2017,$2017,$2017,$2017,$2018,$2000,$2000
.dw $2000,$2000,$2019,$2100,$2102,$2104,$2106,$2108,$210A,$210C,$210E,$2110,$2112,$2114,$2116,$2118,$211A,$211C,$211E,$2120,$2122,$2124,$2126,$2128,$212A,$212C,$212E,$2130,$2132,$201A,$2000,$2000
.dw $2000,$2000,$2019,$2101,$2103,$2105,$2107,$2109,$210B,$210D,$210F,$2111,$2113,$2115,$2117,$2119,$211B,$211D,$211F,$2121,$2123,$2125,$2127,$2129,$212B,$212D,$212F,$2131,$2133,$201A,$2000,$2000
.dw $2000,$2000,$2019,$2134,$2136,$2138,$213A,$213C,$213E,$2140,$2142,$2144,$2146,$2148,$214A,$214C,$214E,$2150,$2152,$2154,$2156,$2158,$215A,$215C,$215E,$2160,$2162,$2164,$2166,$201A,$2000,$2000
.dw $2000,$2000,$2019,$2135,$2137,$2139,$213B,$213D,$213F,$2141,$2143,$2145,$2147,$2149,$214B,$214D,$214F,$2151,$2153,$2155,$2157,$2159,$215B,$215D,$215F,$2161,$2163,$2165,$2167,$201A,$2000,$2000
.dw $2000,$2000,$2019,$2168,$216A,$216C,$216E,$2170,$2172,$2174,$2176,$2178,$217A,$217C,$217E,$2180,$2182,$2184,$2186,$2188,$218A,$218C,$218E,$2190,$2192,$2194,$2196,$2198,$219A,$201A,$2000,$2000
.dw $2000,$2000,$2019,$2169,$216B,$216D,$216F,$2171,$2173,$2175,$2177,$2179,$217B,$217D,$217F,$2181,$2183,$2185,$2187,$2189,$218B,$218D,$218F,$2191,$2193,$2195,$2197,$2199,$219B,$201A,$2000,$2000
.dw $2000,$2000,$2019,$219C,$219E,$21A0,$21A2,$21A4,$21A6,$21A8,$21AA,$21AC,$21AE,$21B0,$21B2,$21B4,$21B6,$21B8,$21BA,$21BC,$21BE,$21C0,$21C2,$21C4,$21C6,$21C8,$21CA,$21CC,$21CE,$201A,$2000,$2000
.dw $2000,$2000,$2019,$219D,$219F,$21A1,$21A3,$21A5,$21A7,$21A9,$21AB,$21AD,$21AF,$21B1,$21B3,$21B5,$21B7,$21B9,$21BB,$21BD,$21BF,$21C1,$21C3,$21C5,$21C7,$21C9,$21CB,$21CD,$21CF,$201A,$2000,$2000
tail:
.dw $2000,$2000,$201B,$201C,$201C,$201C,$201C,$201C,$201C,$201C,$201C,$201C,$201C,$201C,$201C,$201C,$201C,$201C,$201C,$201C,$201C,$201C,$201C,$201C,$201C,$201C,$201C,$201C,$201C,$201D,$2000,$2000
.dw $2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000

endmap:

intromap:

.dw $2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000
.dw $2000,$2000,$2000,$2100,$2102,$2104,$2106,$2108,$210A,$210C,$210E,$2110,$2112,$2114,$2116,$2118,$211A,$211C,$211E,$2120,$2122,$2124,$2126,$2128,$212A,$212C,$212E,$2130,$2132,$2000,$2000,$2000
.dw $2000,$2000,$2000,$2101,$2103,$2105,$2107,$2109,$210B,$210D,$210F,$2111,$2113,$2115,$2117,$2119,$211B,$211D,$211F,$2121,$2123,$2125,$2127,$2129,$212B,$212D,$212F,$2131,$2133,$2000,$2000,$2000
.dw $2000,$2000,$2000,$2134,$2136,$2138,$213A,$213C,$213E,$2140,$2142,$2144,$2146,$2148,$214A,$214C,$214E,$2150,$2152,$2154,$2156,$2158,$215A,$215C,$215E,$2160,$2162,$2164,$2166,$2000,$2000,$2000
.dw $2000,$2000,$2000,$2135,$2137,$2139,$213B,$213D,$213F,$2141,$2143,$2145,$2147,$2149,$214B,$214D,$214F,$2151,$2153,$2155,$2157,$2159,$215B,$215D,$215F,$2161,$2163,$2165,$2167,$2000,$2000,$2000
.dw $2000,$2000,$2000,$2168,$216A,$216C,$216E,$2170,$2172,$2174,$2176,$2178,$217A,$217C,$217E,$2180,$2182,$2184,$2186,$2188,$218A,$218C,$218E,$2190,$2192,$2194,$2196,$2198,$219A,$2000,$2000,$2000
.dw $2000,$2000,$2000,$2169,$216B,$216D,$216F,$2171,$2173,$2175,$2177,$2179,$217B,$217D,$217F,$2181,$2183,$2185,$2187,$2189,$218B,$218D,$218F,$2191,$2193,$2195,$2197,$2199,$219B,$2000,$2000,$2000
.dw $2000,$2000,$2000,$219C,$219E,$21A0,$21A2,$21A4,$21A6,$21A8,$21AA,$21AC,$21AE,$21B0,$21B2,$21B4,$21B6,$21B8,$21BA,$21BC,$21BE,$21C0,$21C2,$21C4,$21C6,$21C8,$21CA,$21CD,$21CF,$2000,$2000,$2000
.dw $2000,$2000,$2000,$219D,$219F,$21A1,$21A3,$21A5,$21A7,$21A9,$21AB,$21AD,$21AF,$21B1,$21B3,$21B5,$21B7,$21B9,$21BB,$21BD,$21BF,$21C1,$21C3,$21C5,$21C7,$21C9,$21CB,$21CE,$21D0,$2000,$2000,$2000
.dw $2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000

; cela manque certes d'optimisation je ferai une routine pour effacer de la map a ma guise un jour
clearmap:
.dw $2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000
.dw $2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000
.dw $2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000
.dw $2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000
.dw $2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000
.dw $2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000
.dw $2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000
.dw $2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000
.dw $2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000
.dw $2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000
;un poil plus long pour effacer la fenètre gils dans la foulée
.dw $2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000
.dw $2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000
.dw $2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000
.dw $2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000
.dw $2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000
endclearmap:

	.incsrc "ptr.asm"

lentbl:
	.incbin ".\files\lentbl.dat"

fontaddr:
	.incbin ".\files\vwf.dat"

.endp (0)


;=====================================================================
; Les Fonctions de chargement de pointeur de dialogue
;=====================================================================
.mem 8
.index 16
.patch ($00B404)
	JSR.L CalculePositionTb
 	JSR.L PointeurBank1de1
 	STA.B $DD
 	LDX.B $3D
 	STX.W $0772
 	RTS
 .endp (0)
 .patch ($00B41D)
 	JSR.L CalculePositionTb
 	JSR.L PointeurBank1de2
 	STA.B $DD
 	LDX.B $3D
 	STX.W $0772
 	RTS
 .endp (0)
 .patch ($00B436)
 	JSR.L CalculePositionTb
 	JSR.L PointeurBank3
 	STA.B $DD
 	LDX.B $3D
 	STX.W $0772
 	RTS
 .endp (0)
 .patch ($00B3BB)
 	LDA.W $1702
 	STA.B $3D
 	LDA.W $1701
 	STA.B $3E
 	JSR.L PointeurBank2
 	RTS
 .endp (0)


; Patch pour eviter les problemes de scroll du texte
.patch ($00B736)
	LDA.B #$EC
.endp (0)

; Patching Map Display
;.patch ($00B718)
;	NOP
;	NOP
;.endp (0)


;.patch ($00B333)
;	STZ.B $EB
;.endp (0)

.patch ($00B81C)
	LDA #$03
.endp (0)

.patch ($00B848)
	LDX.W #$001A
.endp (0)

.patch ($00B86B)
	LDX.W #$001A
.endp (0)

.patch ($00B88A)
	ADC.B #$1A
.endp (0)

.patch ($00B897)
	ADC.B #$1A
.endp (0)

;patch pour pouvoir utiliser la vwf dans les intros
.patch ($00D438)
	LDY.W #$21D1
.endp (0)

;patch de l'interieur de la fenètre pour decaler de $100 et utiliser le tileset vwfé :^)
.patch ($14F75C)
.db $D0,$21,$D0,$21,$D0,$21,$D0,$21,$D0,$21,$D0,$21,$D0,$21,$D0,$21,$D0,$21,$D0,$21,$D0,$21,$D0,$21,$D0,$21
.db $D0,$21,$D0,$21,$D0,$21,$D0,$21,$D0,$21,$D0,$21,$D0,$21,$D0,$21,$D0,$21,$D0,$21,$D0,$21,$D0,$21,$D0,$21
.endp (0)

txref = $ED
.patch ($14F66C)
	.dw $2006+txref,$2008+txref			; ô OUI ;)
.endp (0)

.patch ($14F67C)
	.dw $2007+txref,$2009+txref			; Bah oui
.endp (0)

.patch ($14F68C)
	.dw $2000+txref,$2002+txref,$2004+txref		; ô NON
.endp (0)

.patch ($14F69C)
	.dw $2001+txref,$2003+txref,$2005+txref		;bah Non	
.endp (0)


.patch ($00B775)
	RTS
.endp (0)

.patch ($00B791)
NOP
NOP
NOP
.endp (0)

.patch ($00B7A9)
NOP
NOP
NOP
.endp (0)

.patch ($00B7C4)
NOP
NOP
NOP
.endp (0)

;;; test
;.patch ($00B834)
;NOP
;NOP
;NOP
;.endp (0)

;.patch ($00B84E)
;NOP
;NOP
;NOP
;.endp (0)

;.patch ($00B871)
;NOP
;NOP
;NOP
;.endp (0)

;scroll 1
.patch ($00B706)
	STZ.W $2112
.endp (0)

;scroll 2
.patch ($00B733)
	STZ.W $2111
.endp (0)

.patch ($00B738)
	STZ.W $2112
.endp (0)

.patch ($00B755)
	STZ.W $2112
.endp (0)

;clear map call
.patch ($00B7DF)
	JSL.L wclear
	RTS
.endp (0)

;décalage des mini fenètres ^^
;haut de la fenètre Gils
.patch ($00AD33)
	LDX.W #$2892+$100
.endp (0)
;suite
.patch ($00AD42)
	LDX.W #$28B2+$100
.endp (0)

;00AD5A LDX #$28D2
.patch ($00AD5A)
	LDX.W #$28D2+$100
.endp (0)

;00AD72 LDX #$28F2
.patch ($00AD72)
	LDX.W #$28F2+$100
.endp (0)

;00AD8A LDX #$28D3 
.patch ($00AD8A)
	LDX.W #$28D3+$100
.endp (0)

.patch ($00AEE7)
	LDA.B #$29
.endp (0)

;décalage du curseur
.patch ($00AE38)
	LDX.W #$29C4
.endp (0)

.patch ($00AE51)
	LDX.W #$2A04
.endp (0)